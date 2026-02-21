' Live channel list item with current/next program line.

sub init()
  m.bg = m.top.findNode("bg")
  m.logoBorder = m.top.findNode("logoBorder")
  m.logoBg = m.top.findNode("logoBg")
  m.logo = m.top.findNode("logo")
  m.title = m.top.findNode("title")
  m.program = m.top.findNode("program")
  m.time = m.top.findNode("time")
  m.next = m.top.findNode("next")
  m.progressBg = m.top.findNode("progressBg")
  m.progressFill = m.top.findNode("progressFill")
  m.progressW = 0
  if m.progressBg <> invalid and m.progressBg.width <> invalid then m.progressW = Int(m.progressBg.width)
end sub

sub onItemContentChanged()
  c = m.top.itemContent
  if c = invalid then return

  if c.title <> invalid then
    m.title.text = c.title
  else
    m.title.text = ""
  end if

  logoUrl = ""
  if c.logoUrl <> invalid then logoUrl = c.logoUrl.ToStr().Trim()
  if logoUrl = "" and c.hdPosterUrl <> invalid then logoUrl = c.hdPosterUrl.ToStr().Trim()
  if logoUrl = "" and c.posterUrl <> invalid then logoUrl = c.posterUrl.ToStr().Trim()
  if m.logo <> invalid then
    if logoUrl <> "" then
      m.logo.uri = logoUrl
      m.logo.visible = true
    else
      m.logo.uri = ""
      m.logo.visible = false
    end if
  end if

  nowTitle = ""
  nextTitle = ""
  timeLabel = ""
  if c.programTitle <> invalid then nowTitle = c.programTitle.ToStr().Trim()
  if c.programNextTitle <> invalid then nextTitle = c.programNextTitle.ToStr().Trim()
  if c.programTimeLabel <> invalid then timeLabel = c.programTimeLabel.ToStr().Trim()

  if nowTitle = "" then
    nowTitle = "Sem programacao"
  end if
  if m.program <> invalid then m.program.text = nowTitle

  if m.time <> invalid then m.time.text = timeLabel

  nextLine = ""
  if nextTitle <> "" then nextLine = "Proximo: " + nextTitle
  if m.next <> invalid then m.next.text = nextLine

  prog = -1.0
  if c.programProgress <> invalid then prog = c.programProgress
  if prog < 0 then
    if m.progressBg <> invalid then m.progressBg.visible = false
    if m.progressFill <> invalid then m.progressFill.visible = false
  else
    if prog > 1 then prog = 1
    if prog < 0 then prog = 0
    if m.progressBg <> invalid then m.progressBg.visible = true
    if m.progressFill <> invalid then
      m.progressFill.visible = true
      w = m.progressW
      if w <= 0 and m.progressBg <> invalid and m.progressBg.width <> invalid then w = Int(m.progressBg.width)
      if w < 4 then w = 4
      pw = Int(w * prog)
      if pw < 4 then pw = 4
      if pw > w then pw = w
      m.progressFill.width = pw
    end if
  end if

  applyStyle()
end sub

sub onItemHasFocusChanged()
  applyStyle()
end sub

sub applyStyle()
  focused = (m.top.itemHasFocus = true)
  if focused then
    if m.bg <> invalid then
      if m.bg.hasField("color") then m.bg.color = "0x1B2432"
    end if
    if m.logoBorder <> invalid then m.logoBorder.color = "0xD8B765"
    if m.title <> invalid then m.title.color = "0xFFFFFF"
    if m.program <> invalid then m.program.color = "0xE2E8F0"
    if m.time <> invalid then m.time.color = "0xC7D1E0"
    if m.next <> invalid then m.next.color = "0xC7D1E0"
    if m.progressFill <> invalid then m.progressFill.color = "0xD7B25C"
  else
    if m.bg <> invalid then
      if m.bg.hasField("color") then m.bg.color = "0x121A26"
    end if
    if m.logoBorder <> invalid then m.logoBorder.color = "0x1F2A3B"
    if m.title <> invalid then m.title.color = "0xD0D6E0"
    if m.program <> invalid then m.program.color = "0x9AA4B2"
    if m.time <> invalid then m.time.color = "0x8EA0B8"
    if m.next <> invalid then m.next.color = "0x8EA0B8"
    if m.progressFill <> invalid then m.progressFill.color = "0xBCA45A"
  end if
end sub
