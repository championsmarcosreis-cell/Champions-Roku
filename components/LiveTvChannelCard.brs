sub init()
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
end sub
