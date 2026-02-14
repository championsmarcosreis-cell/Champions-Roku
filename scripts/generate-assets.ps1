$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Split-Path -Parent $root

$imagesDir = Join-Path $root 'images'
New-Item -ItemType Directory -Force -Path $imagesDir | Out-Null

$logoSrc = Join-Path $imagesDir 'logo_src.png'
if (-not (Test-Path $logoSrc)) {
  throw "Missing $logoSrc (put a source logo there first)"
}

function New-Bitmap([int]$w, [int]$h) {
  $bmp = New-Object System.Drawing.Bitmap $w, $h, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $bmp.SetResolution(72, 72)
  return $bmp
}

function With-Graphics($bmp, [scriptblock]$fn) {
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  try { & $fn $g } finally { $g.Dispose() }
}

function Fill-Background($g, [int]$w, [int]$h) {
  $rect = New-Object System.Drawing.Rectangle 0,0,$w,$h
  $c1 = [System.Drawing.ColorTranslator]::FromHtml('#0B0F16')
  $c2 = [System.Drawing.ColorTranslator]::FromHtml('#111B2A')
  $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush $rect, $c1, $c2, 35.0
  try { $g.FillRectangle($brush, $rect) } finally { $brush.Dispose() }

  # Subtle vignette
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  try {
    $path.AddEllipse(-$w*0.10, -$h*0.25, $w*1.20, $h*1.60) | Out-Null
    $pBrush = New-Object System.Drawing.Drawing2D.PathGradientBrush $path
    try {
      $pBrush.CenterColor = [System.Drawing.Color]::FromArgb(30, 255, 200, 90)
      $pBrush.SurroundColors = @([System.Drawing.Color]::FromArgb(210, 0, 0, 0))
      $g.FillRectangle($pBrush, $rect)
    } finally { $pBrush.Dispose() }
  } finally { $path.Dispose() }
}

function Draw-LogoCentered($g, $logoImg, [int]$w, [int]$h, [double]$scale, [int]$yOffset) {
  $maxW = [int]($w * $scale)
  $maxH = [int]($h * $scale)
  $ratio = [Math]::Min($maxW / $logoImg.Width, $maxH / $logoImg.Height)
  $dw = [int]([Math]::Round($logoImg.Width * $ratio))
  $dh = [int]([Math]::Round($logoImg.Height * $ratio))
  $dx = [int](($w - $dw) / 2)
  $dy = [int](($h - $dh) / 2) + $yOffset
  # Remove the black square behind the logo (key out near-black pixels).
  $attr = New-Object System.Drawing.Imaging.ImageAttributes
  try {
    $low = [System.Drawing.Color]::FromArgb(0, 0, 0)
    $high = [System.Drawing.Color]::FromArgb(30, 30, 30)
    $attr.SetColorKey($low, $high)

    $dest = New-Object System.Drawing.Rectangle $dx, $dy, $dw, $dh
    $g.DrawImage($logoImg, $dest, 0, 0, $logoImg.Width, $logoImg.Height, ([System.Drawing.GraphicsUnit]::Pixel), $attr)
  } finally {
    $attr.Dispose()
  }
}

function Draw-Title($g, [int]$w, [int]$y, [int]$fontSize, [string]$text) {
  $font = New-Object System.Drawing.Font 'Segoe UI Semibold', $fontSize, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
  try {
    $fmt = New-Object System.Drawing.StringFormat
    $fmt.Alignment = [System.Drawing.StringAlignment]::Center
    $fmt.LineAlignment = [System.Drawing.StringAlignment]::Near
    $rect = New-Object System.Drawing.RectangleF 0, $y, $w, ($fontSize*2)

    $shadow = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(160, 0, 0, 0))
    $gold = [System.Drawing.ColorTranslator]::FromHtml('#D8B765')
    $brush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(240, $gold.R, $gold.G, $gold.B))
    try {
      $g.DrawString($text, $font, $shadow, ($rect.X+1), ($rect.Y+1), $fmt)
      $g.DrawString($text, $font, $brush, $rect, $fmt)
    } finally {
      $shadow.Dispose()
      $brush.Dispose()
      $fmt.Dispose()
    }
  } finally {
    $font.Dispose()
  }
}

function New-RoundedRectPath([int]$x, [int]$y, [int]$w, [int]$h, [int]$r) {
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $r * 2
  $path.AddArc($x, $y, $d, $d, 180, 90) | Out-Null
  $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90) | Out-Null
  $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90) | Out-Null
  $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90) | Out-Null
  $path.CloseFigure()
  return $path
}

$logoImg = [System.Drawing.Image]::FromFile($logoSrc)
try {
  # App-internal logo (used by Poster in the home scene)
  $logoOut = New-Bitmap 256 256
  With-Graphics $logoOut {
    param($g)
    $g.Clear([System.Drawing.Color]::Transparent)
    Draw-LogoCentered $g $logoImg 256 256 0.85 0
  }
  $logoOut.Save((Join-Path $imagesDir 'logo.png'), [System.Drawing.Imaging.ImageFormat]::Png)
  $logoOut.Dispose()

  # Channel icons (home tile)
  $iconHd = New-Bitmap 290 218
  With-Graphics $iconHd {
    param($g)
    Fill-Background $g 290 218
    Draw-LogoCentered $g $logoImg 290 218 0.68 -8
    Draw-Title $g 290 168 18 'CHAMPIONS'
  }
  $iconHd.Save((Join-Path $imagesDir 'icon_focus_hd.png'), [System.Drawing.Imaging.ImageFormat]::Png)
  $iconHd.Dispose()

  $iconSd = New-Bitmap 214 144
  With-Graphics $iconSd {
    param($g)
    Fill-Background $g 214 144
    Draw-LogoCentered $g $logoImg 214 144 0.70 -4
    Draw-Title $g 214 108 14 'CHAMPIONS'
  }
  $iconSd.Save((Join-Path $imagesDir 'icon_focus_sd.png'), [System.Drawing.Imaging.ImageFormat]::Png)
  $iconSd.Dispose()

  # Splash screens
  $splashHd = New-Bitmap 1280 720
  With-Graphics $splashHd {
    param($g)
    Fill-Background $g 1280 720
    Draw-LogoCentered $g $logoImg 1280 720 0.38 -30
    Draw-Title $g 1280 470 54 'CHAMPIONS'
    Draw-Title $g 1280 545 22 'Roku Dev'
  }
  $splashHd.Save((Join-Path $imagesDir 'splash_hd.png'), [System.Drawing.Imaging.ImageFormat]::Png)
  $splashHd.Dispose()

  $splashSd = New-Bitmap 720 480
  With-Graphics $splashSd {
    param($g)
    Fill-Background $g 720 480
    Draw-LogoCentered $g $logoImg 720 480 0.44 -22
    Draw-Title $g 720 310 34 'CHAMPIONS'
    Draw-Title $g 720 360 18 'Roku Dev'
  }
  $splashSd.Save((Join-Path $imagesDir 'splash_sd.png'), [System.Drawing.Imaging.ImageFormat]::Png)
  $splashSd.Dispose()

  # UI background (used in MainScene)
  $bg = New-Bitmap 1280 720
  With-Graphics $bg {
    param($g)
    Fill-Background $g 1280 720
  }
  $bg.Save((Join-Path $imagesDir 'background.png'), [System.Drawing.Imaging.ImageFormat]::Png)
  $bg.Dispose()

  # Card + input/button chrome (PNG with rounded corners)
  function Make-RoundedRectPng([string]$path, [int]$w, [int]$h, [int]$r, [string]$fillHex, [int]$fillA, [string]$borderHex, [int]$borderA, [int]$borderW, [int]$shadowA) {
    $bmp = New-Bitmap $w $h
    With-Graphics $bmp {
      param($g)
      $g.Clear([System.Drawing.Color]::Transparent)

      if ($shadowA -gt 0) {
        $shadowPath = New-RoundedRectPath 3 4 ($w-6) ($h-6) $r
        $shadowBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb($shadowA, 0, 0, 0))
        try { $g.FillPath($shadowBrush, $shadowPath) } finally { $shadowBrush.Dispose(); $shadowPath.Dispose() }
      }

      $path2 = New-RoundedRectPath 0 0 $w $h $r
      $fill = [System.Drawing.ColorTranslator]::FromHtml($fillHex)
      $border = [System.Drawing.ColorTranslator]::FromHtml($borderHex)

      $fillBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb($fillA, $fill.R, $fill.G, $fill.B))
      $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb($borderA, $border.R, $border.G, $border.B), $borderW)
      try {
        $g.FillPath($fillBrush, $path2)
        $g.DrawPath($pen, $path2)
      } finally {
        $fillBrush.Dispose()
        $pen.Dispose()
        $path2.Dispose()
      }
    }
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
  }

  Make-RoundedRectPng (Join-Path $imagesDir 'card.png') 520 260 18 '#0E1623' 235 '#263246' 220 2 110
  Make-RoundedRectPng (Join-Path $imagesDir 'field_normal.png') 440 56 14 '#0E1623' 235 '#223044' 210 2 0
  Make-RoundedRectPng (Join-Path $imagesDir 'field_focus.png') 440 56 14 '#0E1623' 245 '#CFA84A' 255 3 0
  Make-RoundedRectPng (Join-Path $imagesDir 'button_normal.png') 440 56 14 '#CFA84A' 255 '#B78E2F' 255 2 0
  Make-RoundedRectPng (Join-Path $imagesDir 'button_focus.png') 440 56 14 '#E3C06A' 255 '#F5D889' 255 2 0

  Write-Host "OK: generated Roku assets in $imagesDir"
} finally {
  $logoImg.Dispose()
}
