# NFe Cidades Download

📦 Pacote **Dart/Flutter** para download de NFe de [nfe-cidades.com.br](https://www.nfe-cidades.com.br)

## ✨ Características Principais

- 🔄 **Auto-dispose automático** - Recursos liberados automaticamente
- 🌐 **API unificada** - Mesma API funciona em Web, Mobile e Desktop
- 📦 **Dart puro** - Funciona sem dependência do Flutter SDK
- 📄 **Retorno Map/JSON** - Flexível e fácil de trabalhar
- 💾 **Salvamento integrado** - Salva PDFs em todas as plataformas

## Características

- ✅ Funciona em **todas as plataformas**: Web, Mobile (Android/iOS), Desktop (Windows/macOS/Linux)
- ✅ **Dart puro** - não requer Flutter (mas funciona perfeitamente com Flutter também)
- ✅ **Auto-dispose** - recursos liberados automaticamente, sem `finally` necessário
- ✅ Resolve reCAPTCHA v2 automaticamente usando Anti-Captcha
- ✅ Retorna URL de download + bytes do PDF
- ✅ Salvamento de arquivos multiplataforma integrado
- ✅ Timeout configurável
- ✅ Gerenciamento automático de cookies de sessão
- ✅ Exceções específicas para diferentes tipos de erro
- ✅ Type-safe com extensions para Map

## Pré-requisitos

1. **Chave da API Anti-Captcha**: Crie uma conta em [anti-captcha.com](https://anti-captcha.com) e obtenha sua chave de API
2. **Créditos Anti-Captcha**: O serviço cobra aproximadamente $1.00 por 1000 captchas resolvidos
3. **Senha da NFe**: A senha formatada da nota fiscal (ex: `ABCD1234567890`)

## Instalação

```yaml
dependencies:
  nfe_cidades_download: ^1.0.0
```

```bash
dart pub get  # ou flutter pub get
```

## Uso Básico (Recomendado)

```dart
import 'package:nfe_cidades_download/nfe_cidades_download.dart';

void main() async {
  final baixador = BaixadorNfeCidades(
    chaveApiAntiCaptcha: 'SUA_CHAVE_API',
  );

  // Auto-dispose automático! Sem finally necessário!
  final resultado = await baixador(
    senha: 'ABCD1234567890',
    baixarBytes: true,
  );

  print('URL: ${resultado.urlDownload}');
  print('ID: ${resultado.idDocumento}');
  print('Tamanho: ${resultado.tamanho} bytes');

  // Salvar funciona em TODAS as plataformas:
  // - Web: dispara download no browser
  // - Nativo: salva no diretório atual (ou caminho customizado)
  await resultado.salvar!('nota_fiscal.pdf');

  print('PDF salvo com sucesso!');
}
```

## Funcionalidades

### 🔄 Auto-Dispose Automático

Os recursos são liberados automaticamente após cada operação. Não é necessário usar `try/finally` com `baixador.liberar()`:

```dart
final baixador = BaixadorNfeCidades(chaveApiAntiCaptcha: key);
final resultado = await baixador(senha: senha, baixarBytes: true);
print(resultado.urlDownload);
// Recursos liberados automaticamente!
```

### 🌐 API Unificada Multiplataforma

Uma única API que funciona em todas as plataformas, sem código específico:

```dart
// Funciona em Web, Mobile e Desktop!
final resultado = await baixador(
  senha: 'ABC123',
  baixarBytes: true,
);

// Salvamento automático por plataforma
await resultado.salvar!('nota.pdf');
// Web: dispara download do browser
// Nativo: salva no diretório atual
```

### 📄 Retorno Map/JSON Flexível

O retorno é um `Map<String, dynamic>` com type-safety via extensions:

```dart
final resultado = await baixador(senha: '...', baixarBytes: true);

// Acesso type-safe com extensions (recomendado)
String url = resultado.urlDownload;     // String
String id = resultado.idDocumento;      // String
int tamanho = resultado.tamanho;        // int
Uint8List? bytes = resultado.bytes;     // Uint8List?
String? base64 = resultado.bytesBase64; // String?

// Acesso direto ao Map (também funciona)
print(resultado['urlDownload']);
print(resultado['tamanho']);

// Fácil serialização para JSON
final json = {
  'urlDownload': resultado.urlDownload,
  'idDocumento': resultado.idDocumento,
  'tamanho': resultado.tamanho,
  'bytesBase64': resultado.bytesBase64,
};
```

### 💾 Salvamento de Arquivos Integrado

```dart
final resultado = await baixador(senha: '...', baixarBytes: true);

// Salvamento padrão
await resultado.salvar!(null);  // Salva como {idDocumento}.pdf

// Caminho customizado (apenas plataformas nativas)
await resultado.salvar!('/Downloads/minha_nota.pdf');

// Na web: sempre dispara download do browser (caminho é ignorado)
// Em mobile/desktop: salva no caminho especificado
```

### 📦 Uso Avançado (Reutilizável)

Para múltiplos downloads reutilizando conexões:

```dart
final baixador = BaixadorNfeCidades(chaveApiAntiCaptcha: 'SUA_CHAVE');
final executor = baixador.criarExecutor();

try {
  final r1 = await executor.baixarNfe(senha: 'ABC123', baixarBytes: true);
  final r2 = await executor.baixarNfe(senha: 'DEF456', baixarBytes: true);
  final r3 = await executor.baixarNfe(senha: 'GHI789', baixarBytes: true);

  await r1['salvar']!('nota1.pdf');
  await r2['salvar']!('nota2.pdf');
  await r3['salvar']!('nota3.pdf');
} finally {
  executor.liberar(); // Cleanup manual apenas neste caso
}
```

## Estrutura do Resultado

```dart
{
  'urlDownload': 'https://www.nfe-cidades.com.br/relatorioNotaFiscal.action?id=...',
  'idDocumento': '123456789',
  'tamanho': 45678,  // bytes
  'bytes': Uint8List(...),  // null se baixarBytes=false
  'bytesBase64': 'JVBERi0xLj...',  // null se baixarBytes=false
  'salvar': (caminho) async { ... }  // null se baixarBytes=false
}
```

## Tratamento de Erros

```dart
try {
  final resultado = await baixador(senha: 'ABC123', baixarBytes: true);
  await resultado.salvar!('nota.pdf');
} on ExcecaoSenhaInvalida catch (e) {
  print('Senha inválida: ${e.message}');
} on ExcecaoDocumentoNaoEncontrado catch (e) {
  print('Documento não encontrado: ${e.message}');
} on ExcecaoTempoEsgotadoCaptcha catch (e) {
  print('Timeout ao resolver captcha: ${e.message}');
} on ExcecaoAntiCaptcha catch (e) {
  print('Erro na API Anti-Captcha: ${e.message}');
} on ExcecaoRede catch (e) {
  print('Erro de rede: ${e.message}');
} on ExcecaoNfe catch (e) {
  print('Erro genérico: ${e.message}');
}
```

## Timeout Customizado

```dart
final resultado = await baixador(
  senha: 'ABC123',
  baixarBytes: true,
  tempoLimite: Duration(minutes: 5), // Padrão: 3 minutos
);
```

## Compatibilidade de Plataformas

| Plataforma | Suportado | Salvamento de Arquivos |
|-----------|-----------|------------------------|
| Web | ✅ | Download via browser |
| Android | ✅ | Salva no sistema de arquivos |
| iOS | ✅ | Salva no sistema de arquivos |
| Windows | ✅ | Salva no sistema de arquivos |
| macOS | ✅ | Salva no sistema de arquivos |
| Linux | ✅ | Salva no sistema de arquivos |

**Nota**: O pacote funciona em **Dart puro** (sem Flutter) e em projetos Flutter.

## API

### Classe Callable

A classe `BaixadorNfeCidades` é callable, permitindo uso direto:

```dart
final resultado = await baixador(senha: 'ABC123', baixarBytes: true);
```

### Retorno Map com Extensions

O resultado é um `Map<String, dynamic>` com extensions para type-safety:

```dart
// Acesso type-safe (recomendado)
String url = resultado.urlDownload;
int tamanho = resultado.tamanho;

// Acesso direto ao Map
print(resultado['urlDownload']);
```

## Exemplos Completos

Veja a pasta [example/](example/) para exemplos completos de uso.

## Limitações

1. **Créditos Anti-Captcha**: Requer créditos pagos no serviço Anti-Captcha
2. **Tempo de Processamento**: Resolução de captcha pode levar 10-30 segundos
3. **Web - Salvamento**: Na web, o arquivo sempre vai para a pasta de Downloads do browser (limitação do navegador)

## Suporte

- 📫 Issues: [GitHub Issues](https://github.com/MarlonSantosDev/nfe_cidades_download/issues)
- 📖 Documentação: [API Docs](https://pub.dev/documentation/nfe_cidades_download/latest/)

## Licença

MIT License - veja [LICENSE](LICENSE) para detalhes.

## Créditos

Este pacote utiliza:
- [dio](https://pub.dev/packages/dio) - Cliente HTTP
- [Anti-Captcha](https://anti-captcha.com) - Serviço de resolução de captchas
- [web](https://pub.dev/packages/web) - Interoperabilidade com APIs web

---

**Nota**: Este pacote não é afiliado ao portal nfe-cidades.com.br ou ao serviço Anti-Captcha.
