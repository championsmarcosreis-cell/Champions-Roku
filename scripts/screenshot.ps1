param(
  [string]$RokuIp = '192.168.0.39',
  [string]$Username = 'rokudev',
  [string]$PasswordFile = (Join-Path (Split-Path -Parent $PSScriptRoot) '.secrets\\roku_dev_password.txt'),
  [string]$OutPath = (Join-Path (Split-Path -Parent $PSScriptRoot) 'dist\\dev.jpg'),
  [string]$OutPngPath = ''
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
if ([string]::IsNullOrWhiteSpace($OutPngPath)) {
  $OutPngPath = [System.IO.Path]::ChangeExtension($OutPath, '.png')
}
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $OutPngPath) | Out-Null

$maxAttempts = 5
for ($attempt = 1; $attempt -le $maxAttempts; $attempt++) {
  try {
    # Trigger screenshot
    & curl.exe -sS --max-time 30 --digest -u "$Username`:$password" -F "mysubmit=Screenshot" $inspectUrl | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "curl.exe failed to trigger screenshot (exit=$LASTEXITCODE)" }

    # Fetch image
    & curl.exe -sS --max-time 30 --digest -u "$Username`:$password" -o $OutPath $jpgUrl | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "curl.exe failed to fetch screenshot (exit=$LASTEXITCODE)" }

    $hdr = Get-Content -AsByteStream -TotalCount 2 -Path $OutPath
    if ($hdr.Count -lt 2 -or $hdr[0] -ne 0xFF -or $hdr[1] -ne 0xD8) {
      $previewBytes = Get-Content -AsByteStream -TotalCount 256 -Path $OutPath
      $preview = [System.Text.Encoding]::UTF8.GetString($previewBytes)
      throw "Screenshot fetch did not return a JPEG. First bytes:`n$preview"
    }

    break
  } catch {
    if ($attempt -ge $maxAttempts) { throw }
    Write-Host "WARNING: screenshot attempt $attempt/$maxAttempts failed: $($_.Exception.Message)"
    Start-Sleep -Seconds 2
  }
}

# Convert to PNG for tooling that can't attach JPEGs.
try {
  Add-Type -AssemblyName System.Drawing
  $img = [System.Drawing.Image]::FromFile((Resolve-Path -LiteralPath $OutPath))
  try {
    $img.Save($OutPngPath, [System.Drawing.Imaging.ImageFormat]::Png)
  } finally {
    $img.Dispose()
  }
  Write-Host "OK: $OutPngPath"
} catch {
  Write-Host "WARN: could not convert screenshot to PNG: $($_.Exception.Message)"
}

Write-Host "OK: $OutPath"
