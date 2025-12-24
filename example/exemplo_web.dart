import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:nfe_cidades_download/nfe_cidades_download.dart';

/// Exemplo específico para uso em Flutter Web
///
/// Este exemplo demonstra como usar o pacote nfe_cidades_download
/// em uma aplicação Flutter Web, incluindo download de arquivos.
void main() async {
  // Configure sua chave da API Anti-Captcha
  // Obtenha em: https://anti-captcha.com
  const apiKey = 'SUA_CHAVE_API_AQUI';

  // Crie uma instância do downloader
  final downloader = NfeCidadesDownloader(antiCaptchaApiKey: apiKey);

  try {
    print('Iniciando download da NFe...');

    // Exemplo 1: Obter apenas a URL de download
    final result = await downloader.downloadNfe(senha: 'ABCD1234567890');
    print('✓ URL de download obtida: ${result.downloadUrl}');
    print('  Document ID: ${result.documentId}');

    // Exemplo 2: Baixar o PDF completo e fazer download no navegador
    print('\nBaixando PDF completo...');
    final resultWithPdf = await downloader.downloadNfe(
      senha: 'ABCD1234567890',
      downloadBytes: true,
      timeout: Duration(minutes: 2),
    );

    if (resultWithPdf.pdfBytes != null) {
      print('✓ PDF baixado com sucesso!');
      print('  Tamanho: ${resultWithPdf.pdfBytes!.length} bytes');

      // Fazer download do arquivo no navegador usando package:web
      // Converte Uint8List para Blob usando a API moderna
      final bytes = resultWithPdf.pdfBytes!;
      final uint8Array = bytes.buffer.asUint8List().toJS;
      final blobParts = [uint8Array as web.BlobPart].toJS;
      final blob = web.Blob(blobParts);
      final url = web.URL.createObjectURL(blob);
      final anchor = web.HTMLAnchorElement();
      anchor.href = url;
      anchor.download = 'nota_fiscal_${resultWithPdf.documentId}.pdf';
      anchor.click();
      web.URL.revokeObjectURL(url);

      print('  Download iniciado no navegador');
    }
  } on InvalidSenhaException catch (e) {
    print('✗ Senha inválida: $e');
  } on DocumentNotFoundException catch (e) {
    print('✗ Documento não encontrado: $e');
  } on CaptchaTimeoutException catch (e) {
    print('✗ Timeout ao resolver captcha: $e');
    print('  Dica: O Anti-Captcha pode estar sobrecarregado. Tente novamente.');
  } on AntiCaptchaException catch (e) {
    print('✗ Erro no Anti-Captcha: $e');
    print('  Dica: Verifique se sua chave da API está correta e tem créditos.');
  } on NetworkException catch (e) {
    print('✗ Erro de rede: $e');
    print('  Dica: Verifique sua conexão com a internet.');
  } on TimeoutException catch (e) {
    print('✗ Timeout: $e');
  } on NfeException catch (e) {
    print('✗ Erro geral: $e');
  } finally {
    // Sempre limpar os recursos
    downloader.dispose();
    print('\nRecursos liberados.');
  }
}
