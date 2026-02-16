' Video subclass used to capture keys while Video has focus.
' Some Roku firmwares consume OK/* in the Video node and never bubble to Scene.
' We emit simple signals for MainScene to open our custom overlay.

sub init()
  if m.top.overlayRequested = invalid then m.top.overlayRequested = false
  if m.top.settingsRequested = invalid then m.top.settingsRequested = false
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
  if press <> true then return false
  k = key
  if k = invalid then k = ""
  kl = LCase(k.Trim())

  ' VOD seek: avoid Roku's built-in trickplay (which uses OK to confirm) since
  ' OK is reserved for our overlay/settings. We do a simple skip and keep
  ' playback running.
  if kl = "left" or kl = "right" then
    if m.top <> invalid and m.top.hasField("duration") and m.top.hasField("position") and m.top.hasField("seek") then
      curDur = m.top.duration
      if curDur = invalid then curDur = 0
      curDur = Int(curDur)

      ' Only on VOD (Live often reports duration=0).
      if curDur > 0 then
        curPos = m.top.position
        if curPos = invalid then curPos = 0
        curPos = Int(curPos)

        skipBySec = 10
        seekTo = curPos
        if kl = "right" then
          seekTo = curPos + skipBySec
        else
          seekTo = curPos - skipBySec
        end if

        if seekTo < 0 then seekTo = 0
        if seekTo > (curDur - 1) then seekTo = curDur - 1

        m.top.seek = seekTo
        if m.top.hasField("control") then m.top.control = "play"
        return true
      end if
    end if
    return false
  end if

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
