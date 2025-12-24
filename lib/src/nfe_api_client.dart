import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'constants.dart';
import 'exceptions/nfe_exceptions.dart';

/// Client for interacting with NFe-Cidades API
class NfeApiClient {
  final Dio _dio;

  NfeApiClient({Dio? dio, CookieJar? cookieJar}) : _dio = dio ?? Dio() {
    // Na web, o Dio gerencia cookies automaticamente através do navegador
    // Em outras plataformas, usamos CookieJar para gerenciar cookies
    if (!kIsWeb) {
      final jar = cookieJar ?? CookieJar();
      _dio.interceptors.add(CookieManager(jar));
    }
    // Na web, os cookies são gerenciados automaticamente pelo navegador
    _dio.options.headers['User-Agent'] = NfeConstants.userAgent;
  }

  /// Searches for a document using senha and captcha token
  /// Returns the encrypted data parameter needed for the next step
  Future<String> buscarDocumento({
    required String senha,
    required String captchaToken,
  }) async {
    try {
      final response = await _dio.post(
        NfeConstants.nfeBuscarDocumentoUrl,
        data: jsonEncode({'captcha': captchaToken, 'senha': senha}),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json, text/plain, */*',
            'Origin': NfeConstants.nfeBaseUrl,
            'Referer': NfeConstants.nfeLandingPage,
          },
          responseType: ResponseType.json,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw InvalidSenhaException(
          'Invalid senha or captcha token',
          statusCode: response.statusCode,
        );
      }

      if (response.statusCode != 200) {
        throw NfeApiException(
          'Failed to search for document: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }

      // The response should contain encrypted data
      // Handle different response formats: string JSON, Map, or direct string

      // Check for null or empty response
      if (response.data == null) {
        throw NfeApiException(
          'Invalid response from buscarDocumento: response data is null',
        );
      }

      Map<String, dynamic>? data;

      if (response.data is String) {
        final responseStr = response.data as String;
        if (responseStr.isEmpty) {
          throw NfeApiException(
            'Invalid response from buscarDocumento: response data is empty',
          );
        }
        // Try to parse JSON string
        try {
          final decoded = jsonDecode(responseStr);
          if (decoded is Map<String, dynamic>) {
            data = decoded;
          } else if (decoded is String) {
            // Response is a direct string (the encrypted data)
            return decoded;
          }
        } catch (e) {
          // If it's not valid JSON, treat as direct string response
          return responseStr;
        }
      } else if (response.data is Map<String, dynamic>) {
        data = response.data as Map<String, dynamic>;
      }

      // Check if we have a Map with 'validador' or 'data' key
      if (data != null) {
        // Try 'validador' first (current API format)
        if (data.containsKey('validador')) {
          final validador = data['validador'];
          if (validador is String) {
            return validador;
          }
        }
        // Fallback to 'data' for backward compatibility
        if (data.containsKey('data')) {
          final encryptedData = data['data'];
          if (encryptedData is String) {
            return encryptedData;
          }
        }
      }

      // If we got here, the response structure is unexpected
      final responseStr = response.data.toString();
      final preview = responseStr.length > 200
          ? '${responseStr.substring(0, 200)}...'
          : responseStr;
      throw NfeApiException(
        'Invalid response from buscarDocumento. '
        'Expected JSON with "validador" or "data" field, or direct string. '
        'Received type: ${response.data.runtimeType}, preview: $preview',
      );
    } on DioException catch (e, stackTrace) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw TimeoutException('Request timed out', e, stackTrace);
      }
      throw NetworkException('Network error in buscarDocumento', e, stackTrace);
    }
  }

  /// Retrieves document details and extracts the document ID
  Future<String> getDocumentId({
    required String senha,
    required String encryptedData,
  }) async {
    try {
      final response = await _dio.get(
        NfeConstants.nfeDocumentosUrl,
        queryParameters: {'senha': senha, 'data': encryptedData},
        options: Options(
          headers: {
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Referer':
                '${NfeConstants.nfeBaseUrl}/public/documentos?senha=$senha&data=$encryptedData',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 404) {
        throw DocumentNotFoundException(
          'Document not found',
          statusCode: response.statusCode,
        );
      }

      if (response.statusCode != 200) {
        throw NfeApiException(
          'Failed to get document details: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }

      // Parse HTML response to extract document ID
      // The ID is typically in a link or JavaScript variable
      final html = response.data as String;
      final documentId = _extractDocumentIdFromHtml(html);

      if (documentId == null) {
        throw NfeApiException('Could not extract document ID from response');
      }

      return documentId;
    } on DioException catch (e, stackTrace) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw TimeoutException('Request timed out', e, stackTrace);
      }
      throw NetworkException('Network error in getDocumentId', e, stackTrace);
    }
  }

  /// Downloads the PDF bytes for a document
  Future<Uint8List> downloadPdf(String documentId) async {
    try {
      final response = await _dio.get(
        NfeConstants.nfeRelatorioUrl,
        queryParameters: {'id': documentId},
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 404) {
        throw DocumentNotFoundException(
          'PDF not found for document ID: $documentId',
          statusCode: response.statusCode,
        );
      }

      if (response.statusCode != 200) {
        throw NfeApiException(
          'Failed to download PDF: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }

      return Uint8List.fromList(response.data as List<int>);
    } on DioException catch (e, stackTrace) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw TimeoutException('PDF download timed out', e, stackTrace);
      }
      throw NetworkException('Network error downloading PDF', e, stackTrace);
    }
  }

  /// Extracts document ID from HTML response
  /// This is a simplified version - actual implementation may need to be adjusted
  /// based on the real HTML structure
  String? _extractDocumentIdFromHtml(String html) {
    // Look for patterns like: relatorioNotaFiscal.action?id=XXXXX
    final regex = RegExp(r'relatorioNotaFiscal\.action\?id=([^"&\s]+)');
    final match = regex.firstMatch(html);
    return match?.group(1);
  }

  /// Disposes resources
  void dispose() {
    _dio.close();
  }
}
