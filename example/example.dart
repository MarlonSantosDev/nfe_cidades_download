import 'package:nfe_cidades_download/nfe_cidades_download.dart';

/// Exemplo de uso do pacote nfe_cidades_download
///
/// Este exemplo demonstra a API v1.1.0 unificada que funciona em todas
/// as plataformas (Web, Mobile, Desktop) com auto-dispose automático,
/// salvamento multiplataforma e sistema de cache inteligente.
///
const chaveApiAntiCaptcha = '7112f738d4e027fef1f55db83dc469c5';
const senhaNfe = '17PI.QZNQ.HYQU.CYMM';
void main() async {
  // Criar instância do baixador
  // Obtenha sua chave em: https://anti-captcha.com
  const baixador = BaixadorNfeCidades(
    chaveApiAntiCaptcha: chaveApiAntiCaptcha,
  );

  print('🚀 Iniciando download de NFe...\n');

  try {
    // Download com auto-dispose automático!
    // Não é mais necessário usar try/finally com baixador.liberar()
    final resultado = await baixador(
      senha: senhaNfe, // Substitua pela senha da sua NFe
      baixarBytes: true, // true para baixar o PDF completo
    );

    // Acesso type-safe via extensions
    print('✅ Download concluído com sucesso!\n');
    print('📄 Informações da NFe:');
    print('   URL: ${resultado.urlDownload}');
    print('   ID do Documento: ${resultado.idDocumento}');
    print('   Tamanho: ${resultado.tamanho} bytes\n');

    // Salvamento multiplataforma - funciona em todas as plataformas!
    // - Web: dispara download no browser
    // - Mobile/Desktop: salva no diretório atual
    print('💾 Salvando PDF...');

    // Opção 1: Sem parâmetro - usa o ID do documento como nome (recomendado)
    await resultado.salvar!();
    print('✅ PDF salvo: ${resultado.idDocumento}.pdf');

    // Opção 2: Com nome customizado (extensão .pdf é adicionada automaticamente)
    // await resultado.salvar!(nome: 'nota_fiscal');

    // Opção 3: Com nome e extensão completa
    // await resultado.salvar!(nome: 'minha_nota.pdf');
    print('');
  } on ExcecaoSenhaInvalida catch (e) {
    print('❌ Senha inválida: $e');
  } on ExcecaoDocumentoNaoEncontrado catch (e) {
    print('❌ Documento não encontrado: $e');
  } on ExcecaoTempoEsgotadoCaptcha catch (e) {
    print('❌ Timeout ao resolver captcha: $e');
  } on ExcecaoAntiCaptcha catch (e) {
    print('❌ Erro na API Anti-Captcha: $e');
    print('   Verifique se você tem créditos suficientes em sua conta');
  } on ExcecaoRede catch (e) {
    print('❌ Erro de rede: $e');
  } on ExcecaoNfe catch (e) {
    print('❌ Erro: $e');
  }

  // ✨ Recursos liberados automaticamente!
  // Não é mais necessário chamar baixador.liberar()
  print('\n✨ Recursos liberados automaticamente (auto-dispose)');
}

/// Exemplo avançado: múltiplos downloads reutilizando conexões
void exemploAvancado() async {
  const baixador = BaixadorNfeCidades(
    chaveApiAntiCaptcha: chaveApiAntiCaptcha,
  );

  // Para múltiplos downloads, use criarExecutor()
  // Isso permite reutilizar as mesmas conexões HTTP
  final executor = baixador.criarExecutor();

  try {
    print('📥 Baixando múltiplas NFes...\n');

    final senhas = [senhaNfe, senhaNfe, senhaNfe];
    final resultados = <Map<String, dynamic>>[];

    for (final senha in senhas) {
      print('   Baixando senha: $senha');
      final resultado = await executor.baixarNfe(
        senha: senha,
        baixarBytes: true,
      );
      resultados.add(resultado);
    }

    print('\n💾 Salvando ${resultados.length} PDFs...');
    for (var i = 0; i < resultados.length; i++) {
      // Salva com ID do documento como nome padrão
      await resultados[i]['salvar']!();
      final id = resultados[i]['idDocumento'];
      print('   ✅ Salvo: $id.pdf');
    }

    print('\n✅ Todos os downloads concluídos!');
  } finally {
    // Cleanup manual necessário apenas quando usar criarExecutor()
    executor.liberar();
    print('🧹 Recursos liberados manualmente');
  }
}

/// Exemplo: apenas obter URL sem baixar bytes
void exemploApenasUrl() async {
  const baixador = BaixadorNfeCidades(
    chaveApiAntiCaptcha: chaveApiAntiCaptcha,
  );

  final resultado = await baixador(
    senha: senhaNfe,
    baixarBytes: false, // Não baixa os bytes - apenas URL
  );

  print('URL: ${resultado.urlDownload}');
  print('ID: ${resultado.idDocumento}');

  // resultado.bytes será null
  // resultado.salvar será null
  assert(resultado.bytes == null);
  assert(resultado.salvar == null);

  // Use a URL para download manual se necessário
  print('Use esta URL para download manual');
}

/// Exemplo: timeout customizado
void exemploTimeout() async {
  const baixador = BaixadorNfeCidades(
    chaveApiAntiCaptcha: chaveApiAntiCaptcha,
  );

  try {
    final resultado = await baixador(
      senha: senhaNfe,
      baixarBytes: true,
      tempoLimite: const Duration(minutes: 5), // Padrão é 3 minutos
    );

    print('Sucesso: ${resultado.idDocumento}');
  } on ExcecaoTempoEsgotado catch (e) {
    print('Operação expirou após 5 minutos: $e');
  }
}

/// Exemplo: Sistema de cache
void exemploCache() async {
  const baixador = BaixadorNfeCidades(
    chaveApiAntiCaptcha: chaveApiAntiCaptcha,
  );

  print('⚡ Demonstração do Sistema de Cache\n');

  // Cache está ativado por padrão
  print('📌 Cache Status: ${BaixadorNfeCidades.usarCache ? "Ativado" : "Desativado"}\n');

  print('🔄 Primeira chamada (busca da fonte + salva no cache)...');
  final inicio1 = DateTime.now();
  final resultado1 = await baixador(senha: senhaNfe, baixarBytes: true);
  final duracao1 = DateTime.now().difference(inicio1);
  print('✅ Concluído em ${duracao1.inSeconds}s');
  print('   ID: ${resultado1.idDocumento}\n');

  print('⚡ Segunda chamada (retorna do cache)...');
  final inicio2 = DateTime.now();
  final resultado2 = await baixador(senha: senhaNfe, baixarBytes: true);
  final duracao2 = DateTime.now().difference(inicio2);
  print('✅ Concluído em ${duracao2.inMilliseconds}ms (CACHE HIT!)');
  print('   ID: ${resultado2.idDocumento}\n');

  print('📊 Comparação:');
  print('   Sem cache: ${duracao1.inSeconds}s');
  print('   Com cache: ${duracao2.inMilliseconds}ms');
  print('   Ganho: ${(duracao1.inMilliseconds / duracao2.inMilliseconds).toStringAsFixed(1)}x mais rápido!\n');

  // Desabilitar cache
  print('❌ Desabilitando cache...');
  BaixadorNfeCidades.usarCache = false;
  print('   Cache Status: ${BaixadorNfeCidades.usarCache ? "Ativado" : "Desativado"}\n');

  print('🔄 Terceira chamada (cache desabilitado, busca da fonte)...');
  final inicio3 = DateTime.now();
  final resultado3 = await baixador(senha: senhaNfe, baixarBytes: true);
  final duracao3 = DateTime.now().difference(inicio3);
  print('✅ Concluído em ${duracao3.inSeconds}s');
  print('   ID: ${resultado3.idDocumento}\n');

  // Reabilitar cache
  BaixadorNfeCidades.usarCache = true;

  // Limpar cache de senha específica
  print('🧹 Limpando cache da senha específica...');
  await BaixadorNfeCidades.limparCachePorSenha(senhaNfe);
  print('✅ Cache da senha removido!\n');

  print('🔄 Quarta chamada (cache foi limpo, busca da fonte novamente)...');
  final inicio4 = DateTime.now();
  final resultado4 = await baixador(senha: senhaNfe, baixarBytes: true);
  final duracao4 = DateTime.now().difference(inicio4);
  print('✅ Concluído em ${duracao4.inSeconds}s');
  print('   ID: ${resultado4.idDocumento}\n');

  // Limpar todo o cache
  print('🧹 Limpando todo o cache...');
  await BaixadorNfeCidades.limparCache();
  print('✅ Cache limpo com sucesso!\n');
}
