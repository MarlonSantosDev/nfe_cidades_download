import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'anti_captcha_client.dart';
import 'nfe_api_client.dart';
import 'nfe_file_saver.dart';
import 'constants.dart';
import 'exceptions/nfe_exceptions.dart';
import 'cache/nfe_cache_config.dart';
import 'cache/nfe_cache_manager.dart';

/// Interface para executor reutilizável de downloads NFe
abstract class NfeExecutor {
  /// Baixa um documento NFe usando a senha fornecida
  Future<Map<String, dynamic>> baixarNfe({
    required String senha,
    bool baixarBytes = false,
    Duration? tempoLimite,
  });

  /// Libera recursos do executor
  void liberar();
}

/// Classe principal para baixar documentos NFe do site nfe-cidades.com.br
///
/// Esta classe usa o serviço Anti-Captcha para resolver desafios reCAPTCHA
/// e então baixa documentos NFe.
///
/// **NOVO em v0.1.0**: Auto-dispose automático! Não é mais necessário chamar
/// `finally { baixador.liberar(); }`. Os recursos são liberados automaticamente.
///
/// Exemplo de uso simples (recomendado):
/// ```dart
/// final baixador = BaixadorNfeCidades(chaveApiAntiCaptcha: 'SUA_CHAVE_API');
///
/// // Callable com auto-dispose - sem finally necessário!
/// final resultado = await baixador(
///   senha: 'ABCD1234567890',
///   baixarBytes: true,
/// );
///
/// print('URL: ${resultado.urlDownload}');
/// print('Tamanho: ${resultado.tamanho} bytes');
///
/// // Salvar funciona em todas as plataformas
/// await resultado.salvar!('nota_fiscal.pdf');
/// ```
///
/// Exemplo de uso avançado (reutilizável):
/// ```dart
/// final baixador = BaixadorNfeCidades(chaveApiAntiCaptcha: 'SUA_CHAVE');
/// final executor = baixador.criarExecutor();
/// try {
///   final r1 = await executor.baixarNfe(senha: 'ABC123');
///   final r2 = await executor.baixarNfe(senha: 'DEF456');
/// } finally {
///   executor.liberar(); // Cleanup manual apenas neste caso
/// }
/// ```
class BaixadorNfeCidades {
  /// Chave da API Anti-Captcha usada para resolver reCAPTCHA
  ///
  /// Esta chave é obrigatória e pode ser obtida em https://anti-captcha.com
  /// após criar uma conta no serviço.
  final String chaveApiAntiCaptcha;

  /// Cria uma nova instância do baixador de NFe
  ///
  /// [chaveApiAntiCaptcha] é obrigatório - obtenha em https://anti-captcha.com
  const BaixadorNfeCidades({required this.chaveApiAntiCaptcha});

  /// Habilita ou desabilita o cache globalmente
  ///
  /// - `true` (padrão): Cache ativado - NFes são armazenadas e retornadas do cache
  /// - `false`: Cache desativado - sempre busca da fonte (Anti-Captcha + API)
  ///
  /// Exemplo:
  /// ```dart
  /// // Desabilitar cache
  /// BaixadorNfeCidades.usarCache = false;
  ///
  /// // Habilitar cache (padrão)
  /// BaixadorNfeCidades.usarCache = true;
  /// ```
  static bool get usarCache => NfeCacheConfig.usarCache;
  static set usarCache(bool valor) => NfeCacheConfig.usarCache = valor;

  /// Limpa todo o cache armazenado
  ///
  /// Remove todas as entradas de NFes cacheadas do shared_preferences.
  /// Útil para forçar re-download de todos os documentos ou liberar espaço.
  ///
  /// Exemplo:
  /// ```dart
  /// await BaixadorNfeCidades.limparCache();
  /// print('Cache limpo com sucesso!');
  /// ```
  static Future<void> limparCache() => NfeCacheConfig.limparCache();

  /// Limpa o cache de uma senha específica
  ///
  /// Remove apenas a entrada de cache da senha fornecida, mantendo
  /// todas as outras entradas intactas.
  ///
  /// [senha] é a senha da NFe cujo cache deve ser removido
  ///
  /// Exemplo:
  /// ```dart
  /// // Remover cache de uma senha específica
  /// await BaixadorNfeCidades.limparCachePorSenha('17PI.QZNQ.HYQU.CYMM');
  /// print('Cache da senha removido!');
  ///
  /// // Próxima chamada com essa senha buscará da fonte
  /// final resultado = await baixador(senha: '17PI.QZNQ.HYQU.CYMM');
  /// ```
  static Future<void> limparCachePorSenha(String senha) =>
      NfeCacheConfig.limparCachePorSenha(senha);

  /// Executa download com auto-dispose (callable)
  ///
  /// Esta é a forma recomendada de usar o baixador. Os recursos são
  /// liberados automaticamente após a execução.
  ///
  /// [senha] é a senha formatada (ex: "ABCD1234567890")
  /// [baixarBytes] determina se deve baixar os bytes reais do PDF (padrão: false)
  /// [tempoLimite] define o tempo máximo para aguardar toda a operação
  ///
  /// Retorna [Map<String, dynamic>] contendo:
  /// - `urlDownload`: URL de download do PDF
  /// - `idDocumento`: ID do documento
  /// - `tamanho`: Tamanho em bytes do PDF
  /// - `bytes`: Bytes do PDF (Uint8List) - null se baixarBytes=false
  /// - `bytesBase64`: Bytes em base64 - null se baixarBytes=false
  /// - `salvar`: Função para salvar o PDF - null se baixarBytes=false
  ///   - Sem parâmetro: salva como "{idDocumento}.pdf"
  ///   - Com nome: salva com nome customizado (adiciona .pdf se necessário)
  ///
  /// Use a extension [NfeResultExtension] para acesso type-safe aos campos.
  ///
  /// Lança [ExcecaoSenhaInvalida] se a senha for inválida
  /// Lança [ExcecaoDocumentoNaoEncontrado] se o documento não for encontrado
  /// Lança [ExcecaoTempoEsgotadoCaptcha] se a resolução do captcha expirar
  /// Lança [ExcecaoAntiCaptcha] se a API Anti-Captcha falhar
  /// Lança [ExcecaoApiNfe] para outros erros da API NFe-Cidades
  /// Lança [ExcecaoRede] para erros relacionados à rede
  /// Lança [ExcecaoTempoEsgotado] se a operação expirar
  Future<Map<String, dynamic>> call({
    required String senha,
    bool baixarBytes = false,
    Duration? tempoLimite,
  }) async {
    final executor = _BaixadorNfeExecutor(
      chaveApiAntiCaptcha: chaveApiAntiCaptcha,
    );
    try {
      return await executor.baixarNfe(
        senha: senha,
        baixarBytes: baixarBytes,
        tempoLimite: tempoLimite,
      );
    } finally {
      executor.liberar();
    }
  }

  /// Cria executor reutilizável (uso avançado)
  ///
  /// Use este método quando precisar fazer múltiplos downloads reutilizando
  /// as mesmas conexões HTTP. Requer chamada manual de `.liberar()`.
  ///
  /// Exemplo:
  /// ```dart
  /// final executor = baixador.criarExecutor();
  /// try {
  ///   final r1 = await executor.baixarNfe(senha: 'ABC');
  ///   final r2 = await executor.baixarNfe(senha: 'DEF');
  /// } finally {
  ///   executor.liberar();
  /// }
  /// ```
  NfeExecutor criarExecutor() {
    return _BaixadorNfeExecutor(
      chaveApiAntiCaptcha: chaveApiAntiCaptcha,
    );
  }
}

/// Implementação interna do executor de downloads (reutilizável)
///
/// Esta classe contém a implementação real do download de NFe.
/// Usuários normais devem usar a classe [BaixadorNfeCidades] callable.
class _BaixadorNfeExecutor implements NfeExecutor {
  final String chaveApiAntiCaptcha;
  final ClienteAntiCaptcha _clienteCaptcha;
  final ClienteApiNfe _clienteNfe;
  late final NfeCacheManager _cacheManager;

  /// Cria uma nova instância do executor
  ///
  /// [dio] é opcional - forneça uma instância Dio personalizada se necessário
  _BaixadorNfeExecutor({required this.chaveApiAntiCaptcha, Dio? dio})
      : _clienteCaptcha = ClienteAntiCaptcha(chaveApi: chaveApiAntiCaptcha, dio: dio),
        _clienteNfe = ClienteApiNfe(dio: dio) {
    _cacheManager = NfeCacheManager();
  }

  /// Baixa um documento NFe usando a senha fornecida
  ///
  /// Retorna Map com dados do download. Use [NfeResultExtension] para
  /// acesso type-safe.
  @override
  Future<Map<String, dynamic>> baixarNfe({
    required String senha,
    bool baixarBytes = false,
    Duration? tempoLimite,
  }) async {
    final tempoLimiteEfetivo = tempoLimite ?? ConstantesNfe.tempoLimitePadrao;

    try {
      return await Future.any([
        _baixarNfeComCache(senha: senha, baixarBytes: baixarBytes),
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

  /// Baixa NFe com suporte a cache
  ///
  /// Verifica se cache está habilitado e se existe entrada cacheada.
  /// Se sim, retorna do cache. Caso contrário, busca da fonte e cacheia.
  Future<Map<String, dynamic>> _baixarNfeComCache({
    required String senha,
    required bool baixarBytes,
  }) async {
    // 1. Verificar se cache está habilitado
    if (!NfeCacheConfig.usarCache) {
      return await _baixarNfeInterno(senha: senha, baixarBytes: baixarBytes);
    }

    // 2. Tentar obter do cache
    final entryCache = await _cacheManager.obter(senha);

    if (entryCache != null) {
      // Verificar se cache atende aos requisitos
      // Se baixarBytes=true mas cache não tem bytes, buscar da fonte
      if (baixarBytes && entryCache.bytesBase64 == null) {
        // Cache existe mas sem bytes - buscar da fonte
        final resultado = await _baixarNfeInterno(senha: senha, baixarBytes: baixarBytes);

        // Atualizar cache com bytes
        unawaited(_cacheManager.salvar(senha, resultado).catchError((erro) {
          assert(() {
            print('[BaixadorNfe] Erro ao atualizar cache: $erro');
            return true;
          }());
        }));

        return resultado;
      }

      // Cache HIT - retornar do cache
      return entryCache.paraResultado(baixarBytes: baixarBytes);
    }

    // 3. Cache MISS - buscar da fonte
    final resultado = await _baixarNfeInterno(senha: senha, baixarBytes: baixarBytes);

    // 4. Salvar no cache (fire-and-forget, não bloqueia retorno)
    unawaited(_cacheManager.salvar(senha, resultado).catchError((erro) {
      // Log apenas - falha no cache é transparente
      assert(() {
        print('[BaixadorNfe] Erro ao salvar cache: $erro');
        return true;
      }());
    }));

    return resultado;
  }

  /// Implementação interna do processo de download
  Future<Map<String, dynamic>> _baixarNfeInterno({
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
    String? bytesBase64;

    if (baixarBytes) {
      bytesPdf = await _clienteNfe.baixarPdf(idDocumento);
      bytesBase64 = base64Encode(bytesPdf);
    }

    // Criar função de salvar com parâmetro opcional nomeado
    Future<void> Function({String? nome})? funcaoSalvar;
    if (bytesPdf != null) {
      // Capturar valor não-nulo para uso na closure
      final bytesNaoNulos = bytesPdf;
      funcaoSalvar = ({String? nome}) async {
        // Se não fornecido, usa o ID do documento
        // Se fornecido sem extensão .pdf, adiciona automaticamente
        final nomeArquivo = (nome == null || nome.isEmpty)
            ? '$idDocumento.pdf'
            : (!nome.toLowerCase().endsWith('.pdf'))
                ? '$nome.pdf'
                : nome;

        await NfeFileSaver.salvar(
          bytes: bytesNaoNulos,
          nomeArquivo: nomeArquivo,
          caminho: null,
        );
      };
    }

    // Retornar Map com todos os dados
    return {
      'urlDownload': urlDownload,
      'idDocumento': idDocumento,
      'tamanho': bytesPdf?.length ?? 0,
      'bytes': bytesPdf,
      'bytesBase64': bytesBase64,
      'salvar': funcaoSalvar,
    };
  }

  /// Libera todos os recursos
  ///
  /// Chame isso quando terminar de usar o executor
  @override
  void liberar() {
    _clienteCaptcha.liberar();
    _clienteNfe.liberar();
  }
}
