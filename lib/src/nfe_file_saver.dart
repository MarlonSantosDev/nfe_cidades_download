import 'dart:typed_data';
import 'platform_detector.dart';

// Conditional imports para suportar web e nativo
import 'file_saver_stub.dart'
    if (dart.library.io) 'file_saver_io.dart'
    if (dart.library.html) 'file_saver_web.dart';

/// Utilitário para salvar arquivos PDF em todas as plataformas
///
/// Esta classe fornece uma API unificada para salvar PDFs que funciona
/// automaticamente em todas as plataformas:
/// - **Web**: Dispara download do browser usando Blob API
/// - **Nativo** (mobile/desktop): Salva arquivo no sistema de arquivos
///
/// Exemplo:
/// ```dart
/// final bytes = Uint8List(...); // Bytes do PDF
///
/// // Salvar com nome padrão no diretório atual (nativo) ou download (web)
/// await NfeFileSaver.salvar(
///   bytes: bytes,
///   nomeArquivo: 'nota_fiscal.pdf',
/// );
///
/// // Salvar com caminho customizado (apenas nativo, ignorado na web)
/// await NfeFileSaver.salvar(
///   bytes: bytes,
///   nomeArquivo: 'nota_fiscal.pdf',
///   caminho: '/Downloads/notas/nota_fiscal.pdf',
/// );
/// ```
class NfeFileSaver {
  NfeFileSaver._();

  /// Salva PDF em arquivo ou dispara download no browser
  ///
  /// [bytes] - Bytes do PDF como Uint8List
  /// [nomeArquivo] - Nome do arquivo (usado em ambas as plataformas)
  /// [caminho] - Caminho completo customizado (apenas nativo, ignorado na web)
  ///
  /// **Comportamento por plataforma:**
  /// - **Web**: Dispara download do browser com o nome especificado.
  ///   O parâmetro [caminho] é ignorado (navegadores controlam onde salvar).
  /// - **Nativo**: Se [caminho] for fornecido, salva nesse caminho completo.
  ///   Caso contrário, salva no diretório atual com o [nomeArquivo].
  ///
  /// Lança exceção se houver erro ao salvar o arquivo.
  static Future<void> salvar({
    required Uint8List bytes,
    required String nomeArquivo,
    String? caminho,
  }) async {
    if (PlatformDetector.isWeb) {
      return salvarWeb(bytes, nomeArquivo);
    } else {
      return salvarNativo(bytes, caminho ?? nomeArquivo);
    }
  }
}
