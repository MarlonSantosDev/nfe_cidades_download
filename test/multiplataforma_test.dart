import 'package:flutter_test/flutter_test.dart';
import 'package:nfe_cidades_download/nfe_cidades_download.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'dart:typed_data';

/// Testes de validação multiplataforma
///
/// Estes testes verificam se o pacote funciona corretamente em diferentes plataformas,
/// com foco especial na compatibilidade com web.
void main() {
  group('Validação Multiplataforma', () {
    test('deve criar instância do downloader em qualquer plataforma', () {
      final downloader = NfeCidadesDownloader(
        antiCaptchaApiKey: 'test_key_12345',
      );

      expect(downloader.antiCaptchaApiKey, 'test_key_12345');
      expect(() => downloader.dispose(), returnsNormally);
    });

    test('deve funcionar com Dio customizado', () {
      final dio = Dio();
      final downloader = NfeCidadesDownloader(
        antiCaptchaApiKey: 'test_key',
        dio: dio,
      );

      expect(downloader, isNotNull);
      downloader.dispose();
    });

    test('deve criar NfeDownloadResult válido', () {
      final result = NfeDownloadResult(
        downloadUrl: 'https://example.com/download?id=123',
        documentId: '123',
      );

      expect(result.downloadUrl, contains('123'));
      expect(result.documentId, '123');
      expect(result.pdfBytes, isNull);
    });

    test('deve criar NfeDownloadResult com PDF bytes', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final result = NfeDownloadResult(
        downloadUrl: 'https://example.com/download?id=123',
        documentId: '123',
        pdfBytes: bytes,
      );

      expect(result.pdfBytes, isNotNull);
      expect(result.pdfBytes!.length, 5);
    });

    test('deve detectar plataforma corretamente', () {
      // Este teste verifica se kIsWeb está disponível
      // Na web, kIsWeb será true, em outras plataformas será false
      expect(kIsWeb, isA<bool>());
    });

    group('Compatibilidade Web', () {
      test('deve funcionar sem CookieJar na web', () {
        // Na web, o Dio gerencia cookies automaticamente
        // Este teste verifica que não há erro ao criar o cliente sem CookieJar
        final downloader = NfeCidadesDownloader(antiCaptchaApiKey: 'test_key');

        expect(downloader, isNotNull);
        expect(() => downloader.dispose(), returnsNormally);
      });
    });

    group('Exceções Multiplataforma', () {
      test('deve lançar InvalidSenhaException', () {
        expect(
          () => throw InvalidSenhaException('Senha inválida'),
          throwsA(isA<InvalidSenhaException>()),
        );
      });

      test('deve lançar DocumentNotFoundException', () {
        expect(
          () => throw DocumentNotFoundException('Documento não encontrado'),
          throwsA(isA<DocumentNotFoundException>()),
        );
      });

      test('deve lançar CaptchaTimeoutException', () {
        expect(
          () => throw CaptchaTimeoutException('Timeout'),
          throwsA(isA<CaptchaTimeoutException>()),
        );
      });

      test('deve lançar AntiCaptchaException', () {
        expect(
          () => throw AntiCaptchaException('Erro no Anti-Captcha'),
          throwsA(isA<AntiCaptchaException>()),
        );
      });

      test('deve lançar NetworkException', () {
        expect(
          () => throw NetworkException('Erro de rede'),
          throwsA(isA<NetworkException>()),
        );
      });

      test('deve lançar TimeoutException', () {
        expect(
          () => throw TimeoutException('Timeout geral'),
          throwsA(isA<TimeoutException>()),
        );
      });

      test('deve lançar NfeApiException', () {
        expect(
          () => throw NfeApiException('Erro na API'),
          throwsA(isA<NfeApiException>()),
        );
      });
    });
  });
}
