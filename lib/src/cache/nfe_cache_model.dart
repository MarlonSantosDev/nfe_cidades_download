import 'dart:convert';
import 'dart:typed_data';
import '../nfe_file_saver.dart';

/// Modelo de entrada de cache serializável
///
/// Esta classe representa os dados de uma NFe que podem ser armazenados
/// em cache (JSON-friendly). A função `salvar` não pode ser serializada,
/// portanto é reconstituída ao ler do cache.
class NfeCacheEntry {
  /// URL de download do PDF
  final String urlDownload;

  /// ID do documento extraído da API
  final String idDocumento;

  /// Tamanho do PDF em bytes
  final int tamanho;

  /// Bytes do PDF codificados em base64 (null se não baixou bytes)
  final String? bytesBase64;

  /// Timestamp de quando foi cacheado
  final DateTime dataCache;

  /// Cria uma nova entrada de cache
  const NfeCacheEntry({
    required this.urlDownload,
    required this.idDocumento,
    required this.tamanho,
    this.bytesBase64,
    required this.dataCache,
  });

  /// Converte para Map JSON serializável
  Map<String, dynamic> paraJson() => {
        'urlDownload': urlDownload,
        'idDocumento': idDocumento,
        'tamanho': tamanho,
        'bytesBase64': bytesBase64,
        'dataCache': dataCache.toIso8601String(),
      };

  /// Cria entrada de cache a partir de JSON
  factory NfeCacheEntry.deJson(Map<String, dynamic> json) {
    return NfeCacheEntry(
      urlDownload: json['urlDownload'] as String,
      idDocumento: json['idDocumento'] as String,
      tamanho: json['tamanho'] as int,
      bytesBase64: json['bytesBase64'] as String?,
      dataCache: DateTime.parse(json['dataCache'] as String),
    );
  }

  /// Converte para Map de resultado (formato da API pública)
  ///
  /// [baixarBytes] determina se deve reconstituir bytes e função salvar.
  /// Se true e bytesBase64 não for null, reconstrói:
  /// - `bytes`: decodifica bytesBase64
  /// - `salvar`: cria nova closure que chama NfeFileSaver.salvar()
  Map<String, dynamic> paraResultado({bool baixarBytes = false}) {
    Uint8List? bytes;
    Future<void> Function({String? nome})? funcaoSalvar;

    // Reconstituir bytes e função salvar apenas se necessário
    if (baixarBytes && bytesBase64 != null) {
      bytes = base64Decode(bytesBase64!);

      // Capturar valor não-nulo para uso na closure
      final bytesNaoNulos = bytes;

      // Reconstituir função salvar (mesma lógica de nfe_cidades_downloader.dart)
      funcaoSalvar = ({String? nome}) async {
        final nomeArquivo = (nome == null || nome.isEmpty)
            ? '$idDocumento.pdf'
            : (!nome.toLowerCase().endsWith('.pdf'))
                ? '$nome.pdf'
                : nome;

        await NfeFileSaver.salvar(
          bytes: bytesNaoNulos,
          nomeArquivo: nomeArquivo,
          caminho: null,
        );
      };
    }

    // Retornar Map no mesmo formato da API pública
    return {
      'urlDownload': urlDownload,
      'idDocumento': idDocumento,
      'tamanho': tamanho,
      'bytes': bytes,
      'bytesBase64': bytesBase64,
      'salvar': funcaoSalvar,
    };
  }

  /// Cria entrada de cache a partir do Map de resultado da API
  ///
  /// Extrai os campos serializáveis do Map retornado por baixarNfe()
  factory NfeCacheEntry.deResultado(Map<String, dynamic> resultado) {
    return NfeCacheEntry(
      urlDownload: resultado['urlDownload'] as String,
      idDocumento: resultado['idDocumento'] as String,
      tamanho: resultado['tamanho'] as int,
      bytesBase64: resultado['bytesBase64'] as String?,
      dataCache: DateTime.now(),
    );
  }
}
