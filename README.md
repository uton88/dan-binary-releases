# DAN Binary Releases

Public binary-only distribution for `dan`, `dan-web`, and `dan-token-refresh`.

This repository does not contain the application source code. It only contains:

- cross-platform compiled binaries published in GitHub Releases
- one-click install scripts
- runtime config examples

## Quick Start

Linux or macOS:

```bash
curl -fsSL https://raw.githubusercontent.com/uton88/dan-binary-releases/main/install.sh | bash -s -- \
  --cpa-base-url 'https://gpt-up.example.com/' \
  --cpa-token 'replace-me' \
  --mail-api-url 'https://gpt-mail.example.com/' \
  --mail-api-key 'replace-me' \
  --threads 68
```

Debian or Ubuntu one-click install with systemd:

```bash
curl -fsSL https://raw.githubusercontent.com/uton88/dan-binary-releases/main/install.sh | bash -s -- \
  --systemd \
  --cpa-base-url 'https://gpt-up.example.com/' \
  --cpa-token 'replace-me' \
  --mail-api-url 'https://gpt-mail.example.com/' \
  --mail-api-key 'replace-me' \
  --threads 68
```

No-root Linux one-click install and background run:

```bash
curl -fsSL https://raw.githubusercontent.com/uton88/dan-binary-releases/main/install.sh | bash -s -- \
  --install-dir "$HOME/dan-runtime" \
  --background \
  --cpa-base-url 'https://gpt-up.example.com/' \
  --cpa-token 'replace-me' \
  --mail-api-url 'https://gpt-mail.example.com/' \
  --mail-api-key 'replace-me' \
  --threads 68
```

Windows PowerShell:

```powershell
$p = Join-Path $env:TEMP 'dan-install.ps1'; Invoke-WebRequest 'https://raw.githubusercontent.com/uton88/dan-binary-releases/main/install.ps1' -OutFile $p; & $p -CpaBaseUrl 'https://gpt-up.example.com/' -CpaToken 'replace-me' -MailApiUrl 'https://gpt-mail.example.com/' -MailApiKey 'replace-me' -Threads 68
```

## Default behavior

- installs `dan-web` by default
- downloads the matching binary for the current OS and CPU architecture
- writes `config.json`
- writes `config/web_config.json`
- keeps the domain list and other defaults from the bundled example

## Optional parameters

Linux or macOS installer flags:

- `--component dan-web|dan|dan-token-refresh`
- `--install-dir /path/to/runtime`
- `--version latest|vX.Y.Z`
- `--cpa-base-url URL`
- `--cpa-token TOKEN`
- `--mail-api-url URL`
- `--mail-api-key KEY`
- `--threads 68`
- `--web-token linuxdo`
- `--client-api-token linuxdo`
- `--port 25666`
- `--systemd`
- `--service-name dan-web`
- `--background`
- `--log-file /path/to/dan-web.log`
- `--pid-file /path/to/dan-web.pid`

Windows installer parameters match the same fields:

- `-Component`
- `-InstallDir`
- `-Version`
- `-CpaBaseUrl`
- `-CpaToken`
- `-MailApiUrl`
- `-MailApiKey`
- `-Threads`
- `-WebToken`
- `-ClientApiToken`
- `-Port`

## Release assets

Use the public release assets directly if you do not want the installer:

- `https://github.com/uton88/dan-binary-releases/releases/latest`

The release publishes these binaries:

- `dan` for `windows/linux/darwin` on `amd64/arm64`
- `dan-web` for `windows/linux/darwin` on `amd64/arm64`
- `dan-token-refresh` for `windows/linux/darwin` on `amd64/arm64`
- `SHA256SUMS.txt`

## Config examples

- [config.json.example](./examples/config.json.example)
- [web_config.json.example](./examples/web_config.json.example)
