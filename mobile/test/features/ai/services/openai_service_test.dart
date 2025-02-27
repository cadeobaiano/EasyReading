import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:easy_reading/features/ai/services/openai_service.dart';
import 'package:easy_reading/features/ai/models/ai_response.dart';
import 'package:easy_reading/core/config/env_config.dart';
import 'dart:async';

class MockEnvConfig extends Mock implements EnvConfig {}
class MockHttpClient extends Mock {}

void main() {
  late OpenAIService openAIService;
  late MockEnvConfig mockEnvConfig;

  setUp(() {
    mockEnvConfig = MockEnvConfig();
    when(() => mockEnvConfig.openAIApiKey).thenReturn('test-api-key');

    openAIService = OpenAIService(
      envConfig: mockEnvConfig,
    );
  });

  group('OpenAIService', () {
    test('gera frases de apoio com sucesso', () async {
      final result = await openAIService.generateSupportPhrases(
        word: 'test',
        context: 'testing context',
      );

      expect(result, isA<AIResponse>());
      expect(result.phrases, isNotEmpty);
    });

    test('lida com erros de API corretamente', () async {
      when(() => mockEnvConfig.openAIApiKey).thenReturn('invalid-key');

      expect(
        () => openAIService.generateSupportPhrases(
          word: 'test',
          context: 'testing context',
        ),
        throwsException,
      );
    });

    test('lida com timeout corretamente', () async {
      when(() => mockEnvConfig.openAIApiKey).thenReturn('timeout-key');

      expect(
        () => openAIService.generateSupportPhrases(
          word: 'test',
          context: 'testing context',
        ),
        throwsA(isA<TimeoutException>()),
      );
    });
  });
}
