sub init()
  m.cardBg = m.top.findNode("cardBg")
  m.focusRing = m.top.findNode("focusRing")
  m.coverBg = m.top.findNode("coverBg")
  m.cover = m.top.findNode("cover")
  m.focusOverlay = m.top.findNode("focusOverlay")
  m.overlayFade = m.top.findNode("overlayFade")
  m.title = m.top.findNode("title")
  m.meta = m.top.findNode("meta")
  m.progressBg = m.top.findNode("progressBg")
  m.progressFill = m.top.findNode("progressFill")
  m.rankBadgeBorder = m.top.findNode("rankBadgeBorder")
  m.rankBadgeBg = m.top.findNode("rankBadgeBg")
  m.rankBadgeIcon = m.top.findNode("rankBadgeIcon")
  m.rankBadgeText = m.top.findNode("rankBadgeText")
  m.rankValue = 0
  m.lastCoverUri = ""
  m.coverFallbackPoster = ""
  m.coverTargetW = 560
  m.coverTargetH = 318
  m.contentNode = invalid
  m.ownerGrid = invalid
  m.overlayFocused = false
  if m.cover <> invalid and m.cover.hasField("loadStatus") then
    m.cover.observeField("loadStatus", "onCoverLoadStatusChanged")
  end if
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
    m.coverFallbackPoster = ""
    _resetCoverLayout()
    _applyCover("", "zoomToFill")
    if m.focusRing <> invalid then m.focusRing.visible = false
    if m.focusOverlay <> invalid then m.focusOverlay.visible = false
    if m.overlayFade <> invalid then m.overlayFade.opacity = 1.0
    if m.title <> invalid then m.title.text = ""
    if m.meta <> invalid then m.meta.text = ""
    if m.progressBg <> invalid then m.progressBg.visible = false
    if m.progressFill <> invalid then m.progressFill.visible = false
    if m.rankBadgeBorder <> invalid then m.rankBadgeBorder.visible = false
    if m.rankBadgeBg <> invalid then m.rankBadgeBg.visible = false
    if m.rankBadgeIcon <> invalid then m.rankBadgeIcon.visible = false
    if m.rankBadgeText <> invalid then m.rankBadgeText.visible = false
    m.rankValue = 0
    return
  end if

  t = ""
  if c.title <> invalid then t = c.title.ToStr().Trim()
  if m.title <> invalid then m.title.text = t

  itemType = ""
  if c.itemType <> invalid then itemType = c.itemType.ToStr().Trim()
  if m.meta <> invalid then m.meta.text = friendlyType(itemType)

  poster = ""
  wide = ""
  if c.wideUrl <> invalid then poster = c.wideUrl.ToStr().Trim()
  if poster <> "" then wide = poster
  if wide = "" and c.bannerUrl <> invalid then wide = c.bannerUrl.ToStr().Trim()
  if wide = "" and c.backdropUrl <> invalid then wide = c.backdropUrl.ToStr().Trim()
  if wide = "" and c.thumbWideUrl <> invalid then wide = c.thumbWideUrl.ToStr().Trim()
  if wide = "" and c.hdPosterUrl <> invalid then wide = c.hdPosterUrl.ToStr().Trim()
  if wide = "" and c.HDPosterUrl <> invalid then wide = c.HDPosterUrl.ToStr().Trim()

  poster = ""
  if c.posterUrl <> invalid then poster = c.posterUrl.ToStr().Trim()
  if poster = "" and c.sdPosterUrl <> invalid then poster = c.sdPosterUrl.ToStr().Trim()
  if poster = "" and c.SDPosterUrl <> invalid then poster = c.SDPosterUrl.ToStr().Trim()
  if poster = "" and c.hdPosterUrl <> invalid then poster = c.hdPosterUrl.ToStr().Trim()
  if poster = "" and c.HDPosterUrl <> invalid then poster = c.HDPosterUrl.ToStr().Trim()

  mode = "zoomToFill"
  if c.posterMode <> invalid then
    mode = c.posterMode.ToStr().Trim()
    if mode = "" then mode = "zoomToFill"
  end if
  if poster = "" then poster = "pkg:/images/logo.png"
  if wide = "" then wide = poster
  m.coverFallbackPoster = poster
  _applyCover(wide, mode)

  pct = 0
  if c.resumePercent <> invalid then
    pct = Int(Val(c.resumePercent.ToStr()))
  else if c.percent <> invalid then
    pct = Int(Val(c.percent.ToStr()))
  end if
  if pct < 0 then pct = 0
  if pct > 100 then pct = 100

  if m.progressBg <> invalid then m.progressBg.visible = (pct > 0)
  if m.progressFill <> invalid then
    m.progressFill.visible = (pct > 0)
    if pct > 0 then m.progressFill.width = Int(5.60 * pct)
  end if

  rank = 0
  if c.rank <> invalid then rank = Int(Val(c.rank.ToStr()))
  m.rankValue = rank
  showRank = (rank > 0 and rank <= 10)
  if showRank then
    if m.rankBadgeBorder <> invalid then m.rankBadgeBorder.visible = true
    if m.rankBadgeBg <> invalid then m.rankBadgeBg.visible = true
    if m.rankBadgeIcon <> invalid then m.rankBadgeIcon.visible = (rank <= 3)
    if m.rankBadgeText <> invalid then
      m.rankBadgeText.visible = true
      if rank <= 3 then
        m.rankBadgeText.text = "TOP" + rank.ToStr()
        m.rankBadgeText.translation = [35, 17]
        m.rankBadgeText.width = 62
      else
        m.rankBadgeText.text = "#" + rank.ToStr()
        m.rankBadgeText.translation = [32, 17]
        m.rankBadgeText.width = 64
      end if
    end if
  else
    if m.rankBadgeBorder <> invalid then m.rankBadgeBorder.visible = false
    if m.rankBadgeBg <> invalid then m.rankBadgeBg.visible = false
    if m.rankBadgeIcon <> invalid then m.rankBadgeIcon.visible = false
    if m.rankBadgeText <> invalid then m.rankBadgeText.visible = false
  end if

  applyStyle()
end sub

sub _clearContentObservers()
  c = m.contentNode
  if c = invalid then return
  if c.hasField("title") then c.unobserveField("title")
  if c.hasField("wideUrl") then c.unobserveField("wideUrl")
  if c.hasField("bannerUrl") then c.unobserveField("bannerUrl")
  if c.hasField("backdropUrl") then c.unobserveField("backdropUrl")
  if c.hasField("thumbWideUrl") then c.unobserveField("thumbWideUrl")
  if c.hasField("hdPosterUrl") then c.unobserveField("hdPosterUrl")
  if c.hasField("posterUrl") then c.unobserveField("posterUrl")
  if c.hasField("posterMode") then c.unobserveField("posterMode")
  if c.hasField("resumePercent") then c.unobserveField("resumePercent")
  if c.hasField("played") then c.unobserveField("played")
  if c.hasField("rank") then c.unobserveField("rank")
  m.contentNode = invalid
end sub

sub _observeContent(c as Object)
  if c = invalid then return
  m.contentNode = c
  if c.hasField("title") then c.observeField("title", "onContentFieldChanged")
  if c.hasField("wideUrl") then c.observeField("wideUrl", "onContentFieldChanged")
  if c.hasField("bannerUrl") then c.observeField("bannerUrl", "onContentFieldChanged")
  if c.hasField("backdropUrl") then c.observeField("backdropUrl", "onContentFieldChanged")
  if c.hasField("thumbWideUrl") then c.observeField("thumbWideUrl", "onContentFieldChanged")
  if c.hasField("hdPosterUrl") then c.observeField("hdPosterUrl", "onContentFieldChanged")
  if c.hasField("posterUrl") then c.observeField("posterUrl", "onContentFieldChanged")
  if c.hasField("posterMode") then c.observeField("posterMode", "onContentFieldChanged")
  if c.hasField("resumePercent") then c.observeField("resumePercent", "onContentFieldChanged")
  if c.hasField("played") then c.observeField("played", "onContentFieldChanged")
  if c.hasField("rank") then c.observeField("rank", "onContentFieldChanged")
end sub
sub onCoverLoadStatusChanged()
  if m.cover = invalid then return
  st = m.cover.loadStatus
  if st = invalid then return
  s = LCase(st.ToStr().Trim())
  if s = "failed" then
    if m.coverFallbackPoster <> invalid and m.coverFallbackPoster <> "" then
      _applyCover(m.coverFallbackPoster, "zoomToFill")
    end if
  end if
end sub

sub onItemHasFocusChanged()
  _ensureOwnerGridObserver()
  applyStyle()
end sub

sub _applyCover(uri as String, mode as String)
  if m.cover = invalid then return

  md = mode
  if md = invalid then md = ""
  md = md.ToStr().Trim()
  if md = "" then md = "zoomToFill"
  md = _normalizePosterMode(md)
  if m.cover.hasField("loadDisplayMode") then m.cover.loadDisplayMode = md

  nextUri = uri
  if nextUri = invalid then nextUri = ""
  nextUri = nextUri.ToStr().Trim()
  if nextUri = "" then nextUri = "pkg:/images/logo.png"

  _resetCoverLayout()
  if m.lastCoverUri <> nextUri then
    m.cover.uri = nextUri
    m.lastCoverUri = nextUri
  end if
end sub

sub _resetCoverLayout()
  if m.cover = invalid then return
  w = m.coverTargetW
  h = m.coverTargetH
  if w = invalid then w = 560
  if h = invalid then h = 318
  if m.cover.hasField("loadWidth") then m.cover.loadWidth = w
  if m.cover.hasField("loadHeight") then m.cover.loadHeight = h
  if m.cover.hasField("width") then m.cover.width = w
  if m.cover.hasField("height") then m.cover.height = h
  if m.cover.hasField("translation") then m.cover.translation = [0, 0]
end sub

function _normalizePosterMode(raw as String) as String
  md = raw
  if md = invalid then md = ""
  md = md.ToStr().Trim()
  if md = "" then return "zoomToFill"
  return md
end function

sub applyStyle()
  focused = _isFocusedTile()
  if m.cardBg <> invalid then
    m.cardBg.uri = "pkg:/images/card.png"
    m.cardBg.visible = false
  end if
  if m.focusRing <> invalid then m.focusRing.visible = false
  if m.focusOverlay <> invalid then m.focusOverlay.visible = focused

  if m.overlayFade <> invalid then
    if focused then
      m.overlayFade.opacity = 0.82
    else
      m.overlayFade.opacity = 1.0
    end if
  end if

  if m.title <> invalid then
    if focused then
      m.title.color = "0xFFFFFF"
    else
      m.title.color = "0xE6EBF3"
    end if
  end if
  if m.meta <> invalid then
    if focused then
      m.meta.color = "0xD5E1F2"
    else
      m.meta.color = "0x9FB0C5"
    end if
  end if

  if m.rankBadgeBorder <> invalid and m.rankBadgeBorder.visible = true then
    rank = Int(m.rankValue)
    borderUri = "pkg:/images/rank_badge_border_dark_92x28.png"
    if rank = 1 then
      borderUri = "pkg:/images/rank_badge_border_gold_92x28.png"
    else if rank = 2 then
      borderUri = "pkg:/images/rank_badge_border_silver_92x28.png"
    else if rank = 3 then
      borderUri = "pkg:/images/rank_badge_border_bronze_92x28.png"
    end if
    if focused then borderUri = "pkg:/images/rank_badge_border_focus_92x28.png"
    _setPosterUriIfChanged(m.rankBadgeBorder, borderUri)
  end if

  if m.rankBadgeBg <> invalid and m.rankBadgeBg.visible = true then
    rank = Int(m.rankValue)
    badgeUri = "pkg:/images/rank_badge_bg_dark_90x26.png"
    if rank = 1 then
      badgeUri = "pkg:/images/rank_badge_bg_gold_90x26.png"
    else if rank = 2 then
      badgeUri = "pkg:/images/rank_badge_bg_silver_90x26.png"
    else if rank = 3 then
      badgeUri = "pkg:/images/rank_badge_bg_bronze_90x26.png"
    end if
    _setPosterUriIfChanged(m.rankBadgeBg, badgeUri)
  end if

  if m.rankBadgeText <> invalid and m.rankBadgeText.visible = true then
    rank = Int(m.rankValue)
    if rank > 0 and rank <= 3 then
      m.rankBadgeText.color = "0x0B0F16"
    else
      m.rankBadgeText.color = "0xFFFFFF"
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

sub _setPosterUriIfChanged(n as Object, uri as String)
  if n = invalid then return
  if uri = invalid then uri = ""
  nextUri = uri.ToStr().Trim()
  curUri = ""
  if n.uri <> invalid then curUri = n.uri.ToStr().Trim()
  if curUri = nextUri then return
  n.uri = nextUri
end sub

function friendlyType(raw as String) as String
  t = raw
  if t = invalid then t = ""
  t = LCase(t.Trim())
  if t = "movie" then return "Movie"
  if t = "series" then return "Series"
  if t = "episode" then return "Episode"
  if t = "livetvchannel" or t = "livetv" then return "Live TV"
  return raw
end function
