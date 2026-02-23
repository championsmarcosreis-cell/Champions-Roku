sub init()
  m.posterBg = m.top.findNode("posterBg")
  m.poster = m.top.findNode("p")
  m.progressBg = m.top.findNode("progressBg")
  m.progressFill = m.top.findNode("progressFill")
  m.focusBorder = m.top.findNode("focus")
  m.title = m.top.findNode("t")
end sub

sub onItemContentChanged()
  c = m.top.itemContent
  if c = invalid then
    if m.poster <> invalid then m.poster.uri = ""
    if m.progressBg <> invalid then m.progressBg.visible = false
    if m.progressFill <> invalid then
      m.progressFill.visible = false
      m.progressFill.width = 0
    end if
    if m.title <> invalid then m.title.text = ""
    if m.focusBorder <> invalid then m.focusBorder.visible = false
    return
  end if

  posterUri = _posterUriFromContent(c)
  if m.poster <> invalid then m.poster.uri = posterUri

  titleText = ""
  if c.title <> invalid then titleText = c.title.ToStr().Trim()
  if m.title <> invalid then m.title.text = _fitPosterTitle(titleText)

  pct = _resumePercentFromContent(c)
  played = false
  if c.played <> invalid then played = (c.played = true)
  if pct >= 98 then played = true

  hasProgressSignal = _hasResumeSignal(c)
  showProgress = ((pct > 0 or hasProgressSignal) and played <> true)
  if m.progressBg <> invalid then m.progressBg.visible = showProgress
  if m.progressFill <> invalid then
    m.progressFill.visible = showProgress
    if showProgress then
      w = Int((160.0 * pct) / 100.0)
      if w < 2 then w = 2
      if w > 160 then w = 160
      m.progressFill.width = w
    else
      m.progressFill.width = 0
    end if
  end if

  applyStyle()
end sub

sub onItemHasFocusChanged()
  applyStyle()
end sub

sub applyStyle()
  focused = (m.top.itemHasFocus = true)
  if m.focusBorder <> invalid then m.focusBorder.visible = focused
  if m.title <> invalid then
    if focused then
      m.title.color = "0xFFFFFFFF"
    else
      m.title.color = "0xE6EBF3FF"
    end if
  end if
  if m.posterBg <> invalid then
    if focused then
      m.posterBg.color = "0x111C2DFF"
    else
      m.posterBg.color = "0x0A111DFF"
    end if
  end if
end sub

function _posterUriFromContent(c as Object) as String
  if c = invalid then return "pkg:/images/logo.png"

  p = ""
  if c.hdPosterUrl <> invalid then p = c.hdPosterUrl.ToStr().Trim()
  if p = "" and c.HDPosterUrl <> invalid then p = c.HDPosterUrl.ToStr().Trim()
  if p = "" and c.sdPosterUrl <> invalid then p = c.sdPosterUrl.ToStr().Trim()
  if p = "" and c.SDPosterUrl <> invalid then p = c.SDPosterUrl.ToStr().Trim()
  if p = "" and c.posterUrl <> invalid then p = c.posterUrl.ToStr().Trim()
  if p = "" then p = "pkg:/images/logo.png"
  return p
end function

function _fitPosterTitle(raw as Dynamic) as String
  t = ""
  if raw <> invalid then t = raw.ToStr()
  t = t.Trim()
  if t = "" then return ""

  maxChars = 34
  if Len(t) <= maxChars then return t

  keep = maxChars - 3
  if keep < 1 then keep = 1
  return Left(t, keep).Trim() + "..."
end function

function _resumePercentFromContent(c as Object) as Integer
  if c = invalid then return 0

  pct = 0
  if c.resumePercent <> invalid then
    pct = Int(Val(c.resumePercent.ToStr()))
  else if c.percent <> invalid then
    pct = Int(Val(c.percent.ToStr()))
  else
    posMs = 0
    durMs = 0
    if c.resumePositionMs <> invalid then posMs = Int(Val(c.resumePositionMs.ToStr()))
    if c.resumeDurationMs <> invalid then durMs = Int(Val(c.resumeDurationMs.ToStr()))
    if durMs > 0 and posMs > 0 then pct = Int((100.0 * posMs) / durMs)
  end if

  if pct < 0 then pct = 0
  if pct > 100 then pct = 100
  return pct
end function

function _hasResumeSignal(c as Object) as Boolean
  if c = invalid then return false

  posMs = 0
  if c.resumePositionMs <> invalid then posMs = Int(Val(c.resumePositionMs.ToStr()))
  if posMs <= 0 and c.positionMs <> invalid then posMs = Int(Val(c.positionMs.ToStr()))
  if posMs > 0 then return true

  pct = 0
  if c.resumePercent <> invalid then pct = Int(Val(c.resumePercent.ToStr()))
  if pct <= 0 and c.percent <> invalid then pct = Int(Val(c.percent.ToStr()))
  return (pct > 0)
end function
