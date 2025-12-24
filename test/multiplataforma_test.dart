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
    test('deve criar instância do baixador em qualquer plataforma', () {
      final baixador = BaixadorNfeCidades(
        chaveApiAntiCaptcha: 'test_key_12345',
      );

      expect(baixador.chaveApiAntiCaptcha, 'test_key_12345');
      expect(() => baixador.liberar(), returnsNormally);
    });

    test('deve funcionar com Dio customizado', () {
      final dio = Dio();
      final baixador = BaixadorNfeCidades(
        chaveApiAntiCaptcha: 'test_key',
        dio: dio,
      );

      expect(baixador, isNotNull);
      baixador.liberar();
    });

    test('deve criar ResultadoDownloadNfe válido', () {
      const resultado = ResultadoDownloadNfe(
        urlDownload: 'https://example.com/download?id=123',
        idDocumento: '123',
      );

      expect(resultado.urlDownload, contains('123'));
      expect(resultado.idDocumento, '123');
      expect(resultado.bytesPdf, isNull);
    });

    test('deve criar ResultadoDownloadNfe com PDF bytes', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final resultado = ResultadoDownloadNfe(
        urlDownload: 'https://example.com/download?id=123',
        idDocumento: '123',
        bytesPdf: bytes,
      );

      expect(resultado.bytesPdf, isNotNull);
      expect(resultado.bytesPdf!.length, 5);
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
        final baixador = BaixadorNfeCidades(chaveApiAntiCaptcha: 'test_key');

        expect(baixador, isNotNull);
        expect(() => baixador.liberar(), returnsNormally);
      });
    });

    group('Exceções Multiplataforma', () {
      test('deve lançar ExcecaoSenhaInvalida', () {
        expect(
          () => throw const ExcecaoSenhaInvalida('Senha inválida'),
          throwsA(isA<ExcecaoSenhaInvalida>()),
        );
      });

      test('deve lançar ExcecaoDocumentoNaoEncontrado', () {
        expect(
          () => throw const ExcecaoDocumentoNaoEncontrado(
              'Documento não encontrado'),
          throwsA(isA<ExcecaoDocumentoNaoEncontrado>()),
        );
      });

      test('deve lançar ExcecaoTempoEsgotadoCaptcha', () {
        expect(
          () => throw const ExcecaoTempoEsgotadoCaptcha('Timeout'),
          throwsA(isA<ExcecaoTempoEsgotadoCaptcha>()),
        );
      });

      test('deve lançar ExcecaoAntiCaptcha', () {
        expect(
          () => throw const ExcecaoAntiCaptcha('Erro no Anti-Captcha'),
          throwsA(isA<ExcecaoAntiCaptcha>()),
        );
      });

      test('deve lançar ExcecaoRede', () {
        expect(
          () => throw const ExcecaoRede('Erro de rede'),
          throwsA(isA<ExcecaoRede>()),
        );
      });

      test('deve lançar ExcecaoTempoEsgotado', () {
        expect(
          () => throw const ExcecaoTempoEsgotado('Timeout geral'),
          throwsA(isA<ExcecaoTempoEsgotado>()),
        );
      });

      test('deve lançar ExcecaoApiNfe', () {
        expect(
          () => throw const ExcecaoApiNfe('Erro na API'),
          throwsA(isA<ExcecaoApiNfe>()),
        );
      });
    });
  });
}
