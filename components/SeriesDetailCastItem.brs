sub init()
  m.cardBg = m.top.findNode("cardBg")
  m.focusRing = m.top.findNode("focusRing")
  m.cover = m.top.findNode("cover")
  m.title = m.top.findNode("title")
  m.role = m.top.findNode("role")
end sub

sub onItemContentChanged()
  c = m.top.itemContent
  if c = invalid then
    if m.cover <> invalid then m.cover.uri = ""
    if m.title <> invalid then m.title.text = ""
    if m.role <> invalid then m.role.text = ""
    if m.focusRing <> invalid then m.focusRing.visible = false
    return
  end if

  t = ""
  if c.title <> invalid then t = c.title.ToStr().Trim()
  if m.title <> invalid then m.title.text = t
  r = ""
  if c.meta <> invalid then r = c.meta.ToStr().Trim()
  if m.role <> invalid then
    m.role.text = r
    m.role.visible = (r <> "")
  end if

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
  if m.title <> invalid then
    if focused then
      m.title.color = "0xFFFFFF"
    else
      m.title.color = "0xE6EBF3"
    end if
  end if
  if m.role <> invalid then m.role.color = "0xAAB4C2"
end sub
