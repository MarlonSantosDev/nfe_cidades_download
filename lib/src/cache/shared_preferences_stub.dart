/// Stub para shared_preferences em ambientes sem Flutter
///
/// Esta implementação fornece uma interface compatível mas sem funcionalidade
/// real de persistência. É usada em ambientes Dart puro onde shared_preferences
/// não está disponível.
class SharedPreferences {
  SharedPreferences._();

  static SharedPreferences? _instance;

  /// Retorna uma instância singleton (sempre a mesma)
  static Future<SharedPreferences> getInstance() async {
    _instance ??= SharedPreferences._();
    return _instance!;
  }

  final Map<String, String> _data = {};

  /// Lê uma string do storage (em memória apenas)
  String? getString(String key) => _data[key];

  /// Salva uma string no storage (em memória apenas)
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  /// Remove uma chave do storage
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  /// Retorna todas as chaves
  Set<String> getKeys() => _data.keys.toSet();

  /// Limpa todos os dados
  Future<bool> clear() async {
    _data.clear();
    return true;
  }
}
