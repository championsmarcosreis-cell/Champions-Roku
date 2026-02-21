' Live channel list item with current/next program line.

sub init()
  m.bg = m.top.findNode("bg")
  m.logo = m.top.findNode("logo")
  m.title = m.top.findNode("title")
  m.program = m.top.findNode("program")
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
  if c.programTitle <> invalid then nowTitle = c.programTitle.ToStr().Trim()
  if c.programNextTitle <> invalid then nextTitle = c.programNextTitle.ToStr().Trim()

  line = ""
  if nowTitle <> "" then
    line = "Agora: " + nowTitle
    if nextTitle <> "" then line = line + " | Proximo: " + nextTitle
  else
    line = "Sem programacao"
  end if
  m.program.text = line

  applyStyle()
end sub

sub onItemHasFocusChanged()
  applyStyle()
end sub

sub applyStyle()
  focused = (m.top.itemHasFocus = true)
  if focused then
    if m.bg <> invalid then m.bg.uri = "pkg:/images/field_focus.png"
    if m.title <> invalid then m.title.color = "0xFFFFFF"
    if m.program <> invalid then m.program.color = "0xE2E8F0"
  else
    if m.bg <> invalid then m.bg.uri = "pkg:/images/field_normal.png"
    if m.title <> invalid then m.title.color = "0xD0D6E0"
    if m.program <> invalid then m.program.color = "0x9AA4B2"
  end if
end sub
