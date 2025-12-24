import 'dart:typed_data';

/// Objeto de resultado contendo a URL de download e opcionalmente os bytes do PDF
///
/// Esta classe representa o resultado de uma operação de download de NFe bem-sucedida.
/// Ela contém a URL de download, o ID do documento e opcionalmente os bytes do PDF
/// se [baixarBytes] foi definido como `true` na chamada [BaixadorNfeCidades.baixarNfe].
///
/// Exemplo:
/// ```dart
/// final resultado = await baixador.baixarNfe(
///   senha: 'ABCD1234567890',
///   baixarBytes: true,
/// );
///
/// print('URL de download: ${resultado.urlDownload}');
/// print('ID do documento: ${resultado.idDocumento}');
/// if (resultado.bytesPdf != null) {
///   print('Tamanho do PDF: ${resultado.bytesPdf!.length} bytes');
/// }
/// ```
class ResultadoDownloadNfe {
  /// A URL para baixar o documento PDF da NFe
  ///
  /// Esta URL pode ser usada diretamente em um navegador ou cliente HTTP para baixar
  /// o arquivo PDF. A URL é válida por um tempo limitado.
  final String urlDownload;

  /// Os bytes do documento PDF (apenas preenchido se baixarBytes foi true)
  ///
  /// Será `null` a menos que [baixarBytes] tenha sido definido como `true` na
  /// chamada [BaixadorNfeCidades.baixarNfe]. Quando preenchido, contém o
  /// arquivo PDF completo como um array de bytes.
  final Uint8List? bytesPdf;

  /// O ID do documento extraído da resposta da API
  ///
  /// Este é o identificador único do documento NFe, extraído da
  /// resposta da API NFe-Cidades.
  final String idDocumento;

  /// Cria uma nova instância de [ResultadoDownloadNfe]
  ///
  /// [urlDownload] e [idDocumento] são obrigatórios.
  /// [bytesPdf] é opcional e apenas preenchido quando a operação de download
  /// foi solicitada com `baixarBytes: true`.
  const ResultadoDownloadNfe({
    required this.urlDownload,
    required this.idDocumento,
    this.bytesPdf,
  });

  @override
  String toString() => 'ResultadoDownloadNfe(urlDownload: $urlDownload, '
      'idDocumento: $idDocumento, temBytesPdf: ${bytesPdf != null})';
}
