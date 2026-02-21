sub init()
  m.cardBg = m.top.findNode("cardBg")
  m.focusRing = m.top.findNode("focusRing")
  m.cover = m.top.findNode("cover")
  m.textOverlay = m.top.findNode("textOverlay")
  m.title = m.top.findNode("title")
  m.meta = m.top.findNode("meta")
  m.progressBg = m.top.findNode("progressBg")
  m.progressFill = m.top.findNode("progressFill")
  m.rankBadgeBorder = m.top.findNode("rankBadgeBorder")
  m.rankBadgeBg = m.top.findNode("rankBadgeBg")
  m.rankBadgeIcon = m.top.findNode("rankBadgeIcon")
  m.rankBadgeText = m.top.findNode("rankBadgeText")
  m.rankValue = 0
  m.completeBadgeBg = m.top.findNode("completeBadgeBg")
  m.completeBadgeText = m.top.findNode("completeBadgeText")
end sub

sub onItemContentChanged()
  c = m.top.itemContent
  if c = invalid then
    if m.cover <> invalid then
      if m.cover.hasField("loadDisplayMode") then m.cover.loadDisplayMode = "zoomToFill"
      m.cover.uri = ""
    end if
    if m.focusRing <> invalid then m.focusRing.visible = false
    if m.title <> invalid then m.title.text = ""
    if m.meta <> invalid then m.meta.text = ""
    if m.progressBg <> invalid then m.progressBg.visible = false
    if m.progressFill <> invalid then m.progressFill.visible = false
    if m.rankBadgeBorder <> invalid then m.rankBadgeBorder.visible = false
    if m.rankBadgeBg <> invalid then m.rankBadgeBg.visible = false
    if m.rankBadgeIcon <> invalid then m.rankBadgeIcon.visible = false
    if m.rankBadgeText <> invalid then m.rankBadgeText.visible = false
    m.rankValue = 0
    if m.completeBadgeBg <> invalid then m.completeBadgeBg.visible = false
    if m.completeBadgeText <> invalid then m.completeBadgeText.visible = false
    return
  end if

  t = ""
  if c.title <> invalid then t = c.title.ToStr().Trim()
  if m.title <> invalid then m.title.text = t

  itemType = ""
  if c.itemType <> invalid then itemType = c.itemType.ToStr().Trim()
  if m.meta <> invalid then m.meta.text = friendlyType(itemType)
  if m.meta <> invalid then m.meta.visible = false

  poster = ""
  if c.hdPosterUrl <> invalid then poster = c.hdPosterUrl.ToStr().Trim()
  if poster = "" and c.HDPosterUrl <> invalid then poster = c.HDPosterUrl.ToStr().Trim()
  if poster = "" and c.sdPosterUrl <> invalid then poster = c.sdPosterUrl.ToStr().Trim()
  if poster = "" and c.SDPosterUrl <> invalid then poster = c.SDPosterUrl.ToStr().Trim()
  if poster = "" and c.posterUrl <> invalid then poster = c.posterUrl.ToStr().Trim()
  if poster = "" then poster = "pkg:/images/logo.png"
  if m.cover <> invalid then m.cover.uri = poster

  pct = 0
  if c.resumePercent <> invalid then
    pct = Int(Val(c.resumePercent.ToStr()))
  else if c.percent <> invalid then
    pct = Int(Val(c.percent.ToStr()))
  end if
  played = false
  if c.played <> invalid then played = (c.played = true)
  if pct < 0 then pct = 0
  if pct > 100 then pct = 100
  if pct >= 98 then played = true
  if played = true and pct < 100 then pct = 100

  showProgress = (pct > 0 and played <> true)
  if m.progressBg <> invalid then m.progressBg.visible = showProgress
  if m.progressFill <> invalid then
    m.progressFill.visible = showProgress
    if showProgress then m.progressFill.width = Int(1.24 * pct)
  end if

  rank = 0
  if c.rank <> invalid then rank = Int(Val(c.rank.ToStr()))
  m.rankValue = rank
  showRank = (rank > 0 and rank <= 10)
  if m.rankBadgeBorder <> invalid then m.rankBadgeBorder.visible = showRank
  if m.rankBadgeBg <> invalid then m.rankBadgeBg.visible = showRank
  if m.rankBadgeText <> invalid then
    m.rankBadgeText.visible = showRank
    if rank > 0 and rank <= 3 then
      m.rankBadgeText.text = "TOP " + rank.ToStr()
    else if rank > 3 then
      m.rankBadgeText.text = "#" + rank.ToStr()
    else
      m.rankBadgeText.text = ""
    end if
  end if
  if m.rankBadgeIcon <> invalid then m.rankBadgeIcon.visible = (showRank and rank > 0 and rank <= 3)
  if m.rankBadgeText <> invalid then
    if rank > 0 and rank <= 3 then
      m.rankBadgeText.translation = [44, 14]
      m.rankBadgeText.width = 40
    else
      m.rankBadgeText.translation = [31, 14]
      m.rankBadgeText.width = 54
    end if
  end if

  if m.completeBadgeBg <> invalid then m.completeBadgeBg.visible = played
  if m.completeBadgeText <> invalid then m.completeBadgeText.visible = played

  applyStyle()
end sub

sub onItemHasFocusChanged()
  applyStyle()
end sub

sub applyStyle()
  focused = (m.top.itemHasFocus = true)
  if m.focusRing <> invalid then m.focusRing.visible = focused
  if m.textOverlay <> invalid then
    m.textOverlay.color = "0x00000000"
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

  if m.completeBadgeBg <> invalid and m.completeBadgeBg.visible = true then
    if focused then
      m.completeBadgeBg.color = "0x41D983"
    else
      m.completeBadgeBg.color = "0x33C86B"
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
