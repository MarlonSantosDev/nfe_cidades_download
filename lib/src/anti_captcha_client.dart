import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'constants.dart';
import 'exceptions/nfe_exceptions.dart';
import 'models/anti_captcha_models.dart';

/// Client for interacting with Anti-Captcha API
class AntiCaptchaClient {
  final String apiKey;
  final Dio _dio;

  AntiCaptchaClient({required this.apiKey, Dio? dio}) : _dio = dio ?? Dio();

  /// Solves a reCAPTCHA v2 challenge and returns the gRecaptchaResponse token
  ///
  /// Throws [AntiCaptchaException] if the API returns an error
  /// Throws [CaptchaTimeoutException] if solving times out
  /// Throws [NetworkException] for network-related errors
  Future<String> solveRecaptchaV2({
    required String websiteUrl,
    required String siteKey,
    Duration? maxWaitTime,
    Duration? pollingInterval,
  }) async {
    final maxWait = maxWaitTime ?? NfeConstants.captchaMaxPollingTime;
    final pollInterval = pollingInterval ?? NfeConstants.captchaPollingInterval;

    // Step 1: Create task
    final taskId = await _createTask(websiteUrl, siteKey);

    // Step 2: Poll for result
    final startTime = DateTime.now();
    while (DateTime.now().difference(startTime) < maxWait) {
      await Future.delayed(pollInterval);

      final result = await _getTaskResult(taskId);

      if (result.hasError) {
        throw AntiCaptchaException(
          result.errorDescription ?? 'Unknown error from Anti-Captcha',
          errorCode: result.errorCode,
        );
      }

      if (result.isReady && result.gRecaptchaResponse != null) {
        return result.gRecaptchaResponse!;
      }

      // Continue polling if still processing
      if (!result.isProcessing) {
        throw AntiCaptchaException('Unexpected status: ${result.status}');
      }
    }

    throw CaptchaTimeoutException(
      'Captcha solving timed out after ${maxWait.inSeconds} seconds',
    );
  }

  /// Creates a captcha task and returns the task ID
  Future<int> _createTask(String websiteUrl, String siteKey) async {
    try {
      final request = AntiCaptchaCreateTaskRequest(
        clientKey: apiKey,
        task: RecaptchaV2TaskProxyless(
          websiteURL: websiteUrl,
          websiteKey: siteKey,
        ),
      );

      final response = await _dio.post(
        NfeConstants.antiCaptchaCreateTaskUrl,
        data: jsonEncode(request.toJson()),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final result = AntiCaptchaCreateTaskResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (result.hasError) {
        throw AntiCaptchaException(
          result.errorDescription ?? 'Failed to create captcha task',
          errorCode: result.errorCode,
        );
      }

      if (result.taskId == null) {
        throw AntiCaptchaException('No task ID returned from Anti-Captcha');
      }

      return result.taskId!;
    } on DioException catch (e, stackTrace) {
      throw NetworkException(
        'Network error creating captcha task',
        e,
        stackTrace,
      );
    }
  }

  /// Gets the result of a captcha task
  Future<AntiCaptchaGetResultResponse> _getTaskResult(int taskId) async {
    try {
      final request = AntiCaptchaGetResultRequest(
        clientKey: apiKey,
        taskId: taskId,
      );

      final response = await _dio.post(
        NfeConstants.antiCaptchaGetResultUrl,
        data: jsonEncode(request.toJson()),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      return AntiCaptchaGetResultResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e, stackTrace) {
      throw NetworkException(
        'Network error getting captcha result',
        e,
        stackTrace,
      );
    }
  }

  /// Disposes resources
  void dispose() {
    _dio.close();
  }
}
