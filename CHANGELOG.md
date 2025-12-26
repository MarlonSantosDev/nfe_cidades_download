# Changelog

## [1.0.0] - 2024-12-24

### 🎉 MAJOR RELEASE

Primeira versão estável com API completamente redesenhada. Esta é uma reescrita completa do pacote.

### ✨ Funcionalidades Principais

- **Auto-dispose automático**: Padrão callable class com cleanup automático de recursos. Recursos são liberados automaticamente após cada operação.
- **Retorno Map/JSON nativo**: Retorna `Map<String, dynamic>` com extensions para type-safety e autocomplete. Fácil serialização JSON.
- **API unificada multiplataforma**: Mesma API funciona automaticamente em todas as plataformas (Web, Mobile, Desktop).
- **Salvamento integrado**: Função `salvar()` integrada no resultado Map funciona em todas as plataformas.
- **Dart puro**: Funciona sem dependência do Flutter SDK. Compatível com projetos Dart puro e Flutter.

### 📦 Novos Componentes

- `PlatformDetector`: Detecção de plataforma em Dart puro
- `NfeFileSaver`: Salvamento de arquivos multiplataforma
- `NfeResultExtension`: Extensions para acesso type-safe ao Map de resultado
- `_BaixadorNfeExecutor`: Classe interna reutilizável para uso avançado

### 🔧 Campos do Resultado

- `urlDownload`: URL de download do PDF
- `idDocumento`: ID do documento
- `tamanho`: Tamanho em bytes do PDF
- `bytes`: Bytes do PDF (Uint8List) - null se baixarBytes=false
- `bytesBase64`: Bytes em base64 - null se baixarBytes=false
- `salvar`: Função para salvar o PDF - null se baixarBytes=false

### 📝 Documentação

- README completo com exemplos para todas as plataformas
- Exemplos de código atualizados
- Comentários de código aprimorados

---

## [0.0.2] - 2024-XX-XX

### Adicionado
- Versão inicial do pacote
- Download de NFe via nfe-cidades.com.br
- Integração com Anti-Captcha para resolver reCAPTCHA v2
- Suporte multiplataforma (web, mobile, desktop)
- Classe `BaixadorNfeCidades` para orquestração
- Exceções customizadas para tratamento de erros
- Gerenciamento de cookies automático
