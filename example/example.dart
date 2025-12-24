library;

/// Exemplo multiplataforma para uso do pacote nfe_cidades_download
///
/// IMPORTANTE: Este exemplo deve ser executado com Flutter, não com `dart` diretamente:
///   - Para executar: `flutter run -d chrome` (web) ou `flutter run` (outras plataformas)
///   - NÃO use: `dart example/exemplo.dart` (não funcionará porque o pacote usa Flutter)
///
/// Este exemplo funciona em todas as plataformas:
///   - Web: Exibe informações (não salva arquivo)
///   - Android, iOS, Windows, macOS, Linux: Salva arquivo PDF

import 'package:nfe_cidades_download/nfe_cidades_download.dart';

// Import condicional para dart:io (apenas em plataformas não-web)
// Na web, usa um stub que lança erro explicativo
import 'dart:io' if (dart.library.html) 'example/dart_io_stub.dart' show File;

/// Verifica se podemos usar File (não estamos na web)
/// Retorna true se File está disponível e funcional
bool _canUseFile() {
  try {
    // Tenta criar um File temporário para verificar se dart:io está disponível
    // Se File() não lançar exceção, estamos em uma plataforma não-web
    File('__test_file_check__');
    return true;
  } catch (e) {
    // Se lançou exceção, provavelmente estamos na web ou File não está disponível
    return false;
  }
}

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

    // Exemplo 2: Baixar a URL e os bytes do PDF
    print('\nBaixando PDF completo...');
    final resultadoComPdf = await baixador.baixarNfe(
      senha: 'ABCD1234567890',
      baixarBytes: true,
      tempoLimite: const Duration(minutes: 2),
    );

    if (resultadoComPdf.bytesPdf != null) {
      // Verifica se estamos na web tentando usar File
      // Se File não estiver disponível ou lançar erro, estamos na web
      final isWeb = !_canUseFile();
      if (isWeb) {
        // Na web, você pode usar a URL diretamente ou fazer download via JavaScript
        print('✓ PDF baixado com sucesso!');
        print('  Tamanho: ${resultadoComPdf.bytesPdf!.length} bytes');
        print('  URL de download: ${resultadoComPdf.urlDownload}');
        print(
          '  Dica: Na web, use a URL para fazer download ou processe os bytes no navegador',
        );
      } else {
        // Em plataformas nativas (Android, iOS, Desktop), salvar em arquivo
        final file = File('${resultadoComPdf.idDocumento}.pdf');
        await file.writeAsBytes(resultadoComPdf.bytesPdf!);
        print('✓ PDF salvo com sucesso: ${file.path}');
        print('  Tamanho: ${resultadoComPdf.bytesPdf!.length} bytes');
      }
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
