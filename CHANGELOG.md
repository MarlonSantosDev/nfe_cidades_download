# Changelog

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
