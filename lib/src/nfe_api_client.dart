import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'constants.dart';
import 'exceptions/nfe_exceptions.dart';

/// Cliente para interagir com a API NFe-Cidades
///
/// Esta classe trata todas as requisições HTTP para o site NFe-Cidades,
/// incluindo busca de documentos, extração de ID do documento e download de PDF.
///
/// Ela gerencia cookies automaticamente usando [CookieJar] em plataformas não-web
/// e depende do gerenciamento de cookies do navegador em plataformas web.
class ClienteApiNfe {
  final Dio _dio;

  /// Cria uma nova instância de [ClienteApiNfe]
  ///
  /// [dio] é opcional - forneça uma instância Dio personalizada se necessário.
  /// [cookieJar] é opcional e apenas usado em plataformas não-web.
  /// Em plataformas web, os cookies são gerenciados automaticamente pelo navegador.
  ClienteApiNfe({Dio? dio, CookieJar? cookieJar}) : _dio = dio ?? Dio() {
    // Na web, o Dio gerencia cookies automaticamente através do navegador
    // Em outras plataformas, usamos CookieJar para gerenciar cookies
    if (!kIsWeb) {
      final jar = cookieJar ?? CookieJar();
      _dio.interceptors.add(CookieManager(jar));
    }
    // Na web, os cookies são gerenciados automaticamente pelo navegador
    _dio.options.headers['User-Agent'] = ConstantesNfe.agenteUsuario;
  }

  /// Busca um documento usando senha e token do captcha
  ///
  /// Este método envia uma requisição POST para a API NFe-Cidades para buscar
  /// um documento usando a senha e o token do captcha fornecidos. Retorna uma
  /// string de dados criptografados necessária para a próxima etapa do processo de download.
  ///
  /// [senha] é a senha formatada da NFe (ex: "ABCD1234567890")
  /// [tokenCaptcha] é o token reCAPTCHA v2 obtido do Anti-Captcha
  ///
  /// Retorna a string de dados criptografados necessária para [obterIdDocumento]
  ///
  /// Lança [ExcecaoSenhaInvalida] se a senha ou o token do captcha for inválido
  /// Lança [ExcecaoApiNfe] para outros erros da API
  /// Lança [ExcecaoRede] para erros relacionados à rede
  /// Lança [ExcecaoTempoEsgotado] se a requisição expirar
  Future<String> buscarDocumento({
    required String senha,
    required String tokenCaptcha,
  }) async {
    try {
      final resposta = await _dio.post(
        ConstantesNfe.urlBuscarDocumentoNfe,
        data: jsonEncode({'captcha': tokenCaptcha, 'senha': senha}),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json, text/plain, */*',
            'Origin': ConstantesNfe.urlBaseNfe,
            'Referer': ConstantesNfe.urlPaginaInicialNfe,
          },
          responseType: ResponseType.json,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (resposta.statusCode == 401 || resposta.statusCode == 403) {
        throw ExcecaoSenhaInvalida(
          'Senha ou token do captcha inválido',
          codigoStatus: resposta.statusCode,
        );
      }

      if (resposta.statusCode != 200) {
        throw ExcecaoApiNfe(
          'Falha ao buscar documento: ${resposta.statusMessage}',
          codigoStatus: resposta.statusCode,
        );
      }

      // A resposta deve conter dados criptografados
      // Tratar diferentes formatos de resposta: JSON string, Map ou string direta

      // Verificar resposta nula ou vazia
      if (resposta.data == null) {
        throw const ExcecaoApiNfe(
          'Resposta inválida de buscarDocumento: dados da resposta são nulos',
        );
      }

      Map<String, dynamic>? dados;

      if (resposta.data is String) {
        final stringResposta = resposta.data as String;
        if (stringResposta.isEmpty) {
          throw const ExcecaoApiNfe(
            'Resposta inválida de buscarDocumento: dados da resposta estão vazios',
          );
        }
        // Tentar analisar string JSON
        try {
          final decodificado = jsonDecode(stringResposta);
          if (decodificado is Map<String, dynamic>) {
            dados = decodificado;
          } else if (decodificado is String) {
            // Resposta é uma string direta (os dados criptografados)
            return decodificado;
          }
        } catch (erro) {
          // Se não for JSON válido, tratar como resposta de string direta
          return stringResposta;
        }
      } else if (resposta.data is Map<String, dynamic>) {
        dados = resposta.data as Map<String, dynamic>;
      }

      // Verificar se temos um Map com chave 'validador' ou 'data'
      if (dados != null) {
        // Tentar 'validador' primeiro (formato atual da API)
        if (dados.containsKey('validador')) {
          final validador = dados['validador'];
          if (validador is String) {
            return validador;
          }
        }
        // Fallback para 'data' para compatibilidade com versões anteriores
        if (dados.containsKey('data')) {
          final dadosCriptografados = dados['data'];
          if (dadosCriptografados is String) {
            return dadosCriptografados;
          }
        }
      }

      // Se chegamos aqui, a estrutura da resposta é inesperada
      final stringResposta = resposta.data.toString();
      final preview = stringResposta.length > 200
          ? '${stringResposta.substring(0, 200)}...'
          : stringResposta;
      throw ExcecaoApiNfe(
        'Resposta inválida de buscarDocumento. '
        'Esperado JSON com campo "validador" ou "data", ou string direta. '
        'Tipo recebido: ${resposta.data.runtimeType}, preview: $preview',
      );
    } on DioException catch (erro, rastreamentoPilha) {
      if (erro.type == DioExceptionType.connectionTimeout ||
          erro.type == DioExceptionType.receiveTimeout) {
        throw ExcecaoTempoEsgotado(
            'Requisição expirou', erro, rastreamentoPilha);
      }
      throw ExcecaoRede(
          'Erro de rede em buscarDocumento', erro, rastreamentoPilha);
    }
  }

  /// Recupera detalhes do documento e extrai o ID do documento
  ///
  /// Este método recupera a página HTML contendo os detalhes do documento e
  /// extrai o ID do documento dela. O ID do documento é necessário para construir
  /// a URL de download.
  ///
  /// [senha] é a senha formatada da NFe
  /// [dadosCriptografados] é a string de dados criptografados retornada de [buscarDocumento]
  ///
  /// Retorna o ID do documento como uma string
  ///
  /// Lança [ExcecaoDocumentoNaoEncontrado] se o documento não for encontrado
  /// Lança [ExcecaoApiNfe] se o ID do documento não puder ser extraído
  /// Lança [ExcecaoRede] para erros relacionados à rede
  /// Lança [ExcecaoTempoEsgotado] se a requisição expirar
  Future<String> obterIdDocumento({
    required String senha,
    required String dadosCriptografados,
  }) async {
    try {
      final resposta = await _dio.get(
        ConstantesNfe.urlDocumentosNfe,
        queryParameters: {'senha': senha, 'data': dadosCriptografados},
        options: Options(
          headers: {
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Referer':
                '${ConstantesNfe.urlBaseNfe}/public/documentos?senha=$senha&data=$dadosCriptografados',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (resposta.statusCode == 404) {
        throw ExcecaoDocumentoNaoEncontrado(
          'Documento não encontrado',
          codigoStatus: resposta.statusCode,
        );
      }

      if (resposta.statusCode != 200) {
        throw ExcecaoApiNfe(
          'Falha ao obter detalhes do documento: ${resposta.statusMessage}',
          codigoStatus: resposta.statusCode,
        );
      }

      // Analisar resposta HTML para extrair ID do documento
      // O ID geralmente está em um link ou variável JavaScript
      final html = resposta.data as String;
      final idDocumento = _extrairIdDocumentoDoHtml(html);

      if (idDocumento == null) {
        throw const ExcecaoApiNfe(
            'Não foi possível extrair o ID do documento da resposta');
      }

      return idDocumento;
    } on DioException catch (erro, rastreamentoPilha) {
      if (erro.type == DioExceptionType.connectionTimeout ||
          erro.type == DioExceptionType.receiveTimeout) {
        throw ExcecaoTempoEsgotado(
            'Requisição expirou', erro, rastreamentoPilha);
      }
      throw ExcecaoRede(
          'Erro de rede em obterIdDocumento', erro, rastreamentoPilha);
    }
  }

  /// Baixa os bytes do PDF para um documento
  ///
  /// Este método baixa o arquivo PDF completo para o ID do documento fornecido
  /// e o retorna como um array de bytes.
  ///
  /// [idDocumento] é o ID do documento obtido de [obterIdDocumento]
  ///
  /// Retorna o arquivo PDF como um [Uint8List]
  ///
  /// Lança [ExcecaoDocumentoNaoEncontrado] se o PDF não for encontrado
  /// Lança [ExcecaoApiNfe] para outros erros da API
  /// Lança [ExcecaoRede] para erros relacionados à rede
  /// Lança [ExcecaoTempoEsgotado] se o download expirar
  Future<Uint8List> baixarPdf(String idDocumento) async {
    try {
      final resposta = await _dio.get(
        ConstantesNfe.urlRelatorioNfe,
        queryParameters: {'id': idDocumento},
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (resposta.statusCode == 404) {
        throw ExcecaoDocumentoNaoEncontrado(
          'PDF não encontrado para o ID do documento: $idDocumento',
          codigoStatus: resposta.statusCode,
        );
      }

      if (resposta.statusCode != 200) {
        throw ExcecaoApiNfe(
          'Falha ao baixar PDF: ${resposta.statusMessage}',
          codigoStatus: resposta.statusCode,
        );
      }

      return Uint8List.fromList(resposta.data as List<int>);
    } on DioException catch (erro, rastreamentoPilha) {
      if (erro.type == DioExceptionType.connectionTimeout ||
          erro.type == DioExceptionType.receiveTimeout) {
        throw ExcecaoTempoEsgotado(
            'Download do PDF expirou', erro, rastreamentoPilha);
      }
      throw ExcecaoRede('Erro de rede ao baixar PDF', erro, rastreamentoPilha);
    }
  }

  /// Extrai o ID do documento da resposta HTML
  ///
  /// Este método analisa a resposta HTML do endpoint documentos.action
  /// e extrai o ID do documento usando um padrão de expressão regular.
  ///
  /// O padrão procura por URLs contendo "relatorioNotaFiscal.action?id="
  /// e extrai o valor do ID.
  ///
  /// [html] é o conteúdo HTML da resposta documentos.action
  ///
  /// Retorna o ID do documento se encontrado, ou `null` se não encontrado
  String? _extrairIdDocumentoDoHtml(String html) {
    // Procurar padrões como: relatorioNotaFiscal.action?id=XXXXX
    final regex = RegExp(r'relatorioNotaFiscal\.action\?id=([^"&\s]+)');
    final correspondencia = regex.firstMatch(html);
    return correspondencia?.group(1);
  }

  /// Libera recursos
  ///
  /// Fecha a instância Dio subjacente e libera todos os recursos.
  /// Sempre chame este método quando terminar de usar o cliente.
  void liberar() {
    _dio.close();
  }
}
