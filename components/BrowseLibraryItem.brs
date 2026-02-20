sub init()
  m.bg = m.top.findNode("bg")
  m.accent = m.top.findNode("accent")
  m.label = m.top.findNode("label")
end sub

sub onItemContentChanged()
  c = m.top.itemContent
  if c = invalid then
    if m.label <> invalid then m.label.text = ""
    return
  end if

  if m.label <> invalid then
    if c.title <> invalid then
      m.label.text = c.title
    else
      m.label.text = ""
    end if
  end if
  applyStyle()
end sub

sub onItemHasFocusChanged()
  applyStyle()
end sub

sub applyStyle()
  focused = (m.top.itemHasFocus = true)
  if m.bg <> invalid then
    if focused then
      m.bg.uri = "pkg:/images/field_focus.png"
    else
      m.bg.uri = "pkg:/images/field_normal.png"
    end if
  end if

  if m.label <> invalid then
    if focused then
      m.label.color = "0xFFFFFF"
    else
      m.label.color = "0xD0D6E0"
    end if
  end if
  if m.accent <> invalid then
    if focused then
      m.accent.color = "0xE4BF6A"
    else
      m.accent.color = "0xD7B25C"
    end if
  end if
end sub
