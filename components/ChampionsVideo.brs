' Video subclass used to capture keys while Video has focus.
' Some Roku firmwares consume OK/* in the Video node and never bubble to Scene.
' We emit simple signals for MainScene to open our custom overlay.

sub init()
  if m.top.overlayRequested = invalid then m.top.overlayRequested = false
  if m.top.settingsRequested = invalid then m.top.settingsRequested = false
  if m.top.scrubEvent = invalid then m.top.scrubEvent = ""
  if m.top.keyEvent = invalid then m.top.keyEvent = ""
  m.seq = 0
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
  k = key
  if k = invalid then k = ""
  kl = LCase(k.Trim())

  mapped = kl
  if kl = "rev" then mapped = "left"
  if kl = "fwd" then mapped = "right"
  if kl = "channelup" or kl = "chanup" then mapped = "up"
  if kl = "channeldown" or kl = "chandown" then mapped = "down"
  if kl = "play" or kl = "pause" or kl = "playpause" then mapped = "playpause"

  allow = {
    ok: true
    back: true
    left: true
    right: true
    up: true
    down: true
    playpause: true
    options: true
    info: true
  }

  if allow[mapped] = true then
    if press = true then
      print "[video-key] raw=" + kl + " mapped=" + mapped
      m.seq = m.seq + 1
      m.top.keyEvent = mapped + ":press:" + m.seq.ToStr()
    end if
    return true
  end if

  return false
end function
