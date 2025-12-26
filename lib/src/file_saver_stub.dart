import 'dart:typed_data';

/// Stub para salvar arquivos (fallback)
///
/// Esta implementação nunca deve ser chamada em produção.
/// Serve apenas como interface para os conditional imports.
Future<void> salvarWeb(Uint8List bytes, String nomeArquivo) async {
  throw UnsupportedError(
    'Salvamento de arquivos não suportado nesta plataforma',
  );
}

/// Stub para salvar arquivos nativos (fallback)
Future<void> salvarNativo(Uint8List bytes, String caminho) async {
  throw UnsupportedError(
    'Salvamento de arquivos não suportado nesta plataforma',
  );
}
