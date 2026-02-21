sub init()
  m.cardBg = m.top.findNode("cardBg")
  m.cardBorder = m.top.findNode("cardBorder")
  m.logoFrame = m.top.findNode("logoFrame")
  m.logo = m.top.findNode("logo")
  m.channelNameLabel = m.top.findNode("channelNameLabel")
  m.programTitleLabel = m.top.findNode("programTitleLabel")
  m.programTimeLabel = m.top.findNode("programTimeLabel")
  m.nextLabel = m.top.findNode("nextLabel")
  onFieldsChanged()
end sub

sub onFieldsChanged()
  nm = m.top.channelName
  if nm = invalid then nm = ""
  nm = nm.Trim()
  if nm = "" then nm = "Canal"
  if m.channelNameLabel <> invalid then m.channelNameLabel.text = nm

  ttl = m.top.programTitle
  if ttl = invalid then ttl = ""
  ttl = ttl.Trim()
  if ttl = "" then ttl = "Sem programacao"
  if m.programTitleLabel <> invalid then m.programTitleLabel.text = ttl

  tm = m.top.programTime
  if tm = invalid then tm = ""
  tm = tm.Trim()
  if tm = "" then tm = "--:-- - --:--"
  if m.programTimeLabel <> invalid then m.programTimeLabel.text = tm

  nxt = m.top.nextTitle
  if nxt = invalid then nxt = ""
  nxt = nxt.Trim()
  if nxt = "" then nxt = "Proximo: -"
  if m.nextLabel <> invalid then m.nextLabel.text = nxt

  logoUri = m.top.logoUri
  if logoUri = invalid then logoUri = ""
  logoUri = logoUri.Trim()
  if logoUri = "" then logoUri = "pkg:/images/logo.png"
  if m.logo <> invalid then m.logo.uri = logoUri

  applyLayout()
end sub

sub applyLayout()
  w = m.top.layoutWidth
  if w = invalid then w = 280
  w = Int(w)
  if w < 260 then w = 260
  h = Int(w * 0.82)
  if h < 230 then h = 230

  if m.cardBg <> invalid then
    m.cardBg.width = w
    m.cardBg.height = h
  end if
  if m.cardBorder <> invalid then
    m.cardBorder.width = w
    m.cardBorder.height = h
  end if

  logoBox = Int(w * 0.24)
  if logoBox < 64 then logoBox = 64
  if logoBox > 120 then logoBox = 120
  logoX = Int(w * 0.06)
  logoY = Int(h * 0.08)
  if m.logoFrame <> invalid then
    m.logoFrame.translation = [logoX, logoY]
    m.logoFrame.width = logoBox
    m.logoFrame.height = logoBox
  end if
  if m.logo <> invalid then
    m.logo.translation = [logoX + 8, logoY + 8]
    m.logo.width = logoBox - 16
    m.logo.height = logoBox - 16
  end if

  nameX = logoX + logoBox + 12
  if m.channelNameLabel <> invalid then
    m.channelNameLabel.translation = [nameX, logoY + 6]
    m.channelNameLabel.width = w - nameX - 16
  end if

  progY = logoY + logoBox + 18
  if m.programTitleLabel <> invalid then
    m.programTitleLabel.translation = [logoX, progY]
    m.programTitleLabel.width = w - (logoX * 2)
  end if
  if m.programTimeLabel <> invalid then
    m.programTimeLabel.translation = [logoX, progY + 42]
    m.programTimeLabel.width = w - (logoX * 2)
  end if
  if m.nextLabel <> invalid then
    m.nextLabel.translation = [logoX, progY + 76]
    m.nextLabel.width = w - (logoX * 2)
  end if
end sub
