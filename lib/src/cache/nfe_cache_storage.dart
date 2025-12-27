// Conditional import: usa shared_preferences do pub.dev quando disponível (Flutter),
// senão usa stub em memória (Dart puro/web sem Flutter)
import 'package:shared_preferences/shared_preferences.dart'
    if (dart.library.html) 'shared_preferences_stub.dart';

/// Abstração sobre shared_preferences para armazenamento de cache
///
/// Esta classe encapsula todas as operações de leitura/escrita no storage,
/// facilitando testes e isolando a implementação do shared_preferences.
class NfeCacheStorage {
  /// Prefixo usado para todas as chaves de cache
  static const String _prefixoCache = 'nfe_cache:';

  /// Lê um valor do storage
  ///
  /// [chave] é a chave completa (incluindo prefixo)
  /// Retorna o valor armazenado ou null se não existir
  Future<String?> ler(String chave) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(chave);
    } catch (e) {
      // Falha ao ler é transparente - retorna null
      _logErro('Erro ao ler chave $chave', e);
      return null;
    }
  }

  /// Escreve um valor no storage
  ///
  /// [chave] é a chave completa (incluindo prefixo)
  /// [valor] é o valor a ser armazenado (JSON string)
  /// Retorna true se salvou com sucesso, false caso contrário
  Future<bool> escrever(String chave, String valor) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(chave, valor);
    } catch (e) {
      // Falha ao escrever é transparente - apenas log
      _logErro('Erro ao escrever chave $chave', e);
      return false;
    }
  }

  /// Remove uma chave específica do storage
  ///
  /// [chave] é a chave completa (incluindo prefixo)
  /// Retorna true se removeu com sucesso, false caso contrário
  Future<bool> remover(String chave) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(chave);
    } catch (e) {
      _logErro('Erro ao remover chave $chave', e);
      return false;
    }
  }

  /// Limpa todas as entradas de cache (apenas chaves com prefixo)
  ///
  /// Remove apenas chaves que começam com [_prefixoCache],
  /// preservando outras chaves do shared_preferences
  Future<void> limparTudo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chaves = prefs.getKeys();

      // Filtrar apenas chaves de cache
      final chavesCache = chaves.where((k) => k.startsWith(_prefixoCache));

      // Remover cada chave de cache
      for (final chave in chavesCache) {
        await prefs.remove(chave);
      }
    } catch (e) {
      _logErro('Erro ao limpar cache', e);
    }
  }

  /// Log de erros apenas em modo debug
  void _logErro(String mensagem, dynamic erro) {
    assert(() {
      print('[NfeCacheStorage] $mensagem: $erro');
      return true;
    }());
  }
}
