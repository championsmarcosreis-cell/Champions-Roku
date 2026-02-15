' List item with a right-side selection marker.

sub init()
  m.bg = m.top.findNode("bg")
  m.label = m.top.findNode("label")
  m.mark = m.top.findNode("mark")
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
  focused = (m.top.itemHasFocus = true)
  selected = false
  if c.selected <> invalid then selected = (c.selected = true)

  if focused then
    m.bg.uri = "pkg:/images/field_focus.png"
    m.label.color = "0xFFFFFF"
  else
    m.bg.uri = "pkg:/images/field_normal.png"
    m.label.color = "0xD0D6E0"
  end if

  if selected then
    m.mark.text = "OK"
  else
    m.mark.text = ""
  end if
end sub

