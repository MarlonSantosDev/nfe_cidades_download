/// Detecção de plataforma sem dependência do Flutter.
///
/// Esta classe fornece detecção de plataforma pura em Dart,
/// permitindo que o pacote funcione sem depender do Flutter SDK.
///
/// Usa conditional imports para determinar se está executando na web
/// ou em plataformas nativas (mobile/desktop).
library;

import 'platform/platform.dart'
    if (dart.library.io) 'platform/platform_io.dart'
    if (dart.library.html) 'platform/platform_web.dart';

/// Detector de plataforma - determina se está executando na web ou nativo
class PlatformDetector {
  PlatformDetector._();

  static bool? _isWebCached;

  /// Retorna `true` se executando na web, `false` caso contrário
  ///
  /// Este getter usa cache para evitar verificações repetidas.
  /// A detecção é feita em tempo de compilação usando conditional imports.
  static bool get isWeb {
    _isWebCached ??= platformIsWeb;
    return _isWebCached!;
  }

  /// Retorna `true` se executando em plataforma nativa (mobile/desktop)
  static bool get isNative => !isWeb;

  /// Reseta o cache (útil para testes)
  static void resetCache() {
    _isWebCached = null;
  }
}
