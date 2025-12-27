# Changelog

## [1.0.1] - 2025-12-27
### Alterado
 - Ajuste  e correção de bugs
 
## [1.0.0] - 2025-12-26
### Adicionado

#### Sistema de Cache Inteligente
- ✅ Sistema de cache inteligente usando `shared_preferences`
- ✅ Cache ativado por padrão (transparente, zero configuração)
- ✅ Cache tolerante a falhas (erros não afetam o download)
- ✅ Cache multiplataforma (funciona em todas as plataformas Flutter)
- ✅ Armazenamento persistente de NFes localmente
- ✅ Redução de tempo de resposta de ~30s para <100ms em cache hits
- ✅ Economia de créditos Anti-Captcha em acessos repetidos

#### Arquitetura do Cache
- ✅ Classe `NfeCacheConfig` para configuração global do cache
- ✅ Classe `NfeCacheManager` para orquestração de operações de cache
- ✅ Classe `NfeCacheStorage` para abstração do shared_preferences
- ✅ Classe `NfeCacheEntry` para modelo serializável de dados em cache
- ✅ Serialização/deserialização JSON automática
- ✅ Prefixo de chaves (`nfe_cache:`) para isolamento de dados
- ✅ Timestamp de cacheamento para rastreamento

#### Controle do Cache
- ✅ Cache ativado/desativado globalmente via `BaixadorNfeCidades.usarCache`
- ✅ Limpeza de cache manual global (`BaixadorNfeCidades.limparCache()`)
- ✅ Limpeza de cache por senha específica (`BaixadorNfeCidades.limparCachePorSenha()`)
- ✅ Preservação de outros dados do shared_preferences ao limpar cache
- ✅ Remoção seletiva apenas de chaves com prefixo de cache

#### Funcionalidades Avançadas do Cache
- ✅ Cache inteligente que verifica requisitos antes de retornar
- ✅ Atualização automática de cache quando `baixarBytes=true` e cache não tem bytes
- ✅ Reconstituição automática da função `salvar` a partir do cache
- ✅ Suporte a cache com ou sem bytes do PDF
- ✅ Tratamento transparente de erros (log apenas em modo debug)
- ✅ Fire-and-forget para salvamento de cache (não bloqueia retorno)

## [0.0.2] - 2025-12-24

### Adicionado

#### Melhorias para Pub.dev Score 100%
- ✅ Adicionado `repository`, `issue_tracker` e `documentation` no `pubspec.yaml`
- ✅ Atualizado `environment` para suportar Dart 3.0+ e Flutter 3.0+
- ✅ Melhorada documentação DartDoc em todos os arquivos públicos
- ✅ Adicionada documentação completa para classes, métodos e propriedades
- ✅ Melhorado `analysis_options.yaml` com regras adicionais de lint
- ✅ Expandida cobertura de testes com novos casos de teste
- ✅ Melhorada documentação do arquivo principal da biblioteca

#### Documentação
- ✅ Documentação completa para `NfeDownloadResult` com exemplos
- ✅ Documentação completa para `NfeCidadesDownloader` com exemplos de uso
- ✅ Documentação completa para todas as exceções
- ✅ Documentação completa para `NfeApiClient` e `AntiCaptchaClient`
- ✅ Documentação completa para constantes e modelos internos
- ✅ Adicionada documentação da biblioteca principal com características e pré-requisitos

#### Testes
- ✅ Adicionados testes para `NfeDownloadResult` com PDF bytes
- ✅ Adicionados testes para exceções com status codes
- ✅ Adicionados testes para preservação de erros originais e stack traces
- ✅ Adicionados testes para `toString()` de exceções e resultados

#### Configuração
- ✅ Melhorado `analysis_options.yaml` com regras de lint adicionais
- ✅ Configurado para ignorar `avoid_print` em arquivos de exemplo
- ✅ Adicionadas regras recomendadas do Flutter Lints

### Alterado

#### Pubspec.yaml
- ✅ Atualizado `environment.sdk` para `>=3.0.0 <4.0.0`
- ✅ Atualizado `environment.flutter` para `>=3.0.0`
- ✅ Adicionado `repository` com URL do GitHub
- ✅ Adicionado `issue_tracker` com URL do GitHub issues
- ✅ Adicionado `documentation` com URL do README

#### Documentação
- ✅ Melhorada documentação de todos os métodos públicos
- ✅ Adicionados exemplos de código na documentação
- ✅ Melhorada descrição de parâmetros e valores de retorno
- ✅ Adicionada documentação de exceções que podem ser lançadas

## [0.0.1] - 2025-12-23

### Adicionado

#### Funcionalidades Principais
- ✅ Classe `NfeCidadesDownloader` para download de notas fiscais do portal nfe-cidades.com.br
- ✅ Resolução automática de reCAPTCHA v2 usando o serviço Anti-Captcha
- ✅ Busca de documentos NFe usando senha formatada
- ✅ Download de URL direta do PDF da NFe
- ✅ Opção para baixar bytes do PDF automaticamente
- ✅ Gerenciamento automático de cookies de sessão
- ✅ Timeout configurável para operações

#### API e Modelos
- ✅ Classe `NfeDownloadResult` com:
  - URL de download direto
  - ID do documento
  - Bytes do PDF (opcional)
- ✅ Método `downloadNfe()` com parâmetros:
  - `senha`: Senha formatada da NFe
  - `downloadBytes`: Flag para baixar bytes do PDF
  - `timeout`: Timeout configurável
- ✅ Método `dispose()` para liberação de recursos

#### Tratamento de Erros
- ✅ Hierarquia completa de exceções:
  - `NfeException` (base)
  - `InvalidSenhaException` - Senha inválida ou captcha rejeitado
  - `DocumentNotFoundException` - Documento não encontrado
  - `CaptchaTimeoutException` - Timeout ao resolver captcha
  - `AntiCaptchaException` - Erro na API Anti-Captcha
  - `NetworkException` - Erros de rede/conexão
  - `TimeoutException` - Timeout geral da operação
  - `NfeApiException` - Erros genéricos da API NFe-Cidades

#### Compatibilidade
- ✅ Suporte multiplataforma:
  - Web (Flutter Web)
  - Android
  - iOS
  - Windows
  - macOS
  - Linux
- ✅ Uso apenas de bibliotecas multiplataforma (dio, cookie_jar, dio_cookie_manager)

#### Clientes Internos
- ✅ `AntiCaptchaClient` - Cliente para integração com API Anti-Captcha
- ✅ `NfeApiClient` - Cliente para interação com API NFe-Cidades
- ✅ Extração automática de document ID de respostas HTML

#### Configurações
- ✅ Timeout padrão: 5 minutos
- ✅ Timeout de captcha: 3 minutos
- ✅ Polling de captcha: A cada 2 segundos
- ✅ reCAPTCHA Site Key configurado

#### Documentação
- ✅ README.md completo com exemplos de uso
- ✅ Exemplos de código para diferentes cenários
- ✅ Documentação de API
- ✅ Guia de troubleshooting
- ✅ Exemplo completo em `example/exemplo.dart`

#### Dependências
- ✅ `dio: ^5.9.0` - Cliente HTTP
- ✅ `cookie_jar: ^4.0.8` - Gerenciamento de cookies
- ✅ `dio_cookie_manager: ^3.3.0` - Integração de cookies com Dio

#### Desenvolvimento
- ✅ Testes unitários configurados
- ✅ Linter configurado (flutter_lints)
- ✅ Mockito para testes
- ✅ Build runner para geração de código