/// Biblioteca para download de NFe do site nfe-cidades.com.br
/// 
/// Esta biblioteca permite fazer download de Notas Fiscais Eletrônicas (NFe)
/// do site nfe-cidades.com.br, utilizando o serviço Anti-Captcha para resolver
/// os captchas necessários durante o processo de autenticação.
/// 
/// ## Características
/// 
/// - ✅ Resolve reCAPTCHA v2 automaticamente usando Anti-Captcha
/// - ✅ Retorna URL de download direto da NFe
/// - ✅ Opção para baixar os bytes do PDF automaticamente
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
///   try {
///     final resultado = await baixador.baixarNfe(
///       senha: 'ABCD1234567890',
///     );
/// 
///     print('URL: ${resultado.urlDownload}');
///     print('ID do Documento: ${resultado.idDocumento}');
///   } finally {
///     baixador.liberar();
///   }
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
export 'src/models/nfe_download_result.dart';
export 'src/exceptions/nfe_exceptions.dart';
