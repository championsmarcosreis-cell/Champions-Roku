param(
  [string]$RokuIp = '192.168.0.39',
  [string]$Username = 'rokudev',
  [string]$PasswordFile = (Join-Path (Split-Path -Parent $PSScriptRoot) '.secrets\\roku_dev_password.txt'),
  [string]$OutPath = (Join-Path (Split-Path -Parent $PSScriptRoot) 'dist\\dev.jpg')
)

$ErrorActionPreference = 'Stop'

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
    $enc = (Get-Content -Raw $filePath).Trim()
    if ($enc) {
      $secure = ConvertTo-SecureString $enc
      return Unprotect-SecureStringToPlain $secure
    }
  }
  $secure = Read-Host -Prompt 'Roku dev password' -AsSecureString
  return Unprotect-SecureStringToPlain $secure
}

$password = Get-RokuDevPassword $PasswordFile
if ([string]::IsNullOrWhiteSpace($password)) { throw 'Missing Roku dev password' }

$inspectUrl = "http://$RokuIp/plugin_inspect"
$jpgUrl = "http://$RokuIp/pkgs/dev.jpg?time=$([int][DateTimeOffset]::Now.ToUnixTimeSeconds())"

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $OutPath) | Out-Null

# Trigger screenshot
& curl.exe -sS --max-time 30 --digest -u "$Username`:$password" -F "mysubmit=Screenshot" $inspectUrl | Out-Null

# Fetch image
& curl.exe -sS --max-time 30 --digest -u "$Username`:$password" -o $OutPath $jpgUrl | Out-Null

Write-Host "OK: $OutPath"

