import 'dart:typed_data';
import 'dart:io';

/// Implementação de salvamento para plataformas nativas (mobile/desktop)
///
/// Usa dart:io para escrever arquivos no sistema de arquivos.
Future<void> salvarNativo(Uint8List bytes, String caminho) async {
  try {
    final file = File(caminho);
    await file.writeAsBytes(bytes);
  } catch (e) {
    throw Exception('Erro ao salvar arquivo: $e');
  }
}

/// Stub para web (não usado em plataforma nativa)
Future<void> salvarWeb(Uint8List bytes, String nomeArquivo) async {
  throw UnsupportedError(
    'salvarWeb não deve ser chamado em plataforma nativa',
  );
}
