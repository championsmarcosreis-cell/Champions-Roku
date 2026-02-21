sub init()
  m.cardBg = m.top.findNode("cardBg")
  m.focusRing = m.top.findNode("focusRing")
  m.cover = m.top.findNode("cover")
  m.overlayFadeA = m.top.findNode("overlayFadeA")
  m.overlayFadeB = m.top.findNode("overlayFadeB")
  m.overlayFadeC = m.top.findNode("overlayFadeC")
  m.title = m.top.findNode("title")
  m.meta = m.top.findNode("meta")
  m.progressBg = m.top.findNode("progressBg")
  m.progressFill = m.top.findNode("progressFill")
  m.rankBadgeBorder = m.top.findNode("rankBadgeBorder")
  m.rankBadgeBg = m.top.findNode("rankBadgeBg")
  m.rankBadgeText = m.top.findNode("rankBadgeText")
  m.rankValue = 0
  m.lastCoverUri = ""
  m.coverFallbackPoster = ""
  m.coverUsingWide = false
  if m.cover <> invalid and m.cover.hasField("loadStatus") then
    m.cover.observeField("loadStatus", "onCoverLoadStatusChanged")
  end if
end sub

sub onItemContentChanged()
  c = m.top.itemContent
  if c = invalid then
    m.coverFallbackPoster = ""
    m.coverUsingWide = false
    _applyCover("", "zoomToFill")
    if m.focusRing <> invalid then m.focusRing.visible = false
    if m.title <> invalid then m.title.text = ""
    if m.meta <> invalid then m.meta.text = ""
    if m.progressBg <> invalid then m.progressBg.visible = false
    if m.progressFill <> invalid then m.progressFill.visible = false
    if m.rankBadgeBorder <> invalid then m.rankBadgeBorder.visible = false
    if m.rankBadgeBg <> invalid then m.rankBadgeBg.visible = false
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
  m.coverUsingWide = (wide <> "" and wide <> poster)
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
    if pct > 0 then m.progressFill.width = Int(5.56 * pct)
  end if

  rank = 0
  if c.rank <> invalid then rank = Int(Val(c.rank.ToStr()))
  m.rankValue = rank
  if rank > 0 and rank <= 3 then
    if m.rankBadgeBorder <> invalid then m.rankBadgeBorder.visible = true
    if m.rankBadgeBg <> invalid then m.rankBadgeBg.visible = true
    if m.rankBadgeText <> invalid then
      m.rankBadgeText.visible = true
      m.rankBadgeText.text = "TOP " + rank.ToStr()
    end if
  else
    if m.rankBadgeBorder <> invalid then m.rankBadgeBorder.visible = false
    if m.rankBadgeBg <> invalid then m.rankBadgeBg.visible = false
    if m.rankBadgeText <> invalid then m.rankBadgeText.visible = false
  end if

  applyStyle()
end sub

sub onCoverLoadStatusChanged()
  if m.cover = invalid then return
  if m.coverUsingWide <> true then return
  if m.coverFallbackPoster = invalid or m.coverFallbackPoster = "" then return
  st = m.cover.loadStatus
  if st = invalid then return
  s = LCase(st.ToStr().Trim())
  if s = "failed" then
    m.coverUsingWide = false
    _applyCover(m.coverFallbackPoster, "zoomToFill")
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
  if m.cover.hasField("loadDisplayMode") then m.cover.loadDisplayMode = md

  nextUri = uri
  if nextUri = invalid then nextUri = ""
  nextUri = nextUri.ToStr().Trim()
  if nextUri = "" then nextUri = "pkg:/images/logo.png"

  if m.lastCoverUri <> nextUri then
    m.cover.uri = nextUri
    m.lastCoverUri = nextUri
  end if
end sub

sub applyStyle()
  focused = (m.top.itemHasFocus = true)
  if m.cardBg <> invalid then m.cardBg.uri = "pkg:/images/card.png"
  if m.focusRing <> invalid then m.focusRing.visible = focused

  fadeA = "0x400A111D"
  fadeB = "0x7E0A111D"
  fadeC = "0xB40A111D"
  if focused then
    fadeA = "0x520A111D"
    fadeB = "0x900A111D"
    fadeC = "0xC40A111D"
  end if
  if m.overlayFadeA <> invalid then m.overlayFadeA.color = fadeA
  if m.overlayFadeB <> invalid then m.overlayFadeB.color = fadeB
  if m.overlayFadeC <> invalid then m.overlayFadeC.color = fadeC

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
    border = "0x2D3A4E"
    if rank = 1 then
      border = "0xAD8D3E"
    else if rank = 2 then
      border = "0x9BA3B2"
    else if rank = 3 then
      border = "0x9C6947"
    end if
    if focused then border = "0xE0E8F5"
    m.rankBadgeBorder.color = border
  end if

  if m.rankBadgeBg <> invalid and m.rankBadgeBg.visible = true then
    rank = Int(m.rankValue)
    badge = "0x1C2635"
    if rank = 1 then
      badge = "0xD7B25C"
    else if rank = 2 then
      badge = "0xBFC7D4"
    else if rank = 3 then
      badge = "0xC17F59"
    end if
    m.rankBadgeBg.color = badge
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
