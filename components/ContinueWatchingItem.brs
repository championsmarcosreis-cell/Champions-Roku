sub init()
  m.thumbGroup = m.top.findNode("thumbGroup")
  m.cover = m.top.findNode("cover")
  m.focusOverlay = m.top.findNode("focusOverlay")
  m.borderTop = m.top.findNode("borderTop")
  m.borderBottom = m.top.findNode("borderBottom")
  m.borderLeft = m.top.findNode("borderLeft")
  m.borderRight = m.top.findNode("borderRight")
  m.titleLabel = m.top.findNode("titleLabel")
  m.footerBg = m.top.findNode("footerBg")
  m.subtitle = m.top.findNode("subtitle")
  m.progressBg = m.top.findNode("progressBg")
  m.progressFill = m.top.findNode("progressFill")
  m.contentNode = invalid
  m.ownerGrid = invalid
  _ensureBorderNodes()
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

sub _renderContent(c as Object)
  if c = invalid then
    if m.cover <> invalid then
      if m.cover.hasField("loadDisplayMode") then m.cover.loadDisplayMode = "zoomToFill"
      m.cover.uri = ""
    end if
    if m.titleLabel <> invalid then m.titleLabel.text = ""
    if m.subtitle <> invalid then
      m.subtitle.text = ""
      m.subtitle.visible = false
    end if
    if m.progressBg <> invalid then m.progressBg.visible = false
    if m.progressFill <> invalid then m.progressFill.visible = false
    if m.focusOverlay <> invalid then m.focusOverlay.visible = false
    if m.borderTop <> invalid then m.borderTop.visible = false
    if m.borderBottom <> invalid then m.borderBottom.visible = false
    if m.borderLeft <> invalid then m.borderLeft.visible = false
    if m.borderRight <> invalid then m.borderRight.visible = false
    return
  end if

  ttl = _resolveContinueTitle(c)
  showTitle = _fitContinueTitle(ttl)
  if m.titleLabel <> invalid then m.titleLabel.text = showTitle

  subTxt = ""
  if c.itemType <> invalid then subTxt = _friendlyType(c.itemType.ToStr().Trim())
  if m.subtitle <> invalid then
    m.subtitle.text = subTxt
    m.subtitle.visible = (subTxt <> "")
  end if

  art = ""
  if c.wideUrl <> invalid then art = c.wideUrl.ToStr().Trim()
  if art = "" and c.posterUrl <> invalid then art = c.posterUrl.ToStr().Trim()
  if art = "" and c.hdPosterUrl <> invalid then art = c.hdPosterUrl.ToStr().Trim()
  if art = "" and c.HDPosterUrl <> invalid then art = c.HDPosterUrl.ToStr().Trim()
  if art = "" then art = "pkg:/images/logo.png"

  mode = "zoomToFill"
  if c.posterMode <> invalid then
    tmpMode = c.posterMode.ToStr().Trim()
    if tmpMode <> "" then mode = tmpMode
  end if
  modeL = LCase(mode)
  if modeL <> "zoomtofill" and modeL <> "scaletofit" and modeL <> "scaletofill" then
    mode = "zoomToFill"
  end if

  if m.cover <> invalid then
    if m.cover.hasField("loadDisplayMode") then m.cover.loadDisplayMode = mode
    m.cover.uri = art
  end if

  ratio = _resumeRatio(c)
  showProgress = (ratio > 0)
  if m.progressBg <> invalid then m.progressBg.visible = showProgress
  if m.progressFill <> invalid then
    m.progressFill.visible = showProgress
    if showProgress then
      w = Int(248 * ratio)
      if w < 1 then w = 1
      if w > 248 then w = 248
      m.progressFill.width = w
    end if
  end if

  applyStyle()
end sub

sub _clearContentObservers()
  c = m.contentNode
  if c = invalid then return
  if c.hasField("title") then c.unobserveField("title")
  if c.hasField("wideUrl") then c.unobserveField("wideUrl")
  if c.hasField("hdPosterUrl") then c.unobserveField("hdPosterUrl")
  if c.hasField("posterUrl") then c.unobserveField("posterUrl")
  if c.hasField("posterMode") then c.unobserveField("posterMode")
  if c.hasField("resumePercent") then c.unobserveField("resumePercent")
  if c.hasField("played") then c.unobserveField("played")
  m.contentNode = invalid
end sub

sub _observeContent(c as Object)
  if c = invalid then return
  m.contentNode = c
  if c.hasField("title") then c.observeField("title", "onContentFieldChanged")
  if c.hasField("wideUrl") then c.observeField("wideUrl", "onContentFieldChanged")
  if c.hasField("hdPosterUrl") then c.observeField("hdPosterUrl", "onContentFieldChanged")
  if c.hasField("posterUrl") then c.observeField("posterUrl", "onContentFieldChanged")
  if c.hasField("posterMode") then c.observeField("posterMode", "onContentFieldChanged")
  if c.hasField("resumePercent") then c.observeField("resumePercent", "onContentFieldChanged")
  if c.hasField("played") then c.observeField("played", "onContentFieldChanged")
end sub

sub onItemHasFocusChanged()
  _ensureOwnerGridObserver()
  applyStyle()
end sub

sub applyStyle()
  focused = _isFocusedTile()
  if m.focusOverlay <> invalid then m.focusOverlay.visible = false
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
      m.footerBg.color = "0x111C2DF0"
    else
      m.footerBg.color = "0x0A111DE0"
    end if
  end if

  if m.subtitle <> invalid then
    if focused then
      m.subtitle.color = "0xD5E1F2FF"
    else
      m.subtitle.color = "0x9FB0C5FF"
    end if
  end if
end sub

sub onOwnerGridItemFocusedChanged()
  applyStyle()
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

  if _sameItemId(focusedNode, m.top.itemContent) then return true
  if _sameItemPath(focusedNode, m.top.itemContent) then return true

  ta = _resolveContinueTitle(focusedNode)
  tb = _resolveContinueTitle(m.top.itemContent)
  if ta <> "" and tb <> "" then
    return (LCase(ta) = LCase(tb))
  end if
  return false
end function

function _sameItemId(a as Object, b as Object) as Boolean
  if a = invalid or b = invalid then return false
  aid = ""
  bid = ""
  if a.id <> invalid then aid = a.id.ToStr().Trim()
  if b.id <> invalid then bid = b.id.ToStr().Trim()
  if aid = "" or bid = "" then return false
  return (LCase(aid) = LCase(bid))
end function

function _sameItemPath(a as Object, b as Object) as Boolean
  if a = invalid or b = invalid then return false
  ap = ""
  bp = ""
  if a.path <> invalid then ap = a.path.ToStr().Trim()
  if b.path <> invalid then bp = b.path.ToStr().Trim()
  if ap = "" or bp = "" then return false
  return (LCase(ap) = LCase(bp))
end function

sub _ensureOwnerGridObserver()
  if m.ownerGrid <> invalid then return
  g = _resolveOwnerGrid()
  if g = invalid then return
  m.ownerGrid = g
  if m.ownerGrid.hasField("itemFocused") then
    m.ownerGrid.observeField("itemFocused", "onOwnerGridItemFocusedChanged")
  end if
end sub

sub _ensureBorderNodes()
  if m.thumbGroup = invalid then return
  if m.borderTop = invalid then m.borderTop = _createBorderRect("continueBorderTop", [0, 0], 248, 3)
  if m.borderBottom = invalid then m.borderBottom = _createBorderRect("continueBorderBottom", [0, 137], 248, 3)
  if m.borderLeft = invalid then m.borderLeft = _createBorderRect("continueBorderLeft", [0, 0], 3, 140)
  if m.borderRight = invalid then m.borderRight = _createBorderRect("continueBorderRight", [245, 0], 3, 140)
end sub

function _createBorderRect(id as String, tr as Object, w as Integer, h as Integer) as Object
  if m.thumbGroup = invalid then return invalid
  r = CreateObject("roSGNode", "Rectangle")
  if r = invalid then return invalid
  r.id = id
  r.translation = tr
  r.width = w
  r.height = h
  r.color = "0xD8B765FF"
  r.visible = false
  m.thumbGroup.appendChild(r)
  return r
end function

function _resumeRatio(c as Object) as Float
  if c = invalid then return 0

  posTicks = 0.0
  if c.positionTicks <> invalid then posTicks = Val(c.positionTicks.ToStr())
  if posTicks <= 0 and c.playbackPositionTicks <> invalid then posTicks = Val(c.playbackPositionTicks.ToStr())
  durTicks = 0.0
  if c.durationTicks <> invalid then durTicks = Val(c.durationTicks.ToStr())
  if durTicks <= 0 and c.runTimeTicks <> invalid then durTicks = Val(c.runTimeTicks.ToStr())
  if durTicks > 0 and posTicks > 0 then
    rTicks = posTicks / durTicks
    if rTicks < 0 then rTicks = 0
    if rTicks > 1 then rTicks = 1
    return rTicks
  end if

  posMs = 0
  if c.resumePositionMs <> invalid then posMs = Int(Val(c.resumePositionMs.ToStr()))
  if posMs <= 0 and c.positionMs <> invalid then posMs = Int(Val(c.positionMs.ToStr()))
  durMs = 0
  if c.resumeDurationMs <> invalid then durMs = Int(Val(c.resumeDurationMs.ToStr()))
  if durMs <= 0 and c.durationMs <> invalid then durMs = Int(Val(c.durationMs.ToStr()))

  r = 0.0
  if durMs > 0 and posMs > 0 then
    r = posMs / durMs
  else if c.resumePercent <> invalid then
    r = Val(c.resumePercent.ToStr()) / 100.0
  end if

  if r < 0 then r = 0
  if r > 1 then r = 1
  if r <= 0 and posMs > 0 then r = 0.01
  return r
end function

function _friendlyType(raw as String) as String
  t = raw
  if t = invalid then t = ""
  t = LCase(t.Trim())
  if t = "movie" then return "Movie"
  if t = "series" then return "Series"
  if t = "episode" then return "Episode"
  if t = "livetvchannel" or t = "livetv" then return "Live TV"
  return ""
end function

function _resolveContinueTitle(c as Object) as String
  if c = invalid then return ""
  t = ""
  if c.title <> invalid then t = c.title.ToStr().Trim()
  if t = "" and c.name <> invalid then t = c.name.ToStr().Trim()
  if t = "" and c.Name <> invalid then t = c.Name.ToStr().Trim()
  if t = "" and c.Title <> invalid then t = c.Title.ToStr().Trim()
  if t = "" and c.shortDescriptionLine1 <> invalid then t = c.shortDescriptionLine1.ToStr().Trim()
  if t = "" and c.longDescription <> invalid then t = c.longDescription.ToStr().Trim()
  return t
end function

function _fitContinueTitle(raw as Dynamic) as String
  t = ""
  if raw <> invalid then t = raw.ToStr().Trim()
  if t = "" then return ""
  maxChars = 28
  if Len(t) <= maxChars then return t
  return Left(t, maxChars - 3).Trim() + "..."
end function
