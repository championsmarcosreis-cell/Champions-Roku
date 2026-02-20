sub init()
  m.cardBg = m.top.findNode("cardBg")
  m.focusRing = m.top.findNode("focusRing")
  m.cover = m.top.findNode("cover")
  m.textOverlay = m.top.findNode("textOverlay")
  m.title = m.top.findNode("title")
end sub

sub onItemContentChanged()
  c = m.top.itemContent
  if c = invalid then
    if m.cover <> invalid then
      if m.cover.hasField("loadDisplayMode") then m.cover.loadDisplayMode = "zoomToFill"
      m.cover.uri = ""
    end if
    if m.title <> invalid then m.title.text = ""
    if m.focusRing <> invalid then m.focusRing.visible = false
    return
  end if

  t = ""
  if c.title <> invalid then t = c.title.ToStr().Trim()
  if m.title <> invalid then m.title.text = t

  poster = ""
  if c.hdPosterUrl <> invalid then poster = c.hdPosterUrl.ToStr().Trim()
  if poster = "" and c.HDPosterUrl <> invalid then poster = c.HDPosterUrl.ToStr().Trim()
  if poster = "" and c.sdPosterUrl <> invalid then poster = c.sdPosterUrl.ToStr().Trim()
  if poster = "" and c.SDPosterUrl <> invalid then poster = c.SDPosterUrl.ToStr().Trim()
  if poster = "" and c.posterUrl <> invalid then poster = c.posterUrl.ToStr().Trim()
  if poster = "" then poster = "pkg:/images/logo.png"
  if m.cover <> invalid then m.cover.uri = poster

  applyStyle()
end sub

sub onItemHasFocusChanged()
  applyStyle()
end sub

sub applyStyle()
  focused = (m.top.itemHasFocus = true)
  if m.focusRing <> invalid then m.focusRing.visible = focused
  if m.textOverlay <> invalid then
    if focused then
      m.textOverlay.color = "0xD20A111D"
    else
      m.textOverlay.color = "0xB00A111D"
    end if
  end if
  if m.title <> invalid then
    if focused then
      m.title.color = "0xFFFFFF"
    else
      m.title.color = "0xE6EBF3"
    end if
  end if
end sub
