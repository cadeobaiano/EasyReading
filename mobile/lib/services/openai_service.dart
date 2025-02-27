import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/openai_config.dart';

class OpenAIService {
  final String _baseUrl = OpenAIConfig.apiEndpoint;
  
  Future<String> generateSupportPhrase({
    required String context,
    required String difficulty,
    required String language,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${OpenAIConfig.apiKey}',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a supportive language learning assistant.'
            },
            {
              'role': 'user',
              'content': 'Generate a supportive phrase in $language for a student who found this concept "$context" $difficulty to understand.'
            }
          ],
          'max_tokens': 100,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to generate phrase: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating support phrase: $e');
    }
  }

  Future<List<String>> generateExampleSentences({
    required String word,
    required String language,
    int count = 3,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${OpenAIConfig.apiKey}',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a language learning assistant. Generate example sentences that are clear and helpful for learning.'
            },
            {
              'role': 'user',
              'content': 'Generate $count example sentences in $language using the word "$word". Return only the sentences, one per line.'
            }
          ],
          'max_tokens': 150,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return content.split('\n').where((s) => s.isNotEmpty).take(count).toList();
      } else {
        throw Exception('Failed to generate examples: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating example sentences: $e');
    }
  }

  Future<Map<String, String>> generateWordDefinition({
    required String word,
    required String fromLanguage,
    required String toLanguage,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${OpenAIConfig.apiKey}',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a language learning assistant. Provide clear and concise definitions.'
            },
            {
              'role': 'user',
              'content': 'Provide a definition for the word "$word" from $fromLanguage to $toLanguage. Include: definition, part of speech, and usage notes.'
            }
          ],
          'max_tokens': 200,
          'temperature': 0.5,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // Parse the response into structured data
        final lines = content.split('\n');
        return {
          'definition': lines.firstWhere(
            (l) => l.startsWith('Definition:'),
            orElse: () => 'Definition: Not found',
          ).replaceAll('Definition:', '').trim(),
          'partOfSpeech': lines.firstWhere(
            (l) => l.startsWith('Part of Speech:'),
            orElse: () => 'Part of Speech: Not specified',
          ).replaceAll('Part of Speech:', '').trim(),
          'usageNotes': lines.firstWhere(
            (l) => l.startsWith('Usage:'),
            orElse: () => 'Usage: Not provided',
          ).replaceAll('Usage:', '').trim(),
        };
      } else {
        throw Exception('Failed to generate definition: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating word definition: $e');
    }
  }
}
