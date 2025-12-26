import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

/// Implementação de salvamento para plataforma web
///
/// Usa a Blob API e HTMLAnchorElement para disparar download no browser.
Future<void> salvarWeb(Uint8List bytes, String nomeArquivo) async {
  try {
    // Criar Blob com os bytes do PDF
    // Converte Uint8List para JSUint8Array
    final jsBytes = bytes.toJS;
    final blobParts = [jsBytes].toJS;
    final blob = web.Blob(blobParts);

    // Criar URL temporária para o blob
    final url = web.URL.createObjectURL(blob);

    try {
      // Criar elemento anchor para disparar download
      final anchor = web.HTMLAnchorElement();
      anchor.href = url;
      anchor.download = nomeArquivo;
      anchor.click();
    } finally {
      // Liberar URL do blob
      web.URL.revokeObjectURL(url);
    }
  } catch (e) {
    throw Exception('Erro ao disparar download na web: $e');
  }
}

/// Stub para nativo (não usado na web)
Future<void> salvarNativo(Uint8List bytes, String caminho) async {
  throw UnsupportedError(
    'salvarNativo não deve ser chamado na plataforma web',
  );
}
