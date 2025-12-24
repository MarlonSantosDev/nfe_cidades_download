/// Requisição de criação de tarefa Anti-Captcha
///
/// Esta classe representa uma requisição para criar uma nova tarefa de resolução de reCAPTCHA v2
/// no serviço Anti-Captcha. É usada internamente por [ClienteAntiCaptcha].
class RequisicaoCriarTarefaAntiCaptcha {
  final String chaveCliente;
  final TarefaRecaptchaV2SemProxy tarefa;

  RequisicaoCriarTarefaAntiCaptcha(
      {required this.chaveCliente, required this.tarefa});

  Map<String, dynamic> paraJson() => {
        'clientKey': chaveCliente,
        'task': tarefa.paraJson(),
      };
}

/// Tipo de tarefa RecaptchaV2TaskProxyless
///
/// Representa uma configuração de tarefa reCAPTCHA v2 para o serviço Anti-Captcha.
/// Este tipo de tarefa resolve desafios reCAPTCHA v2 sem usar um proxy.
class TarefaRecaptchaV2SemProxy {
  final String tipo = 'RecaptchaV2TaskProxyless';
  final String urlSite;
  final String chaveSite;

  TarefaRecaptchaV2SemProxy({
    required this.urlSite,
    required this.chaveSite,
  });

  Map<String, dynamic> paraJson() => {
        'type': tipo,
        'websiteURL': urlSite,
        'websiteKey': chaveSite,
      };
}

/// Resposta de criação de tarefa Anti-Captcha
///
/// Representa a resposta da API Anti-Captcha ao criar uma nova tarefa.
/// Contém o ID da tarefa se bem-sucedida, ou informações de erro se falhou.
class RespostaCriarTarefaAntiCaptcha {
  final int? idErro;
  final String? codigoErro;
  final String? descricaoErro;
  final int? idTarefa;

  RespostaCriarTarefaAntiCaptcha({
    this.idErro,
    this.codigoErro,
    this.descricaoErro,
    this.idTarefa,
  });

  factory RespostaCriarTarefaAntiCaptcha.deJson(Map<String, dynamic> json) {
    return RespostaCriarTarefaAntiCaptcha(
      idErro: json['errorId'] as int?,
      codigoErro: json['errorCode'] as String?,
      descricaoErro: json['errorDescription'] as String?,
      idTarefa: json['taskId'] as int?,
    );
  }

  bool get temErro => idErro != null && idErro! > 0;
}

/// Requisição de obtenção de resultado de tarefa Anti-Captcha
///
/// Representa uma requisição para recuperar o resultado de uma tarefa de resolução de captcha
/// do serviço Anti-Captcha.
class RequisicaoObterResultadoAntiCaptcha {
  final String chaveCliente;
  final int idTarefa;

  RequisicaoObterResultadoAntiCaptcha(
      {required this.chaveCliente, required this.idTarefa});

  Map<String, dynamic> paraJson() =>
      {'clientKey': chaveCliente, 'taskId': idTarefa};
}

/// Resposta de obtenção de resultado de tarefa Anti-Captcha
///
/// Representa a resposta da API Anti-Captcha ao recuperar resultados de tarefas.
/// Contém o token de solução do captcha quando pronto, ou informações de status
/// se ainda estiver processando.
class RespostaObterResultadoAntiCaptcha {
  final int? idErro;
  final String? codigoErro;
  final String? descricaoErro;
  final String? status; // 'processing' ou 'ready'
  final Map<String, dynamic>? solucao;

  RespostaObterResultadoAntiCaptcha({
    this.idErro,
    this.codigoErro,
    this.descricaoErro,
    this.status,
    this.solucao,
  });

  factory RespostaObterResultadoAntiCaptcha.deJson(Map<String, dynamic> json) {
    return RespostaObterResultadoAntiCaptcha(
      idErro: json['errorId'] as int?,
      codigoErro: json['errorCode'] as String?,
      descricaoErro: json['errorDescription'] as String?,
      status: json['status'] as String?,
      solucao: json['solution'] as Map<String, dynamic>?,
    );
  }

  bool get temErro => idErro != null && idErro! > 0;
  bool get estaPronto => status == 'ready';
  bool get estaProcessando => status == 'processing';
  String? get respostaRecaptcha => solucao?['gRecaptchaResponse'] as String?;
}
