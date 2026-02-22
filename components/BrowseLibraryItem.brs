sub init()
  m.focusBg = m.top.findNode("focusBg")
  m.icon = m.top.findNode("icon")
  m.label = m.top.findNode("label")
  m.scene = m.top.getScene()
  if m.scene <> invalid and m.scene.hasField("browseFocusVisual") then
    m.scene.observeField("browseFocusVisual", "onBrowseFocusVisualChanged")
  end if
  if m.scene <> invalid and m.scene.hasField("browseTabsSelection") then
    m.scene.observeField("browseTabsSelection", "onBrowseTabsSelectionChanged")
  end if
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

sub onBrowseFocusVisualChanged()
  applyStyle()
end sub

sub onBrowseTabsSelectionChanged()
  applyStyle()
end sub

function _itemCollectionType() as String
  c = m.top.itemContent
  if c = invalid then return ""
  if c.hasField("collectionType") then
    t = c.collectionType
    if t <> invalid then return LCase(t.ToStr().Trim())
  end if
  return ""
end function

function _iconUri(ctype as String, active as Boolean) as String
  suffix = "_white.png"
  if active then suffix = "_gold.png"

  if ctype = "livetv" then return "pkg:/images/tab_livetv" + suffix
  if ctype = "tvshows" then return "pkg:/images/tab_series" + suffix
  return "pkg:/images/tab_movies" + suffix
end function

sub applyStyle()
  ctype = _itemCollectionType()
  focused = (m.top.itemHasFocus = true)
  if focused and m.scene <> invalid and m.scene.hasField("browseFocusVisual") then
    mode = m.scene.browseFocusVisual
    if mode = invalid then mode = ""
    mode = LCase(mode.ToStr().Trim())
    focused = (mode = "views")
  end if

  selected = false
  if m.scene <> invalid and m.scene.hasField("browseTabsSelection") then
    sel = m.scene.browseTabsSelection
    if sel = invalid then sel = ""
    selected = (LCase(sel.ToStr().Trim()) = ctype and ctype <> "")
  end if

  active = (focused or selected)

  if m.focusBg <> invalid then
    ' Keep tabs clean like Windows: no filled focus box.
    m.focusBg.color = "0x00000000"
  end if

  if m.icon <> invalid then m.icon.uri = _iconUri(ctype, active)

  if m.label <> invalid then
    if active then
      m.label.color = "0xD7B25C"
    else
      m.label.color = "0xFFFFFF"
    end if
  end if
end sub
