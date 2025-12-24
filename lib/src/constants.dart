/// Constantes para o baixador de NFe-Cidades
///
/// Esta classe contém todas as constantes usadas pelo baixador de NFe,
/// incluindo endpoints da API, timeouts e valores de configuração.
///
/// Todas as constantes são estáticas e não podem ser instanciadas.
class ConstantesNfe {
  /// Construtor privado para prevenir instanciação
  ConstantesNfe._();

  /// Endpoint da API Anti-Captcha para criar novas tarefas
  static const urlCriarTarefaAntiCaptcha =
      'https://api.anti-captcha.com/createTask';

  /// Endpoint da API Anti-Captcha para recuperar resultados de tarefas
  static const urlObterResultadoAntiCaptcha =
      'https://api.anti-captcha.com/getTaskResult';

  /// URL base do site NFe-Cidades
  static const urlBaseNfe = 'https://www.nfe-cidades.com.br';

  /// Endpoint para buscar documentos por senha
  static const urlBuscarDocumentoNfe =
      '$urlBaseNfe/v2/rest/public/login/buscarDocumento';

  /// Endpoint para recuperar detalhes do documento
  static const urlDocumentosNfe = '$urlBaseNfe/documentos.action';

  /// Endpoint para baixar relatórios PDF
  static const urlRelatorioNfe = '$urlBaseNfe/relatorioNotaFiscal.action';

  /// URL da página inicial do NFe-Cidades
  static const urlPaginaInicialNfe = '$urlBaseNfe/landing-page';

  /// Chave do site reCAPTCHA v2 usada pelo NFe-Cidades
  static const chaveSiteRecaptcha = '6Lf9374hAAAAAMorFLzMzomJWlbu0FK92Q25culn';

  /// String User-Agent usada em requisições HTTP
  static const agenteUsuario =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0';

  /// Timeout padrão para toda a operação de download
  static const tempoLimitePadrao = Duration(minutes: 1);

  /// Intervalo entre requisições de polling para resultados do captcha
  static const intervaloPollingCaptcha = Duration(seconds: 2);

  /// Tempo máximo para aguardar a resolução do captcha
  static const tempoMaximoPollingCaptcha = Duration(minutes: 3);
}
