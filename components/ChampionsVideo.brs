' Video subclass used to capture keys while Video has focus.
' Some Roku firmwares consume OK/* in the Video node and never bubble to Scene.
' We emit simple signals for MainScene to open our custom overlay.

sub init()
  if m.top.overlayRequested = invalid then m.top.overlayRequested = false
  if m.top.settingsRequested = invalid then m.top.settingsRequested = false
  m.scrubbing = false
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
  k = key
  if k = invalid then k = ""
  kl = LCase(k.Trim())

  ' LEFT/RIGHT: allow Roku native trickplay for VOD, but auto-confirm on release
  ' (so users don't need OK, which we reserve for our overlay/settings).
  if kl = "left" or kl = "right" then
    dur = 0
    if m.top <> invalid and m.top.hasField("duration") then
      d = m.top.duration
      if d <> invalid then dur = Int(d)
    end if

    ' VOD only (Live often reports duration=0).
    if dur > 0 then
      if press = true then
        m.scrubbing = true
        return false ' let Roku handle trickplay UI
      else
        ' Release: resume playback from the selected trickplay position.
        if m.scrubbing = true then
          if m.top <> invalid and m.top.hasField("control") then m.top.control = "play"
          m.scrubbing = false
        end if
        return false
      end if
    end if
    return false
  end if

  if press <> true then return false

  if kl = "ok" then
    ' If trickplay is active, let Roku consume OK to confirm seek.
    if m.scrubbing = true then
      m.scrubbing = false
      return false
    end if

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
