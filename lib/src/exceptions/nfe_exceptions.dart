/// Exceção base para o baixador de NFe
abstract class ExcecaoNfe implements Exception {
  /// A mensagem de erro
  final String mensagem;

  /// O erro original que causou esta exceção (se houver)
  final dynamic erroOriginal;

  /// O rastreamento de pilha (se disponível)
  final StackTrace? rastreamentoPilha;

  const ExcecaoNfe(this.mensagem, [this.erroOriginal, this.rastreamentoPilha]);

  @override
  String toString() =>
      'ExcecaoNfe: $mensagem${erroOriginal != null ? ' ($erroOriginal)' : ''}';
}

/// Exceção lançada quando a API Anti-Captcha falha
class ExcecaoAntiCaptcha extends ExcecaoNfe {
  /// O código de erro retornado pelo Anti-Captcha
  final String? codigoErro;

  /// Cria uma [ExcecaoAntiCaptcha] com a [mensagem] fornecida.
  ///
  /// Opcionalmente inclui um [codigoErro] da API Anti-Captcha,
  /// [erroOriginal] que causou esta exceção, e [rastreamentoPilha].
  const ExcecaoAntiCaptcha(
    String mensagem, {
    this.codigoErro,
    dynamic erroOriginal,
    StackTrace? rastreamentoPilha,
  }) : super(mensagem, erroOriginal, rastreamentoPilha);

  @override
  String toString() =>
      'ExcecaoAntiCaptcha: $mensagem${codigoErro != null ? ' (código: $codigoErro)' : ''}';
}

/// Exceção lançada quando a resolução do captcha expira
class ExcecaoTempoEsgotadoCaptcha extends ExcecaoNfe {
  /// Cria uma [ExcecaoTempoEsgotadoCaptcha] com a [mensagem] fornecida.
  ///
  /// Opcionalmente inclui [erroOriginal] que causou esta exceção
  /// e [rastreamentoPilha].
  const ExcecaoTempoEsgotadoCaptcha(
    super.mensagem, [
    super.erroOriginal,
    super.rastreamentoPilha,
  ]);

  @override
  String toString() => 'ExcecaoTempoEsgotadoCaptcha: $mensagem';
}

/// Exceção lançada quando a API NFe-Cidades falha
class ExcecaoApiNfe extends ExcecaoNfe {
  /// O código de status HTTP (se aplicável)
  final int? codigoStatus;

  const ExcecaoApiNfe(
    String mensagem, {
    this.codigoStatus,
    dynamic erroOriginal,
    StackTrace? rastreamentoPilha,
  }) : super(mensagem, erroOriginal, rastreamentoPilha);

  @override
  String toString() =>
      'ExcecaoApiNfe: $mensagem${codigoStatus != null ? ' (HTTP $codigoStatus)' : ''}';
}

/// Exceção lançada quando o documento não é encontrado
class ExcecaoDocumentoNaoEncontrado extends ExcecaoApiNfe {
  /// Cria uma [ExcecaoDocumentoNaoEncontrado] com a [mensagem] fornecida.
  ///
  /// Opcionalmente inclui [codigoStatus] da resposta HTTP,
  /// [erroOriginal] que causou esta exceção, e [rastreamentoPilha].
  const ExcecaoDocumentoNaoEncontrado(
    super.mensagem, {
    super.codigoStatus,
    super.erroOriginal,
    super.rastreamentoPilha,
  });

  @override
  String toString() => 'ExcecaoDocumentoNaoEncontrado: $mensagem';
}

/// Exceção lançada quando a senha é inválida
class ExcecaoSenhaInvalida extends ExcecaoApiNfe {
  /// Cria uma [ExcecaoSenhaInvalida] com a [mensagem] fornecida.
  ///
  /// Opcionalmente inclui [codigoStatus] da resposta HTTP,
  /// [erroOriginal] que causou esta exceção, e [rastreamentoPilha].
  const ExcecaoSenhaInvalida(
    super.mensagem, {
    super.codigoStatus,
    super.erroOriginal,
    super.rastreamentoPilha,
  });

  @override
  String toString() => 'ExcecaoSenhaInvalida: $mensagem';
}

/// Exceção lançada para erros relacionados à rede
class ExcecaoRede extends ExcecaoNfe {
  const ExcecaoRede(
    super.mensagem, [
    super.erroOriginal,
    super.rastreamentoPilha,
  ]);

  @override
  String toString() => 'ExcecaoRede: $mensagem';
}

/// Exceção lançada quando a operação expira
class ExcecaoTempoEsgotado extends ExcecaoNfe {
  const ExcecaoTempoEsgotado(
    super.mensagem, [
    super.erroOriginal,
    super.rastreamentoPilha,
  ]);

  @override
  String toString() => 'ExcecaoTempoEsgotado: $mensagem';
}
