' Login screen styled like the Windows app (no "Baixados") + optional Live player.

sub init()
  m.top.backgroundColor = "0x0B0F16"
  m.form = {
    username: ""
    password: ""
  }

  m.mode = "login" ' login | home | browse | live (will be applied after UI binds)
  m.focusIndex = 0 ' login: 0=username,1=password,2=login; home: 0=live,1=tokens,2=logout
  m.pendingPrompt = ""
  m.pendingDialog = invalid
  m.pendingJob = ""
  m.pendingPlayTitle = ""
  m.pendingPlayExtraQuery = {}
  m.pendingPlayStreamFormat = ""
  m.pendingPlayIsLive = false
  m.pendingPlaybackKind = ""
  m.pendingPlaybackItemId = ""
  m.pendingPlaybackTitle = ""
  m.pendingPlaybackInfoIsLive = false
  m.pendingPlaybackInfoKind = ""
  m.playbackKind = ""
  m.playbackIsLive = false
  m.playbackItemId = ""
  m.playbackTitle = ""
  m.vodFallbackAttempted = false
  m.vodJellyfinTranscodeAttempted = false
  m.liveEdgeSnapped = false
  m.lastPlayerState = ""
  m.devAutoplay = ""
  m.devAutoplayDone = false
  m.browseFocus = "views" ' views | items
  m.activeViewId = ""
  m.activeViewCollection = ""
  m.pendingShelfViewId = ""
  m.queuedShelfViewId = ""
  m.shelfCache = {}
  m.playbackSignPath = ""
  m.playbackSignExtraQuery = {}
  m.playbackStreamFormat = ""
  m.playbackSignedExp = 0
  m.liveResignPending = false
  m.ignoreNextStopped = false
  m.trackPrefsAppliedAudio = false
  m.trackPrefsAppliedSub = false
  m.vodPrefs = loadVodPlayerPrefs()
  m.settingsOpen = false
  m.overlayOpen = false
  m.settingsCol = "audio" ' audio | sub
  m.availableAudioTracksCache = []
  m.availableSubtitleTracksCache = []

  cfg0 = loadConfig()
  m.apiBase = cfg0.apiBase
  if m.apiBase = invalid or m.apiBase = "" then m.apiBase = "https://api.champions.place"

  m.devAutoplay = bundledDevAutoplay()
  if m.devAutoplay = invalid then m.devAutoplay = ""
  m.devAutoplay = LCase(m.devAutoplay.Trim())

  appTokenLen = 0
  if cfg0.appToken <> invalid then appTokenLen = Len(cfg0.appToken)
  jellyfinLen = 0
  if cfg0.jellyfinToken <> invalid then jellyfinLen = Len(cfg0.jellyfinToken)
  print "MainScene init apiBase=" + m.apiBase + " appTokenLen=" + appTokenLen.ToStr() + " jellyfinTokenLen=" + jellyfinLen.ToStr() + " devAutoplay=" + m.devAutoplay + " build=2026-02-14a"

  if cfg0.jellyfinToken <> invalid and cfg0.jellyfinToken <> "" then
    m.startupMode = "home"
  else
    m.startupMode = "login"
  end if
  print "MainScene startupMode=" + m.startupMode

  m.gatewayTask = CreateObject("roSGNode", "GatewayTask")
  if m.gatewayTask <> invalid then
    m.gatewayTask.observeField("state", "onGatewayTaskStateChanged")
    m.top.appendChild(m.gatewayTask)
  end if

  ' IMPORTANT: On some Roku firmware versions, init() runs before all XML nodes
  ' are materialized. Bind UI nodes on a short timer with retries.
  m.bindAttempts = 0
  m.bindTimer = CreateObject("roSGNode", "Timer")
  if m.bindTimer <> invalid then
    m.bindTimer.duration = 0.1
    m.bindTimer.repeat = false
    m.bindTimer.observeField("fire", "onBindTimerFire")
    m.top.appendChild(m.bindTimer)
    m.bindTimer.control = "start"
  else
    onBindTimerFire()
  end if

  m.playTimeoutTimer = CreateObject("roSGNode", "Timer")
  if m.playTimeoutTimer <> invalid then
    m.playTimeoutTimer.duration = 12
    m.playTimeoutTimer.repeat = false
    m.playTimeoutTimer.observeField("fire", "onPlayTimeoutFire")
    m.top.appendChild(m.playTimeoutTimer)
  end if

  m.devAutoplayTimer = CreateObject("roSGNode", "Timer")
  if m.devAutoplayTimer <> invalid then
    m.devAutoplayTimer.duration = 1.5
    m.devAutoplayTimer.repeat = false
    m.devAutoplayTimer.observeField("fire", "onDevAutoplayFire")
    m.top.appendChild(m.devAutoplayTimer)
  end if

  ' Live signatures expire (gateway default is 20 minutes). Renew periodically during playback.
  m.sigCheckTimer = CreateObject("roSGNode", "Timer")
  if m.sigCheckTimer <> invalid then
    m.sigCheckTimer.duration = 30
    m.sigCheckTimer.repeat = true
    m.sigCheckTimer.observeField("fire", "onSigCheckTimerFire")
    m.top.appendChild(m.sigCheckTimer)
  end if

  m.top.setFocus(true)
end sub

sub bindUiNodes()
  m.logoPoster = m.top.findNode("logoPoster")
  m.titleLabel = m.top.findNode("titleLabel")
  m.statusLabel = m.top.findNode("statusLabel")
  m.hintLabel = m.top.findNode("hintLabel")

  m.loginCard = m.top.findNode("loginCard")
  m.homeCard = m.top.findNode("homeCard")
  m.browseCard = m.top.findNode("browseCard")
  m.viewsList = m.top.findNode("viewsList")
  m.itemsList = m.top.findNode("itemsList")
  m.browseEmptyLabel = m.top.findNode("browseEmptyLabel")
  m.viewsTitle = m.top.findNode("viewsTitle")
  m.itemsTitle = m.top.findNode("itemsTitle")
  m.liveCard = m.top.findNode("liveCard")
  m.channelsList = m.top.findNode("channelsList")
  m.liveEmptyLabel = m.top.findNode("emptyLabel")

  m.usernameBg = m.top.findNode("usernameBg")
  m.usernameText = m.top.findNode("usernameText")
  m.passwordBg = m.top.findNode("passwordBg")
  m.passwordText = m.top.findNode("passwordText")
  m.loginBg = m.top.findNode("loginBg")
  m.loginText = m.top.findNode("loginText")

  m.homeLiveBg = m.top.findNode("homeLiveBg")
  m.homeTokensBg = m.top.findNode("homeTokensBg")
  m.homeLogoutBg = m.top.findNode("homeLogoutBg")

  if m.player = invalid then m.player = m.top.findNode("player")
  if m.playerOverlay = invalid then m.playerOverlay = m.top.findNode("playerOverlay")
  if m.playerOverlayCircle = invalid then m.playerOverlayCircle = m.top.findNode("playerOverlayCircle")
  if m.playerOverlayIcon = invalid then m.playerOverlayIcon = m.top.findNode("playerOverlayIcon")
  if m.playerSettingsModal = invalid then m.playerSettingsModal = m.top.findNode("playerSettingsModal")
  if m.playerSettingsAudioList = invalid then m.playerSettingsAudioList = m.top.findNode("playerSettingsAudioList")
  if m.playerSettingsSubList = invalid then m.playerSettingsSubList = m.top.findNode("playerSettingsSubList")
  if m.player <> invalid and (m.playerObsSetup <> true) then
    m.player.observeField("state", "onPlayerStateChanged")
    m.player.observeField("errorMsg", "onPlayerError")
    m.player.observeField("duration", "onPlayerDurationChanged")
    if m.player.hasField("availableAudioTracks") then
      m.player.observeField("availableAudioTracks", "onAvailableAudioTracksChanged")
    end if
    if m.player.hasField("availableSubtitleTracks") then
      m.player.observeField("availableSubtitleTracks", "onAvailableSubtitleTracksChanged")
    end if
    if m.player.hasField("audioTrack") then
      m.player.observeField("audioTrack", "onAudioTrackChanged")
    end if
    ' Some firmwares expose currentSubtitleTrack rather than subtitleTrack changes.
    if m.player.hasField("currentSubtitleTrack") then
      m.player.observeField("currentSubtitleTrack", "onCurrentSubtitleTrackChanged")
    else if m.player.hasField("subtitleTrack") then
      m.player.observeField("subtitleTrack", "onCurrentSubtitleTrackChanged")
    end if

    ' If Video has focus, intercept keys via ChampionsVideo signals.
    if m.player.hasField("overlayRequested") then
      m.player.observeField("overlayRequested", "onPlayerOverlayRequested")
    end if
    if m.player.hasField("settingsRequested") then
      m.player.observeField("settingsRequested", "onPlayerSettingsRequested")
    end if
    m.playerObsSetup = true
  end if

  ' Best-effort: allow switching audio tracks without pausing (HLS).
  ' Guarded for firmware compatibility.
  if m.player <> invalid and m.player.hasField("seamlessAudioTrackSelection") then
    m.player.seamlessAudioTrackSelection = true
  end if

  if m.playerSettingsAudioList <> invalid and (m.settingsObsSetup <> true) then
    m.playerSettingsAudioList.observeField("itemSelected", "onSettingsAudioSelected")
    if m.playerSettingsSubList <> invalid then m.playerSettingsSubList.observeField("itemSelected", "onSettingsSubSelected")
    m.settingsObsSetup = true
  end if

  if m.channelsList <> invalid and (m.channelsObsSetup <> true) then
    m.channelsList.observeField("itemSelected", "onChannelSelected")
    m.channelsObsSetup = true
  end if

  if m.viewsList <> invalid and (m.viewsObsSetup <> true) then
    m.viewsList.observeField("itemFocused", "onViewFocused")
    m.viewsList.observeField("itemSelected", "onViewSelected")
    m.viewsObsSetup = true
  end if

  if m.itemsList <> invalid and (m.itemsObsSetup <> true) then
    m.itemsList.observeField("itemSelected", "onItemSelected")
    m.itemsObsSetup = true
  end if
end sub

function uiReady() as Boolean
  return (m.loginCard <> invalid and m.homeCard <> invalid and m.browseCard <> invalid and m.viewsList <> invalid and m.itemsList <> invalid and m.liveCard <> invalid and m.channelsList <> invalid and m.hintLabel <> invalid)
end function

sub onBindTimerFire()
  m.bindAttempts = m.bindAttempts + 1
  bindUiNodes()

  if uiReady() then
    print "UI ready (" + m.startupMode + ")"
    renderForm()

    ' Dev-only: force showing the login card (use .secrets/dev_autoplay.txt = "login").
    if m.devAutoplay = "login" and m.devAutoplayDone <> true then
      m.devAutoplayDone = true
      print "DEV autoplay login: enterLogin"
      enterLogin()
      return
    end if

    ' If we're dev-autoplaying Live, go straight to Live mode to avoid starting
    ' Browse requests that would block the channels load (pendingJob gate).
    if m.devAutoplay = "live" and m.devAutoplayDone <> true then
      print "DEV autoplay live: enterLive"
      enterLive()
      return
    end if

    if m.startupMode = "browse" then
      enterBrowse()
    else if m.startupMode = "home" then
      enterHome()
    else
      enterLogin()
    end if

    ' Dev-only autoplay hooks (use .secrets/dev_autoplay.txt):
    ' - "vod": auto-play first VOD item from the first shelf
    ' - "live": auto-enter Live list and auto-play the first channel
    ' - "hls": auto-play /hls/master.m3u8 (encoder pipeline via gateway master)
    ' - "encoder": auto-play encoder HLS directly (bypass gateway signing)
    ' - "master": auto-play /hls/master.m3u8 (mixed variants)
    if (m.devAutoplay = "hls" or m.devAutoplay = "encoder" or m.devAutoplay = "master") and m.devAutoplayDone <> true and m.devAutoplayTimer <> invalid then
      m.devAutoplayTimer.control = "start"
    end if
    return
  end if

  if m.bindAttempts < 15 and m.bindTimer <> invalid then
    m.bindTimer.control = "start"
    return
  end if

  ' Give the user something usable even if late binding failed.
  renderForm()
  enterLogin()
  setStatus("ui init failed")
end sub

sub onDevAutoplayFire()
  if m.devAutoplayDone = true then return
  if m.devAutoplay <> "hls" and m.devAutoplay <> "encoder" and m.devAutoplay <> "master" then return

  if m.devAutoplay = "encoder" then
    m.devAutoplayDone = true
    print "DEV autoplay ENCODER HLS"
    ' Direct encoder HLS test (LAN). This intentionally bypasses /sign so we can
    ' isolate Roku playback issues from gateway/VPS/CDN pipelines.
    startVideo("http://192.168.0.168/0.m3u8", "Live (Encoder)", "hls", true, "live-encoder", "")
    return
  end if

  if m.devAutoplay = "master" then
    cfg = loadConfig()
    if cfg.appToken = "" or cfg.jellyfinToken = "" then return
    m.devAutoplayDone = true
    print "DEV autoplay HLS MASTER"
    signAndPlay("/hls/master.m3u8", "Live")
    return
  end if
 
  cfg = loadConfig()
  if cfg.appToken = "" or cfg.jellyfinToken = "" then return
 
  m.devAutoplayDone = true
  print "DEV autoplay HLS"
  signAndPlay("/hls/master.m3u8", "Live")
end sub

sub layoutCards()
  ' Cards are 520x260 on a 1280x720 UI (manifest ui_resolutions=hd).
  x = 380 ' (1280-520)/2
  y = 390
  if m.loginCard <> invalid then m.loginCard.translation = [x, y]
  if m.homeCard <> invalid then m.homeCard.translation = [x, y]
  if m.browseCard <> invalid then m.browseCard.translation = [90, 130]
  if m.liveCard <> invalid then m.liveCard.translation = [x, 150]
end sub

sub renderForm()
  if m.usernameText <> invalid then m.usernameText.text = fieldDisplay("Usuario", m.form.username, false)
  if m.passwordText <> invalid then m.passwordText.text = fieldDisplay("Senha", m.form.password, true)
  if m.loginText <> invalid then m.loginText.text = "Entrar"
end sub

function fieldDisplay(placeholder as String, value as String, secret as Boolean) as String
  v = value
  if v = invalid then v = ""
  if v = "" then return placeholder
  if secret then return "********"
  return v
end function

sub setStatus(msg as String)
  if m.statusLabel = invalid then return

  t = msg
  if t = invalid then t = ""
  t = t.Trim()

  ' Keep the UI clean: hide transient player states like "playing".
  tl = LCase(t)
  if tl = "" or tl = "ready" or tl = "playing" or tl = "buffering" or tl = "stopped" or tl = "finished" then
    m.statusLabel.visible = false
    m.statusLabel.text = ""
  else
    m.statusLabel.visible = true
    m.statusLabel.text = t
  end if
end sub

sub doLogin()
  if m.mode <> "login" then return
  if m.gatewayTask = invalid then
    setStatus("gateway: missing task")
    return
  end if
  if m.pendingJob <> "" then
    setStatus("aguarde...")
    return
  end if

  cfg = loadConfig()
  if cfg.appToken = invalid or cfg.appToken = "" then
    setStatus("faltou APP_TOKEN (pressione *)")
    return
  end if
  if m.form.username = "" then
    setStatus("faltou usuario")
    return
  end if
  if m.form.password = "" then
    setStatus("faltou senha")
    return
  end if

  setStatus("login...")
  m.pendingJob = "login"
  m.gatewayTask.kind = "login"
  m.gatewayTask.apiBase = m.apiBase
  m.gatewayTask.appToken = cfg.appToken
  m.gatewayTask.username = m.form.username
  m.gatewayTask.password = m.form.password
  m.gatewayTask.control = "run"
end sub

sub playLive()
  signAndPlay("/hls/master.m3u8", "Live")
end sub

sub onPlayerOverlayRequested()
  if m.player = invalid then return
  if m.player.visible <> true then return
  if m.settingsOpen = true then return
  if m.overlayOpen = true then
    showPlayerSettings()
  else
    showPlayerOverlay()
  end if
end sub

sub onPlayerSettingsRequested()
  if m.player = invalid then return
  if m.player.visible <> true then return
  showPlayerSettings()
end sub

function _normLang(s as String) as String
  ' Back-compat shim (older code calls _normLang).
  return normalizeLang(s)
end function

function normalizeLang(tag as Dynamic) as String
  v = ""
  if tag <> invalid then v = tag.ToStr()
  v = LCase(v.Trim())
  if v = "" then return ""

  v = v.Replace("_", "-")

  ' Strip region/variants (pt-br -> pt, por-br -> por).
  dash = Instr(1, v, "-")
  if dash > 0 then v = Left(v, dash - 1)
  semi = Instr(1, v, ";")
  if semi > 0 then v = Left(v, semi - 1)
  v = v.Trim()
  if v = "" then return ""

  ' Map common ISO 639-2/3 to short tags used by prefs.
  if v = "por" or v = "pt" then return "pt"
  if v = "eng" or v = "en" then return "en"
  if v = "spa" or v = "es" then return "es"
  return v
end function

function _pickTrackByLang(tracks as Object, prefLang as String) as Object
  if type(tracks) <> "roArray" then return invalid
  want = normalizeLang(prefLang)
  if want = "" then return invalid

  ' First pass: exact match on Language.
  for each t in tracks
    if type(t) = "roAssociativeArray" then
      lang = ""
      if t.Language <> invalid then lang = normalizeLang(t.Language)
      if lang = want then return t
    end if
  end for

  ' Second pass: prefix match (e.g. "por" vs "por-BR").
  for each t in tracks
    if type(t) = "roAssociativeArray" then
      lang = ""
      if t.Language <> invalid then lang = normalizeLang(t.Language)
      if lang <> "" and Left(lang, Len(want)) = want then return t
    end if
  end for
  return invalid
end function

sub _ensureDefaultVodPrefs()
  if type(m.vodPrefs) <> "roAssociativeArray" then m.vodPrefs = loadVodPlayerPrefs()
  if m.vodPrefs.audioLang = invalid then m.vodPrefs.audioLang = ""
  if m.vodPrefs.subtitleLang = invalid then m.vodPrefs.subtitleLang = ""
  if m.vodPrefs.subtitlesEnabled = invalid then m.vodPrefs.subtitlesEnabled = false

  ' Normalize any stored prefs (legacy "por"/"eng"/regions).
  m.vodPrefs.audioLang = normalizeLang(m.vodPrefs.audioLang)
  m.vodPrefs.subtitleLang = normalizeLang(m.vodPrefs.subtitleLang)

  ' Defaults (ExoPlayer-like).
  if m.vodPrefs.audioLang.Trim() = "" then m.vodPrefs.audioLang = "pt"
  if m.vodPrefs.subtitleLang.Trim() = "" then m.vodPrefs.subtitleLang = "pt"
end sub

sub applyPreferredTracks()
  if m.player = invalid then return
  if m.player.visible <> true then return
  ' VOD only (do not change Live behavior).
  if m.playbackIsLive = true then return
  _ensureDefaultVodPrefs()

  if m.trackPrefsAppliedAudio <> true then
    if m.player.hasField("availableAudioTracks") and m.player.hasField("audioTrack") then
      tracks = m.player.availableAudioTracks
      picked = _pickTrackByLang(tracks, m.vodPrefs.audioLang)
      if picked <> invalid and picked.Track <> invalid then
        tId = picked.Track
        if tId <> invalid then tId = tId.ToStr()
        if tId <> "" then
          print "player pref audioLang=" + m.vodPrefs.audioLang + " -> track=" + tId
          m.player.audioTrack = tId
          m.trackPrefsAppliedAudio = true
        end if
      end if
    end if
  end if

  if m.trackPrefsAppliedSub <> true then
    if m.vodPrefs.subtitlesEnabled <> true then
      _disableSubtitles()
      m.trackPrefsAppliedSub = true
      return
    end if

    if m.player.hasField("availableSubtitleTracks") then
      tracks = m.player.availableSubtitleTracks
      picked = _pickTrackByLang(tracks, m.vodPrefs.subtitleLang)
      if picked <> invalid and picked.Track <> invalid then
        tId = picked.Track
        if tId <> invalid then tId = tId.ToStr()
        if tId <> "" then
          print "player pref subtitleLang=" + m.vodPrefs.subtitleLang + " -> track=" + tId
          _setSubtitleTrack(tId)
          m.trackPrefsAppliedSub = true
        end if
      end if
    end if
  end if
end sub

sub _setSubtitleTrack(trackId as String)
  if m.player = invalid then return
  id = trackId
  if id = invalid then id = ""
  id = id.Trim()
  if id = "" then return
  if m.player.hasField("subtitleTrack") then
    m.player.subtitleTrack = id
  else if m.player.hasField("currentSubtitleTrack") then
    m.player.currentSubtitleTrack = id
  end if
end sub

sub _disableSubtitles()
  if m.player = invalid then return
  if m.player.hasField("subtitleTrack") then m.player.subtitleTrack = "off"
  if m.player.hasField("currentSubtitleTrack") then m.player.currentSubtitleTrack = "off"
end sub

sub onAvailableAudioTracksChanged()
  if m.player <> invalid and m.player.hasField("availableAudioTracks") then
    t = m.player.availableAudioTracks
    if type(t) = "roArray" then m.availableAudioTracksCache = t
  end if
  ' Tracks usually become available shortly after load.
  applyPreferredTracks()
end sub

sub onAvailableSubtitleTracksChanged()
  if m.player <> invalid and m.player.hasField("availableSubtitleTracks") then
    t = m.player.availableSubtitleTracks
    if type(t) = "roArray" then m.availableSubtitleTracksCache = t
  end if
  applyPreferredTracks()
end sub

sub onAudioTrackChanged()
  if m.player = invalid then return
  if m.player.visible <> true then return
  if m.player.hasField("availableAudioTracks") <> true then return
  if m.playbackIsLive = true then return

  cur = m.player.audioTrack
  if cur = invalid then cur = ""
  cur = cur.ToStr().Trim()
  if cur = "" then return

  tracks = m.player.availableAudioTracks
  if type(tracks) <> "roArray" then return
  for each t in tracks
    if type(t) = "roAssociativeArray" and t.Track <> invalid and t.Track.ToStr() = cur then
      if t.Language <> invalid then
        lang = normalizeLang(t.Language.ToStr())
        if lang <> "" then
          _ensureDefaultVodPrefs()
          if normalizeLang(m.vodPrefs.audioLang) <> lang then
            print "player audioTrack changed -> save prefAudioLang=" + lang
            m.vodPrefs.audioLang = lang
            saveVodPlayerPrefs(m.vodPrefs.audioLang, m.vodPrefs.subtitleLang, (m.vodPrefs.subtitlesEnabled = true))
          end if
        end if
      end if
      exit for
    end if
  end for
end sub

sub onCurrentSubtitleTrackChanged()
  if m.player = invalid then return
  if m.player.visible <> true then return
  if m.player.hasField("availableSubtitleTracks") <> true then return
  if m.playbackIsLive = true then return

  cur = ""
  if m.player.hasField("currentSubtitleTrack") then
    cur = m.player.currentSubtitleTrack
  else if m.player.hasField("subtitleTrack") then
    cur = m.player.subtitleTrack
  end if
  if cur = invalid then cur = ""
  cur = cur.ToStr().Trim()
  if cur = "" then return

  tracks = m.player.availableSubtitleTracks
  if type(tracks) <> "roArray" then return
  for each t in tracks
    if type(t) = "roAssociativeArray" and t.Track <> invalid and t.Track.ToStr() = cur then
      if t.Language <> invalid then
        lang = normalizeLang(t.Language.ToStr())
        if lang <> "" then
          _ensureDefaultVodPrefs()
          if normalizeLang(m.vodPrefs.subtitleLang) <> lang then
            print "player subtitleTrack changed -> save prefSubtitleLang=" + lang
            m.vodPrefs.subtitleLang = lang
            saveVodPlayerPrefs(m.vodPrefs.audioLang, m.vodPrefs.subtitleLang, true)
          end if
        end if
      end if
      exit for
    end if
  end for
end sub

function _overlayContent() as Object
  ' Legacy: overlay used to be a MarkupList. Kept for compatibility if reintroduced.
  return CreateObject("roSGNode", "ContentNode")
end function

sub showPlayerOverlay()
  if m.playerOverlay = invalid then return
  if m.player = invalid or m.player.visible <> true then return
  m.overlayOpen = true
  m.playerOverlay.visible = true
end sub

sub hidePlayerOverlay()
  if m.playerOverlay = invalid then return
  m.overlayOpen = false
  m.playerOverlay.visible = false
  if m.player <> invalid and m.player.visible = true then m.player.setFocus(true)
end sub

sub showPlayerSettings()
  if m.playerSettingsModal = invalid then return
  if m.player = invalid or m.player.visible <> true then return
  ' Avoid the overlay hint bleeding through behind the modal.
  if m.overlayOpen = true then hidePlayerOverlay()
  m.settingsOpen = true
  m.settingsCol = "audio"
  m.playerSettingsModal.visible = true
  refreshPlayerSettingsLists()
  if m.playerSettingsAudioList <> invalid then m.playerSettingsAudioList.setFocus(true)
end sub

sub hidePlayerSettings()
  if m.playerSettingsModal = invalid then return
  m.settingsOpen = false
  m.playerSettingsModal.visible = false
  if m.player <> invalid and m.player.visible = true then m.player.setFocus(true)
end sub

sub refreshPlayerSettingsLists()
  if m.playerSettingsAudioList = invalid or m.playerSettingsSubList = invalid then return

  isVod = (m.playbackIsLive <> true)
  if isVod then _ensureDefaultVodPrefs()

  ' Audio
  audioRoot = CreateObject("roSGNode", "ContentNode")
  tracksA = []
  if m.player <> invalid and m.player.hasField("availableAudioTracks") then
    t = m.player.availableAudioTracks
    if type(t) = "roArray" then tracksA = t
  end if
  if type(tracksA) <> "roArray" then tracksA = []
  for each tr in tracksA
    if type(tr) = "roAssociativeArray" then
      title = ""
      lang = ""
      if tr.Language <> invalid then lang = tr.Language.ToStr()
      if tr.Description <> invalid and tr.Description.ToStr().Trim() <> "" then
        title = tr.Description.ToStr()
      else if lang <> "" then
        title = lang
      else
        title = "Audio"
      end if
      c = CreateObject("roSGNode", "ContentNode")
      c.addField("trackId", "string", false)
      c.addField("lang", "string", false)
      c.addField("selected", "boolean", false)
      c.title = title
      if tr.Track <> invalid then c.trackId = tr.Track.ToStr() else c.trackId = ""
      c.lang = normalizeLang(lang)
      c.selected = false
      if m.player <> invalid and m.player.hasField("audioTrack") then
        cur = m.player.audioTrack
        if cur <> invalid and cur.ToStr() = c.trackId then c.selected = true
      end if
      audioRoot.appendChild(c)
    end if
  end for
  m.playerSettingsAudioList.content = audioRoot

  ' Subtitles (first item: OFF)
  subRoot = CreateObject("roSGNode", "ContentNode")
  off = CreateObject("roSGNode", "ContentNode")
  off.addField("trackId", "string", false)
  off.addField("lang", "string", false)
  off.addField("selected", "boolean", false)
  off.title = "Desligado"
  off.trackId = "off"
  off.lang = ""
  off.selected = true
  if isVod and m.vodPrefs.subtitlesEnabled = true then off.selected = false
  subRoot.appendChild(off)

  tracksS = []
  if m.player <> invalid and m.player.hasField("availableSubtitleTracks") then
    t = m.player.availableSubtitleTracks
    if type(t) = "roArray" then tracksS = t
  end if
  if type(tracksS) <> "roArray" then tracksS = []
  cur = ""
  if m.player <> invalid and m.player.hasField("currentSubtitleTrack") then
    cur = m.player.currentSubtitleTrack
  else if m.player <> invalid and m.player.hasField("subtitleTrack") then
    cur = m.player.subtitleTrack
  end if
  if cur = invalid then cur = ""
  cur = cur.ToStr()

  for each tr in tracksS
    if type(tr) = "roAssociativeArray" then
      title = ""
      lang = ""
      if tr.Language <> invalid then lang = tr.Language.ToStr()
      if tr.Description <> invalid and tr.Description.ToStr().Trim() <> "" then
        title = tr.Description.ToStr()
      else if lang <> "" then
        title = lang
      else
        title = "Legenda"
      end if
      c = CreateObject("roSGNode", "ContentNode")
      c.addField("trackId", "string", false)
      c.addField("lang", "string", false)
      c.addField("selected", "boolean", false)
      c.title = title
      if tr.Track <> invalid then c.trackId = tr.Track.ToStr() else c.trackId = ""
      c.lang = normalizeLang(lang)
      c.selected = false
      if cur <> "" and cur = c.trackId and (not isVod or (isVod and m.vodPrefs.subtitlesEnabled = true)) then
        c.selected = true
        off.selected = false
      end if
      subRoot.appendChild(c)
    end if
  end for

  ' If R2 VOD doesn't expose subtitle tracks, offer a fallback to Jellyfin playback
  ' so the user can still get captions/subtitles (if available upstream).
  if isVod and m.playbackKind = "vod-r2" and subRoot.getChildCount() <= 1 then
    load = CreateObject("roSGNode", "ContentNode")
    load.addField("trackId", "string", false)
    load.addField("lang", "string", false)
    load.addField("selected", "boolean", false)
    load.title = "Carregar legendas (Jellyfin)"
    load.trackId = "__load_jellyfin__"
    load.lang = ""
    load.selected = false
    subRoot.appendChild(load)
  end if

  m.playerSettingsSubList.content = subRoot
end sub

sub onOverlayItemSelected()
  showPlayerSettings()
end sub

sub onSettingsAudioSelected()
  if m.playerSettingsAudioList = invalid then return
  idx = m.playerSettingsAudioList.itemSelected
  root = m.playerSettingsAudioList.content
  if root = invalid then return
  it = root.getChild(idx)
  if it = invalid then return
  trackId = it.trackId
  if trackId = invalid then trackId = ""
  trackId = trackId.ToStr().Trim()
  if trackId = "" then return

  if m.player <> invalid and m.player.hasField("audioTrack") then m.player.audioTrack = trackId

  if m.playbackIsLive <> true then
    _ensureDefaultVodPrefs()
    lang = it.lang
    if lang = invalid then lang = ""
    lang = normalizeLang(lang.ToStr())
    if lang <> "" then m.vodPrefs.audioLang = lang
    saveVodPlayerPrefs(m.vodPrefs.audioLang, m.vodPrefs.subtitleLang, (m.vodPrefs.subtitlesEnabled = true))
  end if

  refreshPlayerSettingsLists()
end sub

sub onSettingsSubSelected()
  if m.playerSettingsSubList = invalid then return
  idx = m.playerSettingsSubList.itemSelected
  root = m.playerSettingsSubList.content
  if root = invalid then return
  it = root.getChild(idx)
  if it = invalid then return
  trackId = it.trackId
  if trackId = invalid then trackId = ""
  trackId = trackId.ToStr().Trim()
  if trackId = "" then return

  if trackId = "off" then
    _disableSubtitles()
    if m.playbackIsLive <> true then
      _ensureDefaultVodPrefs()
      m.vodPrefs.subtitlesEnabled = false
      saveVodPlayerPrefs(m.vodPrefs.audioLang, m.vodPrefs.subtitleLang, false)
    end if
    refreshPlayerSettingsLists()
    return
  end if

  if trackId = "__load_jellyfin__" then
    tryVodSubtitlesFromJellyfin()
    return
  end if

  _setSubtitleTrack(trackId)
  if m.playbackIsLive <> true then
    _ensureDefaultVodPrefs()
    m.vodPrefs.subtitlesEnabled = true
    lang = it.lang
    if lang = invalid then lang = ""
    lang = normalizeLang(lang.ToStr())
    if lang <> "" then m.vodPrefs.subtitleLang = lang
    saveVodPlayerPrefs(m.vodPrefs.audioLang, m.vodPrefs.subtitleLang, true)
  end if
  refreshPlayerSettingsLists()
end sub

sub signAndPlay(rawPath as String, title as String)
  target = parseTarget(rawPath, "/hls/master.m3u8")
  beginSign(target.path, target.query, title, "hls", true, "live", "")
end sub

sub playVodById(itemId as String, title as String)
  id = itemId
  if id = invalid then id = ""
  id = id.Trim()
  if id = "" then
    setStatus("vod: missing item id")
    return
  end if

  t = title
  if t = invalid then t = ""
  t = t.Trim()
  if t = "" then t = "Video"

  m.vodFallbackAttempted = false
  m.vodJellyfinTranscodeAttempted = false
  m.pendingPlaybackItemId = id
  m.pendingPlaybackTitle = t

  r2 = r2VodPathForItemId(id)
  if r2 <> "" then
    target = parseTarget(r2, r2)
    ' Roku needs subtitles embedded in HLS (Video node can't send auth headers).
    ' Pass api_key so the gateway can fetch Jellyfin subtitle metadata and expose
    ' EXT-X-MEDIA (SUBTITLES) for this R2 VOD master.
    cfg = loadConfig()
    q = target.query
    if type(q) <> "roAssociativeArray" then q = {}
    q["roku"] = "1"
    if cfg.jellyfinToken <> invalid and cfg.jellyfinToken.Trim() <> "" then
      q["api_key"] = cfg.jellyfinToken.Trim()
    end if
    beginSign(target.path, q, t, "hls", false, "vod-r2", id)
    return
  end if

  requestJellyfinPlayback(id, t, false, "vod-jellyfin")
end sub

sub onGatewayTaskStateChanged()
  if m.gatewayTask = invalid then return
  st = m.gatewayTask.state
  if st <> "done" and st <> "stop" then return

  job = m.pendingJob
  if job = "" then return
  m.pendingJob = ""

  if job = "login" then
    if m.gatewayTask.ok = true then
      cfg = loadConfig()
      saveConfig(m.apiBase, cfg.appToken, m.gatewayTask.accessToken, m.gatewayTask.userId)
      loadSavedIntoForm()
      enterHome()
    else
      err = m.gatewayTask.error
      if err = invalid or err = "" then err = "unknown"
      setStatus("login failed: " + err)
    end if
    return
  end if

  if job = "views" then
    if m.gatewayTask.ok = true then
      raw = m.gatewayTask.resultJson
      items = ParseJson(raw)
      if type(items) <> "roArray" then items = []

      root = CreateObject("roSGNode", "ContentNode")
      for each v in items
        c = CreateObject("roSGNode", "ContentNode")
        c.addField("collectionType", "string", false)
        if v <> invalid then
          if v.id <> invalid then c.id = v.id
          if v.name <> invalid then c.title = v.name else c.title = ""
          if v.collectionType <> invalid then c.collectionType = v.collectionType else c.collectionType = ""
        else
          c.title = ""
          c.collectionType = ""
        end if
        root.appendChild(c)
      end for

      if m.viewsList <> invalid then m.viewsList.content = root

      ' Reset items list until a view is focused.
      if m.itemsList <> invalid then m.itemsList.content = CreateObject("roSGNode", "ContentNode")
      if m.browseEmptyLabel <> invalid then
        m.browseEmptyLabel.text = "Sem itens"
        m.browseEmptyLabel.visible = true
      end if

      setStatus("ready")

      ' Preload the first shelf (best-effort).
      if root.getChildCount() > 0 then
        first = root.getChild(0)
        if first <> invalid then
          m.activeViewId = first.id
          m.activeViewCollection = first.collectionType
          if m.itemsTitle <> invalid then
            t0 = first.title
            if t0 = invalid then t0 = ""
            t0 = t0.Trim()
            if t0 = "" then
              m.itemsTitle.text = "Recentes"
            else
              m.itemsTitle.text = "Recentes: " + t0
            end if
          end if
          if first.collectionType <> "livetv" then
            loadShelfForView(first.id)
          else
            if m.browseEmptyLabel <> invalid then
              m.browseEmptyLabel.text = "Pressione OK para abrir Live TV"
              m.browseEmptyLabel.visible = true
            end if
          end if
        end if
      else
        if m.browseEmptyLabel <> invalid then
          m.browseEmptyLabel.text = "Sem bibliotecas"
          m.browseEmptyLabel.visible = true
        end if
      end if

      if m.mode = "browse" and m.viewsList <> invalid then
        m.browseFocus = "views"
        m.viewsList.setFocus(true)
      end if
    else
      err = m.gatewayTask.error
      if err = invalid or err = "" then err = "unknown"
      setStatus("views failed: " + err)
      if m.browseEmptyLabel <> invalid then
        m.browseEmptyLabel.text = "Falhou ao carregar bibliotecas"
        m.browseEmptyLabel.visible = true
      end if
    end if
    return
  end if

  if job = "shelf" then
    viewId = m.pendingShelfViewId
    m.pendingShelfViewId = ""

    if m.gatewayTask.ok = true then
      raw = m.gatewayTask.resultJson
      if viewId <> invalid and viewId <> "" then
        m.shelfCache[viewId] = raw
      end if

      if m.activeViewId = viewId then
        renderShelfItems(raw)
      end if

      setStatus("ready")
    else
      err = m.gatewayTask.error
      if err = invalid or err = "" then err = "unknown"
      setStatus("shelf failed: " + err)
      if m.browseEmptyLabel <> invalid then
        m.browseEmptyLabel.text = "Falhou ao carregar itens"
        m.browseEmptyLabel.visible = true
      end if
    end if

    ' If the user changed views while the request was in flight, load the latest queued one.
    if m.queuedShelfViewId <> "" then
      nextId = m.queuedShelfViewId
      m.queuedShelfViewId = ""
      loadShelfForView(nextId)
    end if
    return
  end if

  if job = "channels" then
    if m.gatewayTask.ok = true then
      raw = m.gatewayTask.resultJson
      items = ParseJson(raw)
      if type(items) <> "roArray" then items = []
      print "channels ok count=" + items.Count().ToStr()

      root = CreateObject("roSGNode", "ContentNode")
      for each ch in items
        c = CreateObject("roSGNode", "ContentNode")
        if ch <> invalid then
          if ch.id <> invalid then c.id = ch.id
          if ch.name <> invalid then c.title = ch.name else c.title = ""
          c.addField("path", "string", false)
          if ch.path <> invalid then c.path = ch.path else c.path = ""
        else
          c.title = ""
          c.addField("path", "string", false)
          c.path = ""
        end if
        root.appendChild(c)
      end for

      if m.channelsList <> invalid then m.channelsList.content = root

      if m.liveEmptyLabel <> invalid then
        m.liveEmptyLabel.text = "Sem canais"
        m.liveEmptyLabel.visible = (root.getChildCount() = 0)
      end if

      setStatus("ready")
      if m.mode = "live" and m.channelsList <> invalid then m.channelsList.setFocus(true)

      if m.devAutoplay = "live" and m.devAutoplayDone <> true then
        ' Helpful for debugging when we can't inject keypress events remotely.
        if root.getChildCount() > 0 then
          first = root.getChild(0)
          if first <> invalid then
            p = ""
            if first.hasField("path") then p = first.path
            if p <> invalid then p = p.Trim()
            if p <> "" then
              m.devAutoplayDone = true
              print "DEV autoplay LIVE path: " + p
              signAndPlay(p, first.title)
            else
              m.devAutoplayDone = true
              print "DEV autoplay LIVE: missing channel path; fallback to /hls/master.m3u8"
              signAndPlay("/hls/master.m3u8", first.title)
            end if
          end if
        end if
      end if
    else
      err = m.gatewayTask.error
      if err = invalid or err = "" then err = "unknown"
      print "channels failed: " + err
      setStatus("channels failed: " + err)
      if m.liveEmptyLabel <> invalid then
        m.liveEmptyLabel.text = "Falhou ao carregar canais"
        m.liveEmptyLabel.visible = true
      end if
    end if
    return
  end if

  if job = "playback" then
    itemId = m.pendingPlaybackItemId
    title = m.pendingPlaybackTitle
    isLive = (m.pendingPlaybackInfoIsLive = true)
    kind = m.pendingPlaybackInfoKind
    if kind = invalid then kind = ""
    kind = kind.Trim()
    if kind = "" then kind = "vod-jellyfin"

    if m.gatewayTask.ok = true then
      raw = m.gatewayTask.resultJson
      info = ParseJson(raw)
      if type(info) <> "roAssociativeArray" then info = {}

      path = ""
      query = {}
      container = ""
      if info.path <> invalid then path = info.path
      if type(info.query) = "roAssociativeArray" then query = info.query
      if info.container <> invalid then container = info.container

      if path = invalid then path = ""
      path = path.Trim()

      fmt = inferStreamFormat(path, container)

      liveStr = "false"
      if isLive = true then liveStr = "true"
      print "playbackinfo ok path=" + path + " fmt=" + fmt + " kind=" + kind + " live=" + liveStr

      ' Consume the pending flags (playback job is async).
      m.pendingPlaybackInfoIsLive = false
      m.pendingPlaybackInfoKind = ""

      beginSign(path, query, title, fmt, isLive, kind, itemId)
    else
      err = m.gatewayTask.error
      if err = invalid or err = "" then err = "unknown"
      m.pendingPlaybackInfoIsLive = false
      m.pendingPlaybackInfoKind = ""
      print "playbackinfo failed: " + err
      ' If VOD direct playback is not possible (codec/profile), retry once with transcoding enabled.
      if isLive <> true and kind = "vod-jellyfin" and m.vodJellyfinTranscodeAttempted <> true then
        err2 = LCase(err.Trim())
        if err2 = "transcode_forbidden" or err2 = "direct_disabled" or err2 = "no_media_sources" then
          m.vodJellyfinTranscodeAttempted = true
          setStatus("vod: tentando transcode...")
          requestJellyfinPlayback2(itemId, title, false, "vod-jellyfin", true, true)
          return
        end if
      end if

      setStatus("playback failed: " + err)
    end if

    return
  end if

  if job = "sign" then
    if m.gatewayTask.ok = true then
      cfg = loadConfig()
      url = cfg.apiBase + m.gatewayTask.signedUrl
      url = appendQuery(url, m.pendingPlayExtraQuery)
      t = m.pendingPlayTitle
      if t = invalid then t = ""
      t = t.Trim()
      if t = "" then t = "Live"
      kind = m.pendingPlaybackKind
      if kind = invalid then kind = ""
      kind = kind.Trim()
      if kind = "" then kind = "unknown"

      itemId = m.pendingPlaybackItemId
      if itemId = invalid then itemId = ""
      itemId = itemId.Trim()

      fmt = m.pendingPlayStreamFormat
      if fmt = invalid then fmt = ""
      fmt = fmt.Trim()
      if fmt = "" then fmt = inferStreamFormat(url, "")

      isLive = (m.pendingPlayIsLive = true)
      safeUrl = url
      qpos = Instr(1, safeUrl, "?") ' 1-based; returns 0 when not found
      if qpos > 0 then safeUrl = Left(safeUrl, qpos - 1)
      liveStr = "false"
      if isLive = true then liveStr = "true"
      print "sign ok kind=" + kind + " live=" + liveStr + " fmt=" + fmt + " url=" + safeUrl

      expVal = m.gatewayTask.exp
      if expVal = invalid then expVal = 0
      m.playbackSignedExp = Int(expVal)
      m.playbackStreamFormat = fmt

      ' Reset pending state now that the signed URL is consumed.
      m.pendingPlayTitle = ""
      m.pendingPlayExtraQuery = {}
      m.pendingPlayStreamFormat = ""
      m.pendingPlayIsLive = false
      m.pendingPlaybackKind = ""
      m.pendingPlaybackItemId = ""

      setStatus("opening...")
      startVideo(url, t, fmt, isLive, kind, itemId)
    else
      err = m.gatewayTask.error
      if err = invalid or err = "" then err = "unknown"
      m.liveResignPending = false
      setStatus("sign failed: " + err)
    end if
    return
  end if
end sub

sub startVideo(url as String, title as String, streamFormat as String, isLive as Boolean, kind as String, itemId as String)
  if m.player = invalid then
    setStatus("player: missing node")
    return
  end if

  ' Reset per-playback track preference application.
  m.trackPrefsAppliedAudio = false
  m.trackPrefsAppliedSub = false
  m.availableAudioTracksCache = []
  m.availableSubtitleTracksCache = []

  ' Clear any prior selection so we don't carry track IDs across unrelated assets.
  ' We'll re-apply preferences once track lists become available.
  if m.player.hasField("audioTrack") then m.player.audioTrack = ""
  if m.player.hasField("subtitleTrack") then m.player.subtitleTrack = ""
  if m.player.hasField("currentSubtitleTrack") then m.player.currentSubtitleTrack = ""

  ' Clear transient status before entering the video plane.
  setStatus("ready")

  safeUrl = url
  if safeUrl = invalid then safeUrl = ""
  qpos = Instr(1, safeUrl, "?") ' 1-based; returns 0 when not found
  if qpos > 0 then safeUrl = Left(safeUrl, qpos - 1)
  liveStr = "false"
  if isLive = true then liveStr = "true"
  fmtStr = streamFormat
  if fmtStr = invalid then fmtStr = ""
  fmtStr = fmtStr.Trim()
  print "startVideo kind=" + kind + " live=" + liveStr + " fmt=" + fmtStr + " url=" + safeUrl

  ' If we're switching streams mid-playback (Live signature renew), ignore the
  ' transient "stopped" state so we don't exit back to the UI.
  wasResign = (m.liveResignPending = true)
  if wasResign = true and m.player.visible = true then m.ignoreNextStopped = true
  m.liveResignPending = false

  c = CreateObject("roSGNode", "ContentNode")
  c.url = url
  if streamFormat <> invalid and streamFormat.Trim() <> "" then
    c.streamFormat = streamFormat.Trim()
  end if
  c.title = title

  ' Best-effort sound hinting for Roku TVs. Should not break sticks.
  ' These classifiers help Roku TVs pick appropriate audio processing presets.
  classifier = "comedy"
  if isLive = true then classifier = "sports"
  if classifier <> "" then
    if c.hasField("contentClassifier") then
      c.contentClassifier = classifier
    else if c.hasField("ContentClassifier") then
      c.ContentClassifier = classifier
    else
      c.addField("contentClassifier", "string", false)
      c.contentClassifier = classifier
    end if
  end if

  ' Mark live playback and start near the live edge without doing any seeks.
  ' Avoiding seek-based "snap to live" is critical for A/V sync stability on some firmwares.
  if isLive = true then
    if c.hasField("Live") then
      c.Live = true
    else if c.hasField("live") then
      c.live = true
    else
      c.addField("Live", "boolean", false)
      c.Live = true
    end if

    ' Per Roku content metadata docs, negative PlayStart is relative to the live edge (OS 8.0+).
    ' Start further behind the edge to give the firmware more room to build a stable buffer
    ' (some devices show subtle A/V sync jitter when starting too close to the edge).
    if c.hasField("PlayStart") then
      c.PlayStart = -24
    else if c.hasField("playStart") then
      c.playStart = -24
    else if c.hasField("playstart") then
      c.playstart = -24
    else
      c.addField("PlayStart", "float", false)
      c.PlayStart = -24
    end if

    ' Live doesn't need trick/transport UI; reduce overlay work.
    if c.hasField("VideoDisableUI") then
      c.VideoDisableUI = true
    else if c.hasField("videoDisableUI") then
      c.videoDisableUI = true
    else
      c.addField("VideoDisableUI", "boolean", false)
      c.VideoDisableUI = true
    end if
  end if

  m.playbackKind = kind
  m.playbackIsLive = isLive
  m.playbackItemId = itemId
  m.playbackTitle = title
  m.liveEdgeSnapped = false

  m.player.content = c
  m.player.visible = true
  m.player.control = "play"
  ' Give focus to the Video node so Roku's built-in transport UI works.
  m.player.setFocus(true)
  hidePlayerOverlay()
  if m.settingsOpen = true then hidePlayerSettings()

  if isLive = true then
    if m.sigCheckTimer <> invalid then m.sigCheckTimer.control = "start"
  else
    if m.sigCheckTimer <> invalid then m.sigCheckTimer.control = "stop"
  end if

  ' If the R2 playlist is missing, some firmwares stay buffering for a long
  ' time without surfacing an error. Fallback to Jellyfin after a short grace.
  if kind = "vod-r2" and m.playTimeoutTimer <> invalid then
    m.playTimeoutTimer.control = "start"
  end if
end sub

sub onPlayTimeoutFire()
  if m.player = invalid then return
  if m.player.visible <> true then return
  if m.playbackKind <> "vod-r2" then return
  if m.vodFallbackAttempted = true then return

  st = m.lastPlayerState
  if st = invalid then st = ""
  st = LCase(st.Trim())
  if st = "playing" then return

  id = m.playbackItemId
  t = m.playbackTitle
  if id = invalid then id = ""
  id = id.Trim()
  if id = "" then return

  m.vodFallbackAttempted = true
  print "VOD R2 timeout (state=" + st + "): fallback to Jellyfin"
  m.player.control = "stop"
  m.player.visible = false
  setStatus("vod r2 lento; tentando jellyfin...")
  requestJellyfinPlayback(id, t, false, "vod-jellyfin")
end sub

sub stopPlaybackAndReturn(reason as String)
  if m.player = invalid then return
  if m.player.visible <> true then return

  r = reason
  if r = invalid then r = ""
  print "stopPlaybackAndReturn reason=" + r

  ' Cancel any in-flight playback jobs (especially Live signature renew) so a late
  ' /sign response can't restart playback after the user exits.
  m.pendingJob = ""
  m.pendingPlayTitle = ""
  m.pendingPlayExtraQuery = {}
  m.pendingPlayStreamFormat = ""
  m.pendingPlayIsLive = false
  m.pendingPlaybackKind = ""
  m.pendingPlaybackItemId = ""

  if m.playTimeoutTimer <> invalid then m.playTimeoutTimer.control = "stop"
  if m.sigCheckTimer <> invalid then m.sigCheckTimer.control = "stop"

  m.player.control = "stop"
  m.player.visible = false
  m.player.content = invalid

  m.playbackKind = ""
  m.playbackIsLive = false
  m.playbackItemId = ""
  m.playbackTitle = ""
  m.vodFallbackAttempted = false
  m.vodJellyfinTranscodeAttempted = false
  m.liveEdgeSnapped = false
  m.lastPlayerState = ""
  m.playbackSignedExp = 0
  m.liveResignPending = false
  m.ignoreNextStopped = false
  m.settingsOpen = false
  m.overlayOpen = false
  if m.playerOverlay <> invalid then m.playerOverlay.visible = false
  if m.playerSettingsModal <> invalid then m.playerSettingsModal.visible = false

  if m.mode = "live" and m.channelsList <> invalid then
    m.channelsList.setFocus(true)
  else
    applyFocus()
  end if
end sub

sub onSigCheckTimerFire()
  if m.player = invalid then return
  if m.player.visible <> true then return
  if m.playbackIsLive <> true then return
  if m.pendingJob <> "" then return
  if m.liveResignPending = true then return

  expVal = m.playbackSignedExp
  if expVal = invalid then expVal = 0
  expNum = Int(expVal)
  if expNum <= 0 then return

  dt = CreateObject("roDateTime")
  if dt = invalid then return
  nowNum = dt.AsSeconds()
  if nowNum <= 0 then return

  remaining = expNum - nowNum
  if remaining > 120 then return

  p = m.playbackSignPath
  if p = invalid then p = ""
  p = p.Trim()
  if p = "" then return

  cfg = loadConfig()
  if cfg.apiBase = "" or cfg.appToken = "" or cfg.jellyfinToken = "" then return

  print "live: renew signature remaining=" + remaining.ToStr() + " path=" + p
  m.liveResignPending = true
  beginSign(p, m.playbackSignExtraQuery, m.playbackTitle, m.playbackStreamFormat, true, m.playbackKind, m.playbackItemId)
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
  if press <> true then return false

  k = key
  if k = invalid then k = ""
  kl = LCase(k.Trim())

  ' Modal player settings has priority during playback.
  if m.settingsOpen = true then
    if kl = "back" then
      hidePlayerSettings()
      return true
    end if
    if kl = "left" then
      m.settingsCol = "audio"
      if m.playerSettingsAudioList <> invalid then m.playerSettingsAudioList.setFocus(true)
      return true
    end if
    if kl = "right" then
      m.settingsCol = "sub"
      if m.playerSettingsSubList <> invalid then m.playerSettingsSubList.setFocus(true)
      return true
    end if
    return false
  end if

  if m.overlayOpen = true then
    if kl = "back" then
      hidePlayerOverlay()
      return true
    end if
    if kl = "ok" then
      showPlayerSettings()
      return true
    end if
    return false
  end if

  ' Always allow BACK to exit playback, regardless of the current mode.
  if m.player <> invalid and m.player.visible = true and kl = "back" then
    setStatus("stopped")
    stopPlaybackAndReturn("back")
    return true
  end if

  ' NOTE: We intentionally avoid programmatic seeking during live playback.
  ' Seeking to "duration - N" can land between segment boundaries and introduce A/V sync issues.

  if m.mode = "browse" then
    if m.player <> invalid and m.player.visible = true then return false

    if key = "left" then
      if m.browseFocus = "items" then
        m.browseFocus = "views"
        applyFocus()
        return true
      end if
    end if

    if key = "right" then
      if m.browseFocus = "views" then
        m.browseFocus = "items"
        applyFocus()
        return true
      end if
    end if
  end if

  if key = "up" then
    if m.player <> invalid and m.player.visible = true then return false
    if m.mode = "live" or m.mode = "browse" then return false
    if m.focusIndex > 0 then m.focusIndex = m.focusIndex - 1
    applyFocus()
    return true
  end if

  if key = "down" then
    if m.player <> invalid and m.player.visible = true then return false
    if m.mode = "live" or m.mode = "browse" then return false
    if m.focusIndex < 2 then m.focusIndex = m.focusIndex + 1
    applyFocus()
    return true
  end if

  if key = "OK" then
    if m.player <> invalid and m.player.visible = true then
      showPlayerOverlay()
      return true
    end if
    if m.mode = "live" or m.mode = "browse" then return false
    if m.mode = "login" then
      if m.focusIndex = 0 then
        promptKeyboard("username", "Usuario", m.form.username, false)
      else if m.focusIndex = 1 then
        promptKeyboard("password", "Senha", m.form.password, true)
      else
        doLogin()
      end if
    else if m.mode = "home" then
      if m.focusIndex = 0 then
        enterLive()
      else if m.focusIndex = 1 then
        showTokens()
      else
        doLogout()
      end if
    end if
    return true
  end if

  if key = "back" then
    if m.mode = "live" then
      enterBrowse()
      return true
    end if

    if m.mode = "browse" then
      if m.browseFocus = "items" then
        m.browseFocus = "views"
        applyFocus()
        return true
      end if
      enterHome()
      return true
    end if
  end if

  if key = "options" then
    ' While video is playing, open our settings dialog (do not depend on Roku * menu).
    if m.player <> invalid and m.player.visible = true then
      showPlayerSettings()
      return true
    end if
    showSettings()
    return true
  end if

  if kl = "info" then
    if m.player <> invalid and m.player.visible = true then
      showPlayerSettings()
      return true
    end if
  end if

  if kl = "ok" then
    if m.player <> invalid and m.player.visible = true then
      showPlayerOverlay()
      return true
    end if
  end if

  if key = "play" then
    ' During playback, do not hijack PLAY for dev shortcuts.
    if m.player <> invalid and m.player.visible = true then return false
    ' Quick dev shortcut: Play Live if logged in.
    cfg = loadConfig()
    if cfg.appToken <> "" and cfg.jellyfinToken <> "" then
      playLive()
      return true
    end if
  end if

  return false
end function

sub applyFocus()
  if m.mode = "live" then
    if m.channelsList <> invalid then m.channelsList.setFocus(true)
    return
  end if

  if m.mode = "browse" then
    if m.browseFocus = "items" then
      if m.itemsList <> invalid then
        m.itemsList.setFocus(true)
      else if m.viewsList <> invalid then
        m.viewsList.setFocus(true)
      end if
    else
      if m.viewsList <> invalid then m.viewsList.setFocus(true)
    end if
    return
  end if

  if m.mode = "home" then
    applyHomeFocus()
    return
  end if

  ' username row
  if m.usernameBg <> invalid then
    if m.focusIndex = 0 then
      m.usernameBg.uri = "pkg:/images/field_focus.png"
    else
      m.usernameBg.uri = "pkg:/images/field_normal.png"
    end if
  end if
  if m.usernameText <> invalid then
    if m.focusIndex = 0 then
      m.usernameText.color = "0xFFFFFF"
    else
      m.usernameText.color = "0xD0D6E0"
    end if
  end if

  ' password row
  if m.passwordBg <> invalid then
    if m.focusIndex = 1 then
      m.passwordBg.uri = "pkg:/images/field_focus.png"
    else
      m.passwordBg.uri = "pkg:/images/field_normal.png"
    end if
  end if
  if m.passwordText <> invalid then
    if m.focusIndex = 1 then
      m.passwordText.color = "0xFFFFFF"
    else
      m.passwordText.color = "0xD0D6E0"
    end if
  end if

  ' login row
  if m.loginBg <> invalid then
    if m.focusIndex = 2 then
      m.loginBg.uri = "pkg:/images/login_button_focus.png"
    else
      m.loginBg.uri = "pkg:/images/login_button_normal.png"
    end if
  end if
  if m.loginText <> invalid then
    if m.focusIndex = 2 then
      m.loginText.color = "0x0B0F16"
    else
      m.loginText.color = "0xD8B765"
    end if
  end if
end sub

sub applyHomeFocus()
  ' Home menu items: 0=live,1=tokens,2=logout.
  if m.homeLiveBg <> invalid then
    if m.focusIndex = 0 then m.homeLiveBg.uri = "pkg:/images/button_focus.png" else m.homeLiveBg.uri = "pkg:/images/button_normal.png"
  end if
  if m.homeTokensBg <> invalid then
    if m.focusIndex = 1 then m.homeTokensBg.uri = "pkg:/images/button_focus.png" else m.homeTokensBg.uri = "pkg:/images/button_normal.png"
  end if
  if m.homeLogoutBg <> invalid then
    if m.focusIndex = 2 then m.homeLogoutBg.uri = "pkg:/images/button_focus.png" else m.homeLogoutBg.uri = "pkg:/images/button_normal.png"
  end if
end sub

sub showSettings()
  if m.pendingDialog <> invalid then return

  dlg = CreateObject("roSGNode", "Dialog")
  dlg.title = "Opcoes"
  dlg.message = "1) Configurar APP_TOKEN" + Chr(10) + "2) Tokens" + Chr(10) + "3) Limpar dados salvos" + Chr(10) + "4) Sair"
  dlg.buttons = ["APP_TOKEN", "Tokens", "Limpar", "Sair", "Cancelar"]
  dlg.observeField("buttonSelected", "onSettingsDone")
  m.pendingDialog = dlg
  m.top.dialog = dlg
  dlg.setFocus(true)
end sub

sub onSettingsDone()
  dlg = m.pendingDialog
  if dlg = invalid then return
  idx = dlg.buttonSelected
  m.top.dialog = invalid
  m.pendingDialog = invalid

  if idx = 0 then
    cfg = loadConfig()
    promptKeyboard("appToken", "APP_TOKEN", cfg.appToken, false)
  else if idx = 1 then
    showTokens()
  else if idx = 2 then
    clearSaved()
  else if idx = 3 then
    doLogout()
  else
    ' no-op
  end if
end sub

sub onPlayerStateChanged()
  st = m.player.state
  if st = invalid then return
  m.lastPlayerState = st
  curPos = m.player.position
  curDur = m.player.duration
  p = 0
  d = 0
  if curPos <> invalid then p = Int(curPos)
  if curDur <> invalid then d = Int(curDur)
  print "player state=" + st + " kind=" + m.playbackKind + " pos=" + p.ToStr() + " dur=" + d.ToStr()
  if st = "playing" then
    if m.playTimeoutTimer <> invalid then m.playTimeoutTimer.control = "stop"
    ' Best-effort: apply preferred tracks once playback is stable.
    applyPreferredTracks()
  else if st = "stopped" then
    if m.ignoreNextStopped = true then
      m.ignoreNextStopped = false
      return
    end if
    ' When the system/player stops playback (for example after the user presses BACK
    ' while the Video UI has focus), ensure we return to our UI.
    stopPlaybackAndReturn("state_stopped")
  else if st = "finished" then
    stopPlaybackAndReturn("finished")
  end if
end sub

sub onPlayerDurationChanged()
  ' no-op (avoid live seek logic for sync stability)
end sub

sub onPlayerError()
  msg = m.player.errorMsg
  if msg = invalid then msg = "unknown"
  print "player error kind=" + m.playbackKind + ": " + msg
  setStatus("player error: " + msg)
  if m.playTimeoutTimer <> invalid then m.playTimeoutTimer.control = "stop"

  ' If R2 VOD fails (missing object, etc.), fall back to Jellyfin DirectPlay/DirectStream.
  if m.playbackKind = "vod-r2" and m.vodFallbackAttempted <> true then
    id = m.playbackItemId
    t = m.playbackTitle
    if id <> invalid and id.Trim() <> "" then
      m.vodFallbackAttempted = true
      if m.player <> invalid then m.player.control = "stop"
      if m.player <> invalid then m.player.visible = false
      setStatus("vod r2 falhou; tentando jellyfin...")
      requestJellyfinPlayback(id, t, false, "vod-jellyfin")
      return
    end if
  end if

  ' If Jellyfin VOD fails (likely codec/profile mismatch), retry once with transcoding enabled.
  if m.playbackKind = "vod-jellyfin" and m.vodJellyfinTranscodeAttempted <> true then
    id2 = m.playbackItemId
    t2 = m.playbackTitle
    if id2 <> invalid and id2.Trim() <> "" then
      m.vodJellyfinTranscodeAttempted = true
      ' Stop without leaving UI: we're switching source.
      m.ignoreNextStopped = true
      if m.player <> invalid then m.player.control = "stop"
      if m.player <> invalid then m.player.visible = false
      setStatus("vod jellyfin falhou; tentando transcode...")
      requestJellyfinPlayback2(id2, t2, false, "vod-jellyfin", true, true)
      return
    end if
  end if

  stopPlaybackAndReturn("error")
end sub

sub clearSaved()
  clearConfig()
  m.form.username = ""
  m.form.password = ""
  renderForm()
  enterLogin()
end sub

sub doLogout()
  clearConfig()
  m.form.username = ""
  m.form.password = ""
  renderForm()
  enterLogin()
end sub

sub promptKeyboard(kind as String, title as String, initial as String, secure as Boolean)
  if m.pendingDialog <> invalid then return
  m.pendingPrompt = kind

  dlg = CreateObject("roSGNode", "KeyboardDialog")
  dlg.title = title
  dlg.text = initial
  dlg.buttons = ["OK", "Cancel"]
  dlg.observeField("buttonSelected", "onKeyboardDone")

  if secure and dlg.hasField("secureMode") then dlg.secureMode = true

  m.pendingDialog = dlg
  m.top.dialog = dlg
  dlg.setFocus(true)
end sub

sub onKeyboardDone()
  dlg = m.pendingDialog
  if dlg = invalid then return

  idx = dlg.buttonSelected
  txt = dlg.text

  m.top.dialog = invalid
  m.pendingDialog = invalid

  if idx <> 0 then
    setStatus("cancelado")
    m.pendingPrompt = ""
    return
  end if

  if m.pendingPrompt = "username" then
    m.form.username = txt.Trim()
  else if m.pendingPrompt = "password" then
    m.form.password = txt
  else if m.pendingPrompt = "appToken" then
    token = txt.Trim()
    cfg = loadConfig()
    saveConfig(m.apiBase, token, cfg.jellyfinToken, cfg.userId)
    setStatus("APP_TOKEN ok")
  end if

  m.pendingPrompt = ""
  renderForm()
  applyFocus()
end sub

sub loadSavedIntoForm()
  ' We intentionally do not store username/password in registry.
  cfg = loadConfig()
  if cfg.appToken = invalid or cfg.appToken = "" then
    if m.hintLabel <> invalid then m.hintLabel.visible = true
  else
    if m.hintLabel <> invalid then m.hintLabel.visible = false
  end if
end sub

sub enterLogin()
  m.mode = "login"
  m.focusIndex = 0
  if m.logoPoster <> invalid then m.logoPoster.visible = true
  if m.titleLabel <> invalid then m.titleLabel.visible = true
  if m.loginCard <> invalid then m.loginCard.visible = true
  if m.homeCard <> invalid then m.homeCard.visible = false
  if m.browseCard <> invalid then m.browseCard.visible = false
  if m.liveCard <> invalid then m.liveCard.visible = false
  layoutCards()
  loadSavedIntoForm()
  applyFocus()
  setStatus("ready")
end sub

sub enterHome()
  m.mode = "home"
  m.focusIndex = 0
  if m.logoPoster <> invalid then m.logoPoster.visible = true
  if m.titleLabel <> invalid then m.titleLabel.visible = true
  if m.loginCard <> invalid then m.loginCard.visible = false
  if m.homeCard <> invalid then m.homeCard.visible = true
  if m.browseCard <> invalid then m.browseCard.visible = false
  if m.liveCard <> invalid then m.liveCard.visible = false
  layoutCards()
  if m.hintLabel <> invalid then m.hintLabel.visible = false
  applyFocus()
  setStatus("ready")
end sub

sub enterBrowse()
  m.mode = "browse"
  m.browseFocus = "views"

  if m.logoPoster <> invalid then m.logoPoster.visible = false
  if m.titleLabel <> invalid then m.titleLabel.visible = false
  if m.loginCard <> invalid then m.loginCard.visible = false
  if m.homeCard <> invalid then m.homeCard.visible = false
  if m.liveCard <> invalid then m.liveCard.visible = false
  if m.browseCard <> invalid then m.browseCard.visible = true
  if m.hintLabel <> invalid then m.hintLabel.visible = false

  layoutCards()

  ' Fresh content on entry (avoid showing stale lists after logout/login).
  m.activeViewId = ""
  m.activeViewCollection = ""
  m.pendingShelfViewId = ""
  m.queuedShelfViewId = ""
  m.shelfCache = {}

  if m.viewsList <> invalid then m.viewsList.content = CreateObject("roSGNode", "ContentNode")
  if m.itemsList <> invalid then m.itemsList.content = CreateObject("roSGNode", "ContentNode")
  if m.browseEmptyLabel <> invalid then
    m.browseEmptyLabel.text = "Sem itens"
    m.browseEmptyLabel.visible = true
  end if

  applyFocus()
  loadViews()
end sub

sub loadViews()
  if m.gatewayTask = invalid then
    setStatus("gateway: missing task")
    return
  end if
  if m.viewsList = invalid then
    setStatus("views: missing list")
    return
  end if
  if m.pendingJob <> "" then
    setStatus("aguarde...")
    return
  end if

  cfg = loadConfig()
  if cfg.apiBase = "" or cfg.appToken = "" or cfg.jellyfinToken = "" or cfg.userId = "" then
    setStatus("views: missing config")
    if m.browseEmptyLabel <> invalid then
      m.browseEmptyLabel.text = "Faltou config (APP_TOKEN/login)"
      m.browseEmptyLabel.visible = true
    end if
    return
  end if

  setStatus("carregando bibliotecas...")
  m.pendingJob = "views"
  m.gatewayTask.kind = "views"
  m.gatewayTask.apiBase = cfg.apiBase
  m.gatewayTask.appToken = cfg.appToken
  m.gatewayTask.jellyfinToken = cfg.jellyfinToken
  m.gatewayTask.userId = cfg.userId
  m.gatewayTask.control = "run"
end sub

sub onViewFocused()
  if m.mode <> "browse" then return
  if m.viewsList = invalid then return

  idx = m.viewsList.itemFocused
  if idx = invalid or idx < 0 then return

  root = m.viewsList.content
  if root = invalid then return
  v = root.getChild(idx)
  if v = invalid then return

  viewId = v.id
  if viewId = invalid then viewId = ""

  ctype = ""
  if v.hasField("collectionType") then ctype = v.collectionType
  if ctype = invalid then ctype = ""

  m.activeViewId = viewId
  m.activeViewCollection = ctype

  if m.itemsTitle <> invalid then
    t = v.title
    if t = invalid then t = ""
    t = t.Trim()
    if t = "" then
      m.itemsTitle.text = "Recentes"
    else
      m.itemsTitle.text = "Recentes: " + t
    end if
  end if

  if ctype = "livetv" then
    if m.itemsList <> invalid then m.itemsList.content = CreateObject("roSGNode", "ContentNode")
    if m.browseEmptyLabel <> invalid then
      m.browseEmptyLabel.text = "Pressione OK para abrir Live TV"
      m.browseEmptyLabel.visible = true
    end if
    return
  end if

  loadShelfForView(viewId)
end sub

sub onViewSelected()
  if m.mode <> "browse" then return
  if m.viewsList = invalid then return

  idx = m.viewsList.itemSelected
  if idx = invalid or idx < 0 then return

  root = m.viewsList.content
  if root = invalid then return
  v = root.getChild(idx)
  if v = invalid then return

  ctype = ""
  if v.hasField("collectionType") then ctype = v.collectionType
  if ctype = invalid then ctype = ""

  if ctype = "livetv" then
    enterLive()
    return
  end if

  m.browseFocus = "items"
  applyFocus()
end sub

sub loadShelfForView(viewId as String)
  if viewId = invalid then return
  id = viewId.Trim()
  if id = "" then return

  if m.itemsList = invalid then return

  cached = invalid
  if m.shelfCache <> invalid then cached = m.shelfCache[id]
  if cached <> invalid and cached <> "" then
    renderShelfItems(cached)
    return
  end if

  if m.pendingJob <> "" then
    if m.pendingJob = "shelf" and m.pendingShelfViewId = id then return
    m.queuedShelfViewId = id
    return
  end if

  cfg = loadConfig()
  if cfg.apiBase = "" or cfg.appToken = "" or cfg.jellyfinToken = "" or cfg.userId = "" then
    setStatus("shelf: missing config")
    if m.browseEmptyLabel <> invalid then
      m.browseEmptyLabel.text = "Faltou config (APP_TOKEN/login)"
      m.browseEmptyLabel.visible = true
    end if
    return
  end if

  if m.browseEmptyLabel <> invalid then
    m.browseEmptyLabel.text = "Carregando..."
    m.browseEmptyLabel.visible = true
  end if

  setStatus("carregando itens...")
  m.pendingJob = "shelf"
  m.pendingShelfViewId = id
  m.gatewayTask.kind = "shelf"
  m.gatewayTask.apiBase = cfg.apiBase
  m.gatewayTask.appToken = cfg.appToken
  m.gatewayTask.jellyfinToken = cfg.jellyfinToken
  m.gatewayTask.userId = cfg.userId
  m.gatewayTask.parentId = id
  m.gatewayTask.limit = 12
  m.gatewayTask.control = "run"
end sub

sub renderShelfItems(raw as String)
  if m.itemsList = invalid then return

  items = ParseJson(raw)
  if type(items) <> "roArray" then items = []

  root = CreateObject("roSGNode", "ContentNode")
  for each it in items
    c = CreateObject("roSGNode", "ContentNode")
    c.addField("itemType", "string", false)
    c.addField("path", "string", false)
    if it <> invalid then
      if it.id <> invalid then c.id = it.id
      if it.name <> invalid then c.title = it.name else c.title = ""
      if it.type <> invalid then c.itemType = it.type else c.itemType = ""
      if it.path <> invalid then c.path = it.path else c.path = ""
    else
      c.title = ""
      c.itemType = ""
      c.path = ""
    end if
    root.appendChild(c)
  end for

  m.itemsList.content = root

  if m.devAutoplay = "vod" and m.devAutoplayDone <> true then
    ' Helpful for debugging when we can't inject keypress events remotely.
    if root.getChildCount() > 0 then
      first = root.getChild(0)
      if first <> invalid then
        m.devAutoplayDone = true
        print "DEV autoplay VOD: " + first.id + " (" + first.title + ")"
        playVodById(first.id, first.title)
      end if
    end if
  end if

  if m.browseEmptyLabel <> invalid then
    m.browseEmptyLabel.text = "Sem itens"
    m.browseEmptyLabel.visible = (root.getChildCount() = 0)
  end if
end sub

sub onItemSelected()
  if m.mode <> "browse" then return
  if m.itemsList = invalid then return

  idx = m.itemsList.itemSelected
  if idx = invalid or idx < 0 then return

  root = m.itemsList.content
  if root = invalid then return
  it = root.getChild(idx)
  if it = invalid then return

  typ = ""
  if it.hasField("itemType") then typ = it.itemType
  if typ = invalid then typ = ""
  typ = typ.Trim()

  ' TODO: Implement series -> resolve next episode; for now, show a clear message.
  if LCase(typ) = "series" then
    if m.pendingDialog <> invalid then return
    dlg = CreateObject("roSGNode", "Dialog")
    dlg.title = it.title
    dlg.message = "Series ainda nao esta implementado no Roku."
    dlg.buttons = ["OK"]
    dlg.observeField("buttonSelected", "onTokensDone")
    m.pendingDialog = dlg
    m.top.dialog = dlg
    dlg.setFocus(true)
    return
  end if

  playVodById(it.id, it.title)
end sub

sub enterLive()
  print "enterLive()"
  m.mode = "live"
  if m.logoPoster <> invalid then m.logoPoster.visible = false
  if m.titleLabel <> invalid then m.titleLabel.visible = false
  if m.loginCard <> invalid then m.loginCard.visible = false
  if m.homeCard <> invalid then m.homeCard.visible = false
  if m.browseCard <> invalid then m.browseCard.visible = false
  if m.liveCard <> invalid then m.liveCard.visible = true
  if m.hintLabel <> invalid then m.hintLabel.visible = false
  layoutCards()
  applyFocus()
  loadChannels()
end sub

sub loadChannels()
  if m.gatewayTask = invalid then
    setStatus("gateway: missing task")
    return
  end if
  if m.channelsList = invalid then
    setStatus("channels: missing list")
    return
  end if

  if m.liveEmptyLabel <> invalid then m.liveEmptyLabel.visible = false
  m.channelsList.content = CreateObject("roSGNode", "ContentNode")

  if m.pendingJob <> "" then
    setStatus("aguarde...")
    return
  end if

  cfg = loadConfig()
  if cfg.apiBase = "" or cfg.appToken = "" or cfg.jellyfinToken = "" then
    setStatus("channels: missing config")
    if m.liveEmptyLabel <> invalid then m.liveEmptyLabel.visible = true
    return
  end if

  print "channels request..."
  setStatus("carregando canais...")
  m.pendingJob = "channels"
  m.gatewayTask.kind = "channels"
  m.gatewayTask.apiBase = cfg.apiBase
  m.gatewayTask.appToken = cfg.appToken
  m.gatewayTask.jellyfinToken = cfg.jellyfinToken
  m.gatewayTask.control = "run"
end sub

sub onChannelSelected()
  if m.mode <> "live" then return
  if m.channelsList = invalid then return

  idx = m.channelsList.itemSelected
  if idx = invalid or idx < 0 then return

  root = m.channelsList.content
  if root = invalid then return

  item = root.getChild(idx)
  if item = invalid then return
  p = ""
  if item.hasField("path") then p = item.path
  if p <> invalid then p = p.Trim()
  if p <> "" then
    signAndPlay(p, item.title)
    return
  end if

  ' Some Jellyfin LiveTV channel payloads omit Path; our Live pipeline is /hls/master.m3u8.
  signAndPlay("/hls/master.m3u8", item.title)
end sub

sub showTokens()
  if m.pendingDialog <> invalid then return
  cfg = loadConfig()

  msg = "APP_TOKEN: " + shortToken(cfg.appToken) + Chr(10) + "JELLYFIN: " + shortToken(cfg.jellyfinToken) + Chr(10) + "USER: " + cfg.userId

  dlg = CreateObject("roSGNode", "Dialog")
  dlg.title = "Tokens"
  dlg.message = msg
  dlg.buttons = ["OK"]
  dlg.observeField("buttonSelected", "onTokensDone")
  m.pendingDialog = dlg
  m.top.dialog = dlg
  dlg.setFocus(true)
end sub

sub onTokensDone()
  m.top.dialog = invalid
  m.pendingDialog = invalid
  setStatus("ready")
  applyFocus()
end sub

function shortToken(t as String) as String
  if t = invalid then return ""
  v = t.Trim()
  if v = "" then return "-"
  if Len(v) <= 16 then return v
  return Left(v, 6) + "..." + Right(v, 4)
end function

function normalizeJellyfinId(id as String) as String
  if id = invalid then return ""
  s = LCase(id.Trim())
  if s = "" then return ""

  out = ""
  for i = 1 to Len(s)
    ch = Mid(s, i, 1)
    if (ch >= "a" and ch <= "z") or (ch >= "0" and ch <= "9") then
      out = out + ch
    end if
  end for
  return out
end function

function r2VodPathForItemId(itemId as String) as String
  norm = normalizeJellyfinId(itemId)
  if norm = "" then return ""

  key = norm
  ' Keep parity with the desktop app's override for a known legacy upload.
  if norm = "a8bcc2c9c478683afaa0d0be1632b5b4" then key = "fallout-s02e01"
  return "/r2/vod/" + key + "/master.m3u8"
end function

function parseQueryString(qs as String) as Object
  out = {}
  if qs = invalid then return out
  s = qs.Trim()
  if s = "" then return out

  i = 1
  n = Len(s)
  while i <= n
    amp = Instr(i, s, "&") ' 1-based; returns 0 when not found
    if amp = 0 then
      p = Mid(s, i)
      i = n + 1
    else
      p = Mid(s, i, amp - i)
      i = amp + 1
    end if

    if p = invalid then p = ""
    p = p.Trim()
    if p <> "" then
      eq = Instr(1, p, "=") ' 1-based; returns 0 when not found
      if eq > 0 then
        k = Left(p, eq - 1)
        v = Mid(p, eq + 1)
      else
        k = p
        v = ""
      end if

      if k = invalid then k = ""
      k = k.Trim()
      if k <> "" then out[k] = v
    end if
  end while
  return out
end function

sub stripSigParams(q as Object)
  if type(q) <> "roAssociativeArray" then return
  toDel = []
  for each k in q
    if k <> invalid then
      kl = LCase(k)
      if kl = "sig" or kl = "exp" then toDel.Push(k)
    end if
  end for
  for each k in toDel
    q.Delete(k)
  end for
end sub

function parseTarget(raw as String, defaultPath as String) as Object
  out = { path: defaultPath, query: {} }
  if raw = invalid then return out

  v = raw.Trim()
  if v = "" then return out

  ' Strip scheme/authority when a full URL is provided.
  scheme = Instr(1, v, "://") ' 1-based; returns 0 when not found
  if scheme > 0 then
    slash = Instr(scheme + 3, v, "/")
    if slash > 0 then
      v = Mid(v, slash)
    else
      v = defaultPath
    end if
  end if

  if v = invalid then v = ""
  v = v.Trim()
  if v = "" then v = defaultPath
  if v = invalid then v = ""
  v = v.Trim()
  if v = "" then v = "/hls/master.m3u8"
  if Left(v, 1) <> "/" then v = "/" + v

  qpos = Instr(1, v, "?") ' 1-based; returns 0 when not found
  if qpos > 0 then
    pathLen = qpos - 1
    if pathLen < 0 then pathLen = 0
    out.path = Left(v, pathLen)
    out.query = parseQueryString(Mid(v, qpos + 1))
    stripSigParams(out.query)
  else
    out.path = v
    out.query = {}
  end if

  return out
end function

function appendQuery(url as String, extra as Object) as String
  if url = invalid then return ""
  if type(extra) <> "roAssociativeArray" then return url
  if extra.Count() <= 0 then return url

  out = url
  sep = "?"
  if Instr(1, out, "?") > 0 then sep = "&"

  for each k in extra
    if k <> invalid then
      v = extra[k]
      if v = invalid then v = ""
      if type(v) <> "roString" then v = v.ToStr()
      out = out + sep + k + "=" + v
      sep = "&"
    end if
  end for

  return out
end function

function inferStreamFormat(pathOrUrl as String, container as String) as String
  p = pathOrUrl
  if p = invalid then p = ""
  v = LCase(p.Trim())

  if v.EndsWith(".m3u8") or v.EndsWith(".m3u") then return "hls"
  if v.EndsWith(".mpd") then return "dash"
  if v.EndsWith(".ism") or v.EndsWith(".ism/manifest") then return "ism"
  if Instr(1, v, "/hls/") > 0 then return "hls"

  c = container
  if c = invalid then c = ""
  cl = LCase(c.Trim())
  if cl = "mp4" or cl = "m4v" or cl = "mov" then return "mp4"

  return "mp4"
end function

sub beginSign(path as String, extraQuery as Object, title as String, streamFormat as String, isLive as Boolean, playbackKind as String, itemId as String)
  if m.gatewayTask = invalid then
    setStatus("gateway: missing task")
    return
  end if
  if m.pendingJob <> "" then
    setStatus("aguarde...")
    return
  end if

  cfg = loadConfig()
  if cfg.apiBase = "" or cfg.appToken = "" or cfg.jellyfinToken = "" then
    setStatus("play: missing config")
    return
  end if

  p = path
  if p = invalid then p = ""
  p = p.Trim()
  if p = "" then
    setStatus("play: missing path")
    return
  end if

  t = title
  if t = invalid then t = ""
  t = t.Trim()
  if t = "" then t = "Video"

  ' Remember the most recent signed target so Live can renew exp/sig mid-playback.
  m.playbackSignPath = p
  if type(extraQuery) = "roAssociativeArray" then
    m.playbackSignExtraQuery = extraQuery
  else
    m.playbackSignExtraQuery = {}
  end if
  m.playbackStreamFormat = streamFormat

  m.pendingPlayTitle = t
  if type(extraQuery) = "roAssociativeArray" then
    m.pendingPlayExtraQuery = extraQuery
  else
    m.pendingPlayExtraQuery = {}
  end if
  m.pendingPlayStreamFormat = streamFormat
  m.pendingPlayIsLive = (isLive = true)
  m.pendingPlaybackKind = playbackKind
  m.pendingPlaybackItemId = itemId

  setStatus("signing " + p)
  liveStr = "false"
  if isLive = true then liveStr = "true"
  fmtStr = streamFormat
  if fmtStr = invalid then fmtStr = ""
  fmtStr = fmtStr.Trim()
  if fmtStr = "" then fmtStr = inferStreamFormat(p, "")
  print "sign start kind=" + playbackKind + " live=" + liveStr + " fmt=" + fmtStr + " path=" + p
  m.pendingJob = "sign"
  m.gatewayTask.kind = "sign"
  m.gatewayTask.apiBase = cfg.apiBase
  m.gatewayTask.appToken = cfg.appToken
  m.gatewayTask.jellyfinToken = cfg.jellyfinToken
  m.gatewayTask.path = p
  m.gatewayTask.control = "run"
end sub

sub requestJellyfinPlayback2(itemId as String, title as String, isLive as Boolean, playbackKind as String, preferDirectStream as Boolean, allowTranscoding as Boolean)
  if m.gatewayTask = invalid then
    setStatus("gateway: missing task")
    return
  end if
  if m.pendingJob <> "" then
    setStatus("aguarde...")
    return
  end if

  cfg = loadConfig()
  if cfg.apiBase = "" or cfg.appToken = "" or cfg.jellyfinToken = "" or cfg.userId = "" then
    setStatus("playback: missing config")
    return
  end if

  id = itemId
  if id = invalid then id = ""
  id = id.Trim()
  if id = "" then
    setStatus("playback: missing item id")
    return
  end if

  t = title
  if t = invalid then t = ""
  t = t.Trim()
  if t = "" then t = "Video"

  m.pendingPlaybackItemId = id
  m.pendingPlaybackTitle = t
  m.pendingPlaybackInfoIsLive = (isLive = true)
  k = playbackKind
  if k = invalid then k = ""
  k = k.Trim()
  if k = "" then k = "vod-jellyfin"
  m.pendingPlaybackInfoKind = k

  print "playbackinfo start itemId=" + id
  setStatus("playbackinfo...")
  m.pendingJob = "playback"
  m.gatewayTask.kind = "playback"
  m.gatewayTask.apiBase = cfg.apiBase
  m.gatewayTask.appToken = cfg.appToken
  m.gatewayTask.jellyfinToken = cfg.jellyfinToken
  m.gatewayTask.userId = cfg.userId
  m.gatewayTask.preferDirectStream = (preferDirectStream = true)
  m.gatewayTask.allowTranscoding = (allowTranscoding = true)
  m.gatewayTask.itemId = id
  m.gatewayTask.control = "run"
end sub

sub tryVodSubtitlesFromJellyfin()
  if m.player = invalid then return
  if m.playbackIsLive = true then return

  id = m.playbackItemId
  if id = invalid then id = ""
  id = id.Trim()
  if id = "" then return

  t = m.playbackTitle
  if t = invalid then t = ""
  t = t.Trim()
  if t = "" then t = "Video"

  ' Enable subs preference so if Jellyfin exposes tracks, we auto-pick.
  _ensureDefaultVodPrefs()
  m.vodPrefs.subtitlesEnabled = true
  saveVodPlayerPrefs(m.vodPrefs.audioLang, m.vodPrefs.subtitleLang, true)

  hidePlayerSettings()

  ' Stop without exiting UI (we are switching source).
  m.ignoreNextStopped = true
  m.player.control = "stop"
  m.player.visible = false

  setStatus("vod: carregando legendas do jellyfin...")
  ' Force a transcoded session (more likely to expose subtitle tracks to Roku).
  requestJellyfinPlayback2(id, t, false, "vod-jellyfin", true, true)
end sub

sub requestJellyfinPlayback(itemId as String, title as String, isLive as Boolean, playbackKind as String)
  requestJellyfinPlayback2(itemId, title, isLive, playbackKind, (isLive = true), (isLive = true))
end sub

sub seekToLiveEdge(reason as String)
  if m.player = invalid then return
  if m.player.visible <> true then return
  if m.playbackIsLive <> true then return

  dur = m.player.duration
  if dur = invalid then return
  d = Int(dur)
  if d <= 0 then return

  curPos = m.player.position
  p = 0
  if curPos <> invalid then p = Int(curPos)

  behind = d - p
  target = d - 3
  if target < 0 then target = 0

  print "live edge (" + reason + ") dur=" + d.ToStr() + " pos=" + p.ToStr() + " behind=" + behind.ToStr() + " -> " + target.ToStr()
  m.player.seek = target
  m.liveEdgeSnapped = true
end sub

sub maybeSnapLiveEdge(reason as String)
  if m.player = invalid then return
  if m.player.visible <> true then return
  if m.playbackIsLive <> true then return
  if m.liveEdgeSnapped = true then return

  dur = m.player.duration
  if dur = invalid then return
  d = Int(dur)
  if d <= 0 then return

  curPos = m.player.position
  p = 0
  if curPos <> invalid then p = Int(curPos)

  behind = d - p
  ' Keep close to the live edge; the HLS window can be large.
  if behind <= 8 then return
  seekToLiveEdge("snap_" + reason)
end sub
