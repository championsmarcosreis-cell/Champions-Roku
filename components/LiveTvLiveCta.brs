sub init()
  m.focusRing = m.top.findNode("focusRing")
  m.tileBg = m.top.findNode("tileBg")
  m.tileBorder = m.top.findNode("tileBorder")
  m.logo = m.top.findNode("logo")
  m.channelLabel = m.top.findNode("channelLabel")
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

  focused = (m.top.ctaFocused = true)
  if m.focusRing <> invalid then m.focusRing.visible = focused
  if focused then
    if m.tileBg <> invalid then m.tileBg.color = "0x1A2A40"
    if m.tileBorder <> invalid then
      m.tileBorder.color = "0xD7B25C"
      m.tileBorder.opacity = 0.85
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
