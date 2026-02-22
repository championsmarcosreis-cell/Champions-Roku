param(
  [string]$RokuIp = '192.168.0.39',
  [string]$Username = 'rokudev'
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot

Write-Host '1/4 Generate assets'
& (Join-Path $PSScriptRoot 'generate-assets.ps1')

Write-Host '2/4 Package zip'
& (Join-Path $PSScriptRoot 'package.ps1')

Write-Host '3/4 Install on Roku'
$installOk = $true
$installErr = $null
try {
  & (Join-Path $PSScriptRoot 'install.ps1') -RokuIp $RokuIp -Username $Username
} catch {
  $installOk = $false
  $installErr = $_
  Write-Warning "Install failed or did not confirm success: $($_.Exception.Message)"
}

Start-Sleep -Seconds 2

Write-Host '4/4 Screenshot'
& (Join-Path $PSScriptRoot 'screenshot.ps1') -RokuIp $RokuIp -Username $Username

Write-Host ("OK: latest screenshot at {0}" -f (Join-Path $root 'dist\\dev.png'))
Write-Host ("(also saved JPEG at {0})" -f (Join-Path $root 'dist\\dev.jpg'))

if (-not $installOk) {
  throw "Install did not confirm success. Screenshot captured for inspection."
}
