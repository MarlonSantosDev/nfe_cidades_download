import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'anti_captcha_client.dart';
import 'nfe_api_client.dart';
import 'constants.dart';
import 'models/nfe_download_result.dart';
import 'exceptions/nfe_exceptions.dart';

/// Main class for downloading NFe documents from nfe-cidades.com.br
///
/// This class uses Anti-Captcha service to solve reCAPTCHA challenges
/// and then downloads NFe documents.
///
/// Example usage:
/// ```dart
/// final downloader = NfeCidadesDownloader(antiCaptchaApiKey: 'YOUR_API_KEY');
/// try {
///   final result = await downloader.downloadNfe(
///     senha: 'ABCD1234567890',
///     downloadBytes: true,
///   );
///   print('Download URL: ${result.downloadUrl}');
///   if (result.pdfBytes != null) {
///     // Save PDF to file
///   }
/// } finally {
///   downloader.dispose();
/// }
/// ```
class NfeCidadesDownloader {
  final String antiCaptchaApiKey;
  final AntiCaptchaClient _captchaClient;
  final NfeApiClient _nfeClient;

  /// Creates a new NFe downloader instance
  ///
  /// [antiCaptchaApiKey] is required - get it from https://anti-captcha.com
  /// [dio] is optional - provide a custom Dio instance if needed
  NfeCidadesDownloader({required this.antiCaptchaApiKey, Dio? dio})
    : _captchaClient = AntiCaptchaClient(apiKey: antiCaptchaApiKey, dio: dio),
      _nfeClient = NfeApiClient(dio: dio);

  /// Downloads an NFe document using the provided senha
  ///
  /// [senha] is the formatted password (e.g., "ABCD1234567890")
  /// [downloadBytes] determines whether to download the actual PDF bytes (default: false)
  /// [timeout] sets the maximum time to wait for the entire operation
  ///
  /// Returns [NfeDownloadResult] containing the download URL and optionally the PDF bytes
  ///
  /// Throws [InvalidSenhaException] if the senha is invalid
  /// Throws [DocumentNotFoundException] if the document is not found
  /// Throws [CaptchaTimeoutException] if captcha solving times out
  /// Throws [AntiCaptchaException] if Anti-Captcha API fails
  /// Throws [NfeApiException] for other NFe-Cidades API errors
  /// Throws [NetworkException] for network-related errors
  /// Throws [TimeoutException] if the operation times out
  Future<NfeDownloadResult> downloadNfe({
    required String senha,
    bool downloadBytes = false,
    Duration? timeout,
  }) async {
    final effectiveTimeout = timeout ?? NfeConstants.defaultTimeout;

    try {
      return await Future.any([
        _downloadNfeInternal(senha: senha, downloadBytes: downloadBytes),
        Future.delayed(effectiveTimeout).then((_) {
          throw TimeoutException(
            'Operation timed out after ${effectiveTimeout.inSeconds} seconds',
          );
        }),
      ]);
    } catch (e) {
      if (e is NfeException) {
        rethrow;
      }
      throw NfeApiException(
        'Unexpected error during download',
        originalError: e,
      );
    }
  }

  /// Internal implementation of the download process
  Future<NfeDownloadResult> _downloadNfeInternal({
    required String senha,
    required bool downloadBytes,
  }) async {
    // Step 1: Solve reCAPTCHA using Anti-Captcha
    final captchaToken = await _captchaClient.solveRecaptchaV2(
      websiteUrl: NfeConstants.nfeLandingPage,
      siteKey: NfeConstants.recaptchaSiteKey,
    );

    // Step 2: Search for document using senha and captcha token
    final encryptedData = await _nfeClient.buscarDocumento(
      senha: senha,
      captchaToken: captchaToken,
    );

    // Step 3: Get document details and extract document ID
    final documentId = await _nfeClient.getDocumentId(
      senha: senha,
      encryptedData: encryptedData,
    );

    // Step 4: Build download URL
    final downloadUrl = '${NfeConstants.nfeRelatorioUrl}?id=$documentId';

    // Step 5: Optionally download PDF bytes
    Uint8List? pdfBytes;
    if (downloadBytes) {
      pdfBytes = await _nfeClient.downloadPdf(documentId);
    }

    return NfeDownloadResult(
      downloadUrl: downloadUrl,
      documentId: documentId,
      pdfBytes: pdfBytes,
    );
  }

  /// Disposes all resources
  ///
  /// Call this when you're done using the downloader
  void dispose() {
    _captchaClient.dispose();
    _nfeClient.dispose();
  }
}
