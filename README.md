# Champions Roku (Dev)

## Build zip
From PowerShell:
```powershell
cd C:\Champions-Roku
.\scripts\package.ps1
```

Output:
- `C:\Champions-Roku\dist\champions-roku.zip`

## Save dev password (local only)
This stores your Roku dev-mode password encrypted with Windows DPAPI in:
- `.secrets\roku_dev_password.txt` (gitignored)

```powershell
cd C:\Champions-Roku
.\scripts\set-dev-password.ps1
```

## Sync gateway APP_TOKEN (build-time only)
Reads `APP_TOKEN` from your gateway VM (SSH) and stores it locally (gitignored).

Runtime API base defaults to:
- `https://api.champions.place`

```powershell
cd C:\Champions-Roku
.\scripts\sync-gateway.ps1
```

Optional (LAN base for debugging only):
```powershell
.\scripts\sync-gateway.ps1 -WriteApiBase
```

## Install on Roku (dev mode)
1. Open the Roku dev installer in browser (example from your screenshot):
   - `http://192.168.0.39`
2. Upload `dist\champions-roku.zip`
3. Click "Install with zip"

If install succeeds, you should see a screen: "Champions (Roku Dev)".

### Install via script (avoids browser blank page)
```powershell
cd C:\Champions-Roku
.\scripts\package.ps1
.\scripts\install.ps1
```

## Screenshot (fast UI iteration)
```powershell
cd C:\Champions-Roku
.\scripts\screenshot.ps1
```

Output:
- `C:\Champions-Roku\dist\dev.jpg`

## One command dev cycle (assets -> package -> install -> screenshot)
```powershell
cd C:\Champions-Roku
.\scripts\dev-cycle.ps1
```
