# Guia de Deployment do EasyReading

Este documento descreve a infraestrutura e processos de deployment do EasyReading.

## Arquitetura de Deployment

### Backend (API)

- **Containerização**: Docker
- **Orquestração**: Docker Compose
- **Monitoramento**: 
  - Prometheus para coleta de métricas
  - Grafana para visualização
  - Healthchecks para disponibilidade

### Mobile (Android/iOS)

- **Android**: Google Play Console
- **iOS**: App Store Connect
- **Distribuição**: Fastlane
- **CI/CD**: GitHub Actions

## Configuração do Ambiente

### Variáveis de Ambiente

```env
# Backend
OPENAI_API_KEY=sua_chave_api
FIREBASE_PROJECT_ID=seu_projeto
FIREBASE_PRIVATE_KEY=sua_chave
FIREBASE_CLIENT_EMAIL=seu_email
JWT_SECRET=seu_segredo

# Grafana
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=senha_segura

# Mobile
SLACK_URL=url_webhook
APPLE_ID=seu_apple_id
```

### Métricas Monitoradas

1. **Performance**
   - Latência de requisições
   - Taxa de erros
   - Uso de CPU/memória
   - Tempo de resposta da API

2. **Negócio**
   - Usuários ativos
   - Flashcards criados
   - Taxa de retenção
   - Progresso dos usuários

3. **Infraestrutura**
   - Disponibilidade
   - Uso de recursos
   - Logs de erros
   - Segurança

## Processo de Deploy

### Backend

1. **Build e Teste**
   ```bash
   # Build da imagem Docker
   docker build -t easyreading-api .
   
   # Execução dos testes
   yarn test
   ```

2. **Deploy**
   ```bash
   # Subir serviços
   docker-compose up -d
   
   # Verificar logs
   docker-compose logs -f
   ```

### Mobile

1. **Android**
   ```bash
   # Deploy para beta
   cd android && fastlane beta
   
   # Deploy para produção
   cd android && fastlane deploy
   ```

2. **iOS**
   ```bash
   # Deploy para TestFlight
   cd ios && fastlane beta
   
   # Deploy para App Store
   cd ios && fastlane release
   ```

## Monitoramento

### Dashboards

1. **Grafana**: http://seu-dominio:3001
   - Login: admin
   - Dashboards predefinidos para API e métricas de negócio

2. **Prometheus**: http://seu-dominio:9090
   - Métricas brutas
   - Configuração de alertas

### Alertas

Configurados para:
- Latência alta (>2s)
- Taxa de erro >1%
- Uso de CPU >80%
- Falhas de healthcheck

## Backup e Recuperação

1. **Dados**
   - Firebase: Backup automático diário
   - Volumes Docker: Backup semanal

2. **Configurações**
   - Versionadas no Git
   - Secrets gerenciados no GitHub

## Segurança

1. **API**
   - HTTPS obrigatório
   - Rate limiting
   - Validação de JWT
   - Sanitização de inputs

2. **Mobile**
   - Certificado SSL pinning
   - Armazenamento seguro
   - Ofuscação de código

## Manutenção

### Rotina Diária
- Verificar dashboards
- Revisar logs de erro
- Monitorar métricas de performance

### Manutenção Semanal
- Atualizar dependências
- Revisar alertas
- Backup de configurações

### Manutenção Mensal
- Análise de tendências
- Otimização de recursos
- Revisão de segurança

## Troubleshooting

### Problemas Comuns

1. **API Indisponível**
   ```bash
   # Verificar status dos containers
   docker-compose ps
   
   # Verificar logs
   docker-compose logs api
   ```

2. **Performance Degradada**
   - Verificar dashboard de métricas
   - Analisar logs de erro
   - Verificar uso de recursos

3. **Erros de Deploy**
   - Verificar pipeline CI/CD
   - Validar variáveis de ambiente
   - Verificar logs de build
