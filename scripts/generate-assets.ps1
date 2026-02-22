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
    # Keep corners cleaner (avoid dark top edges on TVs)
    $path.AddEllipse(-$w*0.25, -$h*0.35, $w*1.50, $h*1.90) | Out-Null
    $pBrush = New-Object System.Drawing.Drawing2D.PathGradientBrush $path
    try {
      # Center glow only; fade to transparent so we don't get dark corners.
      $pBrush.CenterColor = [System.Drawing.Color]::FromArgb(20, 255, 200, 90)
      $pBrush.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 0, 0, 0))
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

    # IMPORTANT: Use the same centered layout rectangle for shadow + foreground;
    # drawing the shadow with x/y would ignore alignment and misplace it.
    $shadowRect = New-Object System.Drawing.RectangleF 1, ($y+1), $w, ($fontSize*2)

    $shadow = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(120, 0, 0, 0))
    $gold = [System.Drawing.ColorTranslator]::FromHtml('#D8B765')
    $brush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(240, $gold.R, $gold.G, $gold.B))
    try {
      $g.DrawString($text, $font, $shadow, $shadowRect, $fmt)
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

function Draw-LionOnlyCentered($g, $logoImg, [int]$w, [int]$h, [double]$scale, [int]$yOffset) {
  $maxW = [int]($w * $scale)
  $maxH = [int]($h * $scale)
  $ratio = [Math]::Min($maxW / $logoImg.Width, $maxH / $logoImg.Height)
  $dw = [int]([Math]::Round($logoImg.Width * $ratio))
  $dh = [int]([Math]::Round($logoImg.Height * $ratio))
  $dx = [int](($w - $dw) / 2)
  $dy = [int](($h - $dh) / 2) + $yOffset

  # Build a temporary, transparent logo bitmap at the exact render size,
  # then remove the outer "C" arc by applying a radial cutoff based on the
  # gap between the arc and the lion.
  $tmp = New-Bitmap $dw $dh
  try {
    With-Graphics $tmp {
      param($tg)
      $tg.Clear([System.Drawing.Color]::Transparent)

      $attr = New-Object System.Drawing.Imaging.ImageAttributes
      try {
        $low = [System.Drawing.Color]::FromArgb(0, 0, 0)
        $high = [System.Drawing.Color]::FromArgb(30, 30, 30)
        $attr.SetColorKey($low, $high)
        $dest0 = New-Object System.Drawing.Rectangle 0, 0, $dw, $dh
        $tg.DrawImage($logoImg, $dest0, 0, 0, $logoImg.Width, $logoImg.Height, ([System.Drawing.GraphicsUnit]::Pixel), $attr)
      } finally {
        $attr.Dispose()
      }
    }

    # Fast pixel access
    $rect = New-Object System.Drawing.Rectangle 0, 0, $dw, $dh
    $data = $tmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadWrite, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb))
    try {
      $stride = $data.Stride
      $buf = New-Object byte[] ($stride * $dh)
      [System.Runtime.InteropServices.Marshal]::Copy($data.Scan0, $buf, 0, $buf.Length)

      # Remove the outer "C" arc with a radial cutoff around the center.
      # The arc lives in the outer ring of the logo, while the lion stays inside.
      $cx = ($dw - 1) / 2.0
      $cy = ($dh - 1) / 2.0
      $maxR = 0

      for ($y = 0; $y -lt $dh; $y++) {
        $row = $y * $stride
        $dy2 = ($y - $cy) * ($y - $cy)
        for ($x = 0; $x -lt $dw; $x++) {
          $i = $row + ($x * 4)
          $a = $buf[$i + 3]
          if ($a -eq 0) { continue }
          $dx2 = ($x - $cx) * ($x - $cx)
          $r = [int][Math]::Round([Math]::Sqrt($dx2 + $dy2))
          if ($r -gt $maxR) { $maxR = $r }
        }
      }

      # Empirically, the lion fits within ~83% of the outer radius for this asset.
      # Use Floor (not Ceiling) to ensure the inner edge of the arc is removed too.
      $cutR = [int][Math]::Floor($maxR * 0.83)
      $cutR2 = $cutR * $cutR

      for ($y = 0; $y -lt $dh; $y++) {
        $row = $y * $stride
        $dy2 = ($y - $cy) * ($y - $cy)
        for ($x = 0; $x -lt $dw; $x++) {
          $i = $row + ($x * 4)
          $a = $buf[$i + 3]
          if ($a -eq 0) { continue }
          $dx2 = ($x - $cx) * ($x - $cx)
          if (($dx2 + $dy2) -ge $cutR2) {
            $buf[$i + 3] = 0
          }
        }
      }

      [System.Runtime.InteropServices.Marshal]::Copy($buf, 0, $data.Scan0, $buf.Length)
    } finally {
      $tmp.UnlockBits($data)
    }

    $g.DrawImage($tmp, $dx, $dy)
  } finally {
    $tmp.Dispose()
  }
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
    Draw-LionOnlyCentered $g $logoImg 290 218 0.92 -37
    Draw-Title $g 290 176 18 'CHAMPIONS'
  }
  $iconHd.Save((Join-Path $imagesDir 'icon_focus_hd.png'), [System.Drawing.Imaging.ImageFormat]::Png)
  $iconHd.Dispose()

  $iconSd = New-Bitmap 214 144
  With-Graphics $iconSd {
    param($g)
    Fill-Background $g 214 144
    Draw-LionOnlyCentered $g $logoImg 214 144 0.92 -32
    Draw-Title $g 214 112 14 'CHAMPIONS'
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

  function Make-RoundedMaskPng([string]$path, [int]$w, [int]$h, [int]$r) {
    $bmp = New-Bitmap $w $h
    With-Graphics $bmp {
      param($g)
      $g.Clear([System.Drawing.Color]::Transparent)

      $path2 = New-RoundedRectPath 0 0 $w $h $r
      $brush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
      try {
        $g.FillPath($brush, $path2)
      } finally {
        $brush.Dispose()
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

  # Login button needs a more obvious focus state (TV viewing distance).
  Make-RoundedRectPng (Join-Path $imagesDir 'login_button_normal.png') 440 56 14 '#0E1623' 245 '#CFA84A' 255 3 0
  Make-RoundedRectPng (Join-Path $imagesDir 'login_button_focus.png') 440 56 14 '#E3C06A' 255 '#FFFFFF' 255 4 0

  # Rounded corner masks for posters/banners
  Make-RoundedMaskPng (Join-Path $imagesDir 'mask_banner_560x318.png') 560 318 18
  Make-RoundedMaskPng (Join-Path $imagesDir 'mask_poster_556x298.png') 556 298 18
  Make-RoundedMaskPng (Join-Path $imagesDir 'mask_rail_124x182.png') 124 182 10
  Make-RoundedMaskPng (Join-Path $imagesDir 'mask_library_68x92.png') 68 92 8

  Write-Host "OK: generated Roku assets in $imagesDir"
} finally {
  $logoImg.Dispose()
}
