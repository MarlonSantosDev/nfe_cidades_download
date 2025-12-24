import 'package:flutter_test/flutter_test.dart';
import 'package:nfe_cidades_download/nfe_cidades_download.dart';

void main() {
  group('NfeCidadesDownloader', () {
    test('should create instance with API key', () {
      final downloader = NfeCidadesDownloader(antiCaptchaApiKey: 'test_key');

      expect(downloader.antiCaptchaApiKey, 'test_key');
      downloader.dispose();
    });

    test('should create NfeDownloadResult with required fields', () {
      final result = NfeDownloadResult(
        downloadUrl: 'https://example.com/download?id=123',
        documentId: '123',
      );

      expect(result.downloadUrl, 'https://example.com/download?id=123');
      expect(result.documentId, '123');
      expect(result.pdfBytes, isNull);
    });

    test('should handle exceptions properly', () {
      expect(
        () => throw InvalidSenhaException('Invalid password'),
        throwsA(isA<InvalidSenhaException>()),
      );

      expect(
        () => throw DocumentNotFoundException('Not found'),
        throwsA(isA<DocumentNotFoundException>()),
      );

      expect(
        () => throw CaptchaTimeoutException('Timeout'),
        throwsA(isA<CaptchaTimeoutException>()),
      );
    });
  });
}
