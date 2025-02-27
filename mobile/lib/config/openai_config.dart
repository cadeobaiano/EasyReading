// IMPORTANTE: Este arquivo é apenas um template.
// A chave real deve ser armazenada em um arquivo .env ou em variáveis de ambiente seguras
class OpenAIConfig {
  static const String apiEndpoint = 'https://api.openai.com/v1';
  
  // A chave real será carregada do ambiente em tempo de execução
  static String get apiKey => const String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );
}
