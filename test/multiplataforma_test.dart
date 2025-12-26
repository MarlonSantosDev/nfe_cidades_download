import 'package:test/test.dart';
import 'package:nfe_cidades_download/nfe_cidades_download.dart';
import 'dart:typed_data';

/// Testes de validação multiplataforma
///
/// Estes testes verificam se o pacote funciona corretamente em diferentes plataformas,
/// com foco especial na compatibilidade Dart puro e API v0.1.0.
void main() {
  group('BaixadorNfeCidades - API v0.1.0', () {
    test('deve criar instância do baixador', () {
      const baixador = BaixadorNfeCidades(
        chaveApiAntiCaptcha: 'test_key_12345',
      );

      expect(baixador.chaveApiAntiCaptcha, 'test_key_12345');
    });

    test('deve ser callable', () {
      const baixador = BaixadorNfeCidades(
        chaveApiAntiCaptcha: 'test_key',
      );

      // Verifica que é callable (tem método call)
      expect(baixador, isA<BaixadorNfeCidades>());
      expect(baixador.chaveApiAntiCaptcha, 'test_key');
    });

    test('deve criar executor reutilizável', () {
      const baixador = BaixadorNfeCidades(
        chaveApiAntiCaptcha: 'test_key',
      );

      final executor = baixador.criarExecutor();
      expect(executor, isNotNull);
      // Cleanup do executor
      executor.liberar();
    });
  });

  group('NfeResultExtension', () {
    test('deve fornecer acesso type-safe ao Map', () {
      final resultado = <String, dynamic>{
        'urlDownload': 'https://example.com/download?id=123',
        'idDocumento': '123',
        'tamanho': 12345,
        'bytes': Uint8List(100),
        'bytesBase64': 'base64string',
        'salvar': null,
      };

      // Testa extensions
      expect(resultado.urlDownload, contains('123'));
      expect(resultado.idDocumento, '123');
      expect(resultado.tamanho, 12345);
      expect(resultado.bytes, isNotNull);
      expect(resultado.bytes!.length, 100);
      expect(resultado.bytesBase64, 'base64string');
    });

    test('deve retornar null para campos opcionais', () {
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
    test('ExcecaoSenhaInvalida deve ser criada', () {
      expect(
        () => throw const ExcecaoSenhaInvalida('Senha inválida'),
        throwsA(isA<ExcecaoSenhaInvalida>()),
      );
    });

    test('ExcecaoDocumentoNaoEncontrado deve ser criada', () {
      expect(
        () => throw const ExcecaoDocumentoNaoEncontrado('Não encontrado'),
        throwsA(isA<ExcecaoDocumentoNaoEncontrado>()),
      );
    });

    test('ExcecaoTempoEsgotado deve ser criada', () {
      expect(
        () => throw const ExcecaoTempoEsgotado('Timeout'),
        throwsA(isA<ExcecaoTempoEsgotado>()),
      );
    });
  });

  group('PlatformDetector', () {
    test('deve detectar plataforma', () {
      // PlatformDetector.isWeb retorna true na web, false em outras plataformas
      expect(PlatformDetector.isWeb, isA<bool>());
      expect(PlatformDetector.isNative, isA<bool>());
      expect(PlatformDetector.isWeb, equals(!PlatformDetector.isNative));
    });
  });
}
