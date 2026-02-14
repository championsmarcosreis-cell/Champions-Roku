' Custom list item for the login form (field vs button styling).

sub init()
  m.bg = m.top.findNode("bg")
  m.label = m.top.findNode("label")
end sub

sub onItemContentChanged()
  c = m.top.itemContent
  if c = invalid then return

  if c.title <> invalid then m.label.text = c.title else m.label.text = ""
  applyStyle()
end sub

sub onItemHasFocusChanged()
  applyStyle()
end sub

sub applyStyle()
  c = m.top.itemContent
  if c = invalid then return

  kind = ""
  if c.shortDescriptionLine1 <> invalid then kind = c.shortDescriptionLine1

  isButton = (kind = "button_login")
  focused = (m.top.itemHasFocus = true)

  if isButton then
    if focused then
      m.bg.uri = "pkg:/images/button_focus.png"
      m.label.color = "0x0B0F16"
    else
      m.bg.uri = "pkg:/images/button_normal.png"
      m.label.color = "0x0B0F16"
    end if
    m.label.horizAlign = "center"
  else
    if focused then
      m.bg.uri = "pkg:/images/field_focus.png"
      m.label.color = "0xFFFFFF"
    else
      m.bg.uri = "pkg:/images/field_normal.png"
      m.label.color = "0xD0D6E0"
    end if
    m.label.horizAlign = "left"
  end if
end sub

