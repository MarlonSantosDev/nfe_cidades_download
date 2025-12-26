import 'dart:convert';
import 'nfe_cache_model.dart';
import 'nfe_cache_storage.dart';

/// Gerenciador de cache de NFes
///
/// Esta classe orquestra as operações de cache, incluindo leitura,
/// escrita e limpeza. Implementa tratamento transparente de erros:
/// falhas no cache não afetam o fluxo principal de download.
class NfeCacheManager {
  final NfeCacheStorage _storage;

  /// Cria um novo gerenciador de cache
  ///
  /// [storage] é opcional - útil para injeção de dependência em testes
  NfeCacheManager({NfeCacheStorage? storage})
      : _storage = storage ?? NfeCacheStorage();

  /// Obtém entrada do cache para uma senha específica
  ///
  /// [senha] é a senha da NFe usada como chave
  /// Retorna [NfeCacheEntry] se encontrado, null caso contrário
  ///
  /// Falhas são tratadas de forma transparente: erros retornam null
  Future<NfeCacheEntry?> obter(String senha) async {
    try {
      final chave = _gerarChave(senha);
      final jsonString = await _storage.ler(chave);

      if (jsonString == null) {
        return null; // Cache miss
      }

      // Deserializar JSON
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return NfeCacheEntry.deJson(json);
    } catch (erro, stackTrace) {
      // Falha no cache é transparente - log e retorna null (cache miss)
      _logErro('Erro ao obter cache para senha $senha', erro, stackTrace);
      return null;
    }
  }

  /// Salva resultado no cache
  ///
  /// [senha] é a senha da NFe usada como chave
  /// [resultado] é o Map retornado por baixarNfe()
  ///
  /// Falhas são tratadas de forma transparente: erros apenas logam
  Future<void> salvar(String senha, Map<String, dynamic> resultado) async {
    try {
      // Converter resultado para modelo cacheável
      final entry = NfeCacheEntry.deResultado(resultado);

      // Serializar para JSON
      final json = jsonEncode(entry.paraJson());

      // Salvar no storage
      final chave = _gerarChave(senha);
      await _storage.escrever(chave, json);
    } catch (erro, stackTrace) {
      // Falha ao salvar é transparente - apenas log
      _logErro('Erro ao salvar cache para senha $senha', erro, stackTrace);
    }
  }

  /// Remove entrada específica do cache
  ///
  /// [senha] é a senha da NFe cuja entrada deve ser removida
  Future<void> remover(String senha) async {
    try {
      final chave = _gerarChave(senha);
      await _storage.remover(chave);
    } catch (erro, stackTrace) {
      _logErro('Erro ao remover cache para senha $senha', erro, stackTrace);
    }
  }

  /// Limpa todo o cache armazenado
  ///
  /// Remove todas as entradas de NFes do cache
  Future<void> limparTudo() async {
    try {
      await _storage.limparTudo();
    } catch (erro, stackTrace) {
      _logErro('Erro ao limpar todo o cache', erro, stackTrace);
    }
  }

  /// Gera chave de cache a partir da senha
  ///
  /// Formato: "nfe_cache:{senha}"
  String _gerarChave(String senha) => 'nfe_cache:$senha';

  /// Log de erros apenas em modo debug
  void _logErro(String mensagem, dynamic erro, [StackTrace? stackTrace]) {
    assert(() {
      print('[NfeCacheManager] $mensagem: $erro');
      if (stackTrace != null) {
        print(stackTrace);
      }
      return true;
    }());
  }
}
