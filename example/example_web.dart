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

  // Crie uma instância do baixador
  final baixador = BaixadorNfeCidades(chaveApiAntiCaptcha: apiKey);

  try {
    print('Iniciando download da NFe...');

    // Exemplo 1: Obter apenas a URL de download
    final resultado = await baixador.baixarNfe(senha: 'ABCD1234567890');
    print('✓ URL de download obtida: ${resultado.urlDownload}');
    print('  ID do Documento: ${resultado.idDocumento}');

    // Exemplo 2: Baixar o PDF completo e fazer download no navegador
    print('\nBaixando PDF completo...');
    final resultadoComPdf = await baixador.baixarNfe(
      senha: 'ABCD1234567890',
      baixarBytes: true,
      tempoLimite: const Duration(minutes: 2),
    );

    if (resultadoComPdf.bytesPdf != null) {
      print('✓ PDF baixado com sucesso!');
      print('  Tamanho: ${resultadoComPdf.bytesPdf!.length} bytes');

      // Fazer download do arquivo no navegador usando package:web
      // Converte Uint8List para Blob usando a API moderna
      final bytes = resultadoComPdf.bytesPdf!;
      final uint8Array = bytes.buffer.asUint8List().toJS;
      final blobParts = [uint8Array as web.BlobPart].toJS;
      final blob = web.Blob(blobParts);
      final url = web.URL.createObjectURL(blob);
      final anchor = web.HTMLAnchorElement();
      anchor.href = url;
      anchor.download = 'nota_fiscal_${resultadoComPdf.idDocumento}.pdf';
      anchor.click();
      web.URL.revokeObjectURL(url);

      print('  Download iniciado no navegador');
    }
  } on ExcecaoSenhaInvalida catch (e) {
    print('✗ Senha inválida: $e');
  } on ExcecaoDocumentoNaoEncontrado catch (e) {
    print('✗ Documento não encontrado: $e');
  } on ExcecaoTempoEsgotadoCaptcha catch (e) {
    print('✗ Timeout ao resolver captcha: $e');
    print('  Dica: O Anti-Captcha pode estar sobrecarregado. Tente novamente.');
  } on ExcecaoAntiCaptcha catch (e) {
    print('✗ Erro no Anti-Captcha: $e');
    print('  Dica: Verifique se sua chave da API está correta e tem créditos.');
  } on ExcecaoRede catch (e) {
    print('✗ Erro de rede: $e');
    print('  Dica: Verifique sua conexão com a internet.');
  } on ExcecaoTempoEsgotado catch (e) {
    print('✗ Timeout: $e');
  } on ExcecaoNfe catch (e) {
    print('✗ Erro geral: $e');
  } finally {
    // Sempre limpar os recursos
    baixador.liberar();
    print('\nRecursos liberados.');
  }
}
