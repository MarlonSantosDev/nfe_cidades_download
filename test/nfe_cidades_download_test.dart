import 'package:test/test.dart';
import 'package:nfe_cidades_download/nfe_cidades_download.dart';
import 'dart:typed_data';

void main() {
  group('BaixadorNfeCidades - API v1.0.0', () {
    test('deve criar instância com chave API', () {
      const baixador = BaixadorNfeCidades(chaveApiAntiCaptcha: 'test_key');
      expect(baixador.chaveApiAntiCaptcha, 'test_key');
    });

    test('deve ser callable', () {
      const baixador = BaixadorNfeCidades(chaveApiAntiCaptcha: 'test_key');
      expect(baixador.call, isA<Function>());
    });

    test('deve criar executor reutilizável', () {
      const baixador = BaixadorNfeCidades(chaveApiAntiCaptcha: 'test_key');
      final executor = baixador.criarExecutor();
      expect(executor, isNotNull);
      executor.liberar();
    });
  });

  group('Map Result com Extensions - API v1.0.0', () {
    test('deve criar resultado Map válido', () {
      final resultado = <String, dynamic>{
        'urlDownload': 'https://example.com/download?id=123',
        'idDocumento': '123',
        'tamanho': 12345,
        'bytes': Uint8List(100),
        'bytesBase64': 'base64string',
      };

      expect(resultado['urlDownload'], 'https://example.com/download?id=123');
      expect(resultado['idDocumento'], '123');
      expect(resultado['tamanho'], 12345);
    });

    test('deve fornecer acesso type-safe via extensions', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final resultado = <String, dynamic>{
        'urlDownload': 'https://example.com/download?id=123',
        'idDocumento': '123',
        'tamanho': 5,
        'bytes': bytes,
        'bytesBase64': 'AQIDBAU=',
      };

      // Testa extensions type-safe
      expect(resultado.urlDownload, 'https://example.com/download?id=123');
      expect(resultado.idDocumento, '123');
      expect(resultado.tamanho, 5);
      expect(resultado.bytes, isNotNull);
      expect(resultado.bytes!.length, 5);
      expect(resultado.bytes, equals(bytes));
      expect(resultado.bytesBase64, 'AQIDBAU=');
    });

    test('deve suportar campos opcionais nulos', () {
      final resultado = <String, dynamic>{
        'urlDownload': 'https://example.com',
        'idDocumento': '123',
        'tamanho': 0,
        'bytes': null,
        'bytesBase64': null,
        'salvar': null,
      };

      expect(resultado.bytes, isNull);
      expect(resultado.bytesBase64, isNull);
      expect(resultado.salvar, isNull);
    });
  });

  group('Exceções', () {
    test('deve lançar ExcecaoSenhaInvalida', () {
      expect(
        () => throw const ExcecaoSenhaInvalida('Senha inválida'),
        throwsA(isA<ExcecaoSenhaInvalida>()),
      );
    });

    test('deve lançar ExcecaoDocumentoNaoEncontrado', () {
      expect(
        () => throw const ExcecaoDocumentoNaoEncontrado('Não encontrado'),
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
        () => throw const ExcecaoAntiCaptcha('Erro'),
        throwsA(isA<ExcecaoAntiCaptcha>()),
      );
    });

    test('deve lançar ExcecaoAntiCaptcha com código de erro', () {
      const excecao = ExcecaoAntiCaptcha(
        'Erro',
        codigoErro: 'ERROR_ZERO_BALANCE',
      );
      expect(excecao.codigoErro, 'ERROR_ZERO_BALANCE');
      expect(excecao.toString(), contains('ERROR_ZERO_BALANCE'));
    });

    test('deve lançar ExcecaoRede', () {
      expect(
        () => throw const ExcecaoRede('Erro de rede'),
        throwsA(isA<ExcecaoRede>()),
      );
    });

    test('deve lançar ExcecaoTempoEsgotado', () {
      expect(
        () => throw const ExcecaoTempoEsgotado('Timeout'),
        throwsA(isA<ExcecaoTempoEsgotado>()),
      );
    });

    test('deve lançar ExcecaoApiNfe', () {
      expect(
        () => throw const ExcecaoApiNfe('Erro na API'),
        throwsA(isA<ExcecaoApiNfe>()),
      );
    });

    test('deve lançar ExcecaoApiNfe com código de status', () {
      const excecao = ExcecaoApiNfe(
        'Erro na API',
        codigoStatus: 500,
      );
      expect(excecao.codigoStatus, 500);
      expect(excecao.toString(), contains('HTTP 500'));
    });

    test('deve lançar ExcecaoSenhaInvalida com código de status', () {
      const excecao = ExcecaoSenhaInvalida(
        'Senha inválida',
        codigoStatus: 401,
      );
      expect(excecao.codigoStatus, 401);
      expect(excecao.toString(), contains('ExcecaoSenhaInvalida'));
    });

    test('deve lançar ExcecaoDocumentoNaoEncontrado com código de status', () {
      const excecao = ExcecaoDocumentoNaoEncontrado(
        'Não encontrado',
        codigoStatus: 404,
      );
      expect(excecao.codigoStatus, 404);
      expect(excecao.toString(), contains('ExcecaoDocumentoNaoEncontrado'));
    });

    test('deve preservar erro original na exceção', () {
      final erroOriginal = Exception('Erro original');
      final excecao = ExcecaoRede(
        'Erro wrapper',
        erroOriginal,
      );
      expect(excecao.erroOriginal, erroOriginal);
      expect(excecao.mensagem, 'Erro wrapper');
      expect(excecao.erroOriginal, isNotNull);
    });

    test('deve preservar stack trace na exceção', () {
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
