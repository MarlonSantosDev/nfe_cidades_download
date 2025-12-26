import 'package:nfe_cidades_download/nfe_cidades_download.dart';

/// Exemplo de uso do pacote nfe_cidades_download
///
/// Este exemplo demonstra a API v1.0.0 unificada que funciona em todas
/// as plataformas (Web, Mobile, Desktop) com auto-dispose automático
/// e salvamento multiplataforma.
void main() async {
  // Criar instância do baixador
  // Obtenha sua chave em: https://anti-captcha.com
  const baixador = BaixadorNfeCidades(
    chaveApiAntiCaptcha: 'SUA_CHAVE_API_ANTI_CAPTCHA',
  );

  print('🚀 Iniciando download de NFe...\n');

  try {
    // Download com auto-dispose automático!
    // Não é mais necessário usar try/finally com baixador.liberar()
    final resultado = await baixador(
      senha: 'ABCD1234567890', // Substitua pela senha da sua NFe
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
    // - Mobile/Desktop: salva no diretório atual ou caminho customizado
    print('💾 Salvando PDF...');
    await resultado.salvar!('nota_fiscal.pdf');
    print('✅ PDF salvo com sucesso: nota_fiscal.pdf\n');

    // Também pode acessar diretamente como Map
    print('📊 Acesso alternativo via Map:');
    print('   ${resultado['idDocumento']}');
    print('   ${resultado['tamanho']} bytes');

    // Para JSON serialization, use bytesBase64
    if (resultado.bytesBase64 != null) {
      print('\n📦 Bytes disponíveis em base64 para serialização JSON');
    }
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
    chaveApiAntiCaptcha: 'SUA_CHAVE_API',
  );

  // Para múltiplos downloads, use criarExecutor()
  // Isso permite reutilizar as mesmas conexões HTTP
  final executor = baixador.criarExecutor();

  try {
    print('📥 Baixando múltiplas NFes...\n');

    final senhas = ['ABC123', 'DEF456', 'GHI789'];
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
      await resultados[i]['salvar']!('nota_$i.pdf');
      print('   ✅ Salvo: nota_$i.pdf');
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
    chaveApiAntiCaptcha: 'SUA_CHAVE_API',
  );

  final resultado = await baixador(
    senha: 'ABCD1234567890',
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
    chaveApiAntiCaptcha: 'SUA_CHAVE_API',
  );

  try {
    final resultado = await baixador(
      senha: 'ABCD1234567890',
      baixarBytes: true,
      tempoLimite: const Duration(minutes: 5), // Padrão é 3 minutos
    );

    print('Sucesso: ${resultado.idDocumento}');
  } on ExcecaoTempoEsgotado catch (e) {
    print('Operação expirou após 5 minutos: $e');
  }
}
