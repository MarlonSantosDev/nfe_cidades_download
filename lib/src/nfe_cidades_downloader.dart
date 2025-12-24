import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'anti_captcha_client.dart';
import 'nfe_api_client.dart';
import 'constants.dart';
import 'models/nfe_download_result.dart';
import 'exceptions/nfe_exceptions.dart';

/// Classe principal para baixar documentos NFe do site nfe-cidades.com.br
///
/// Esta classe usa o serviço Anti-Captcha para resolver desafios reCAPTCHA
/// e então baixa documentos NFe.
///
/// Exemplo de uso:
/// ```dart
/// final baixador = BaixadorNfeCidades(chaveApiAntiCaptcha: 'SUA_CHAVE_API');
/// try {
///   final resultado = await baixador.baixarNfe(
///     senha: 'ABCD1234567890',
///     baixarBytes: true,
///   );
///   print('URL de download: ${resultado.urlDownload}');
///   if (resultado.bytesPdf != null) {
///     // Salvar PDF em arquivo
///   }
/// } finally {
///   baixador.liberar();
/// }
/// ```
class BaixadorNfeCidades {
  final String chaveApiAntiCaptcha;
  final ClienteAntiCaptcha _clienteCaptcha;
  final ClienteApiNfe _clienteNfe;

  /// Cria uma nova instância do baixador de NFe
  ///
  /// [chaveApiAntiCaptcha] é obrigatório - obtenha em https://anti-captcha.com
  /// [dio] é opcional - forneça uma instância Dio personalizada se necessário
  BaixadorNfeCidades({required this.chaveApiAntiCaptcha, Dio? dio})
      : _clienteCaptcha = ClienteAntiCaptcha(chaveApi: chaveApiAntiCaptcha, dio: dio),
        _clienteNfe = ClienteApiNfe(dio: dio);

  /// Baixa um documento NFe usando a senha fornecida
  ///
  /// [senha] é a senha formatada (ex: "ABCD1234567890")
  /// [baixarBytes] determina se deve baixar os bytes reais do PDF (padrão: false)
  /// [tempoLimite] define o tempo máximo para aguardar toda a operação
  ///
  /// Retorna [ResultadoDownloadNfe] contendo a URL de download e opcionalmente os bytes do PDF
  ///
  /// Lança [ExcecaoSenhaInvalida] se a senha for inválida
  /// Lança [ExcecaoDocumentoNaoEncontrado] se o documento não for encontrado
  /// Lança [ExcecaoTempoEsgotadoCaptcha] se a resolução do captcha expirar
  /// Lança [ExcecaoAntiCaptcha] se a API Anti-Captcha falhar
  /// Lança [ExcecaoApiNfe] para outros erros da API NFe-Cidades
  /// Lança [ExcecaoRede] para erros relacionados à rede
  /// Lança [ExcecaoTempoEsgotado] se a operação expirar
  Future<ResultadoDownloadNfe> baixarNfe({
    required String senha,
    bool baixarBytes = false,
    Duration? tempoLimite,
  }) async {
    final tempoLimiteEfetivo = tempoLimite ?? ConstantesNfe.tempoLimitePadrao;

    try {
      return await Future.any([
        _baixarNfeInterno(senha: senha, baixarBytes: baixarBytes),
        Future.delayed(tempoLimiteEfetivo).then((_) {
          throw ExcecaoTempoEsgotado(
            'Operação expirou após ${tempoLimiteEfetivo.inSeconds} segundos',
          );
        }),
      ]);
    } catch (e) {
      if (e is ExcecaoNfe) {
        rethrow;
      }
      throw ExcecaoApiNfe(
        'Erro inesperado durante o download',
        erroOriginal: e,
      );
    }
  }

  /// Implementação interna do processo de download
  Future<ResultadoDownloadNfe> _baixarNfeInterno({
    required String senha,
    required bool baixarBytes,
  }) async {
    // Passo 1: Resolver reCAPTCHA usando Anti-Captcha
    final tokenCaptcha = await _clienteCaptcha.resolverRecaptchaV2(
      urlSite: ConstantesNfe.urlPaginaInicialNfe,
      chaveSite: ConstantesNfe.chaveSiteRecaptcha,
    );

    // Passo 2: Buscar documento usando senha e token do captcha
    final dadosCriptografados = await _clienteNfe.buscarDocumento(
      senha: senha,
      tokenCaptcha: tokenCaptcha,
    );

    // Passo 3: Obter detalhes do documento e extrair ID do documento
    final idDocumento = await _clienteNfe.obterIdDocumento(
      senha: senha,
      dadosCriptografados: dadosCriptografados,
    );

    // Passo 4: Construir URL de download
    final urlDownload = '${ConstantesNfe.urlRelatorioNfe}?id=$idDocumento';

    // Passo 5: Opcionalmente baixar bytes do PDF
    Uint8List? bytesPdf;
    if (baixarBytes) {
      bytesPdf = await _clienteNfe.baixarPdf(idDocumento);
    }

    return ResultadoDownloadNfe(
      urlDownload: urlDownload,
      idDocumento: idDocumento,
      bytesPdf: bytesPdf,
    );
  }

  /// Libera todos os recursos
  ///
  /// Chame isso quando terminar de usar o baixador
  void liberar() {
    _clienteCaptcha.liberar();
    _clienteNfe.liberar();
  }
}
