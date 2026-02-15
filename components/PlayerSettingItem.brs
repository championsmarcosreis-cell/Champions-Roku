' List item with a right-side selection marker.

sub init()
  m.bg = m.top.findNode("bg")
  m.icon = m.top.findNode("icon")
  m.label = m.top.findNode("label")
  m.mark = m.top.findNode("mark")
  m.iconObsSetup = false
  m.iconReady = false
  m.lastIconUri = ""

  if m.icon <> invalid and m.iconObsSetup <> true and m.icon.hasField("loadStatus") then
    m.icon.observeField("loadStatus", "onIconLoadStatusChanged")
    m.iconObsSetup = true
  end if
end sub

sub onItemContentChanged()
  c = m.top.itemContent
  if c = invalid then return
  if c.title <> invalid then m.label.text = c.title else m.label.text = ""
  applyIconState()
  applyStyle()
end sub

sub onItemHasFocusChanged()
  applyStyle()
end sub

sub onIconLoadStatusChanged()
  if m.icon = invalid then return
  st = m.icon.loadStatus
  if st = invalid then st = ""
  st = LCase(st.ToStr().Trim())
  m.iconReady = (st = "ready")
  applyIconMode()
end sub

sub applyIconState()
  c = m.top.itemContent
  if c = invalid then return

  iconUri = ""
  if c.iconUri <> invalid then iconUri = c.iconUri.ToStr()
  iconUri = iconUri.Trim()

  if m.icon <> invalid then
    if iconUri <> "" then
      m.icon.visible = true
      if m.lastIconUri <> iconUri then
        m.lastIconUri = iconUri
        m.iconReady = false
        m.icon.uri = iconUri
      end if
    else
      m.icon.visible = false
      m.lastIconUri = ""
      m.iconReady = false
    end if
  end if

  applyIconMode()
end sub

sub applyIconMode()
  c = m.top.itemContent
  if c = invalid then return

  preferIconOnly = false
  if c.preferIconOnly <> invalid then preferIconOnly = (c.preferIconOnly = true)

  iconShown = (m.icon <> invalid and m.icon.visible = true)

  ' If the icon is requested but failed to load (or loadStatus not supported),
  ' keep the text visible as a fallback.
  hideText = (preferIconOnly = true and iconShown = true and m.iconReady = true)
  if m.label <> invalid then m.label.visible = (hideText <> true)

  if m.icon <> invalid then
    if hideText then
      m.icon.translation = [ Int((440 - 28) / 2), 14 ] ' centered
    else
      m.icon.translation = [18, 14]
    end if
  end if

  if m.label <> invalid then
    if iconShown then
      m.label.translation = [56, 16]
    else
      m.label.translation = [18, 16]
    end if
  end if
end sub

sub applyStyle()
  c = m.top.itemContent
  if c = invalid then return
  focused = (m.top.itemHasFocus = true)
  selected = false
  if c.selected <> invalid then selected = (c.selected = true)

  if focused then
    m.bg.uri = "pkg:/images/field_focus.png"
    if m.label <> invalid then m.label.color = "0xFFFFFF"
  else
    m.bg.uri = "pkg:/images/field_normal.png"
    if m.label <> invalid then m.label.color = "0xD0D6E0"
  end if

  if selected then
    m.mark.text = "OK"
  else
    m.mark.text = ""
  end if
end sub
