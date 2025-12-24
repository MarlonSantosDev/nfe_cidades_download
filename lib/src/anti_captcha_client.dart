import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'constants.dart';
import 'exceptions/nfe_exceptions.dart';
import 'models/anti_captcha_models.dart';

/// Cliente para interagir com a API Anti-Captcha
///
/// Esta classe trata todas as interações com o serviço Anti-Captcha,
/// incluindo criação de tarefas de resolução de captcha e polling de resultados.
///
/// Ela suporta desafios reCAPTCHA v2 e faz polling automático da API
/// até que o captcha seja resolvido ou ocorra um timeout.
class ClienteAntiCaptcha {
  /// A chave da API Anti-Captcha
  ///
  /// Obtenha sua chave de API em https://anti-captcha.com
  final String chaveApi;
  final Dio _dio;

  /// Cria uma nova instância de [ClienteAntiCaptcha]
  ///
  /// [chaveApi] é obrigatório - obtenha em https://anti-captcha.com
  /// [dio] é opcional - forneça uma instância Dio personalizada se necessário
  ClienteAntiCaptcha({required this.chaveApi, Dio? dio}) : _dio = dio ?? Dio();

  /// Resolve um desafio reCAPTCHA v2 e retorna o token gRecaptchaResponse
  ///
  /// Este método cria uma nova tarefa de resolução de captcha, faz polling da API Anti-Captcha
  /// até que o captcha seja resolvido, e retorna o token da solução.
  ///
  /// [urlSite] é a URL do site onde o captcha é exibido
  /// [chaveSite] é a chave do site reCAPTCHA v2
  /// [tempoMaximoEspera] é o tempo máximo para aguardar a resolução do captcha
  ///   (padrão: [ConstantesNfe.tempoMaximoPollingCaptcha])
  /// [intervaloPolling] é o intervalo entre requisições de polling
  ///   (padrão: [ConstantesNfe.intervaloPollingCaptcha])
  ///
  /// Retorna o token gRecaptchaResponse que pode ser usado para enviar formulários
  ///
  /// Lança [ExcecaoAntiCaptcha] se a API retornar um erro
  /// Lança [ExcecaoTempoEsgotadoCaptcha] se a resolução expirar
  /// Lança [ExcecaoRede] para erros relacionados à rede
  Future<String> resolverRecaptchaV2({
    required String urlSite,
    required String chaveSite,
    Duration? tempoMaximoEspera,
    Duration? intervaloPolling,
  }) async {
    final tempoMaximo =
        tempoMaximoEspera ?? ConstantesNfe.tempoMaximoPollingCaptcha;
    final intervalo = intervaloPolling ?? ConstantesNfe.intervaloPollingCaptcha;

    // Passo 1: Criar tarefa
    final idTarefa = await _criarTarefa(urlSite, chaveSite);

    // Passo 2: Fazer polling do resultado
    final tempoInicio = DateTime.now();
    while (DateTime.now().difference(tempoInicio) < tempoMaximo) {
      await Future.delayed(intervalo);

      final resultado = await _obterResultadoTarefa(idTarefa);

      if (resultado.temErro) {
        throw ExcecaoAntiCaptcha(
          resultado.descricaoErro ?? 'Erro desconhecido do Anti-Captcha',
          codigoErro: resultado.codigoErro,
        );
      }

      if (resultado.estaPronto && resultado.respostaRecaptcha != null) {
        return resultado.respostaRecaptcha!;
      }

      // Continuar polling se ainda estiver processando
      if (!resultado.estaProcessando) {
        throw ExcecaoAntiCaptcha('Status inesperado: ${resultado.status}');
      }
    }

    throw ExcecaoTempoEsgotadoCaptcha(
      'Resolução do captcha expirou após ${tempoMaximo.inSeconds} segundos',
    );
  }

  /// Cria uma tarefa de captcha e retorna o ID da tarefa
  ///
  /// Este é um método interno que envia uma requisição para a API Anti-Captcha
  /// para criar uma nova tarefa de resolução de reCAPTCHA v2.
  ///
  /// [urlSite] é a URL do site onde o captcha é exibido
  /// [chaveSite] é a chave do site reCAPTCHA v2
  ///
  /// Retorna o ID da tarefa atribuído pelo Anti-Captcha
  ///
  /// Lança [ExcecaoAntiCaptcha] se a criação da tarefa falhar
  /// Lança [ExcecaoRede] para erros relacionados à rede
  Future<int> _criarTarefa(String urlSite, String chaveSite) async {
    try {
      final requisicao = RequisicaoCriarTarefaAntiCaptcha(
        chaveCliente: chaveApi,
        tarefa: TarefaRecaptchaV2SemProxy(
          urlSite: urlSite,
          chaveSite: chaveSite,
        ),
      );

      final resposta = await _dio.post(
        ConstantesNfe.urlCriarTarefaAntiCaptcha,
        data: jsonEncode(requisicao.paraJson()),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final resultado = RespostaCriarTarefaAntiCaptcha.deJson(
        resposta.data as Map<String, dynamic>,
      );

      if (resultado.temErro) {
        throw ExcecaoAntiCaptcha(
          resultado.descricaoErro ?? 'Falha ao criar tarefa de captcha',
          codigoErro: resultado.codigoErro,
        );
      }

      if (resultado.idTarefa == null) {
        throw const ExcecaoAntiCaptcha(
            'Nenhum ID de tarefa retornado do Anti-Captcha');
      }

      return resultado.idTarefa!;
    } on DioException catch (erro, rastreamentoPilha) {
      throw ExcecaoRede(
        'Erro de rede ao criar tarefa de captcha',
        erro,
        rastreamentoPilha,
      );
    }
  }

  /// Obtém o resultado de uma tarefa de captcha
  ///
  /// Este é um método interno que faz polling da API Anti-Captcha para verificar
  /// o status de uma tarefa de resolução de captcha.
  ///
  /// [idTarefa] é o ID da tarefa retornado de [_criarTarefa]
  ///
  /// Retorna a resposta do resultado da tarefa contendo status e solução
  ///
  /// Lança [ExcecaoRede] para erros relacionados à rede
  Future<RespostaObterResultadoAntiCaptcha> _obterResultadoTarefa(
      int idTarefa) async {
    try {
      final requisicao = RequisicaoObterResultadoAntiCaptcha(
        chaveCliente: chaveApi,
        idTarefa: idTarefa,
      );

      final resposta = await _dio.post(
        ConstantesNfe.urlObterResultadoAntiCaptcha,
        data: jsonEncode(requisicao.paraJson()),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      return RespostaObterResultadoAntiCaptcha.deJson(
        resposta.data as Map<String, dynamic>,
      );
    } on DioException catch (erro, rastreamentoPilha) {
      throw ExcecaoRede(
        'Erro de rede ao obter resultado do captcha',
        erro,
        rastreamentoPilha,
      );
    }
  }

  /// Libera recursos
  ///
  /// Fecha a instância Dio subjacente e libera todos os recursos.
  /// Sempre chame este método quando terminar de usar o cliente.
  void liberar() {
    _dio.close();
  }
}
