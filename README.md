# NFe Cidades Downloader

Pacote Dart/Flutter para baixar notas fiscais do portal [nfe-cidades.com.br](https://www.nfe-cidades.com.br) usando o serviço [Anti-Captcha](https://anti-captcha.com) para resolver reCAPTCHA v2 automaticamente.

## Características

- ✅ Resolve reCAPTCHA v2 automaticamente usando Anti-Captcha
- ✅ Retorna URL de download direto da NFe
- ✅ Opção para baixar os bytes do PDF automaticamente
- ✅ Timeout configurável
- ✅ Gerenciamento automático de cookies de sessão
- ✅ Exceções específicas para diferentes tipos de erro
- ✅ API simples e fácil de usar
- ✅ **Multiplataforma**: Funciona em Web, Android, iOS, Windows, macOS e Linux

## Pré-requisitos

1. **Chave da API Anti-Captcha**: Você precisa criar uma conta em [anti-captcha.com](https://anti-captcha.com) e obter sua chave de API
2. **Créditos Anti-Captcha**: O serviço cobra aproximadamente $1.00 por 1000 captchas resolvidos
3. **Senha da NFe**: A senha formatada da nota fiscal (ex: `ABCD1234567890`)

## Instalação

Adicione ao seu `pubspec.yaml`:

```yaml
dependencies:
  nfe_cidades_download:  ^0.0.3
```

Execute:
```bash
flutter pub get
```

## Compatibilidade de Plataformas

Este pacote é **totalmente multiplataforma** e funciona em:

- ✅ **Web** (Flutter Web) - **Principal uso do pacote**
- ✅ **Android**
- ✅ **iOS**
- ✅ **Windows**
- ✅ **macOS**
- ✅ **Linux**

O pacote utiliza apenas bibliotecas multiplataforma (`dio`, `cookie_jar`, `dio_cookie_manager`) e não possui dependências específicas de plataforma. 

### Compatibilidade Web

O pacote foi **otimizado para funcionar perfeitamente na web**:

- ✅ Gerenciamento automático de cookies através do navegador (sem necessidade de CookieJar)
- ✅ Suporte completo para download de PDFs no navegador
- ✅ Compatível com CORS e políticas de segurança do navegador
- ✅ Funciona em todos os navegadores modernos (Chrome, Firefox, Safari, Edge)

**Nota sobre Web**: Na web, o salvamento de arquivos requer tratamento especial usando `package:web`. Veja o Exemplo 2 abaixo para código multiplataforma e o [exemplo_web.dart](example/exemplo_web.dart) para um exemplo específico de web.

## Uso Básico

### Exemplo 1: Obter apenas a URL de download

```dart
import 'package:nfe_cidades_download/nfe_cidades_download.dart';

void main() async {
  final downloader = NfeCidadesDownloader(
    antiCaptchaApiKey: 'SUA_CHAVE_API',
  );

  try {
    final result = await downloader.downloadNfe(
      senha: 'ABCD1234567890',
    );

    print('URL: ${result.downloadUrl}');
    print('Document ID: ${result.documentId}');
  } finally {
    downloader.dispose();
  }
}
```

### Exemplo 2: Baixar o PDF completo (Multiplataforma)

```dart
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:nfe_cidades_download/nfe_cidades_download.dart';

void main() async {
  final downloader = NfeCidadesDownloader(
    antiCaptchaApiKey: 'SUA_CHAVE_API',
  );

  try {
    final result = await downloader.downloadNfe(
      senha: 'ABCD1234567890',
      downloadBytes: true,
      timeout: Duration(minutes: 10),
    );

    if (result.pdfBytes != null) {
      if (kIsWeb) {
        // Na web, use a URL para download ou processe os bytes no navegador
        print('PDF baixado! Tamanho: ${result.pdfBytes!.length} bytes');
        print('URL de download: ${result.downloadUrl}');
        // Você pode usar package:web para fazer download
        // Veja exemplo_web.dart para implementação completa
      } else {
        // Em plataformas nativas, salvar em arquivo
        final file = File('nota_fiscal.pdf');
        await file.writeAsBytes(result.pdfBytes!);
        print('PDF salvo: ${file.path}');
      }
    }
  } finally {
    downloader.dispose();
  }
}
```

### Exemplo 3: Uso específico para Web (Flutter Web)

Para aplicações web, veja o exemplo completo em [example/exemplo_web.dart](example/exemplo_web.dart) que demonstra como fazer download de arquivos usando `package:web` (substituição moderna de `dart:html`).

### Exemplo 4: Tratamento completo de erros

```dart
import 'package:nfe_cidades_download/nfe_cidades_download.dart';

void main() async {
  final downloader = NfeCidadesDownloader(
    antiCaptchaApiKey: 'SUA_CHAVE_API',
  );

  try {
    final result = await downloader.downloadNfe(
      senha: 'ABCD1234567890',
    );
    print('Sucesso: ${result.downloadUrl}');
  } on InvalidSenhaException catch (e) {
    print('Senha inválida: $e');
  } on DocumentNotFoundException catch (e) {
    print('Documento não encontrado: $e');
  } on CaptchaTimeoutException catch (e) {
    print('Timeout ao resolver captcha: $e');
  } on AntiCaptchaException catch (e) {
    print('Erro no Anti-Captcha: $e');
  } on NetworkException catch (e) {
    print('Erro de rede: $e');
  } on TimeoutException catch (e) {
    print('Timeout geral: $e');
  } on NfeException catch (e) {
    print('Erro: $e');
  } finally {
    downloader.dispose();
  }
}
```

## API

### Classe Principal: `NfeCidadesDownloader`

#### Construtor
```dart
NfeCidadesDownloader({
  required String antiCaptchaApiKey,
  Dio? dio,
})
```

#### Método: `downloadNfe`
```dart
Future<NfeDownloadResult> downloadNfe({
  required String senha,
  bool downloadBytes = false,
  Duration? timeout,
})
```

**Parâmetros:**
- `senha`: Senha formatada da NFe (ex: `ABCD1234567890`)
- `downloadBytes`: Se `true`, baixa os bytes do PDF (padrão: `false`)
- `timeout`: Timeout máximo para toda a operação (padrão: 5 minutos)

**Retorna:** `NfeDownloadResult` contendo:
- `downloadUrl`: URL para download direto
- `documentId`: ID do documento
- `pdfBytes`: Bytes do PDF (se `downloadBytes` foi `true`)

#### Método: `dispose`
```dart
void dispose()
```
Libera recursos. Sempre chame este método quando terminar de usar o downloader.

## Exceções

| Exceção | Descrição |
|---------|-----------|
| `InvalidSenhaException` | Senha inválida ou captcha rejeitado |
| `DocumentNotFoundException` | Documento não encontrado |
| `CaptchaTimeoutException` | Timeout ao resolver captcha (padrão: 3 minutos) |
| `AntiCaptchaException` | Erro na API Anti-Captcha (verifique créditos/chave) |
| `NetworkException` | Erro de rede/conexão |
| `TimeoutException` | Timeout geral da operação |
| `NfeApiException` | Erro genérico da API NFe-Cidades |

## Fluxo de Funcionamento

1. **Resolve reCAPTCHA** usando Anti-Captcha (10-60 segundos)
2. **Busca documento** via API NFe-Cidades com token do captcha
3. **Extrai ID** do documento da resposta HTML
4. **Gera URL** de download direto
5. **Baixa PDF** (opcional) se `downloadBytes: true`

## Configurações Padrão

- **Timeout total**: 5 minutos
- **Timeout captcha**: 3 minutos
- **Polling captcha**: A cada 2 segundos
- **reCAPTCHA Site Key**: `6Lf9374hAAAAAMorFLzMzomJWlbu0FK92Q25culn`

## Limitações e Considerações

- ⚠️ Requer créditos no Anti-Captcha (~$1 por 1000 captchas)
- ⚠️ O tempo de download varia de acordo com a fila do Anti-Captcha
- ⚠️ A senha deve estar no formato correto da NFe-Cidades
- ⚠️ Respeite os termos de uso do portal NFe-Cidades
- ⚠️ Na web, o salvamento de arquivos requer tratamento especial (use `kIsWeb` para detectar a plataforma)

## Troubleshooting

### Erro: "Invalid senha or captcha token"
- Verifique se a senha está correta
- Tente novamente (o captcha pode ter expirado)

### Erro: "Captcha solving timed out"
- O Anti-Captcha está sobrecarregado, tente novamente
- Aumente o timeout: `timeout: Duration(minutes: 10)`

### Erro: "Failed to create captcha task"
- Verifique se sua chave da API está correta
- Verifique se você tem créditos suficientes

### Erro: "Could not extract document ID"
- O formato do HTML pode ter mudado
- Abra uma issue no GitHub

## Exemplo Completo

Veja o arquivo [example/exemplo.dart](example/exemplo.dart) para um exemplo completo com todos os recursos.

## Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## Aviso Legal

Este pacote é fornecido "como está", sem garantias. Use por sua conta e risco. Certifique-se de estar em conformidade com os termos de uso do portal NFe-Cidades e do serviço Anti-Captcha.
