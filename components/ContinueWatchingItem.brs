sub init()
  m.cover = m.top.findNode("cover")
  m.focusOverlay = m.top.findNode("focusOverlay")
  m.title = m.top.findNode("title")
  m.subtitle = m.top.findNode("subtitle")
  m.progressBg = m.top.findNode("progressBg")
  m.progressFill = m.top.findNode("progressFill")
end sub

sub onItemContentChanged()
  c = m.top.itemContent
  if c = invalid then
    if m.cover <> invalid then m.cover.uri = ""
    if m.title <> invalid then m.title.text = ""
    if m.subtitle <> invalid then
      m.subtitle.text = ""
      m.subtitle.visible = false
    end if
    if m.progressBg <> invalid then m.progressBg.visible = false
    if m.progressFill <> invalid then m.progressFill.visible = false
    if m.focusOverlay <> invalid then m.focusOverlay.visible = false
    return
  end if

  ttl = ""
  if c.title <> invalid then ttl = c.title.ToStr().Trim()
  if m.title <> invalid then m.title.text = ttl

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
  if m.cover <> invalid then m.cover.uri = art

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

sub onItemHasFocusChanged()
  applyStyle()
end sub

sub applyStyle()
  focused = (m.top.itemHasFocus = true)
  if m.focusOverlay <> invalid then m.focusOverlay.visible = focused

  if m.title <> invalid then
    if focused then
      m.title.color = "0xFFFFFF"
    else
      m.title.color = "0xE6EBF3"
    end if
  end if

  if m.subtitle <> invalid then
    if focused then
      m.subtitle.color = "0xD5E1F2"
    else
      m.subtitle.color = "0x9FB0C5"
    end if
  end if
end sub

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
