param(
  [string]$GatewaySsh = 'amaro@192.168.0.35',
  [string]$RtspUrl = 'rtsp://192.168.0.168/0',
  [string]$HlsDir = '/dev/shm/champions-hls/hls',
  [int]$HlsTimeSec = 4,
  [int]$HlsListSize = 60,
  [int]$HttpPort = 8089,
  [switch]$TranscodeAudio
)

$ErrorActionPreference = 'Stop'

function Write-RemoteUnitFile([string]$remotePath, [string]$content) {
  $content | ssh -o BatchMode=yes -o ConnectTimeout=5 $GatewaySsh "sudo tee $remotePath > /dev/null"
  if ($LASTEXITCODE -ne 0) { throw "Failed to write $remotePath" }
}

function Parent-PosixPath([string]$p) {
  if ([string]::IsNullOrWhiteSpace($p)) { return '/' }
  $t = $p.Trim()
  $t = $t.TrimEnd('/')
  $idx = $t.LastIndexOf('/')
  if ($idx -le 0) { return '/' }
  return $t.Substring(0, $idx)
}

$hlsDirTrim = $HlsDir.Trim().TrimEnd('/')
if ([string]::IsNullOrWhiteSpace($hlsDirTrim)) { throw "Invalid HlsDir: '$HlsDir'" }

# systemd treats % as a specifier; escape it as %% in unit files.
$segPattern = "$hlsDirTrim/seg_%%05d.ts"
$indexPath = "$hlsDirTrim/index.m3u8"
$serveDir = Parent-PosixPath $hlsDirTrim

$audioArgs = '-c:a copy'
if ($TranscodeAudio) {
  # For Roku stability, re-encode + async-resample audio to avoid timestamp drift/gaps
  # from some RTSP encoders while still copying video.
  $audioArgs = '-c:a aac -b:a 128k -ar 48000 -af aresample=async=1'
}

$hlsService = @"
[Unit]
Description=Champions Live HLS (RTSP -> HLS)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
Restart=always
RestartSec=2

ExecStartPre=/usr/bin/mkdir -p $hlsDirTrim
ExecStartPre=/usr/bin/bash -lc 'rm -f $hlsDirTrim/*.ts $hlsDirTrim/*.m3u8 || true'

ExecStart=/usr/bin/ffmpeg -hide_banner -loglevel info -rtsp_flags prefer_tcp -rtsp_transport tcp -fflags +genpts -i $RtspUrl -map 0:v:0 -map 0:a:0? -c:v copy $audioArgs -f hls -hls_time $HlsTimeSec -hls_list_size $HlsListSize -hls_start_number_source epoch -hls_flags delete_segments+program_date_time+temp_file -hls_segment_filename $segPattern $indexPath
ExecStop=/bin/kill -s SIGINT `$MAINPID

[Install]
WantedBy=multi-user.target
"@

$httpService = @"
[Unit]
Description=Champions Live HLS HTTP (serve $serveDir on :$HttpPort)
After=network.target

[Service]
Type=simple
User=root
Restart=always
RestartSec=2

ExecStart=/usr/bin/python3 -m http.server $HttpPort --directory $serveDir

[Install]
WantedBy=multi-user.target
"@

Write-Host "Writing systemd units on $GatewaySsh ..."
Write-RemoteUnitFile '/etc/systemd/system/champions-live-hls.service' $hlsService
Write-RemoteUnitFile '/etc/systemd/system/champions-live-hls-http.service' $httpService

Write-Host "Reload + enable services ..."
& ssh -o BatchMode=yes -o ConnectTimeout=5 $GatewaySsh 'sudo systemctl daemon-reload'
if ($LASTEXITCODE -ne 0) { throw "daemon-reload failed" }

& ssh -o BatchMode=yes -o ConnectTimeout=5 $GatewaySsh 'sudo systemctl enable --now champions-live-hls.service champions-live-hls-http.service'
if ($LASTEXITCODE -ne 0) { throw "enable --now failed" }

Write-Host "Restart services to apply unit changes ..."
& ssh -o BatchMode=yes -o ConnectTimeout=5 $GatewaySsh 'sudo systemctl restart champions-live-hls.service champions-live-hls-http.service'
if ($LASTEXITCODE -ne 0) { throw "restart failed" }

Write-Host "Status:"
& ssh -o BatchMode=yes -o ConnectTimeout=5 $GatewaySsh 'sudo systemctl --no-pager --full status champions-live-hls.service champions-live-hls-http.service | head -n 80'

Write-Host "OK: Live HLS origin should be available at http://<gateway>:${HttpPort}/hls/index.m3u8"
