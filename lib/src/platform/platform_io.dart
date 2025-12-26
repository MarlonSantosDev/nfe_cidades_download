/// Detecção de plataforma para dart:io (nativo - mobile/desktop)
///
/// Este arquivo é usado quando dart:io está disponível,
/// indicando que estamos em uma plataforma nativa.
library;

/// Indica se a plataforma atual é web
///
/// Retorna `false` porque dart:io só existe em plataformas nativas
const bool platformIsWeb = false;
