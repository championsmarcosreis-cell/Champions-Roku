param(
  [string]$RokuIp = '192.168.0.39',
  [string]$Username = 'rokudev',
  [string]$ZipPath = (Join-Path (Split-Path -Parent $PSScriptRoot) 'dist\\champions-roku.zip'),
  [string]$PasswordFile = (Join-Path (Split-Path -Parent $PSScriptRoot) '.secrets\\roku_dev_password.txt'),
  [int]$Retries = 6,
  [int]$DelaySeconds = 3
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $ZipPath)) {
  throw "ZIP not found: $ZipPath (run scripts\\package.ps1 first)"
}

function Unprotect-SecureStringToPlain([Security.SecureString]$secure) {
  if ($secure -eq $null) { return $null }
  $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
  try { return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
  finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
}

function Get-RokuDevPassword([string]$filePath) {
  if (-not [string]::IsNullOrWhiteSpace($env:ROKU_DEV_PASSWORD)) {
    return $env:ROKU_DEV_PASSWORD
  }

  if ($filePath -and (Test-Path $filePath)) {
    try {
      $enc = (Get-Content -Raw $filePath).Trim()
      if ($enc) {
        $secure = ConvertTo-SecureString $enc
        $plain = Unprotect-SecureStringToPlain $secure
        if (-not [string]::IsNullOrWhiteSpace($plain)) { return $plain }
      }
    } catch {
      Write-Warning "Could not read password file: $filePath"
    }
  }

  $secure = Read-Host -Prompt 'Roku dev password' -AsSecureString
  return Unprotect-SecureStringToPlain $secure
}

$password = Get-RokuDevPassword $PasswordFile
if ([string]::IsNullOrWhiteSpace($password)) {
  throw 'Missing Roku dev password'
}

$url = "http://$RokuIp/plugin_install"

if ($Retries -lt 1) { $Retries = 1 }
if ($DelaySeconds -lt 0) { $DelaySeconds = 0 }

for ($attempt = 1; $attempt -le $Retries; $attempt++) {
  Write-Host "Uploading $ZipPath -> $url (attempt $attempt/$Retries)"
  $html = & curl.exe -sS --max-time 60 --digest -u "$Username`:$password" `
    -F "archive=@$ZipPath" `
    -F "mysubmit=Install" `
    $url

  if ($LASTEXITCODE -ne 0) {
    Write-Warning "curl.exe failed (exit=$LASTEXITCODE)"
    if ($attempt -lt $Retries) { Start-Sleep -Seconds $DelaySeconds }
    continue
  }

  if ($html -match 'Install Success') {
    Write-Host 'OK: Install Success'
    exit 0
  }

  if ($html -match 'Install Failure') {
    $line = ($html | Select-String -Pattern 'Install Failure:[^<]+' -AllMatches | Select-Object -First 1)
    if ($line) {
      throw $line.Matches[0].Value
    }
    throw "Install Failure (open $url in a browser to see details)"
  }

  Write-Warning 'No explicit success/failure found in response.'
  if ($attempt -lt $Retries) { Start-Sleep -Seconds $DelaySeconds }
}

throw "Install did not confirm success after $Retries attempts. Open $url in a browser to inspect."
