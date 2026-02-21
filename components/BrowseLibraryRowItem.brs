sub init()
  m.bg = m.top.findNode("bg")
  m.focusRing = m.top.findNode("focusRing")
  m.cover = m.top.findNode("cover")
  m.accent = m.top.findNode("accent")
  m.title = m.top.findNode("title")
  m.meta = m.top.findNode("meta")
  m.progressBg = m.top.findNode("progressBg")
  m.progressFill = m.top.findNode("progressFill")
  m.completeBadgeBg = m.top.findNode("completeBadgeBg")
  m.completeBadgeText = m.top.findNode("completeBadgeText")
end sub

sub onItemContentChanged()
  c = m.top.itemContent
  if c = invalid then
    if m.cover <> invalid then m.cover.uri = ""
    if m.title <> invalid then m.title.text = ""
    if m.meta <> invalid then m.meta.text = ""
    if m.progressBg <> invalid then m.progressBg.visible = false
    if m.progressFill <> invalid then m.progressFill.visible = false
    if m.completeBadgeBg <> invalid then m.completeBadgeBg.visible = false
    if m.completeBadgeText <> invalid then m.completeBadgeText.visible = false
    if m.focusRing <> invalid then m.focusRing.visible = false
    return
  end if

  t = ""
  if c.title <> invalid then t = c.title.ToStr().Trim()
  if m.title <> invalid then m.title.text = t

  typ = ""
  if c.itemType <> invalid then typ = c.itemType.ToStr().Trim()
  if m.meta <> invalid then m.meta.text = friendlyType(typ)

  poster = ""
  if c.hdPosterUrl <> invalid then poster = c.hdPosterUrl.ToStr().Trim()
  if poster = "" and c.HDPosterUrl <> invalid then poster = c.HDPosterUrl.ToStr().Trim()
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
    if showProgress then m.progressFill.width = Int(0.68 * pct)
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
  if m.bg <> invalid then
    if focused then
      m.bg.uri = "pkg:/images/field_focus.png"
    else
      m.bg.uri = "pkg:/images/field_normal.png"
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
  if m.accent <> invalid then
    if focused then
      m.accent.color = "0xD7B25C"
    else
      m.accent.color = "0x2B3950"
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
