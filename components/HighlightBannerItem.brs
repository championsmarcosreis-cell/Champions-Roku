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
  if m.cover <> invalid and m.cover.hasField("loadStatus") then
    m.cover.observeField("loadStatus", "onCoverLoadStatusChanged")
  end if
end sub

sub onItemContentChanged()
  c = m.top.itemContent
  if c = invalid then
    m.coverFallbackPoster = ""
    _resetCoverLayout()
    _applyCover("", "zoomToFill")
    if m.focusRing <> invalid then m.focusRing.visible = false
    if m.focusOverlay <> invalid then m.focusOverlay.visible = false
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
  focused = (m.top.itemHasFocus = true)
  if m.cardBg <> invalid then
    m.cardBg.uri = "pkg:/images/card.png"
    m.cardBg.visible = false
  end if
  if m.focusRing <> invalid then m.focusRing.visible = false
  if m.focusOverlay <> invalid then m.focusOverlay.visible = focused

  if m.overlayFade <> invalid then
    if focused then
      m.overlayFade.uri = "pkg:/images/overlay_fade_banner_focus_560x318.png"
    else
      m.overlayFade.uri = "pkg:/images/overlay_fade_banner_560x318.png"
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
    m.rankBadgeBorder.uri = borderUri
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
    m.rankBadgeBg.uri = badgeUri
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
