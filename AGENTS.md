# Champions Roku (Dev Notes)

Este repositorio eh um app Roku (SceneGraph/BrightScript) para o projeto Champions.

## Roku (sideload)

- IP padrao do device: `192.168.0.39`
- Usuario (Digest auth): `rokudev`
- Paginas uteis:
  - Installer: `http://192.168.0.39/plugin_install`
  - Inspect (screenshot/logs): `http://192.168.0.39/plugin_inspect`

## Senha do Dev Mode (sem commitar segredo)

Nao coloque a senha em arquivo versionado.

Este projeto salva a senha localmente (apenas nesta maquina/usuario Windows) em:

- `.secrets/roku_dev_password.txt` (DPAPI SecureString)

Como configurar/atualizar a senha local:

```powershell
cd C:\Champions-Roku
.\scripts\set-dev-password.ps1
```

Alternativa (temporaria, nao salva em disco):

```powershell
$env:ROKU_DEV_PASSWORD = 'SUA_SENHA_AQUI'
```

## APP_TOKEN (gateway)

O app precisa do `APP_TOKEN` do gateway para assinar/autorizar requests.

- Arquivo local: `.secrets/gateway_app_token.txt` (gitignored)
- O `scripts/package.ps1` injeta esse token dentro do ZIP em `source/secrets.brs` (auto-gerado no stage).

Para sincronizar automaticamente (requer SSH para a VM/gateway):

```powershell
cd C:\Champions-Roku
.\scripts\sync-gateway.ps1
```

## Loop de desenvolvimento (Windows / PowerShell)

Build + install + screenshot:

```powershell
cd C:\Champions-Roku
.\scripts\dev-cycle.ps1
```

Artefatos:

- ZIP: `dist/champions-roku.zip`
- Screenshot: `dist/dev.jpg`

## Observacao

Os scripts `install.ps1` e `screenshot.ps1` usam Digest auth e podem falhar as vezes se o Roku reiniciar a UI; tente novamente (o `install.ps1` ja tem retries).

