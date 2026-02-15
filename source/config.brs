' Registry-backed config storage.

function _cfgSection() as Object
  return CreateObject("roRegistrySection", "champions")
end function

function _readOrEmpty(sec as Object, key as String) as String
  v = sec.Read(key)
  if v = invalid then return ""
  return v
end function

sub saveConfig(apiBase as String, appToken as String, jellyfinToken as String, userId as String)
  sec = _cfgSection()
  sec.Write("apiBase", apiBase)
  sec.Write("appToken", appToken)
  sec.Write("jellyfinToken", jellyfinToken)
  sec.Write("userId", userId)
  sec.Flush()
end sub

function loadConfig() as Object
  sec = _cfgSection()

  ' API base can be:
  ' 1) saved in registry (local override on the device)
  ' 2) bundled at build-time (LAN/dev builds)
  ' 3) production default
  apiBase = _readOrEmpty(sec, "apiBase")
  bundledBase = bundledApiBase()
  if bundledBase <> "" and bundledBase <> apiBase then
    ' Dev builds may ship a different apiBase; prefer it while preserving other
    ' registry state (tokens, userId). This avoids requiring a delete/reinstall.
    apiBase = bundledBase
    sec.Write("apiBase", apiBase)
    sec.Flush()
  else if apiBase = "" then
    apiBase = bundledBase
    if apiBase = "" then apiBase = "https://api.champions.place"
  end if

  appToken = _readOrEmpty(sec, "appToken")
  if appToken = "" then appToken = bundledAppToken()

  jellyfinToken = _readOrEmpty(sec, "jellyfinToken")
  userId = _readOrEmpty(sec, "userId")

  cfg = {
    apiBase: apiBase
    appToken: appToken
    jellyfinToken: jellyfinToken
    userId: userId
  }
  return cfg
end function

sub clearConfig()
  sec = _cfgSection()
  sec.Delete("apiBase")
  sec.Delete("appToken")
  sec.Delete("jellyfinToken")
  sec.Delete("userId")
  ' VOD player prefs
  sec.Delete("vod_prefAudioLang")
  sec.Delete("vod_prefSubtitleLang")
  sec.Delete("vod_subtitlesEnabled")
  ' Legacy (migrated) keys
  sec.Delete("prefAudioLang")
  sec.Delete("prefSubtitleLang")
  sec.Flush()
end sub

' VOD player preferences (audio/subtitles). Stored per-device.
' ExoPlayer-like behavior: prefer language and persist choices across items.
'
' Notes:
' - We store language codes (e.g., "por", "eng", "pt-BR") instead of track IDs,
'   because track IDs can change per asset/playlist.
function loadVodPlayerPrefs() as Object
  sec = _cfgSection()
  audioLang = _readOrEmpty(sec, "vod_prefAudioLang")
  subLang = _readOrEmpty(sec, "vod_prefSubtitleLang")
  enabledRaw = _readOrEmpty(sec, "vod_subtitlesEnabled")
  enabled = false
  if enabledRaw <> "" then
    lr = LCase(enabledRaw.Trim())
    enabled = (lr = "1" or lr = "true" or lr = "yes" or lr = "on")
  end if

  ' Legacy migration (older dev builds stored prefAudioLang/prefSubtitleLang).
  if audioLang = "" then
    legacy = _readOrEmpty(sec, "prefAudioLang")
    if legacy <> "" then
      audioLang = legacy
      sec.Write("vod_prefAudioLang", audioLang)
    end if
  end if
  if subLang = "" then
    legacy = _readOrEmpty(sec, "prefSubtitleLang")
    if legacy <> "" then
      subLang = legacy
      sec.Write("vod_prefSubtitleLang", subLang)
    end if
  end if

  sec.Flush()
  return {
    audioLang: audioLang
    subtitleLang: subLang
    subtitlesEnabled: enabled
  }
end function

sub saveVodPlayerPrefs(audioLang as String, subtitleLang as String, subtitlesEnabled as Boolean)
  sec = _cfgSection()
  if audioLang <> invalid then sec.Write("vod_prefAudioLang", audioLang)
  if subtitleLang <> invalid then sec.Write("vod_prefSubtitleLang", subtitleLang)
  if subtitlesEnabled = true then
    sec.Write("vod_subtitlesEnabled", "1")
  else
    sec.Write("vod_subtitlesEnabled", "0")
  end if
  sec.Flush()
end sub
