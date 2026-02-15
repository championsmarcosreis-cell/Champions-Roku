' Build-time injected secrets.
'
' This file is SAFE to commit because it contains only empty placeholders.
' scripts/package.ps1 will overwrite the staged copy inside the ZIP with real
' values read from .secrets/ (gitignored).

function bundledAppToken() as String
  return ""
end function

function bundledApiBase() as String
  return ""
end function

' Optional dev helper: when non-empty, MainScene may auto-start playback to help
' with debugging on devices where we can't send ECP keypress events.
' Allowed values: "", "vod", "live"
function bundledDevAutoplay() as String
  return ""
end function
