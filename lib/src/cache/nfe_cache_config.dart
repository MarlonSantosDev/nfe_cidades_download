import 'nfe_cache_storage.dart';

/// Configuração global do sistema de cache de NFes
///
/// Esta classe fornece controle estático sobre o comportamento do cache,
/// permitindo habilitar/desabilitar e limpar o cache globalmente.
class NfeCacheConfig {
  // Prevenir instanciação
  NfeCacheConfig._();

  /// Flag global para habilitar/desabilitar o cache
  ///
  /// - `true` (padrão): Cache ativado - NFes são armazenadas e retornadas do cache
  /// - `false`: Cache desativado - sempre busca da fonte (Anti-Captcha + API)
  ///
  /// Exemplo:
  /// ```dart
  /// // Desabilitar cache
  /// NfeCacheConfig.usarCache = false;
  ///
  /// // Habilitar cache
  /// NfeCacheConfig.usarCache = true;
  /// ```
  static bool usarCache = true;

  /// Limpa todo o cache armazenado
  ///
  /// Remove todas as entradas de NFes cacheadas do shared_preferences.
  /// Útil para forçar re-download de todos os documentos ou liberar espaço.
  ///
  /// Esta operação:
  /// - Remove apenas chaves com prefixo "nfe_cache:"
  /// - Preserva outros dados do shared_preferences
  /// - É assíncrona e deve ser aguardada
  ///
  /// Exemplo:
  /// ```dart
  /// await NfeCacheConfig.limparCache();
  /// print('Cache limpo com sucesso!');
  /// ```
  static Future<void> limparCache() async {
    final storage = NfeCacheStorage();
    await storage.limparTudo();
  }

  /// Limpa o cache de uma senha específica
  ///
  /// Remove apenas a entrada de cache da senha fornecida, mantendo
  /// todas as outras entradas intactas.
  ///
  /// [senha] é a senha da NFe cujo cache deve ser removido
  ///
  /// Esta operação é útil quando você quer:
  /// - Forçar re-download de uma NFe específica
  /// - Liberar espaço de forma seletiva
  /// - Atualizar dados de uma nota específica
  ///
  /// Exemplo:
  /// ```dart
  /// // Remover cache de uma senha específica
  /// await NfeCacheConfig.limparCachePorSenha('17PI.QZNQ.HYQU.CYMM');
  /// print('Cache da senha removido!');
  ///
  /// // Próxima chamada com essa senha buscará da fonte
  /// final resultado = await baixador(senha: '17PI.QZNQ.HYQU.CYMM');
  /// ```
  static Future<void> limparCachePorSenha(String senha) async {
    final storage = NfeCacheStorage();
    final chave = 'nfe_cache:$senha';
    await storage.remover(chave);
  }
}
