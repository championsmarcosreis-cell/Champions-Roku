param(
  [string]$PasswordFile = (Join-Path (Split-Path -Parent $PSScriptRoot) '.secrets\\roku_dev_password.txt')
)

$ErrorActionPreference = 'Stop'

$dir = Split-Path -Parent $PasswordFile
New-Item -ItemType Directory -Force -Path $dir | Out-Null

$secure = Read-Host -Prompt 'Roku dev password' -AsSecureString
$enc = $secure | ConvertFrom-SecureString

Set-Content -Path $PasswordFile -Value $enc -NoNewline

Write-Host "OK: saved encrypted password to $PasswordFile"
Write-Host "Note: This file is DPAPI-encrypted (tied to your Windows user) and is gitignored."
