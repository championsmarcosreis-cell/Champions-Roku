sub init()
  m.cardBg = m.top.findNode("cardBg")
  m.focusRing = m.top.findNode("focusRing")
  m.cover = m.top.findNode("cover")
  m.textOverlay = m.top.findNode("textOverlay")
  m.title = m.top.findNode("title")
  m.meta = m.top.findNode("meta")
  m.progressBg = m.top.findNode("progressBg")
  m.progressFill = m.top.findNode("progressFill")
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
  if pct < 0 then pct = 0
  if pct > 100 then pct = 100

  if m.progressBg <> invalid then m.progressBg.visible = (pct > 0)
  if m.progressFill <> invalid then
    m.progressFill.visible = (pct > 0)
    if pct > 0 then m.progressFill.width = Int(1.18 * pct)
  end if

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
