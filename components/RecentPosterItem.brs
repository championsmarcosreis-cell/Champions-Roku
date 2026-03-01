sub init()
  if m.top <> invalid then
    if m.top.hasField("width") then m.top.width = 160
    if m.top.hasField("height") then m.top.height = 240
  end if

  m.cover = m.top.findNode("cover")
  m.progressBg = m.top.findNode("progressBg")
  m.progressFill = m.top.findNode("progressFill")
  m.titleLabel = m.top.findNode("titleLabel")
  if m.titleLabel = invalid then m.titleLabel = _findFallbackLabel()
  m.footerBg = m.top.findNode("footerBg")
  m.posterBg = m.top.findNode("posterBg")
  m.focusBorder = m.top.findNode("borderGroup")
  m.borderTop = m.top.findNode("borderTop")
  m.borderBottom = m.top.findNode("borderBottom")
  m.borderLeft = m.top.findNode("borderLeft")
  m.borderRight = m.top.findNode("borderRight")
  _ensureBorderNodes()
  m.ownerGrid = invalid
  m.contentNode = invalid
end sub

sub onItemContentChanged()
  _clearContentObservers()
  _ensureOwnerGridObserver()
  c = m.top.itemContent
  _observeContent(c)
  _renderContent(c)
end sub

sub onContentFieldChanged()
  _renderContent(m.top.itemContent)
end sub

sub onItemHasFocusChanged()
  _ensureOwnerGridObserver()
  _applyStyle()
end sub

sub onItemSelectedChanged()
  _ensureOwnerGridObserver()
  _applyStyle()
end sub

sub _renderContent(c as Object)
  if c = invalid then
    if m.cover <> invalid then m.cover.uri = ""
    if m.progressBg <> invalid then m.progressBg.visible = false
    if m.progressFill <> invalid then
      m.progressFill.visible = false
      m.progressFill.width = 0
    end if
    if m.titleLabel <> invalid then
      m.titleLabel.text = ""
      m.titleLabel.visible = true
    end if
    if m.focusBorder <> invalid then m.focusBorder.visible = false
    if m.borderTop <> invalid then m.borderTop.visible = false
    if m.borderBottom <> invalid then m.borderBottom.visible = false
    if m.borderLeft <> invalid then m.borderLeft.visible = false
    if m.borderRight <> invalid then m.borderRight.visible = false
    return
  end if

  p = ""
  if c.hdPosterUrl <> invalid then p = c.hdPosterUrl.ToStr().Trim()
  if p = "" and c.HDPosterUrl <> invalid then p = c.HDPosterUrl.ToStr().Trim()
  if p = "" and c.sdPosterUrl <> invalid then p = c.sdPosterUrl.ToStr().Trim()
  if p = "" and c.SDPosterUrl <> invalid then p = c.SDPosterUrl.ToStr().Trim()
  if p = "" and c.posterUrl <> invalid then p = c.posterUrl.ToStr().Trim()
  if p = "" then p = "pkg:/images/logo.png"
  if m.cover <> invalid then m.cover.uri = p

  titleText = _contentTitle(c)
  if titleText = "" then titleText = _fallbackRecentTitle(c)
  shortTitle = _fitTitle(titleText)
  if m.titleLabel <> invalid then
    m.titleLabel.text = shortTitle.ToStr()
    m.titleLabel.visible = true
  end if

  pct = 0
  if c.resumePercent <> invalid then pct = Int(Val(c.resumePercent.ToStr()))
  if pct < 0 then pct = 0
  if pct > 100 then pct = 100

  played = false
  if c.played <> invalid then played = (c.played = true)
  showProgress = (pct > 0 and played <> true)
  if m.progressBg <> invalid then m.progressBg.visible = showProgress
  if m.progressFill <> invalid then
    m.progressFill.visible = showProgress
    if showProgress then
      w = Int((160.0 * pct) / 100.0)
      if w < 2 then w = 2
      if w > 160 then w = 160
      m.progressFill.width = w
    else
      m.progressFill.width = 0
    end if
  end if

  _applyStyle()
end sub

sub _clearContentObservers()
  c = m.contentNode
  if c = invalid then return
  if c.hasField("title") then c.unobserveField("title")
  if c.hasField("hdPosterUrl") then c.unobserveField("hdPosterUrl")
  if c.hasField("sdPosterUrl") then c.unobserveField("sdPosterUrl")
  if c.hasField("posterUrl") then c.unobserveField("posterUrl")
  if c.hasField("resumePercent") then c.unobserveField("resumePercent")
  if c.hasField("played") then c.unobserveField("played")
  m.contentNode = invalid
end sub

sub _observeContent(c as Object)
  if c = invalid then return
  m.contentNode = c
  if c.hasField("title") then c.observeField("title", "onContentFieldChanged")
  if c.hasField("hdPosterUrl") then c.observeField("hdPosterUrl", "onContentFieldChanged")
  if c.hasField("sdPosterUrl") then c.observeField("sdPosterUrl", "onContentFieldChanged")
  if c.hasField("posterUrl") then c.observeField("posterUrl", "onContentFieldChanged")
  if c.hasField("resumePercent") then c.observeField("resumePercent", "onContentFieldChanged")
  if c.hasField("played") then c.observeField("played", "onContentFieldChanged")
end sub

sub _applyStyle()
  _hideLegacyBorders()
  focused = _isFocusedTile()
  if m.focusBorder <> invalid then m.focusBorder.visible = focused
  if m.borderTop <> invalid then m.borderTop.visible = focused
  if m.borderBottom <> invalid then m.borderBottom.visible = focused
  if m.borderLeft <> invalid then m.borderLeft.visible = focused
  if m.borderRight <> invalid then m.borderRight.visible = focused
  if m.titleLabel <> invalid then
    if focused then
      m.titleLabel.color = "0xFFFFFFFF"
    else
      m.titleLabel.color = "0xE6EBF3FF"
    end if
  end if
  if m.footerBg <> invalid then
    if focused then
      m.footerBg.color = "0x111C2DFF"
    else
      m.footerBg.color = "0x0A111DFF"
    end if
  end if
end sub

sub onOwnerGridItemFocusedChanged()
  _applyStyle()
end sub

function _isFocusedTile() as Boolean
  if m.top = invalid then return false
  grid = _resolveOwnerGrid()
  if grid = invalid then return false
  if grid.hasFocus() <> true then return false

  return _isGridFocusedContentItem(grid)
end function

function _resolveOwnerGrid() as Object
  if m.top = invalid then return invalid
  cur = m.top
  depth = 0
  while cur <> invalid and depth < 10
    if cur.hasField("itemFocused") and cur.hasField("content") and cur.hasField("itemComponentName") then
      return cur
    end if
    cur = cur.getParent()
    depth = depth + 1
  end while
  return invalid
end function

function _isGridFocusedContentItem(grid as Object) as Boolean
  if grid = invalid then return false
  idx = grid.itemFocused
  if idx = invalid then return false
  i = Int(idx)
  if i < 0 then return false
  root = grid.content
  if root = invalid then return false
  total = root.getChildCount()
  if total = invalid or i >= total then return false
  focusedNode = root.getChild(i)
  if focusedNode = invalid then return false
  if m.top = invalid or m.top.itemContent = invalid then return false
  if m.top.itemContent.hasField("id") and focusedNode.hasField("id") then
    return _isSameContentItem(focusedNode, m.top.itemContent)
  end if
  if m.top.itemContent.hasField("path") and focusedNode.hasField("path") then
    ap = m.top.itemContent.path
    bp = focusedNode.path
    if ap <> invalid and bp <> invalid then
      return (LCase(ap.ToStr().Trim()) = LCase(bp.ToStr().Trim()))
    end if
  end if
  return false
end function

function _isSameContentItem(a as Object, b as Object) as Boolean
  if a = invalid or b = invalid then return false

  aid = ""
  bid = ""
  if a.id <> invalid then aid = a.id.ToStr().Trim()
  if b.id <> invalid then bid = b.id.ToStr().Trim()
  if aid <> "" and bid <> "" then return (LCase(aid) = LCase(bid))
  return false
end function

function _fitTitle(raw as Dynamic) as String
  t = ""
  if raw <> invalid then t = raw.ToStr()
  t = t.Trim()
  if t = "" then return ""

  maxChars = 22
  if Len(t) <= maxChars then return t
  keep = maxChars - 3
  if keep < 1 then keep = 1
  return Left(t, keep).Trim() + "..."
end function

function _contentTitle(c as Object) as String
  if c = invalid then return ""

  t = ""
  if c.title <> invalid then t = c.title.ToStr().Trim()
  if t = "" and c.name <> invalid then t = c.name.ToStr().Trim()
  if t = "" and c.Name <> invalid then t = c.Name.ToStr().Trim()
  if t = "" and c.Title <> invalid then t = c.Title.ToStr().Trim()
  if t = "" and c.originalTitle <> invalid then t = c.originalTitle.ToStr().Trim()
  if t = "" and c.OriginalTitle <> invalid then t = c.OriginalTitle.ToStr().Trim()
  if t = "" and c.shortDescriptionLine1 <> invalid then t = c.shortDescriptionLine1.ToStr().Trim()
  if t = "" and c.longDescription <> invalid then t = c.longDescription.ToStr().Trim()
  if t = "" and c.SortName <> invalid then t = c.SortName.ToStr().Trim()
  if t = "" and c.sortName <> invalid then t = c.sortName.ToStr().Trim()
  return t
end function

function _fallbackRecentTitle(c as Object) as String
  if c = invalid then return "(Sem titulo)"

  t = ""
  if c.itemType <> invalid then t = c.itemType.ToStr().Trim()
  if t = "" and c.id <> invalid then t = c.id.ToStr().Trim()
  if t = "" then t = "(Sem titulo)"
  return t
end function

function _findFallbackLabel() as Object
  if m.top = invalid then return invalid
  cnt = m.top.getChildCount()
  if cnt = invalid or cnt <= 0 then return invalid
  i = 0
  while i < cnt
    n = m.top.getChild(i)
    if n <> invalid and n.hasField("text") and n.hasField("font") then
      return n
    end if
    i = i + 1
  end while
  return invalid
end function

sub _ensureBorderNodes()
  if m.top = invalid then return
  if m.borderTop = invalid then m.borderTop = _createBorderRect("recentBorderTop", [0, 0], 160, 3)
  if m.borderBottom = invalid then m.borderBottom = _createBorderRect("recentBorderBottom", [0, 237], 160, 3)
  if m.borderLeft = invalid then m.borderLeft = _createBorderRect("recentBorderLeft", [0, 0], 3, 240)
  if m.borderRight = invalid then m.borderRight = _createBorderRect("recentBorderRight", [157, 0], 3, 240)
end sub

sub _ensureOwnerGridObserver()
  if m.ownerGrid <> invalid then return
  grid = _resolveOwnerGrid()
  if grid = invalid then return
  m.ownerGrid = grid
  if m.ownerGrid.hasField("itemFocused") then
    m.ownerGrid.observeField("itemFocused", "onOwnerGridItemFocusedChanged")
  end if
end sub

sub _hideLegacyBorders()
  if m.top = invalid then return
  cnt = m.top.getChildCount()
  if cnt = invalid or cnt <= 0 then return
  i = 0
  while i < cnt
    n = m.top.getChild(i)
    if _isLegacyBorderRect(n) then
      n.visible = false
    end if
    i = i + 1
  end while
end sub

function _isLegacyBorderRect(n as Object) as Boolean
  if n = invalid then return false
  if n.hasField("visible") <> true then return false
  if n.hasField("width") <> true then return false
  if n.hasField("height") <> true then return false
  if n.hasField("translation") <> true then return false

  nid = ""
  if n.id <> invalid then nid = n.id.ToStr().Trim()
  if nid = "recentBorderTop" or nid = "recentBorderBottom" or nid = "recentBorderLeft" or nid = "recentBorderRight" then return false

  tr = n.translation
  if tr = invalid then return false
  if tr.Count() < 2 then return false

  w = Int(n.width)
  h = Int(n.height)
  x = Int(tr[0])
  y = Int(tr[1])

  if w = 160 and h = 3 and x = 0 and (y = 0 or y = 191) then return true
  if w = 3 and h = 194 and y = 0 and (x = 0 or x = 157) then return true
  return false
end function

function _createBorderRect(id as String, tr as Object, w as Integer, h as Integer) as Object
  if m.top = invalid then return invalid
  r = CreateObject("roSGNode", "Rectangle")
  if r = invalid then return invalid
  r.id = id
  r.translation = tr
  r.width = w
  r.height = h
  r.color = "0xD8B765FF"
  r.visible = false
  m.top.appendChild(r)
  return r
end function
