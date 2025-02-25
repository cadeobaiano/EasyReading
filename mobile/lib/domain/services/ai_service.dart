import 'package:http/http.dart' as http;
import 'dart:convert';

class AIService {
  final String apiKey;
  final String baseUrl = 'https://api.openai.com/v1/chat/completions';

  AIService({required this.apiKey});

  /// Gera frases de apoio personalizadas para um flashcard
  Future<List<String>> generateSupportPhrases({
    required String word,
    required String definition,
    int numberOfPhrases = 3,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'Você é um assistente especializado em criar frases de exemplo '
                  'contextualizadas para ajudar no aprendizado de palavras. '
                  'Gere frases naturais e relevantes que demonstrem o uso da palavra.'
            },
            {
              'role': 'user',
              'content': 'Gere $numberOfPhrases frases de exemplo usando a palavra "$word" '
                  'com o significado: "$definition". As frases devem ser claras e ajudar '
                  'a memorizar o significado da palavra.'
            }
          ],
          'temperature': 0.7,
          'max_tokens': 200,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        
        // Processa o conteúdo para extrair as frases
        final phrases = content
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .take(numberOfPhrases)
            .toList();

        return phrases;
      } else {
        throw Exception('Falha ao gerar frases de apoio');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com o serviço de IA: $e');
    }
  }
}
