// Stub file para plataformas web - dio_cookie_manager
// Este arquivo fornece um stub para CookieManager na web
// onde os cookies são gerenciados automaticamente pelo navegador

import 'package:dio/dio.dart';
import 'cookie_jar_stub.dart' show CookieJar;

/// Stub para CookieManager na web
/// Na web, os cookies são gerenciados automaticamente pelo navegador
/// Implementa Interceptor mas não faz nada (no-op)
class CookieManager extends Interceptor {
  // Construtor que aceita CookieJar mas não faz nada com ele
  CookieManager(CookieJar jar);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // No-op: navegador gerencia cookies automaticamente
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // No-op: navegador gerencia cookies automaticamente
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // No-op: navegador gerencia cookies automaticamente
    handler.next(err);
  }
}
