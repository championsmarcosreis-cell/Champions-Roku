' Video subclass used to capture keys while Video has focus.
' Some Roku firmwares consume OK/* in the Video node and never bubble to Scene.
' We emit simple signals for MainScene to open our custom overlay.

sub init()
  if m.top.overlayRequested = invalid then m.top.overlayRequested = false
  if m.top.settingsRequested = invalid then m.top.settingsRequested = false
  if m.top.scrubEvent = invalid then m.top.scrubEvent = ""
  m.scrubSeq = 0
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
  k = key
  if k = invalid then k = ""
  kl = LCase(k.Trim())

  ' LEFT/RIGHT: emit scrub events so MainScene can implement a continuous seek
  ' that resumes playback automatically (no OK confirm).
  mapped = kl
  if kl = "rev" then mapped = "left"
  if kl = "fwd" then mapped = "right"
  if mapped = "left" or mapped = "right" then
    m.scrubSeq = m.scrubSeq + 1
    action = "up"
    if press = true then action = "down"
    m.top.scrubEvent = mapped + ":" + action + ":" + m.scrubSeq.ToStr()
    return true
  end if

  if press <> true then return false

  if kl = "ok" then
    ' Toggle to guarantee a notify even if alwaysNotify isn't honored.
    m.top.overlayRequested = (m.top.overlayRequested <> true)
    return true
  end if

  if kl = "options" or kl = "info" then
    m.top.settingsRequested = (m.top.settingsRequested <> true)
    return true
  end if

  return false
end function
