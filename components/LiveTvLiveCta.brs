sub init()
  m.focusRing = m.top.findNode("focusRing")
  m.tileBg = m.top.findNode("tileBg")
  m.tileBorder = m.top.findNode("tileBorder")
  m.logoFrame = m.top.findNode("logoFrame")
  m.logo = m.top.findNode("logo")
  m.channelLabel = m.top.findNode("channelLabel")
  m.liveBadge = m.top.findNode("liveBadge")
  m.liveBadgeText = m.top.findNode("liveBadgeText")
  m.playCircle = m.top.findNode("playCircle")
  m.playIcon = m.top.findNode("playIcon")
  onFieldsChanged()
end sub

sub onFieldsChanged()
  nm = m.top.channelName
  if nm = invalid then nm = ""
  nm = nm.Trim()
  if nm = "" then nm = "Canal ao vivo"
  if m.channelLabel <> invalid then m.channelLabel.text = nm

  badge = m.top.badgeText
  if badge = invalid then badge = ""
  badge = badge.Trim()
  if badge = "" then badge = "AO VIVO"
  if m.liveBadgeText <> invalid then m.liveBadgeText.text = badge

  logoUri = m.top.logoUri
  if logoUri = invalid then logoUri = ""
  logoUri = logoUri.Trim()
  if logoUri = "" then logoUri = "pkg:/images/logo.png"
  if m.logo <> invalid then m.logo.uri = logoUri

  applyLayout()

  focused = (m.top.ctaFocused = true)
  if m.focusRing <> invalid then m.focusRing.visible = false
  if focused then
    if m.tileBg <> invalid then m.tileBg.color = "0x16253A"
    if m.tileBorder <> invalid then
      m.tileBorder.color = "0xD7B25C"
      m.tileBorder.opacity = 1.0
    end if
    if m.playCircle <> invalid then m.playCircle.color = "0x2A3E5C"
    if m.playIcon <> invalid then m.playIcon.color = "0xFFFFFF"
  else
    if m.tileBg <> invalid then m.tileBg.color = "0x131F31"
    if m.tileBorder <> invalid then
      m.tileBorder.color = "0x334962"
      m.tileBorder.opacity = 0.55
    end if
    if m.playCircle <> invalid then m.playCircle.color = "0x1E2D44"
    if m.playIcon <> invalid then m.playIcon.color = "0xF2F6FC"
  end if
end sub

sub applyLayout()
  w = m.top.layoutWidth
  if w = invalid then w = 173
  w = Int(w)
  if w < 180 then w = 180
  h = Int(w * 1.35)
  if h < 260 then h = 260
  if h > 360 then h = 360

  if m.focusRing <> invalid then
    m.focusRing.width = w + 8
    m.focusRing.height = h + 8
  end if
  if m.tileBg <> invalid then
    m.tileBg.translation = [2, 2]
    m.tileBg.width = w - 4
    m.tileBg.height = h - 4
  end if
  if m.tileBorder <> invalid then
    m.tileBorder.translation = [0, 0]
    m.tileBorder.width = w
    m.tileBorder.height = h
  end if

  logoBox = Int(w * 0.5)
  if logoBox < 88 then logoBox = 88
  logoX = Int((w - logoBox) / 2)
  logoY = 22
  if m.logoFrame <> invalid then
    m.logoFrame.translation = [logoX, logoY]
    m.logoFrame.width = logoBox
    m.logoFrame.height = logoBox
  end if
  if m.logo <> invalid then
    m.logo.translation = [logoX + 12, logoY + 12]
    m.logo.width = logoBox - 24
    m.logo.height = logoBox - 24
  end if

  if m.channelLabel <> invalid then
    m.channelLabel.translation = [14, logoY + logoBox + 14]
    m.channelLabel.width = w - 28
  end if

  badgeW = Int(w * 0.52)
  if badgeW < 104 then badgeW = 104
  badgeX = Int((w - badgeW) / 2)
  badgeY = logoY + logoBox + 50
  if m.liveBadge <> invalid then
    m.liveBadge.translation = [badgeX, badgeY]
    m.liveBadge.width = badgeW
  end if
  if m.liveBadgeText <> invalid then
    m.liveBadgeText.translation = [badgeX, badgeY + 8]
    m.liveBadgeText.width = badgeW
  end if

  playW = Int(w * 0.34)
  if playW < 68 then playW = 68
  playX = Int((w - playW) / 2)
  playY = h - 84
  if m.playCircle <> invalid then
    m.playCircle.translation = [playX, playY]
    m.playCircle.width = playW
    m.playCircle.height = 54
  end if
  if m.playIcon <> invalid then
    m.playIcon.translation = [playX, playY + 14]
    m.playIcon.width = playW
  end if
end sub
