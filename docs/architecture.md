# Arquitetura do Sistema - Aplicativo de Flashcards

## Visão Geral
Este documento detalha a arquitetura do sistema para o aplicativo de flashcards, dividida em três camadas principais: Frontend Mobile, Backend e Integrações Externas.

## 1. Frontend Mobile (Flutter)

### Tecnologia Principal
- **Framework**: Flutter
- **Linguagem**: Dart
- **Arquitetura**: Clean Architecture + BLoC Pattern

### Componentes Principais
1. **Presentation Layer**
   - Views (Telas principais: Home, Decks, Perfil)
   - Widgets reutilizáveis
   - BLoC (Gerenciamento de estado)

2. **Domain Layer**
   - Entidades de negócio
   - Use Cases
   - Repository Interfaces

3. **Data Layer**
   - Repository Implementations
   - Data Sources
   - API Clients

### Módulos
1. **Core Module**
   - Configurações
   - Injeção de dependência
   - Utilitários
   - Temas e estilos

2. **Feature Modules**
   - Home
   - Decks
   - Perfil
   - Prática de Flashcards
   - Estatísticas

## 2. Backend (NestJS)

### Tecnologia Principal
- **Framework**: NestJS
- **Linguagem**: TypeScript
- **Arquitetura**: Hexagonal Architecture

### Componentes
1. **API Layer**
   - REST Controllers
   - DTOs
   - Validação
   - Autenticação/Autorização

2. **Application Layer**
   - Services
   - Use Cases
   - Event Handlers

3. **Domain Layer**
   - Entities
   - Value Objects
   - Domain Services
   - Repository Interfaces

4. **Infrastructure Layer**
   - Repository Implementations
   - External Service Adapters
   - Database Configurations

### Módulos Principais
1. **Auth Module**
   - JWT Authentication
   - Role-based Authorization

2. **Users Module**
   - User Management
   - Profile Management

3. **Decks Module**
   - Deck CRUD
   - CSV Import/Validation

4. **Practice Module**
   - SM2 Algorithm Implementation
   - Progress Tracking
   - Statistics Generation

5. **AI Integration Module**
   - OpenAI Service Integration
   - Phrase Generation
   - Context Management

## 3. Integrações Externas

### Firebase
1. **Authentication**
   - User Authentication
   - Social Login

2. **Firestore**
   - User Data
   - Deck Data
   - Progress Data
   - Real-time Updates

3. **Cloud Functions**
   - Background Tasks
   - Data Processing
   - Notifications

### OpenAI
1. **API Integration**
   - GPT Model Access
   - Prompt Engineering
   - Response Processing

2. **Features**
   - Phrase Generation
   - Context-aware Support
   - Dynamic Content

### SM2 Algorithm
1. **Implementation**
   - Spaced Repetition Logic
   - Difficulty Calculation
   - Review Scheduling

## Comunicação entre Camadas

### Frontend → Backend
1. **HTTP/HTTPS**
   - REST APIs
   - JWT Authentication
   - Request/Response DTOs

2. **WebSocket**
   - Real-time Updates
   - Progress Sync
   - Notifications

### Backend → Integrações
1. **Firebase SDK**
   - Direct Database Access
   - Authentication Flow
   - Real-time Listeners

2. **OpenAI API**
   - HTTP Requests
   - Async Processing
   - Error Handling

## Segurança

1. **Autenticação**
   - JWT Tokens
   - Firebase Auth
   - Refresh Tokens

2. **Autorização**
   - Role-based Access
   - Resource Protection
   - API Gateway Security

3. **Dados**
   - Encryption at Rest
   - Secure Communication
   - Data Validation

## Escalabilidade

1. **Horizontal Scaling**
   - Container Orchestration
   - Load Balancing
   - Microservices Architecture

2. **Caching**
   - Redis Cache
   - In-memory Caching
   - CDN for Static Assets

3. **Performance**
   - Database Optimization
   - API Response Time
   - Resource Management

## Monitoramento

1. **Logging**
   - Application Logs
   - Error Tracking
   - Audit Trails

2. **Metrics**
   - Performance Metrics
   - User Analytics
   - System Health

3. **Alerting**
   - Error Notifications
   - Performance Alerts
   - System Status
