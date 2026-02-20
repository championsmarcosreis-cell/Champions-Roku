sub init()
  m.cardBg = m.top.findNode("cardBg")
  m.cover = m.top.findNode("cover")
  m.title = m.top.findNode("title")
  m.meta = m.top.findNode("meta")
  m.progressBg = m.top.findNode("progressBg")
  m.progressFill = m.top.findNode("progressFill")
  m.rankBadgeBg = m.top.findNode("rankBadgeBg")
  m.rankBadgeText = m.top.findNode("rankBadgeText")
end sub

sub onItemContentChanged()
  c = m.top.itemContent
  if c = invalid then
    if m.cover <> invalid then m.cover.uri = ""
    if m.title <> invalid then m.title.text = ""
    if m.meta <> invalid then m.meta.text = ""
    if m.progressBg <> invalid then m.progressBg.visible = false
    if m.progressFill <> invalid then m.progressFill.visible = false
    if m.rankBadgeBg <> invalid then m.rankBadgeBg.visible = false
    if m.rankBadgeText <> invalid then m.rankBadgeText.visible = false
    return
  end if

  t = ""
  if c.title <> invalid then t = c.title.ToStr().Trim()
  if m.title <> invalid then m.title.text = t

  itemType = ""
  if c.itemType <> invalid then itemType = c.itemType.ToStr().Trim()
  if m.meta <> invalid then m.meta.text = friendlyType(itemType)

  poster = ""
  if c.hdPosterUrl <> invalid then poster = c.hdPosterUrl.ToStr().Trim()
  if poster = "" and c.HDPosterUrl <> invalid then poster = c.HDPosterUrl.ToStr().Trim()
  if poster = "" and c.sdPosterUrl <> invalid then poster = c.sdPosterUrl.ToStr().Trim()
  if poster = "" and c.SDPosterUrl <> invalid then poster = c.SDPosterUrl.ToStr().Trim()
  if poster = "" and c.posterUrl <> invalid then poster = c.posterUrl.ToStr().Trim()
  if m.cover <> invalid then m.cover.uri = poster

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
    if pct > 0 then m.progressFill.width = Int(3.4 * pct)
  end if

  rank = 0
  if c.rank <> invalid then rank = Int(Val(c.rank.ToStr()))
  if rank > 0 and rank <= 3 then
    if m.rankBadgeBg <> invalid then m.rankBadgeBg.visible = true
    if m.rankBadgeText <> invalid then
      m.rankBadgeText.visible = true
      m.rankBadgeText.text = "TOP " + rank.ToStr()
    end if
  else
    if m.rankBadgeBg <> invalid then m.rankBadgeBg.visible = false
    if m.rankBadgeText <> invalid then m.rankBadgeText.visible = false
  end if

  applyStyle()
end sub

sub onItemHasFocusChanged()
  applyStyle()
end sub

sub applyStyle()
  focused = (m.top.itemHasFocus = true)
  if m.cardBg <> invalid then m.cardBg.uri = "pkg:/images/card.png"
  if m.title <> invalid then
    if focused then
      m.title.color = "0xFFFFFF"
    else
      m.title.color = "0xE6EBF3"
    end if
  end if
  if m.rankBadgeBg <> invalid and m.rankBadgeBg.visible = true then
    if focused then
      m.rankBadgeBg.uri = "pkg:/images/button_focus.png"
    else
      m.rankBadgeBg.uri = "pkg:/images/button_normal.png"
    end if
  end if
  if m.rankBadgeText <> invalid and m.rankBadgeText.visible = true then
    if focused then
      m.rankBadgeText.color = "0x0B0F16"
    else
      m.rankBadgeText.color = "0x0B0F16"
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
