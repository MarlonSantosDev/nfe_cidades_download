/// Biblioteca para download de NFe do site nfe-cidades.com.br
///
/// Esta biblioteca permite fazer download de Notas Fiscais Eletrônicas (NFe)
/// do site nfe-cidades.com.br, utilizando o serviço Anti-Captcha para resolver
/// os captchas necessários durante o processo de autenticação.
///
/// ## ✨ Versão 1.0.0
///
/// - 🔄 **Auto-dispose automático** - Sem necessidade de `finally { baixador.liberar(); }`
/// - 🌐 **API unificada** - Mesma API funciona em Web, Mobile e Desktop
/// - 📦 **Dart puro** - Funciona sem dependência do Flutter
/// - 📄 **Retorno Map/JSON** - Mais flexível e fácil de trabalhar
/// - 💾 **Salvamento integrado** - Salva PDFs em todas as plataformas
/// - 🚀 **API limpa** - Sem código deprecated, apenas o essencial
///
/// ## Características
///
/// - ✅ Resolve reCAPTCHA v2 automaticamente usando Anti-Captcha
/// - ✅ Retorna URL de download direto da NFe
/// - ✅ Opção para baixar os bytes do PDF automaticamente
/// - ✅ Salvamento de arquivos multiplataforma (web, mobile, desktop)
/// - ✅ Timeout configurável
/// - ✅ Gerenciamento automático de cookies de sessão
/// - ✅ Exceções específicas para diferentes tipos de erro
/// - ✅ API simples e fácil de usar
/// - ✅ **Multiplataforma**: Funciona em Web, Android, iOS, Windows, macOS e Linux
///
/// ## Uso Básico
///
/// ```dart
/// import 'package:nfe_cidades_download/nfe_cidades_download.dart';
///
/// void main() async {
///   final baixador = BaixadorNfeCidades(
///     chaveApiAntiCaptcha: 'SUA_CHAVE_API',
///   );
///
///   // Auto-dispose automático! Sem finally necessário!
///   final resultado = await baixador(
///     senha: 'ABCD1234567890',
///     baixarBytes: true,
///   );
///
///   print('URL: ${resultado.urlDownload}');
///   print('ID: ${resultado.idDocumento}');
///   print('Tamanho: ${resultado.tamanho} bytes');
///
///   // Salvar funciona em todas as plataformas
///   await resultado.salvar!('nota_fiscal.pdf');
/// }
/// ```
///
/// ## Pré-requisitos
///
/// 1. **Chave da API Anti-Captcha**: Você precisa criar uma conta em
///    [anti-captcha.com](https://anti-captcha.com) e obter sua chave de API
/// 2. **Créditos Anti-Captcha**: O serviço cobra aproximadamente $1.00 por 1000 captchas resolvidos
/// 3. **Senha da NFe**: A senha formatada da nota fiscal (ex: `ABCD1234567890`)
///
/// Para mais informações, consulte o [README](https://github.com/MarlonSantosDev/nfe_cidades_download#readme).
library;

export 'src/nfe_cidades_downloader.dart';
export 'src/nfe_result_extension.dart';
export 'src/nfe_file_saver.dart';
export 'src/platform_detector.dart';
export 'src/exceptions/nfe_exceptions.dart';
export 'src/cache/nfe_cache_config.dart';
