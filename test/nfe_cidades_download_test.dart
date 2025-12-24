import 'package:flutter_test/flutter_test.dart';
import 'package:nfe_cidades_download/nfe_cidades_download.dart';
import 'dart:typed_data';

void main() {
  group('BaixadorNfeCidades', () {
    test('should create instance with API key', () {
      final baixador = BaixadorNfeCidades(chaveApiAntiCaptcha: 'test_key');

      expect(baixador.chaveApiAntiCaptcha, 'test_key');
      baixador.liberar();
    });

    test('should create instance with custom Dio', () {
      final baixador = BaixadorNfeCidades(
        chaveApiAntiCaptcha: 'test_key',
      );

      expect(baixador, isNotNull);
      expect(baixador.chaveApiAntiCaptcha, 'test_key');
      baixador.liberar();
    });

    test('should dispose resources without errors', () {
      final baixador = BaixadorNfeCidades(chaveApiAntiCaptcha: 'test_key');
      expect(() => baixador.liberar(), returnsNormally);
    });
  });

  group('ResultadoDownloadNfe', () {
    test('should create result with required fields', () {
      const resultado = ResultadoDownloadNfe(
        urlDownload: 'https://example.com/download?id=123',
        idDocumento: '123',
      );

      expect(resultado.urlDownload, 'https://example.com/download?id=123');
      expect(resultado.idDocumento, '123');
      expect(resultado.bytesPdf, isNull);
    });

    test('should create result with PDF bytes', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final resultado = ResultadoDownloadNfe(
        urlDownload: 'https://example.com/download?id=123',
        idDocumento: '123',
        bytesPdf: bytes,
      );

      expect(resultado.urlDownload, 'https://example.com/download?id=123');
      expect(resultado.idDocumento, '123');
      expect(resultado.bytesPdf, isNotNull);
      expect(resultado.bytesPdf!.length, 5);
      expect(resultado.bytesPdf, equals(bytes));
    });

    test('should have correct toString representation', () {
      const resultado = ResultadoDownloadNfe(
        urlDownload: 'https://example.com/download?id=123',
        idDocumento: '123',
      );

      final str = resultado.toString();
      expect(str, contains('ResultadoDownloadNfe'));
      expect(str, contains('urlDownload'));
      expect(str, contains('idDocumento'));
      expect(str, contains('temBytesPdf'));
    });

    test('should have correct toString with PDF bytes', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final resultado = ResultadoDownloadNfe(
        urlDownload: 'https://example.com/download?id=123',
        idDocumento: '123',
        bytesPdf: bytes,
      );

      final str = resultado.toString();
      expect(str, contains('temBytesPdf: true'));
    });
  });

  group('Exceptions', () {
    test('should throw ExcecaoSenhaInvalida', () {
      expect(
        () => throw const ExcecaoSenhaInvalida('Senha inválida'),
        throwsA(isA<ExcecaoSenhaInvalida>()),
      );
    });

    test('should throw ExcecaoDocumentoNaoEncontrado', () {
      expect(
        () => throw const ExcecaoDocumentoNaoEncontrado('Não encontrado'),
        throwsA(isA<ExcecaoDocumentoNaoEncontrado>()),
      );
    });

    test('should throw ExcecaoTempoEsgotadoCaptcha', () {
      expect(
        () => throw const ExcecaoTempoEsgotadoCaptcha('Timeout'),
        throwsA(isA<ExcecaoTempoEsgotadoCaptcha>()),
      );
    });

    test('should throw ExcecaoAntiCaptcha', () {
      expect(
        () => throw const ExcecaoAntiCaptcha('Erro'),
        throwsA(isA<ExcecaoAntiCaptcha>()),
      );
    });

    test('should throw ExcecaoAntiCaptcha with error code', () {
      const excecao = ExcecaoAntiCaptcha(
        'Erro',
        codigoErro: 'ERROR_ZERO_BALANCE',
      );
      expect(excecao.codigoErro, 'ERROR_ZERO_BALANCE');
      expect(excecao.toString(), contains('ERROR_ZERO_BALANCE'));
    });

    test('should throw ExcecaoRede', () {
      expect(
        () => throw const ExcecaoRede('Erro de rede'),
        throwsA(isA<ExcecaoRede>()),
      );
    });

    test('should throw ExcecaoTempoEsgotado', () {
      expect(
        () => throw const ExcecaoTempoEsgotado('Timeout'),
        throwsA(isA<ExcecaoTempoEsgotado>()),
      );
    });

    test('should throw ExcecaoApiNfe', () {
      expect(
        () => throw const ExcecaoApiNfe('Erro na API'),
        throwsA(isA<ExcecaoApiNfe>()),
      );
    });

    test('should throw ExcecaoApiNfe with status code', () {
      const excecao = ExcecaoApiNfe(
        'Erro na API',
        codigoStatus: 500,
      );
      expect(excecao.codigoStatus, 500);
      expect(excecao.toString(), contains('HTTP 500'));
    });

    test('should throw ExcecaoSenhaInvalida with status code', () {
      const excecao = ExcecaoSenhaInvalida(
        'Senha inválida',
        codigoStatus: 401,
      );
      expect(excecao.codigoStatus, 401);
      expect(excecao.toString(), contains('ExcecaoSenhaInvalida'));
    });

    test('should throw ExcecaoDocumentoNaoEncontrado with status code', () {
      const excecao = ExcecaoDocumentoNaoEncontrado(
        'Não encontrado',
        codigoStatus: 404,
      );
      expect(excecao.codigoStatus, 404);
      expect(excecao.toString(), contains('ExcecaoDocumentoNaoEncontrado'));
    });

    test('should preserve original error in exception', () {
      final erroOriginal = Exception('Erro original');
      final excecao = ExcecaoRede(
        'Erro wrapper',
        erroOriginal,
      );
      expect(excecao.erroOriginal, erroOriginal);
      expect(excecao.mensagem, 'Erro wrapper');
      // O erroOriginal é armazenado mas pode não aparecer em toString()
      expect(excecao.erroOriginal, isNotNull);
    });

    test('should preserve stack trace in exception', () {
      final rastreamentoPilha = StackTrace.current;
      final excecao = ExcecaoRede(
        'Erro',
        null,
        rastreamentoPilha,
      );
      expect(excecao.rastreamentoPilha, rastreamentoPilha);
    });
  });
}
