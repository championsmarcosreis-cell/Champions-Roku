sub init()
  m.checkIcon = m.top.findNode("checkIcon")
  m.titleLabel = m.top.findNode("titleLabel")
  m.isSelected = false
  applyStyle()
end sub

sub onItemContentChanged()
  c = m.top.itemContent
  if c = invalid then
    if m.titleLabel <> invalid then m.titleLabel.text = ""
    m.isSelected = false
    applyStyle()
    return
  end if

  txt = ""
  if c.title <> invalid then txt = c.title.ToStr().Trim()
  if m.titleLabel <> invalid then m.titleLabel.text = txt

  sel = false
  if c.selected <> invalid then sel = (c.selected = true)
  m.isSelected = sel

  applyStyle()
end sub

sub onItemHasFocusChanged()
  applyStyle()
end sub

sub applyStyle()
  focused = (m.top.itemHasFocus = true)

  if m.titleLabel <> invalid then
    if focused then
      m.titleLabel.color = "0xD8B765"
    else
      m.titleLabel.color = "0xD0D6E0"
    end if
  end if

  if m.checkIcon <> invalid then
    if m.isSelected then
      m.checkIcon.uri = "pkg:/images/radio_on_24.png"
    else
      m.checkIcon.uri = "pkg:/images/radio_off_24.png"
    end if
  end if
end sub
