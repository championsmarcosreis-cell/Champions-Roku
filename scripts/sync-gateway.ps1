param(
  [string]$GatewaySsh = 'amaro@192.168.0.35',
  [string]$RemoteEnvPath = '/srv/champions-gateway/.env',
  [string]$OutTokenPath = (Join-Path (Split-Path -Parent $PSScriptRoot) '.secrets\\gateway_app_token.txt'),
  [switch]$WriteApiBase,
  [string]$OutApiBasePath = (Join-Path (Split-Path -Parent $PSScriptRoot) '.secrets\\api_base.txt'),
  [string]$Scheme = 'http'
)

$ErrorActionPreference = 'Stop'

function Unquote([string]$s) {
  if ($null -eq $s) { return '' }
  $t = $s.Trim()
  if ($t.Length -ge 2) {
    $first = $t[0]
    $last = $t[$t.Length - 1]
    $dq = [char]34
    $sq = [char]39
    if (($first -eq $dq -and $last -eq $dq) -or ($first -eq $sq -and $last -eq $sq)) {
      return $t.Substring(1, $t.Length - 2)
    }
  }
  return $t
}

Write-Host "Reading APP_TOKEN from ${GatewaySsh}:$RemoteEnvPath"
$remoteCmd = "grep -m1 '^APP_TOKEN=' $RemoteEnvPath | cut -d= -f2-"

$token = & ssh -o BatchMode=yes -o ConnectTimeout=5 $GatewaySsh $remoteCmd
$token = Unquote $token

if ([string]::IsNullOrWhiteSpace($token)) {
  throw "Could not read APP_TOKEN from $RemoteEnvPath"
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $OutTokenPath) | Out-Null
Set-Content -Path $OutTokenPath -Value $token -NoNewline

Write-Host "OK: saved gateway APP_TOKEN to $OutTokenPath (gitignored)"

if ($WriteApiBase) {
  # Optional: save API base using the gateway host + PORT from .env (handy for LAN builds).
  try {
    $remotePortCmd = "grep -m1 '^PORT=' $RemoteEnvPath | cut -d= -f2-"
    $port = & ssh -o BatchMode=yes -o ConnectTimeout=5 $GatewaySsh $remotePortCmd
    $port = (Unquote $port).Trim()
  } catch {
    $port = ''
  }

  if ([string]::IsNullOrWhiteSpace($port)) { $port = '3000' }

  $gatewayHost = $GatewaySsh
  if ($gatewayHost -match '@') { $gatewayHost = $gatewayHost.Split('@')[-1] }
  $gatewayHost = $gatewayHost.Trim()

  if (-not [string]::IsNullOrWhiteSpace($gatewayHost)) {
    $apiBase = ('{0}://{1}:{2}' -f $Scheme, $gatewayHost, $port)
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $OutApiBasePath) | Out-Null
    Set-Content -Path $OutApiBasePath -Value $apiBase -NoNewline
    Write-Host "OK: saved gateway API base to $OutApiBasePath -> $apiBase"
  }
}
