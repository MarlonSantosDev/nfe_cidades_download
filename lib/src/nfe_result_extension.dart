import 'dart:typed_data';

/// Extension para acesso type-safe ao Map de resultado do download de NFe
///
/// Esta extension adiciona getters tipados ao Map retornado por [BaixadorNfeCidades],
/// fornecendo autocomplete e type-safety enquanto mantém a flexibilidade do Map.
///
/// Exemplo de uso:
/// ```dart
/// final resultado = await baixador(senha: 'ABC123', baixarBytes: true);
///
/// // Acesso type-safe via extension
/// print(resultado.urlDownload);  // String
/// print(resultado.idDocumento);   // String
/// print(resultado.tamanho);       // int
/// print(resultado.bytes);         // Uint8List?
/// print(resultado.bytesBase64);   // String?
///
/// // Salvar arquivo
/// await resultado.salvar!('nota.pdf');
///
/// // Ainda pode acessar como Map se necessário
/// print(resultado['urlDownload']);
/// ```
extension NfeResultExtension on Map<String, dynamic> {
  /// URL de download do PDF
  ///
  /// Esta URL pode ser usada diretamente em um navegador ou cliente HTTP
  /// para baixar o arquivo PDF. A URL é válida por um tempo limitado.
  String get urlDownload => this['urlDownload'] as String;

  /// ID do documento extraído da resposta da API
  ///
  /// Este é o identificador único do documento NFe, extraído da
  /// resposta da API NFe-Cidades.
  String get idDocumento => this['idDocumento'] as String;

  /// Tamanho do PDF em bytes
  ///
  /// Retorna o número de bytes do PDF. Será 0 se `baixarBytes` foi false.
  int get tamanho => this['tamanho'] as int;

  /// Bytes do PDF (Uint8List)
  ///
  /// Será `null` se `baixarBytes` foi definido como `false`.
  /// Quando preenchido, contém o arquivo PDF completo como array de bytes.
  Uint8List? get bytes => this['bytes'] as Uint8List?;

  /// Bytes do PDF codificados em base64
  ///
  /// Será `null` se `baixarBytes` foi definido como `false`.
  /// Útil para serialização JSON ou transmissão como string.
  String? get bytesBase64 => this['bytesBase64'] as String?;

  /// Função para salvar o PDF em arquivo
  ///
  /// Será `null` se `baixarBytes` foi definido como `false`.
  ///
  /// **Comportamento por plataforma:**
  /// - **Web**: Dispara download do browser. O parâmetro `caminho` é ignorado.
  /// - **Nativo**: Salva em `caminho` se fornecido, ou no diretório atual
  ///   com o nome `{idDocumento}.pdf`.
  ///
  /// Exemplo:
  /// ```dart
  /// // Caminho padrão
  /// await resultado.salvar!(null);
  ///
  /// // Caminho customizado (apenas nativo)
  /// await resultado.salvar!('/Downloads/minha_nota.pdf');
  /// ```
  Future<void> Function(String? caminho)? get salvar =>
      this['salvar'] as Future<void> Function(String?)?;
}
