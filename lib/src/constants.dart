/// Constants for NFe-Cidades downloader
class NfeConstants {
  NfeConstants._();

  // Anti-Captcha endpoints
  static const antiCaptchaCreateTaskUrl =
      'https://api.anti-captcha.com/createTask';
  static const antiCaptchaGetResultUrl =
      'https://api.anti-captcha.com/getTaskResult';

  // NFe-Cidades endpoints
  static const nfeBaseUrl = 'https://www.nfe-cidades.com.br';
  static const nfeBuscarDocumentoUrl =
      '$nfeBaseUrl/v2/rest/public/login/buscarDocumento';
  static const nfeDocumentosUrl = '$nfeBaseUrl/documentos.action';
  static const nfeRelatorioUrl = '$nfeBaseUrl/relatorioNotaFiscal.action';
  static const nfeLandingPage = '$nfeBaseUrl/landing-page';

  // reCAPTCHA configuration
  static const recaptchaSiteKey = '6Lf9374hAAAAAMorFLzMzomJWlbu0FK92Q25culn';

  // HTTP headers
  static const userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0';

  // Timeouts and intervals
  static const defaultTimeout = Duration(minutes: 1);
  static const captchaPollingInterval = Duration(seconds: 2);
  static const captchaMaxPollingTime = Duration(minutes: 3);
}
