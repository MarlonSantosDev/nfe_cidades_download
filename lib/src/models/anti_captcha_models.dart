/// Anti-Captcha task creation request
class AntiCaptchaCreateTaskRequest {
  final String clientKey;
  final RecaptchaV2TaskProxyless task;

  AntiCaptchaCreateTaskRequest({required this.clientKey, required this.task});

  Map<String, dynamic> toJson() => {
    'clientKey': clientKey,
    'task': task.toJson(),
  };
}

/// RecaptchaV2TaskProxyless task type
class RecaptchaV2TaskProxyless {
  final String type = 'RecaptchaV2TaskProxyless';
  final String websiteURL;
  final String websiteKey;

  RecaptchaV2TaskProxyless({
    required this.websiteURL,
    required this.websiteKey,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'websiteURL': websiteURL,
    'websiteKey': websiteKey,
  };
}

/// Anti-Captcha task creation response
class AntiCaptchaCreateTaskResponse {
  final int? errorId;
  final String? errorCode;
  final String? errorDescription;
  final int? taskId;

  AntiCaptchaCreateTaskResponse({
    this.errorId,
    this.errorCode,
    this.errorDescription,
    this.taskId,
  });

  factory AntiCaptchaCreateTaskResponse.fromJson(Map<String, dynamic> json) {
    return AntiCaptchaCreateTaskResponse(
      errorId: json['errorId'] as int?,
      errorCode: json['errorCode'] as String?,
      errorDescription: json['errorDescription'] as String?,
      taskId: json['taskId'] as int?,
    );
  }

  bool get hasError => errorId != null && errorId! > 0;
}

/// Anti-Captcha get task result request
class AntiCaptchaGetResultRequest {
  final String clientKey;
  final int taskId;

  AntiCaptchaGetResultRequest({required this.clientKey, required this.taskId});

  Map<String, dynamic> toJson() => {'clientKey': clientKey, 'taskId': taskId};
}

/// Anti-Captcha get task result response
class AntiCaptchaGetResultResponse {
  final int? errorId;
  final String? errorCode;
  final String? errorDescription;
  final String? status; // 'processing' or 'ready'
  final Map<String, dynamic>? solution;

  AntiCaptchaGetResultResponse({
    this.errorId,
    this.errorCode,
    this.errorDescription,
    this.status,
    this.solution,
  });

  factory AntiCaptchaGetResultResponse.fromJson(Map<String, dynamic> json) {
    return AntiCaptchaGetResultResponse(
      errorId: json['errorId'] as int?,
      errorCode: json['errorCode'] as String?,
      errorDescription: json['errorDescription'] as String?,
      status: json['status'] as String?,
      solution: json['solution'] as Map<String, dynamic>?,
    );
  }

  bool get hasError => errorId != null && errorId! > 0;
  bool get isReady => status == 'ready';
  bool get isProcessing => status == 'processing';
  String? get gRecaptchaResponse => solution?['gRecaptchaResponse'] as String?;
}
