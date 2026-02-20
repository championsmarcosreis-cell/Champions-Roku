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
  m.pendingProbeUrl = ""
  m.pendingProbeTitle = ""
  m.pendingProbeStreamFormat = ""
  m.pendingProbeIsLive = false
  m.pendingProbeKind = ""
  m.pendingProbeItemId = ""
  m.pendingPlaybackTitle = ""
  m.pendingVodStatusItemId = ""
  m.pendingVodStatusTitle = ""
  m.pendingPlaybackInfoIsLive = false
  m.pendingPlaybackInfoKind = ""
  m.playbackKind = ""
  m.playbackIsLive = false
  m.playbackItemId = ""
  m.playbackTitle = ""
  m.vodFallbackAttempted = false
  m.vodJellyfinTranscodeAttempted = false
  m.liveEdgeSnapped = false
  m.liveFallbackAttempted = false
  m.lastPlayerState = ""
  m.devAutoplay = ""
  m.devAutoplayDone = false
  m.browseFocus = "views" ' views | items | hero_logout | hero_continue
  m.viewsGridCols = 3
  m.itemsGridCols = 3
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
  m.uiLang = resolveUiLang()
  m.metaLang = resolveMetadataLang(m.uiLang)
  m.playAttemptId = ""
  m.playAttemptSignStarted = false
  m.pendingPlayAttemptId = ""
  m.shelfShortTtlMs = 60000
  m.settingsOpen = false
  m.overlayOpen = false
  m.focusNodeId = "scene"
  m.settingsOpenedAtMs = 0
  m.navListsInputLocked = false
  m.lastHandledPlaybackKey = ""
  m.lastHandledPlaybackKeyMs = 0
  m.lastHandledPlaybackState = ""
  m.appStartMs = _nowMs()
  ' Player UX state machine.
  m.uiState = "IDLE" ' IDLE | PLAYING | OSD | SETTINGS
  m.osdFocus = "TIMELINE" ' TIMELINE | GEAR
  m.seekTargetSec = 0
  m.seekActive = false
  m.osdBarMaxW = 1070
  m.settingsCol = "audio" ' audio | sub
  m.availableAudioTracksCache = []
  m.availableSubtitleTracksCache = []
  m.playbackSubtitleSources = []
  m.pendingSubtitleSourcesItemId = ""
  m.subtitleSourcesRequestedItemId = ""
  m.pendingSubtitleSignTrackId = ""
  m.pendingSubtitleSignPrefKey = ""
  m.pendingSubtitleSignLang = ""
  m.pendingSubtitleSignStreamIndex = -1
  m.pendingSubtitleSignSourceUrl = ""
  m.pendingSubtitleSignExtraQuery = {}
  m.lastSubtitleTrackId = ""
  m.lastSubtitleTrackKey = ""
  m.debugPrintedSubtitleTracks = false
  m.progressReportEverySec = 15
  m.progressLastSentPosMs = -1
  m.progressLastSentAtMs = 0
  m.progressPendingFlush = false
  m.progressPendingPlayed = false
  m.progressPendingReason = ""
  m.pendingProgressPosMs = -1
  m.pendingProgressDurMs = -1
  m.pendingProgressPercent = -1
  m.pendingProgressPlayed = false
  m.pendingProgressReason = ""
  m.nextStartResumeMs = 0
  m.playbackResumeTargetSec = -1
  m.playbackResumePending = false
  m.heroContinueAutoplayPending = false
  m.resumeDialogItemId = ""
  m.resumeDialogTitle = ""
  m.resumeDialogPositionMs = 0
  m.lastHeroContinueMs = 0
  m.lastBrowseOpenMs = 0
  m.lastBrowseOpenItemId = ""

  cfg0 = loadConfig()
  m.apiBase = cfg0.apiBase
  if m.apiBase = invalid or m.apiBase = "" then m.apiBase = "https://api.champions.place"

  m.devAutoplay = bundledDevAutoplay()
  if m.devAutoplay = invalid then m.devAutoplay = ""
  m.devAutoplay = LCase(m.devAutoplay.Trim())
  ' Guardrail: only honor dev autoplay when explicitly prefixed.
  ' This avoids accidental auto-play in normal QA builds.
  if Left(m.devAutoplay, 4) = "dev:" then
    m.devAutoplay = Mid(m.devAutoplay, 5).Trim()
  else
    m.devAutoplay = ""
  end if

  appTokenLen = 0
  if cfg0.appToken <> invalid then appTokenLen = Len(cfg0.appToken)
  jellyfinLen = 0
  if cfg0.jellyfinToken <> invalid then jellyfinLen = Len(cfg0.jellyfinToken)
  print "MainScene init apiBase=" + m.apiBase + " appTokenLen=" + appTokenLen.ToStr() + " jellyfinTokenLen=" + jellyfinLen.ToStr() + " devAutoplay=" + m.devAutoplay + " uiLang=" + m.uiLang + " metaLang=" + m.metaLang + " build=2026-02-19a"

  if cfg0.jellyfinToken <> invalid and cfg0.jellyfinToken <> "" then
    m.startupMode = "browse"
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

  m.progressTimer = CreateObject("roSGNode", "Timer")
  if m.progressTimer <> invalid then
    m.progressTimer.duration = m.progressReportEverySec
    m.progressTimer.repeat = true
    m.progressTimer.observeField("fire", "onProgressTimerFire")
    m.top.appendChild(m.progressTimer)
  end if

  ' Simple VOD scrubbing driven by LEFT/RIGHT events from ChampionsVideo.
  m.clock = CreateObject("roTimespan")
  if m.clock <> invalid then m.clock.Mark()

  m.scrubActive = false
  m.scrubDir = 0
  m.scrubTargetSec = 0
  m.scrubStartMs = 0
  m.scrubTimer = CreateObject("roSGNode", "Timer")
  if m.scrubTimer <> invalid then
    m.scrubTimer.duration = 0.15
    m.scrubTimer.repeat = true
    m.scrubTimer.observeField("fire", "onScrubTimerFire")
    m.top.appendChild(m.scrubTimer)
  end if

  ' OSD auto-hide + tick (updates progress UI while visible).
  m.osdHideTimer = CreateObject("roSGNode", "Timer")
  if m.osdHideTimer <> invalid then
    m.osdHideTimer.duration = 3
    m.osdHideTimer.repeat = false
    m.osdHideTimer.observeField("fire", "onOsdHideTimerFire")
    m.top.appendChild(m.osdHideTimer)
  end if

  m.osdTickTimer = CreateObject("roSGNode", "Timer")
  if m.osdTickTimer <> invalid then
    m.osdTickTimer.duration = 0.25
    m.osdTickTimer.repeat = true
    m.osdTickTimer.observeField("fire", "onOsdTickTimerFire")
    m.top.appendChild(m.osdTickTimer)
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
  m.heroPromptText = m.top.findNode("heroPromptText")
  m.heroPromptBtnBg = m.top.findNode("heroPromptBtnBg")
  m.heroPromptBtnText = m.top.findNode("heroPromptBtnText")
  m.heroAvatarBg = m.top.findNode("heroAvatarBg")
  m.heroAvatarPhoto = m.top.findNode("heroAvatarPhoto")
  m.heroAvatarText = m.top.findNode("heroAvatarText")
  if m.viewsList <> invalid and m.viewsList.hasField("numColumns") then
    m.viewsGridCols = _gridCols(m.viewsList.numColumns, m.viewsGridCols)
  end if
  if m.itemsList <> invalid and m.itemsList.hasField("numColumns") then
    m.itemsGridCols = _gridCols(m.itemsList.numColumns, m.itemsGridCols)
  end if
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
  m.homeLiveText = m.top.findNode("homeLiveText")
  m.homeTokensText = m.top.findNode("homeTokensText")
  m.homeLogoutText = m.top.findNode("homeLogoutText")

  if m.player = invalid then m.player = m.top.findNode("player")
  if m.playerOverlay = invalid then m.playerOverlay = m.top.findNode("playerOverlay")
  if m.playerOverlayCircle = invalid then m.playerOverlayCircle = m.top.findNode("playerOverlayCircle")
  if m.playerOverlayIcon = invalid then m.playerOverlayIcon = m.top.findNode("playerOverlayIcon")
  if m.playerOverlayHint = invalid then m.playerOverlayHint = m.top.findNode("playerOverlayHint")
  if m.osdSeekLabel = invalid then m.osdSeekLabel = m.top.findNode("osdSeekLabel")
  if m.osdTimeLabel = invalid then m.osdTimeLabel = m.top.findNode("osdTimeLabel")
  if m.osdBarBg = invalid then m.osdBarBg = m.top.findNode("osdBarBg")
  if m.osdBarFill = invalid then m.osdBarFill = m.top.findNode("osdBarFill")
  if m.osdGearFocus = invalid then m.osdGearFocus = m.top.findNode("osdGearFocus")
  if m.playerSettingsModal = invalid then m.playerSettingsModal = m.top.findNode("playerSettingsModal")
  if m.playerSettingsAudioList = invalid then m.playerSettingsAudioList = m.top.findNode("playerSettingsAudioList")
  if m.playerSettingsSubList = invalid then m.playerSettingsSubList = m.top.findNode("playerSettingsSubList")
  if m.player <> invalid and (m.playerObsSetup <> true) then
    m.player.observeField("state", "onPlayerStateChanged")
    m.player.observeField("errorMsg", "onPlayerError")
    m.player.observeField("duration", "onPlayerDurationChanged")
    if m.player.hasField("keyEvent") then
      m.player.observeField("keyEvent", "onPlayerKeyEvent")
    end if
    if m.player.hasField("availableAudioTracks") then
      m.player.observeField("availableAudioTracks", "onAvailableAudioTracksChanged")
    end if
    if m.player.hasField("availableSubtitleTracks") then
      m.player.observeField("availableSubtitleTracks", "onAvailableSubtitleTracksChanged")
    end if
    if m.player.hasField("audioTrack") then
      m.player.observeField("audioTrack", "onAudioTrackChanged")
    end if
    ' Subtitle track selection differs across firmwares. Observe both when present.
    if m.player.hasField("subtitleTrack") then
      m.player.observeField("subtitleTrack", "onCurrentSubtitleTrackChanged")
    end if
    if m.player.hasField("currentSubtitleTrack") then
      m.player.observeField("currentSubtitleTrack", "onCurrentSubtitleTrackChanged")
    end if
    if m.player.hasField("scrubEvent") then
      m.player.observeField("scrubEvent", "onPlayerScrubEvent")
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

function _isPlaybackVisible() as Boolean
  if m.player <> invalid and m.player.visible = true then return true
  return false
end function

sub onBindTimerFire()
  m.bindAttempts = m.bindAttempts + 1
  bindUiNodes()

  if uiReady() then
    print "UI ready (" + m.startupMode + ")"
    renderForm()
    applyLocalization()

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
  if m.browseCard <> invalid then m.browseCard.translation = [0, 0]
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
    setStatus(_t("please_wait"))
    return
  end if

  cfg = loadConfig()
  if cfg.appToken = invalid or cfg.appToken = "" then
    setStatus(_t("missing_app_token"))
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

function _getCurrentSubtitleTrackId() as String
  if m.player = invalid then return ""

  subId = ""
  if m.player.hasField("subtitleTrack") then subId = m.player.subtitleTrack
  if subId = invalid then subId = ""
  subId = subId.ToStr().Trim()

  curId = ""
  if m.player.hasField("currentSubtitleTrack") then curId = m.player.currentSubtitleTrack
  if curId = invalid then curId = ""
  curId = curId.ToStr().Trim()

  ' currentSubtitleTrack is the effective renderer state. Keep subtitleTrack as
  ' fallback only when current isn't available.
  if curId <> "" then return curId

  if subId <> "" then return subId

  ' Some devices expose textTrack but keep it "off" even when subtitleTrack is
  ' active. Only consult it as a last resort.
  txt = ""
  if m.player.hasField("textTrack") then txt = m.player.textTrack
  if txt = invalid then txt = ""
  return txt.ToStr().Trim()
end function

function _isCaptionModeOff() as Boolean
  if m.player = invalid then return false
  if m.player.hasField("captionMode") <> true then return false
  cm = m.player.captionMode
  if cm = invalid then return false
  s = LCase(cm.ToStr().Trim())
  if s = "" then return false
  return (s = "off" or s = "none" or s = "disabled")
end function

function _areSubtitlesEffectivelyOff(isVod as Boolean) as Boolean
  if _isCaptionModeOff() then return true

  cur = _getCurrentSubtitleTrackId()
  if cur = invalid then cur = ""
  cur = LCase(cur.ToStr().Trim())
  if cur = "" or cur = "off" then return true

  if isVod then
    _ensureDefaultVodPrefs()
    if m.vodPrefs.subtitlesEnabled <> true then return true
    if _normTrackToken(m.vodPrefs.subtitleKey) = "off" then return true
  end if
  return false
end function

function _nowMs() as Integer
  if m.clock <> invalid then return Int(m.clock.TotalMilliseconds())
  dt = CreateObject("roDateTime")
  if dt = invalid then return 0
  return Int(dt.AsSeconds() * 1000)
end function

function _shouldTrackProgress() as Boolean
  if m.playbackIsLive = true then return false
  id = m.playbackItemId
  if id = invalid then id = ""
  id = id.ToStr().Trim()
  return (id <> "")
end function

function _currentProgressSnapshot() as Object
  if m.player = invalid then return { ok: false }
  if m.player.visible <> true then return { ok: false }
  if _shouldTrackProgress() <> true then return { ok: false }

  itemId = m.playbackItemId
  if itemId = invalid then itemId = ""
  itemId = itemId.ToStr().Trim()
  if itemId = "" then return { ok: false }

  curPos = m.player.position
  curDur = m.player.duration
  posSec = 0
  durSec = 0
  if curPos <> invalid then posSec = Int(curPos)
  if curDur <> invalid then durSec = Int(curDur)
  if posSec < 0 then posSec = 0
  if durSec < 0 then durSec = 0

  posMs = posSec * 1000
  durMs = 0
  if durSec > 0 then durMs = durSec * 1000

  pct = -1
  if durSec > 0 then
    pctF = (posSec * 100.0) / durSec
    if pctF < 0 then pctF = 0
    if pctF > 100 then pctF = 100
    pct = Int(pctF)
  end if

  played = false
  if pct >= 98 then played = true

  return {
    ok: true
    itemId: itemId
    positionMs: posMs
    durationMs: durMs
    percent: pct
    played: played
  }
end function

sub _queueProgressReport(reason as String, forcePlayed as Boolean)
  if _shouldTrackProgress() <> true then return
  m.progressPendingFlush = true
  if forcePlayed = true then m.progressPendingPlayed = true
  r = reason
  if r = invalid then r = ""
  r = r.ToStr().Trim()
  if r <> "" then m.progressPendingReason = r
end sub

function _sendProgressReport(reason as String, forcePlayed as Boolean, forceSend as Boolean) as Boolean
  if _shouldTrackProgress() <> true then return false
  if m.gatewayTask = invalid then return false

  taskState = m.gatewayTask.state
  if taskState = invalid then taskState = ""
  taskState = LCase(taskState.ToStr().Trim())
  if taskState = "run" then
    _queueProgressReport(reason, forcePlayed)
    return false
  end if

  if m.pendingJob <> "" then
    _queueProgressReport(reason, forcePlayed)
    return false
  end if

  snap = _currentProgressSnapshot()
  if type(snap) <> "roAssociativeArray" or snap.ok <> true then return false

  itemId = ""
  if snap.itemId <> invalid then itemId = snap.itemId.ToStr().Trim()
  if itemId = "" then return false

  posMs = 0
  if snap.positionMs <> invalid then posMs = Int(snap.positionMs)
  if posMs < 0 then posMs = 0
  durMs = 0
  if snap.durationMs <> invalid then durMs = Int(snap.durationMs)
  if durMs < 0 then durMs = 0
  pct = -1
  if snap.percent <> invalid then pct = Int(snap.percent)
  if pct < -1 then pct = -1
  if pct > 100 then pct = 100
  played = (snap.played = true)
  if forcePlayed = true or m.progressPendingPlayed = true then played = true

  ' Keep resume progress stable: avoid writing tiny startup positions.
  if played <> true and posMs < 15000 then
    return false
  end if

  if forceSend <> true then
    deltaMs = posMs - m.progressLastSentPosMs
    if deltaMs < 0 then deltaMs = -deltaMs
    ageMs = _nowMs() - Int(m.progressLastSentAtMs)
    if m.progressLastSentPosMs >= 0 and deltaMs < 10000 and ageMs >= 0 and ageMs < 30000 and played <> true and m.progressPendingFlush <> true then
      return false
    end if
  end if

  payload = {
    item_id: itemId
    position_ms: posMs
  }
  if durMs > 0 then payload.duration_ms = durMs
  if pct >= 0 then payload.percent = pct
  if played = true then payload.played = true

  cfg = loadConfig()
  if cfg.apiBase = "" or cfg.appToken = "" then
    return false
  end if

  payloadJson = FormatJson(payload)
  if payloadJson = invalid or payloadJson.Trim() = "" then return false

  m.pendingProgressPosMs = posMs
  m.pendingProgressDurMs = durMs
  m.pendingProgressPercent = pct
  m.pendingProgressPlayed = played
  r = reason
  if r = invalid then r = ""
  r = r.ToStr().Trim()
  m.pendingProgressReason = r

  m.pendingJob = "progress_write"
  m.gatewayTask.kind = "progress_write"
  m.gatewayTask.apiBase = cfg.apiBase
  m.gatewayTask.appToken = cfg.appToken
  m.gatewayTask.jellyfinToken = cfg.jellyfinToken
  m.gatewayTask.userId = cfg.userId
  m.gatewayTask.progressBody = payloadJson
  m.gatewayTask.control = "run"

  pctStr = ""
  if pct >= 0 then pctStr = pct.ToStr()
  print "progress write start itemId=" + itemId + " posMs=" + posMs.ToStr() + " durMs=" + durMs.ToStr() + " pct=" + pctStr + " played=" + played.ToStr() + " reason=" + r

  m.progressPendingFlush = false
  m.progressPendingPlayed = false
  m.progressPendingReason = ""
  return true
end function

function _fmtTime(sec as Integer) as String
  s = sec
  if s < 0 then s = 0
  h = Int(s / 3600)
  remainSec = s - (h * 3600)
  mins = Int(remainSec / 60)
  ss = remainSec - (mins * 60)
  mm = Right("0" + mins.ToStr(), 2)
  sss = Right("0" + ss.ToStr(), 2)
  if h > 0 then
    return h.ToStr() + ":" + mm + ":" + sss
  end if
  return mins.ToStr() + ":" + sss
end function

sub _applySeek(reason as String)
  if m.scrubActive <> true then return
  print "seek apply reason=" + reason
  m.scrubActive = false
  m.scrubDir = 0
  if m.scrubTimer <> invalid then m.scrubTimer.control = "stop"

  if m.player <> invalid and m.player.visible = true then
    if m.player.hasField("seek") then m.player.seek = m.scrubTargetSec
    if m.player.hasField("control") then m.player.control = "play"
  end if
  setStatus("playing")
end sub

sub _cancelSeek(reason as String)
  if m.scrubActive <> true then return
  print "seek cancel reason=" + reason
  m.scrubActive = false
  m.scrubDir = 0
  if m.scrubTimer <> invalid then m.scrubTimer.control = "stop"
  setStatus("playing")
end sub

sub _scrubStep(nowMs as Integer)
  if m.scrubActive <> true then return
  if m.player = invalid or m.player.visible <> true then return
  if m.playbackIsLive = true then return

  durVal = m.player.duration
  d = 0
  if durVal <> invalid then d = Int(durVal)
  if d <= 0 then return

  holdMs = nowMs - m.scrubStartMs
  if holdMs < 0 then holdMs = 0

  skipStep = 2
  if holdMs >= 2000 then skipStep = 5
  if holdMs >= 5000 then skipStep = 10
  if holdMs >= 10000 then skipStep = 20

  target = m.scrubTargetSec + (m.scrubDir * skipStep)
  if target < 0 then target = 0
  if target > (d - 1) then target = d - 1
  m.scrubTargetSec = target
  ' Avoid repeated seeks while holding: many Roku devices will go black/buffer
  ' and/or ignore rapid seek updates on HLS VOD. We only apply seek on OK.

  dirSym = ">>"
  if m.scrubDir < 0 then dirSym = "<<"
  setStatus(dirSym + " " + _fmtTime(target) + " / " + _fmtTime(d))
end sub

sub onScrubTimerFire()
  if m.scrubActive <> true then
    if m.scrubTimer <> invalid then m.scrubTimer.control = "stop"
    return
  end if
  if m.player = invalid or m.player.visible <> true then
    _cancelSeek("player_inactive")
    return
  end if
  if m.playbackIsLive = true then
    _cancelSeek("live")
    return
  end if

  nowMs = _nowMs()
  _scrubStep(nowMs)
end sub

sub onOsdHideTimerFire()
  if m.uiState <> "OSD" then return
  hidePlayerOverlay()
end sub

sub onOsdTickTimerFire()
  if m.uiState <> "OSD" then return
  _updateOsdUi()
end sub

sub onPlayerScrubEvent()
  if m.player = invalid then return
  if m.player.visible <> true then return
  if m.playbackIsLive = true then return
  if m.settingsOpen = true then return

  raw = m.player.scrubEvent
  if raw = invalid then return
  s = raw.ToStr()
  if s = invalid then return
  s = s.Trim()
  if s = "" then return

  parts = s.Split(":")
  if type(parts) <> "roArray" or parts.Count() < 2 then return
  k = LCase(parts[0].Trim())
  a = LCase(parts[1].Trim())

  if k = "ok" and a = "press" then
    if m.scrubActive = true then _applySeek("ok")
    return
  end if

  if k = "back" and a = "press" then
    if m.scrubActive = true then _cancelSeek("back")
    return
  end if

  if k = "playpause" and a = "press" then
    if m.scrubActive = true then _cancelSeek("playpause")
    st = ""
    if m.player <> invalid and m.player.state <> invalid then st = m.player.state
    if st = invalid then st = ""
    st = LCase(st.ToStr().Trim())
    if st = "playing" then
      if m.player.hasField("control") then m.player.control = "pause"
      setStatus("paused")
    else
      if m.player.hasField("control") then m.player.control = "play"
      setStatus("playing")
    end if
    return
  end if

  if k <> "left" and k <> "right" then return
  if a <> "down" and a <> "up" then return

  durVal = m.player.duration
  d = 0
  if durVal <> invalid then d = Int(durVal)
  if d <= 0 then return

  nowMs = _nowMs()

  if a = "down" then
    if m.scrubActive <> true then
      m.scrubActive = true

      curPos = m.player.position
      p = 0
      if curPos <> invalid then p = Int(curPos)
      m.scrubTargetSec = p
    end if

    ' (Re)start hold timer for this keypress.
    m.scrubStartMs = nowMs
    if m.scrubTimer <> invalid then m.scrubTimer.control = "start"

    if k = "right" then m.scrubDir = 1 else m.scrubDir = -1

    ' First tick immediately for responsiveness.
    _scrubStep(nowMs)
    return
  end if

  if a = "up" then
    ' Stop the hold-timer but keep seek-mode active until OK/BACK.
    m.scrubDir = 0
    if m.scrubTimer <> invalid then m.scrubTimer.control = "stop"
    setStatus("seek " + _fmtTime(m.scrubTargetSec) + " / " + _fmtTime(d) + " (OK)")
    return
  end if
end sub

sub onPlayerKeyEvent()
  if m.player = invalid then return
  if m.player.visible <> true then return
  ' NOTE: do NOT guard on settingsOpen here. If the Video node has focus
  ' (firmware focus-steal during HLS buffering) while settings is open,
  ' we must still route to handlePlaybackKey so BACK/LEFT/RIGHT work.
  ' handlePlaybackKey already handles the SETTINGS state correctly.

  raw = m.player.keyEvent
  if raw = invalid then return
  s = raw.ToStr()
  if s = invalid then return
  s = s.Trim()
  if s = "" then return

  parts = s.Split(":")
  if type(parts) <> "roArray" or parts.Count() < 2 then return
  k = LCase(parts[0].Trim())
  a = LCase(parts[1].Trim())
  if a <> "press" then return

  ignore = handlePlaybackKey(k)
end sub

sub onPlayerOverlayRequested()
  if m.player = invalid then return
  if m.player.visible <> true then return
  if m.scrubActive = true then _cancelSeek("overlay_ok")
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
  if m.scrubActive = true then _cancelSeek("overlay_settings")
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
  if v = "ita" or v = "it" then return "it"
  return v
end function

function displayLang(tag as Dynamic) as String
  n = normalizeLang(tag)
  if n = "pt" then return "POR"
  if n = "en" then return "ENG"
  if n = "es" then return "ESP"
  if n = "it" then return "ITA"
  v = ""
  if tag <> invalid then v = tag.ToStr()
  v = UCase(v.Trim())
  if v = "" then v = "UND"
  return v
end function

function resolveUiLang() as String
  di = CreateObject("roDeviceInfo")
  loc = ""
  if di <> invalid then
    l0 = di.GetCurrentLocale()
    if l0 <> invalid then loc = l0.ToStr()
  end if

  l = normalizeLang(loc)
  if l = "pt" or l = "es" or l = "it" or l = "en" then return l
  return "en"
end function

function resolveMetadataLang(uiLang as String) as String
  l = normalizeLang(uiLang)
  if l = "es" then return "es-ES"
  if l = "it" then return "it-IT"
  ' Gateway metadata currently supports en-US/es-ES/it-IT. Portuguese falls back to English.
  return "en-US"
end function

function _t(key as String) as String
  raw = key
  if raw = invalid then raw = ""
  raw = raw.ToStr().Trim()
  if raw = "" then return ""
  k = LCase(raw)

  lang = m.uiLang
  if lang = invalid then lang = ""
  lang = normalizeLang(lang)
  if lang = "" then lang = "en"

  if m.trMapCache = invalid then
    m.trMapCache = {
      en: {
        home_live: "Live TV"
        home_tokens: "Tokens"
        home_logout: "Logout"
        profile: "Profile"
        profile_name: "Name"
        profile_photo_url: "Photo URL"
        libraries: "Libraries"
        library_movies: "Movies"
        library_live: "Live TV"
        library_series: "Series"
        recent: "Recent"
        recent_prefix: "Recent: "
        continue: "Continue Watching"
        top10: "Highlights"
        recent_movies: "Recent Movies"
        recent_series: "Recent Series"
        recent_live: "Live Now"
        loading: "Loading..."
        no_items: "No items"
        no_libraries: "No libraries"
        press_ok_live: "Press OK to open Live TV"
        loading_libraries: "loading libraries..."
        loading_items: "loading items..."
        loading_channels: "loading channels..."
        please_wait: "please wait..."
        cancelled: "cancelled"
        views_failed: "Failed to load libraries"
        items_failed: "Failed to load items"
        channels_failed: "Failed to load channels"
        session_expired: "Session expired. Please login again."
        missing_config: "Missing config (APP_TOKEN/login)"
        missing_app_token: "Missing APP_TOKEN (press *)"
        hint_app_token: "Press * to configure APP_TOKEN"
        vod_checking: "vod: checking availability..."
        vod_processing: "vod: processing"
        vod_processing_msg: "Processing: this content is not in R2 yet."
        vod_unavailable: "vod: unavailable"
        vod_unavailable_msg: "Content unavailable."
        series_not_impl: "Series is not implemented on Roku yet."
        vod_try_again: "vod r2 slow; try again"
        off: "Off"
        reload_subs: "Reload subtitles (Jellyfin)"
        no_channels: "No channels"
        hero_continue_text: "Want to continue?"
        hero_continue_cta: "Continue"
        resume_title: "Continue watching"
        resume_from_prefix: "Continue from "
        resume_cancel: "Cancel"
        resume_restart: "Play from start"
        resume_continue: "Continue"
      }
      pt: {
        home_live: "Live TV"
        home_tokens: "Tokens"
        home_logout: "Sair"
        profile: "Perfil"
        profile_name: "Nome"
        profile_photo_url: "Foto URL"
        libraries: "Bibliotecas"
        library_movies: "Filmes"
        library_live: "Live TV"
        library_series: "Series"
        recent: "Recentes"
        recent_prefix: "Recentes: "
        continue: "Continuar Assistindo"
        top10: "Destaques"
        recent_movies: "Filmes recentes"
        recent_series: "Series recentes"
        recent_live: "Ao vivo agora"
        loading: "Carregando..."
        no_items: "Sem itens"
        no_libraries: "Sem bibliotecas"
        press_ok_live: "Pressione OK para abrir Live TV"
        loading_libraries: "carregando bibliotecas..."
        loading_items: "carregando itens..."
        loading_channels: "carregando canais..."
        please_wait: "aguarde..."
        cancelled: "cancelado"
        views_failed: "Falhou ao carregar bibliotecas"
        items_failed: "Falhou ao carregar itens"
        channels_failed: "Falhou ao carregar canais"
        session_expired: "Sessao expirada. Faca login novamente."
        missing_config: "Faltou config (APP_TOKEN/login)"
        missing_app_token: "faltou APP_TOKEN (pressione *)"
        hint_app_token: "Pressione * para configurar APP_TOKEN"
        vod_checking: "vod: verificando disponibilidade..."
        vod_processing: "vod: processando"
        vod_processing_msg: "Processando: este conteudo ainda nao esta no R2."
        vod_unavailable: "vod: indisponivel"
        vod_unavailable_msg: "Conteudo indisponivel."
        series_not_impl: "Series ainda nao esta implementado no Roku."
        vod_try_again: "vod r2 demorou; tente novamente"
        off: "Desligado"
        reload_subs: "Atualizar legendas (Jellyfin)"
        no_channels: "Sem canais"
        hero_continue_text: "Quer continuar?"
        hero_continue_cta: "Continuar"
        resume_title: "Continuar assistindo"
        resume_from_prefix: "Continuar de "
        resume_cancel: "Cancelar"
        resume_restart: "Assistir do inicio"
        resume_continue: "Continuar"
      }
      es: {
        home_live: "En vivo"
        home_tokens: "Tokens"
        home_logout: "Salir"
        profile: "Perfil"
        profile_name: "Nombre"
        profile_photo_url: "Foto URL"
        libraries: "Bibliotecas"
        library_movies: "Peliculas"
        library_live: "En vivo"
        library_series: "Series"
        recent: "Recientes"
        recent_prefix: "Recientes: "
        continue: "Seguir viendo"
        top10: "Destacados"
        recent_movies: "Peliculas recientes"
        recent_series: "Series recientes"
        recent_live: "En vivo ahora"
        loading: "Cargando..."
        no_items: "Sin elementos"
        no_libraries: "Sin bibliotecas"
        press_ok_live: "Pulsa OK para abrir En vivo"
        loading_libraries: "cargando bibliotecas..."
        loading_items: "cargando elementos..."
        loading_channels: "cargando canales..."
        please_wait: "espera..."
        cancelled: "cancelado"
        views_failed: "Fallo al cargar bibliotecas"
        items_failed: "Fallo al cargar elementos"
        channels_failed: "Fallo al cargar canales"
        session_expired: "Sesion expirada. Inicia sesion otra vez."
        missing_config: "Falta config (APP_TOKEN/login)"
        missing_app_token: "falta APP_TOKEN (pulsa *)"
        hint_app_token: "Pulsa * para configurar APP_TOKEN"
        vod_checking: "vod: comprobando disponibilidad..."
        vod_processing: "vod: procesando"
        vod_processing_msg: "Procesando: este contenido aun no esta en R2."
        vod_unavailable: "vod: no disponible"
        vod_unavailable_msg: "Contenido no disponible."
        series_not_impl: "Series aun no esta implementado en Roku."
        vod_try_again: "vod r2 tardo; intentalo de nuevo"
        off: "Desactivado"
        reload_subs: "Actualizar subtitulos (Jellyfin)"
        no_channels: "Sin canales"
        hero_continue_text: "Quieres continuar?"
        hero_continue_cta: "Continuar"
        resume_title: "Seguir viendo"
        resume_from_prefix: "Continuar desde "
        resume_cancel: "Cancelar"
        resume_restart: "Ver desde el inicio"
        resume_continue: "Continuar"
      }
      it: {
        home_live: "Diretta"
        home_tokens: "Token"
        home_logout: "Esci"
        profile: "Profilo"
        profile_name: "Nome"
        profile_photo_url: "URL foto"
        libraries: "Librerie"
        library_movies: "Film"
        library_live: "Diretta"
        library_series: "Serie"
        recent: "Recenti"
        recent_prefix: "Recenti: "
        continue: "Continua a guardare"
        top10: "In evidenza"
        recent_movies: "Film recenti"
        recent_series: "Serie recenti"
        recent_live: "In diretta ora"
        loading: "Caricamento..."
        no_items: "Nessun elemento"
        no_libraries: "Nessuna libreria"
        press_ok_live: "Premi OK per aprire la Diretta"
        loading_libraries: "caricamento librerie..."
        loading_items: "caricamento elementi..."
        loading_channels: "caricamento canali..."
        please_wait: "attendere..."
        cancelled: "annullato"
        views_failed: "Caricamento librerie fallito"
        items_failed: "Caricamento elementi fallito"
        channels_failed: "Caricamento canali fallito"
        session_expired: "Sessione scaduta. Esegui di nuovo il login."
        missing_config: "Config mancante (APP_TOKEN/login)"
        missing_app_token: "manca APP_TOKEN (premi *)"
        hint_app_token: "Premi * per configurare APP_TOKEN"
        vod_checking: "vod: verifica disponibilita..."
        vod_processing: "vod: in elaborazione"
        vod_processing_msg: "In elaborazione: questo contenuto non e ancora su R2."
        vod_unavailable: "vod: non disponibile"
        vod_unavailable_msg: "Contenuto non disponibile."
        series_not_impl: "Serie non ancora implementate su Roku."
        vod_try_again: "vod r2 lento; riprova"
        off: "Disattivato"
        reload_subs: "Aggiorna sottotitoli (Jellyfin)"
        no_channels: "Nessun canale"
        hero_continue_text: "Vuoi continuare?"
        hero_continue_cta: "Continua"
        resume_title: "Continua a guardare"
        resume_from_prefix: "Continua da "
        resume_cancel: "Annulla"
        resume_restart: "Guarda dall'inizio"
        resume_continue: "Continua"
      }
    }
  end if

  enMap = m.trMapCache.en
  map = enMap
  if lang = "pt" and m.trMapCache.pt <> invalid then
    map = m.trMapCache.pt
  else if lang = "es" and m.trMapCache.es <> invalid then
    map = m.trMapCache.es
  else if lang = "it" and m.trMapCache.it <> invalid then
    map = m.trMapCache.it
  end if

  if map[k] <> invalid then return map[k]
  if enMap[k] <> invalid then return enMap[k]
  return raw
end function

sub applyLocalization()
  if m.homeLiveText <> invalid then m.homeLiveText.text = _t("home_live")
  if m.homeTokensText <> invalid then m.homeTokensText.text = _t("home_tokens")
  if m.homeLogoutText <> invalid then m.homeLogoutText.text = _t("home_logout")
  if m.viewsTitle <> invalid then m.viewsTitle.text = _t("libraries")
  if m.heroPromptText <> invalid then m.heroPromptText.text = _t("hero_continue_text")
  if m.heroPromptBtnText <> invalid then m.heroPromptBtnText.text = _t("hero_continue_cta")
  _syncHeroAvatarVisual()
  if m.hintLabel <> invalid then m.hintLabel.text = _t("hint_app_token")
end sub

function _browseListFocusedIndex(lst as Object) as Integer
  if lst = invalid then return -1
  idx = lst.itemFocused
  if idx = invalid or Int(idx) < 0 then
    idx = lst.itemSelected
  end if
  if idx = invalid then return -1
  i = Int(idx)
  if i < 0 then return -1
  return i
end function

function _browseListCount(lst as Object) as Integer
  if lst = invalid then return 0
  root = lst.content
  if root = invalid then return 0
  n = root.getChildCount()
  if n = invalid then return 0
  return Int(n)
end function

function _gridCols(n as Integer, fallbackCols as Integer) as Integer
  cols = n
  if cols = invalid then cols = 0
  cols = Int(cols)
  if cols <= 0 then cols = fallbackCols
  if cols <= 0 then cols = 1
  return cols
end function

function _browseViewCols() as Integer
  return _gridCols(m.viewsGridCols, 3)
end function

function _browseItemCols() as Integer
  return _gridCols(m.itemsGridCols, 3)
end function

sub _syncHeroAvatarVisual()
  if m.heroAvatarText = invalid then return
  m.heroAvatarText.text = ">"
  m.heroAvatarText.visible = true
  if m.heroAvatarPhoto <> invalid then
    m.heroAvatarPhoto.visible = false
    m.heroAvatarPhoto.uri = ""
  end if
end sub

sub _triggerHeroContinue()
  if m.mode <> "browse" then return
  nowMs = _nowMs()
  if nowMs - Int(m.lastHeroContinueMs) < 700 then
    print "hero continue debounce"
    return
  end if
  m.lastHeroContinueMs = nowMs
  m.activeViewId = "__continue"
  m.activeViewCollection = "continue"
  if m.itemsTitle <> invalid then m.itemsTitle.text = _t("continue")
  m.heroContinueAutoplayPending = true
  loadShelfForView("__continue")
  m.browseFocus = "hero_continue"
  applyFocus()
end sub

function _browsePosterUri(itemId as String, apiBase as String, jellyfinToken as String) as String
  id = itemId
  if id = invalid then id = ""
  id = id.ToStr().Trim()
  if id = "" then return ""

  base = apiBase
  if base = invalid then base = ""
  base = base.ToStr().Trim()
  if base = "" then return ""
  if Right(base, 1) = "/" then base = Left(base, Len(base) - 1)

  u = base + "/jellyfin/Items/" + id + "/Images/Primary"
  q = {
    maxWidth: "720"
    quality: "90"
  }
  tok = jellyfinToken
  if tok = invalid then tok = ""
  tok = tok.ToStr().Trim()
  if tok <> "" then
    q["X-Emby-Token"] = tok
    q["X-Jellyfin-Token"] = tok
  end if
  return appendQuery(u, q)
end function

function _browseChannelPosterUri(channelId as String, apiBase as String, jellyfinToken as String) as String
  id = channelId
  if id = invalid then id = ""
  id = id.ToStr().Trim()
  if id = "" then return ""

  base = apiBase
  if base = invalid then base = ""
  base = base.ToStr().Trim()
  if base = "" then return ""
  if Right(base, 1) = "/" then base = Left(base, Len(base) - 1)

  u = base + "/jellyfin/LiveTv/Channels/" + id + "/Images/Primary"
  q = {
    maxWidth: "600"
    quality: "90"
  }
  tok = jellyfinToken
  if tok = invalid then tok = ""
  tok = tok.ToStr().Trim()
  if tok <> "" then
    q["X-Emby-Token"] = tok
    q["X-Jellyfin-Token"] = tok
  end if
  return appendQuery(u, q)
end function

function _aaGetCi(a as Object, key as String) as Dynamic
  if type(a) <> "roAssociativeArray" then return invalid
  if key = invalid then return invalid
  k = key.ToStr()
  if k = "" then return invalid

  if a[k] <> invalid then return a[k]
  kl = LCase(k)
  if a[kl] <> invalid then return a[kl]
  ku = UCase(k)
  if a[ku] <> invalid then return a[ku]

  ' Last resort: scan keys case-insensitively.
  for each kk in a
    if LCase(kk) = kl then return a[kk]
  end for
  return invalid
end function

function _trackIdFromTrackObj(tr as Object) as String
  if type(tr) <> "roAssociativeArray" then return ""
  v = _aaGetCi(tr, "Track")
  if v = invalid then v = _aaGetCi(tr, "Id")
  if v = invalid then v = _aaGetCi(tr, "StreamIndex")
  if v = invalid then v = _aaGetCi(tr, "Index")
  if v = invalid then return ""
  return v.ToStr().Trim()
end function

function _trackLangFromTrackObj(tr as Object) as String
  if type(tr) <> "roAssociativeArray" then return ""
  lang = _aaGetCi(tr, "Language")
  if lang = invalid then lang = _aaGetCi(tr, "Lang")
  if lang = invalid then return ""
  return lang.ToStr()
end function

function _trackTitleFromTrackObj(tr as Object, fallbackLang as String, fallbackLabel as String) as String
  if type(tr) <> "roAssociativeArray" then return fallbackLabel
  desc = _aaGetCi(tr, "Description")
  if desc <> invalid and desc.ToStr().Trim() <> "" then return desc.ToStr().Trim()
  name = _aaGetCi(tr, "Name")
  if name <> invalid and name.ToStr().Trim() <> "" then return name.ToStr().Trim()
  if fallbackLang.Trim() <> "" then return displayLang(fallbackLang)
  return fallbackLabel
end function

function _trackIdMatches(a as String, b as String) as Boolean
  aa = a
  bb = b
  if aa = invalid then aa = ""
  if bb = invalid then bb = ""
  aa = aa.ToStr().Trim()
  bb = bb.ToStr().Trim()
  q = Instr(1, aa, "?")
  if q > 0 then aa = Left(aa, q - 1)
  q2 = Instr(1, bb, "?")
  if q2 > 0 then bb = Left(bb, q2 - 1)
  aa = aa.Trim()
  bb = bb.Trim()
  if aa = "" or bb = "" then return false
  if aa = bb then return true
  if Right(aa, Len(bb) + 1) = ("/" + bb) then return true
  if Right(bb, Len(aa) + 1) = ("/" + aa) then return true

  ' Some firmwares expose runtime subtitle IDs like "webvtt/3" while track
  ' lists can expose "3" (or vice-versa). Match by trailing numeric token.
  na = _trackNumericSuffix(aa)
  nb = _trackNumericSuffix(bb)
  if na <> "" and nb <> "" and na = nb then return true
  return false
end function

function _isSimpleIntegerToken(v as String) as Boolean
  s = v
  if s = invalid then s = ""
  s = s.ToStr().Trim()
  if s = "" then return false
  hasDigit = false
  for i = 1 to Len(s)
    ch = Mid(s, i, 1)
    if ch >= "0" and ch <= "9" then
      hasDigit = true
    else if i = 1 and (ch = "-" or ch = "+") then
      ' allow sign
    else
      return false
    end if
  end for
  return hasDigit
end function

function _trackNumericSuffix(v as String) as String
  s = v
  if s = invalid then s = ""
  s = s.ToStr().Trim()
  if s = "" then return ""

  q = Instr(1, s, "?")
  if q > 0 then s = Left(s, q - 1)
  s = s.Trim()
  if s = "" then return ""

  if _isSimpleIntegerToken(s) then return s

  i = Len(s)
  while i >= 1
    ch = Mid(s, i, 1)
    if ch >= "0" and ch <= "9" then
      i = i - 1
    else
      exit while
    end if
  end while

  if i = Len(s) then return "" ' no trailing digits

  digits = Mid(s, i + 1)
  if digits = invalid then return ""
  digits = digits.Trim()
  if digits = "" then return ""

  if i <= 0 then return digits

  sep = Mid(s, i, 1)
  if sep = "/" then return digits
  return ""
end function

function _looksLikeRokuSubtitleToken(v as String) as Boolean
  s = v
  if s = invalid then s = ""
  s = LCase(s.ToStr().Trim())
  if s = "" then return false
  if s = "off" or s = "auto" then return true
  if _looksLikeSubtitleUrl(s) then return true
  if Instr(1, s, "webvtt/") = 1 then return true
  if Instr(1, s, "eia608/") = 1 then return true
  if Instr(1, s, "eia708/") = 1 then return true
  if Instr(1, s, "cc") = 1 then return true
  if Instr(1, s, "/") > 0 then return true
  if _isSimpleIntegerToken(s) then return false
  return true
end function

function _subtitleDebugIdFields(tr as Object) as String
  if type(tr) <> "roAssociativeArray" then return ""
  keys = [
    "TrackName"
    "Track"
    "Id"
    "StreamIndex"
    "Index"
    "Name"
  ]
  out = ""
  for each key in keys
    v = _aaGetCi(tr, key)
    if v <> invalid then
      s = v.ToStr().Trim()
      if s <> "" then
        if out <> "" then out = out + " "
        out = out + key + "=" + s
      end if
    end if
  end for
  return out
end function

function _trackRawTitleFromTrackObj(tr as Object) as String
  if type(tr) <> "roAssociativeArray" then return ""
  desc = _aaGetCi(tr, "Description")
  if desc <> invalid and desc.ToStr().Trim() <> "" then return desc.ToStr().Trim()
  name = _aaGetCi(tr, "Name")
  if name <> invalid and name.ToStr().Trim() <> "" then return name.ToStr().Trim()
  disp = _aaGetCi(tr, "DisplayName")
  if disp <> invalid and disp.ToStr().Trim() <> "" then return disp.ToStr().Trim()
  title = _aaGetCi(tr, "Title")
  if title <> invalid and title.ToStr().Trim() <> "" then return title.ToStr().Trim()
  return ""
end function

function _trackCodecFromTrackObj(tr as Object) as String
  if type(tr) <> "roAssociativeArray" then return ""
  v = _aaGetCi(tr, "Codec")
  if v = invalid then v = _aaGetCi(tr, "Codecs")
  if v = invalid then v = _aaGetCi(tr, "MimeType")
  if v = invalid then return ""
  return LCase(v.ToStr().Trim())
end function

function _normTrackToken(v) as String
  if v = invalid then return ""
  return LCase(v.ToStr().Trim())
end function

function _audioTrackPrefKeyFromObj(tr as Object) as String
  if type(tr) <> "roAssociativeArray" then return ""
  id = _normTrackToken(_trackIdFromTrackObj(tr))
  if id = "auto" or id = "no" then return id

  title = _normTrackToken(_trackRawTitleFromTrackObj(tr))
  lang = _normTrackToken(_trackLangFromTrackObj(tr))
  codec = _normTrackToken(_trackCodecFromTrackObj(tr))
  if title <> "" or lang <> "" then return title + "|" + lang + "|" + codec
  return id
end function

function _subtitleTrackPrefKeyFromObj(tr as Object, fallbackIndex as Integer) as String
  if type(tr) <> "roAssociativeArray" then return ""

  id = _normTrackToken(_trackIdFromTrackObj(tr))
  if id = "" then id = fallbackIndex.ToStr()
  if id = "off" or id = "no" then return "off"
  if id = "auto" then return "auto"

  title = _normTrackToken(_trackRawTitleFromTrackObj(tr))
  lang = _normTrackToken(_trackLangFromTrackObj(tr))
  codec = _normTrackToken(_trackCodecFromTrackObj(tr))
  if title = "auto" or lang = "auto" then return "auto"

  forcedTag = "0"
  if _isForcedSubtitleTrack(tr) then forcedTag = "1"
  sdhTag = "0"
  if _isSdhSubtitleTrack(tr) then sdhTag = "1"

  if title <> "" or lang <> "" then
    return title + "|" + lang + "|" + codec + "|f" + forcedTag + "|s" + sdhTag
  end if
  return id
end function

function _subtitleSetIdFromTrackObj(tr as Object, fallbackIndex as Integer) as String
  if type(tr) <> "roAssociativeArray" then return fallbackIndex.ToStr()

  candidates = [
    "TrackName"
    "trackName"
    "TrackId"
    "trackId"
    "CurrentTrack"
    "currentTrack"
    "Track"
    "Id"
    "StreamIndex"
    "Index"
  ]

  first = ""
  for each key in candidates
    v = _aaGetCi(tr, key)
    if v <> invalid then
      s = v.ToStr().Trim()
      if s <> "" then
        if first = "" then first = s
        if _looksLikeRokuSubtitleToken(s) then return s
      end if
    end if
  end for

  if first <> "" then return first
  return fallbackIndex.ToStr()
end function

function _pickAudioTrackByKey(tracks as Object, prefKey as String) as Object
  if type(tracks) <> "roArray" then return invalid
  want = _normTrackToken(prefKey)
  if want = "" then return invalid
  for each t in tracks
    if type(t) = "roAssociativeArray" then
      if _audioTrackPrefKeyFromObj(t) = want then return t
    end if
  end for
  return invalid
end function

function _pickSubtitleTrackByKey(tracks as Object, prefKey as String) as Object
  if type(tracks) <> "roArray" then return invalid
  want = _normTrackToken(prefKey)
  if want = "" then return invalid
  idx = 0
  for each t in tracks
    if type(t) = "roAssociativeArray" then
      if _subtitleTrackPrefKeyFromObj(t, idx) = want then return t
    end if
    idx = idx + 1
  end for
  return invalid
end function

sub _mergeSubtitleTrackCache(tracks as Object)
  if type(tracks) <> "roArray" then return
  if type(m.availableSubtitleTracksCache) <> "roArray" then m.availableSubtitleTracksCache = []

  merged = []
  seen = {}

  i = 0
  for each tr in m.availableSubtitleTracksCache
    if type(tr) = "roAssociativeArray" then
      tid = _subtitleSetIdFromTrackObj(tr, i)
      k = "id|" + tid
      if seen[k] <> true then
        seen[k] = true
        merged.Push(tr)
      end if
    end if
    i = i + 1
  end for

  j = 0
  for each tr in tracks
    if type(tr) = "roAssociativeArray" then
      tid = _subtitleSetIdFromTrackObj(tr, j)
      k = "id|" + tid
      if seen[k] <> true then
        seen[k] = true
        merged.Push(tr)
      end if
    end if
    j = j + 1
  end for

  m.availableSubtitleTracksCache = merged
end sub

function _currentSubtitleTracks() as Object
  tracks = []
  if m.player <> invalid and m.player.hasField("availableSubtitleTracks") then
    t = m.player.availableSubtitleTracks
    if type(t) = "roArray" and t.Count() > 0 then tracks = t
  end if
  if type(tracks) <> "roArray" or tracks.Count() = 0 then
    if type(m.availableSubtitleTracksCache) = "roArray" then tracks = m.availableSubtitleTracksCache
  end if
  return tracks
end function

function _sceneIntFromAny(v) as Integer
  if v = invalid then return -1
  if type(v) = "roInt" or type(v) = "roInteger" then return Int(v)
  if type(v) = "roFloat" or type(v) = "Float" then return Int(v)
  s = v.ToStr()
  if s = invalid then return -1
  s = s.Trim()
  if s = "" then return -1
  hasDigit = false
  for i = 1 to Len(s)
    ch = Mid(s, i, 1)
    if ch >= "0" and ch <= "9" then
      hasDigit = true
    else if i = 1 and (ch = "-" or ch = "+") then
      ' allow sign
    else
      return -1
    end if
  end for
  if hasDigit <> true then return -1
  return Int(Val(s))
end function

function _sceneBoolFromAny(v) as Boolean
  if v = invalid then return false
  if type(v) = "roBoolean" then return (v = true)
  s = LCase(v.ToStr().Trim())
  return (s = "1" or s = "true" or s = "yes" or s = "on")
end function

function _vodKeyFromR2Path(v as String) as String
  p = v
  if p = invalid then p = ""
  p = p.ToStr().Trim()
  if p = "" then return ""

  parts = p.Split("/")
  if type(parts) <> "roArray" then return ""
  total = parts.Count()
  if total < 3 then return ""

  for i = 0 to total - 3
    a = parts[i]
    b = parts[i + 1]
    c = parts[i + 2]
    if a = invalid then a = ""
    if b = invalid then b = ""
    if c = invalid then c = ""
    if LCase(a.ToStr().Trim()) = "r2" and LCase(b.ToStr().Trim()) = "vod" then
      key = c.ToStr().Trim()
      if key <> "" then return key
    end if
  end for
  return ""
end function

function _externalSubtitleUrlForStreamIndex(streamIndex as Integer) as String
  if streamIndex < 0 then return ""
  key = _vodKeyFromR2Path(m.playbackSignPath)
  if key = "" then return ""
  cfg = loadConfig()
  base = _vodR2PlaybackBase(cfg.apiBase)
  if base = invalid then base = ""
  base = base.Trim()
  if base = "" then return ""
  return base + "/vod/subtitles/" + key + "/" + streamIndex.ToStr() + ".vtt"
end function

function _subtitleSourcePrefKey(src as Object, fallbackIndex as Integer) as String
  if type(src) <> "roAssociativeArray" then return ""
  idx = _sceneIntFromAny(src.streamIndex)
  if idx < 0 and src.StreamIndex <> invalid then idx = _sceneIntFromAny(src.StreamIndex)
  if idx < 0 and src.index <> invalid then idx = _sceneIntFromAny(src.index)
  if idx < 0 and src.Index <> invalid then idx = _sceneIntFromAny(src.Index)
  if idx >= 0 then return "ext|idx|" + idx.ToStr()

  title = ""
  if src.title <> invalid then title = src.title else if src.Title <> invalid then title = src.Title
  lang = ""
  if src.language <> invalid then lang = src.language else if src.Language <> invalid then lang = src.Language
  codec = ""
  if src.codec <> invalid then codec = src.codec else if src.Codec <> invalid then codec = src.Codec

  forcedStr = "0"
  if _sceneBoolFromAny(src.forced) or _sceneBoolFromAny(src.IsForced) then forcedStr = "1"
  sdhStr = "0"
  if _sceneBoolFromAny(src.hearingImpaired) or _sceneBoolFromAny(src.IsHearingImpaired) then sdhStr = "1"

  t = _normTrackToken(title)
  l = _normTrackToken(lang)
  c = _normTrackToken(codec)
  if t <> "" or l <> "" then return "ext|" + t + "|" + l + "|" + c + "|f" + forcedStr + "|s" + sdhStr
  return "ext|fallback|" + fallbackIndex.ToStr()
end function

function _subtitleSourceLooksForced(src as Object) as Boolean
  if type(src) <> "roAssociativeArray" then return false
  if _sceneBoolFromAny(src.forced) or _sceneBoolFromAny(src.IsForced) then return true
  title = ""
  if src.title <> invalid then title = src.title else if src.Title <> invalid then title = src.Title
  low = LCase(title.ToStr())
  if Instr(1, low, "forced") > 0 then return true
  if Instr(1, low, "forcada") > 0 then return true
  if Instr(1, low, "forçada") > 0 then return true
  return false
end function

function _subtitleSourceLooksSdh(src as Object) as Boolean
  if type(src) <> "roAssociativeArray" then return false
  if _sceneBoolFromAny(src.hearingImpaired) or _sceneBoolFromAny(src.IsHearingImpaired) then return true
  title = ""
  if src.title <> invalid then title = src.title else if src.Title <> invalid then title = src.Title
  low = LCase(title.ToStr())
  if Instr(1, low, "sdh") > 0 then return true
  if Instr(1, low, "hearing impaired") > 0 then return true
  if Instr(1, low, "hearing-impaired") > 0 then return true
  return false
end function

sub _requestPlaybackSubtitleSources()
  if m.gatewayTask = invalid then return
  if m.playbackIsLive = true then return
  if m.playbackKind <> "vod-r2" and m.playbackKind <> "vod-jellyfin" then return
  if m.pendingJob <> "" then return

  itemId = m.playbackItemId
  if itemId = invalid then itemId = ""
  itemId = itemId.ToStr().Trim()
  if itemId = "" then return
  if m.subtitleSourcesRequestedItemId = itemId then return

  cfg = loadConfig()
  if cfg.apiBase = "" or cfg.appToken = "" or cfg.jellyfinToken = "" or cfg.userId = "" then return

  m.subtitleSourcesRequestedItemId = itemId
  m.pendingSubtitleSourcesItemId = itemId
  m.pendingJob = "subtitle_sources"
  m.gatewayTask.kind = "subtitle_sources"
  m.gatewayTask.apiBase = cfg.apiBase
  m.gatewayTask.appToken = cfg.appToken
  m.gatewayTask.jellyfinToken = cfg.jellyfinToken
  m.gatewayTask.userId = cfg.userId
  m.gatewayTask.itemId = itemId
  m.gatewayTask.control = "run"
  print "subtitle sources request itemId=" + itemId
end sub

function _requestSignedSubtitleApply(sourceTrack as String, fallbackTrackId as String, prefKey as String, lang as String, streamIndex as Integer) as Boolean
  if m.gatewayTask = invalid then return false
  if m.playbackIsLive = true then return false
  if m.pendingJob <> "" then return false

  src = sourceTrack
  if src = invalid then src = ""
  src = src.ToStr().Trim()
  if src = "" then return false

  target = parseTarget(src, "")
  path = ""
  if target.path <> invalid then path = target.path
  if path = invalid then path = ""
  path = path.ToStr().Trim()
  if path = "" then return false

  q = {}
  if type(target.query) = "roAssociativeArray" then q = target.query

  cfg = loadConfig()
  if cfg.apiBase = "" or cfg.appToken = "" or cfg.jellyfinToken = "" then return false

  fallback = fallbackTrackId
  if fallback = invalid then fallback = ""
  fallback = fallback.ToStr().Trim()
  key = ""
  if prefKey <> invalid then key = _normTrackToken(prefKey)
  sl = ""
  if lang <> invalid then sl = normalizeLang(lang.ToStr())

  m.pendingSubtitleSignTrackId = fallback
  m.pendingSubtitleSignPrefKey = key
  m.pendingSubtitleSignLang = sl
  m.pendingSubtitleSignStreamIndex = streamIndex
  m.pendingSubtitleSignSourceUrl = src
  m.pendingSubtitleSignExtraQuery = q

  m.pendingJob = "sign_subtitle"
  m.gatewayTask.kind = "sign"
  m.gatewayTask.apiBase = _vodR2PlaybackBase(cfg.apiBase)
  m.gatewayTask.appToken = cfg.appToken
  m.gatewayTask.jellyfinToken = cfg.jellyfinToken
  m.gatewayTask.path = path
  m.gatewayTask.control = "run"
  print "subtitle sign request path=" + path + " key=" + key
  return true
end function

function _nativeSubtitleTrackIdFromSourceIndex(streamIndex as Integer) as String
  idx = Int(streamIndex)
  if idx < 0 then return ""

  tracks = _currentSubtitleTracks()
  if type(tracks) <> "roArray" then return ""

  sawWebvtt = false
  i = 0
  for each tr in tracks
    if type(tr) = "roAssociativeArray" then
      tid = _subtitleSetIdFromTrackObj(tr, i)
      lowTid = LCase(tid)
      if Instr(1, lowTid, "webvtt/") = 1 then sawWebvtt = true

      tIdx = _sceneIntFromAny(_aaGetCi(tr, "StreamIndex"))
      if tIdx < 0 then tIdx = _sceneIntFromAny(_aaGetCi(tr, "Index"))
      if tIdx = idx and tid <> "" then return tid
    end if
    i = i + 1
  end for

  ' Roku commonly maps subtitle source index N -> webvtt/(N+1).
  if sawWebvtt then return "webvtt/" + (idx + 1).ToStr()
  return ""
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

function _trackBoolFromObj(tr as Object, key as String) as Boolean
  if type(tr) <> "roAssociativeArray" then return false
  v = _aaGetCi(tr, key)
  if v = invalid then return false
  if type(v) = "roBoolean" then return (v = true)
  s = LCase(v.ToStr().Trim())
  return (s = "1" or s = "true" or s = "yes" or s = "on")
end function

function _subtitleFlagText(tr as Object) as String
  if type(tr) <> "roAssociativeArray" then return ""
  txt = ""
  keys = ["Description", "DisplayName", "Title", "Label", "Name", "Language", "Url", "URI", "Path", "Src", "Source", "FileName", "File", "Characteristics", "Kind", "Type"]
  for each k in keys
    v = _aaGetCi(tr, k)
    if v <> invalid then
      s = v.ToStr()
      if s <> invalid and s.Trim() <> "" then txt = txt + " " + s
    end if
  end for
  return LCase(txt)
end function

function _isForcedSubtitleTrack(tr as Object) as Boolean
  if type(tr) <> "roAssociativeArray" then return false
  if _trackBoolFromObj(tr, "IsForced") then return true
  if _trackBoolFromObj(tr, "Forced") then return true
  if _trackBoolFromObj(tr, "IsForcedOnly") then return true
  if _trackBoolFromObj(tr, "ForcedOnly") then return true
  txt = _subtitleFlagText(tr)
  ' Filename-based fallback: *.forced.* (e.g., pt.forced.vtt)
  if Instr(1, txt, ".forced.") > 0 then return true
  if Instr(1, txt, ".forcada.") > 0 then return true
  if Instr(1, txt, ".forçada.") > 0 then return true
  if Instr(1, txt, "forcada") > 0 then return true
  if Instr(1, txt, "forçada") > 0 then return true
  return (Instr(1, txt, "forced") > 0)
end function

function _isSdhSubtitleTrack(tr as Object) as Boolean
  if type(tr) <> "roAssociativeArray" then return false
  if _trackBoolFromObj(tr, "IsHearingImpaired") then return true
  if _trackBoolFromObj(tr, "HearingImpaired") then return true
  if _trackBoolFromObj(tr, "IsSDH") then return true
  if _trackBoolFromObj(tr, "SDH") then return true
  txt = _subtitleFlagText(tr)
  if Instr(1, txt, ".sdh.") > 0 then return true
  if Instr(1, txt, "sdh") > 0 then return true
  if Instr(1, txt, "hearing impaired") > 0 then return true
  if Instr(1, txt, "hearing-impaired") > 0 then return true
  return false
end function

function _pickSubtitleTrackByLang(tracks as Object, prefLang as String) as Object
  if type(tracks) <> "roArray" then return invalid
  want = normalizeLang(prefLang)
  if want = "" then return invalid

  candidates = []
  for each t in tracks
    if type(t) = "roAssociativeArray" then
      lang = ""
      if t.Language <> invalid then lang = normalizeLang(t.Language)
      if lang = want then candidates.Push(t)
    end if
  end for

  if candidates.Count() = 0 then return invalid

  ' Forced > normal > SDH/HI.
  for each t in candidates
    if _isForcedSubtitleTrack(t) then return t
  end for
  for each t in candidates
    if _isSdhSubtitleTrack(t) <> true then return t
  end for
  return candidates[0]
end function

sub _ensureDefaultVodPrefs()
  if type(m.vodPrefs) <> "roAssociativeArray" then m.vodPrefs = loadVodPlayerPrefs()
  if m.vodPrefs.audioLang = invalid then m.vodPrefs.audioLang = ""
  if m.vodPrefs.subtitleLang = invalid then m.vodPrefs.subtitleLang = ""
  if m.vodPrefs.audioKey = invalid then m.vodPrefs.audioKey = ""
  if m.vodPrefs.subtitleKey = invalid then m.vodPrefs.subtitleKey = ""
  if m.vodPrefs.subtitlesEnabled = invalid then m.vodPrefs.subtitlesEnabled = false

  ' Normalize any stored prefs (legacy "por"/"eng"/regions).
  m.vodPrefs.audioLang = normalizeLang(m.vodPrefs.audioLang)
  m.vodPrefs.subtitleLang = normalizeLang(m.vodPrefs.subtitleLang)
  m.vodPrefs.audioKey = _normTrackToken(m.vodPrefs.audioKey)
  m.vodPrefs.subtitleKey = _normTrackToken(m.vodPrefs.subtitleKey)

  ' Defaults (ExoPlayer-like).
  dev = normalizeLang(m.uiLang)
  if dev <> "pt" and dev <> "es" and dev <> "it" and dev <> "en" then dev = "en"
  if dev = "" then dev = "en"
  if m.vodPrefs.audioLang.Trim() = "" then m.vodPrefs.audioLang = dev
  if m.vodPrefs.subtitleLang.Trim() = "" then m.vodPrefs.subtitleLang = dev
end sub

sub _saveVodPrefs()
  if type(m.vodPrefs) <> "roAssociativeArray" then return
  saveVodPlayerPrefs(m.vodPrefs.audioLang, m.vodPrefs.subtitleLang, (m.vodPrefs.subtitlesEnabled = true))
  saveVodPlayerPrefKeys(m.vodPrefs.audioKey, m.vodPrefs.subtitleKey)
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
      if type(tracks) <> "roArray" or tracks.Count() = 0 then
        if type(m.availableAudioTracksCache) = "roArray" then tracks = m.availableAudioTracksCache
      end if
      picked = invalid
      prefAudioKey = _normTrackToken(m.vodPrefs.audioKey)
      if prefAudioKey <> "" and prefAudioKey <> "auto" then picked = _pickAudioTrackByKey(tracks, prefAudioKey)
      if picked = invalid then picked = _pickTrackByLang(tracks, m.vodPrefs.audioLang)
      if picked = invalid and normalizeLang(m.vodPrefs.audioLang) <> "en" then picked = _pickTrackByLang(tracks, "en")
      if picked = invalid and type(tracks) = "roArray" and tracks.Count() > 0 then picked = tracks[0]
      if picked <> invalid then
        tId = _trackIdFromTrackObj(picked)
        if tId <> "" then
          print "player pref audioLang=" + m.vodPrefs.audioLang + " audioKey=" + _audioTrackPrefKeyFromObj(picked) + " -> track=" + tId
          m.player.audioTrack = tId
          m.trackPrefsAppliedAudio = true
        end if
      end if
    end if
  end if

  if m.trackPrefsAppliedSub <> true then
    prefSubKey = _normTrackToken(m.vodPrefs.subtitleKey)
    if m.vodPrefs.subtitlesEnabled <> true or prefSubKey = "off" then
      _disableSubtitles()
      m.trackPrefsAppliedSub = true
      return
    end if

    if Left(prefSubKey, 8) = "ext|idx|" then
      idxText = Mid(prefSubKey, 9)
      idxVal = _sceneIntFromAny(idxText)
      if idxVal >= 0 then
        nativePref = _nativeSubtitleTrackIdFromSourceIndex(idxVal)
        if nativePref <> "" then
          _setSubtitleTrack(nativePref)
          curNative = _getCurrentSubtitleTrackId()
          if curNative <> invalid then curNative = curNative.ToStr().Trim() else curNative = ""
          if _trackIdMatches(curNative, nativePref) then
            print "player pref subtitleKey=" + prefSubKey + " native_map track=" + nativePref
            m.lastSubtitleTrackId = curNative
            m.lastSubtitleTrackKey = prefSubKey
            m.trackPrefsAppliedSub = true
            return
          end if
        end if

        extUrl = _externalSubtitleUrlForStreamIndex(idxVal)
        if extUrl <> "" then
          if _requestSignedSubtitleApply(extUrl, "", prefSubKey, m.vodPrefs.subtitleLang, idxVal) then
            m.lastSubtitleTrackKey = prefSubKey
            m.trackPrefsAppliedSub = true
            return
          end if
        end if
        print "player pref subtitleKey=" + prefSubKey + " ext apply failed"
        ' Do not fallback to numeric track id (can collide with non-forced native tracks).
        m.trackPrefsAppliedSub = false
        return
      end if
    end if

    tracks = _currentSubtitleTracks()
    if type(tracks) = "roArray" then
      picked = invalid
      pickedIdx = -1
      if prefSubKey <> "" and prefSubKey <> "off" then
        i = 0
        for each tr in tracks
          if type(tr) = "roAssociativeArray" then
            if _subtitleTrackPrefKeyFromObj(tr, i) = prefSubKey then
              picked = tr
              pickedIdx = i
              exit for
            end if
          end if
          i = i + 1
        end for
      end if
      if picked = invalid then
        picked = _pickSubtitleTrackByLang(tracks, m.vodPrefs.subtitleLang)
      end if
      if picked = invalid and normalizeLang(m.vodPrefs.subtitleLang) <> "en" then picked = _pickSubtitleTrackByLang(tracks, "en")
      if picked = invalid and type(tracks) = "roArray" and tracks.Count() > 0 then picked = tracks[0]
      if picked <> invalid then
        if pickedIdx < 0 then
          wantKey = _subtitleTrackPrefKeyFromObj(picked, 0)
          i = 0
          for each tr in tracks
            if type(tr) = "roAssociativeArray" then
              if _subtitleTrackPrefKeyFromObj(tr, i) = wantKey then
                pickedIdx = i
                exit for
              end if
            end if
            i = i + 1
          end for
          if pickedIdx < 0 then pickedIdx = 0
        end if

        tId = _subtitleSetIdFromTrackObj(picked, pickedIdx)
        if tId <> "" then
          forcedStr = "false"
          if _isForcedSubtitleTrack(picked) then forcedStr = "true"
          sdhStr = "false"
          if _isSdhSubtitleTrack(picked) then sdhStr = "true"
          prefKey = _subtitleTrackPrefKeyFromObj(picked, pickedIdx)
          print "player pref subtitleLang=" + m.vodPrefs.subtitleLang + " subtitleKey=" + prefKey + " -> track=" + tId + " forced=" + forcedStr + " sdh=" + sdhStr
          _setSubtitleTrack(tId)
          m.lastSubtitleTrackKey = prefKey
          m.trackPrefsAppliedSub = true
        end if
      end if
    end if
  end if
end sub

function _looksLikeSubtitleUrl(trackId as String) as Boolean
  v = trackId
  if v = invalid then v = ""
  s = LCase(v.ToStr().Trim())
  if s = "" then return false
  if Instr(1, s, "://") > 0 then return true
  if Left(s, 1) = "/" then return true
  if Left(s, 4) = "pkg:" then return true
  if Instr(1, s, ".vtt") > 0 then return true
  if Instr(1, s, ".srt") > 0 then return true
  if Instr(1, s, ".ttml") > 0 then return true
  return false
end function

sub _setSubtitleTrack(trackId as String)
  if m.player = invalid then return
  id = trackId
  if id = invalid then id = ""
  id = id.Trim()
  if id = "" then return
  isUrl = _looksLikeSubtitleUrl(id)
  if m.player.hasField("captionMode") then m.player.captionMode = "On"
  didSet = false

  if isUrl = true then
    ' Reset native state first to avoid firmware keeping the previous language track.
    if m.player.hasField("subtitleTrack") then m.player.subtitleTrack = "off"
    if m.player.hasField("textTrack") then m.player.textTrack = "off"

    ' URL tracks may be exposed through textTrack on some firmwares.
    if m.player.hasField("textTrack") then
      m.player.textTrack = id
      didSet = true
    end if
    if m.player.hasField("subtitleTrack") then
      m.player.subtitleTrack = id
      didSet = true
    end if
  else
    ' Native track IDs: clear external textTrack first, then set subtitleTrack.
    if m.player.hasField("textTrack") then m.player.textTrack = "off"
    if m.player.hasField("subtitleTrack") then
      m.player.subtitleTrack = id
      didSet = true
    end if
    ' For concrete tokens like "webvtt/1", mirror into textTrack/current to
    ' improve compatibility on firmwares that only honor one of these fields.
    if _isSimpleIntegerToken(id) <> true and m.player.hasField("textTrack") then
      m.player.textTrack = id
      didSet = true
    else if didSet <> true and m.player.hasField("textTrack") then
      ' Numeric fallback only when subtitleTrack couldn't be set.
      m.player.textTrack = id
      didSet = true
    end if
    if m.player.hasField("currentSubtitleTrack") then m.player.currentSubtitleTrack = id
  end if
  if didSet <> true and m.player.hasField("currentSubtitleTrack") then m.player.currentSubtitleTrack = id
  m.lastSubtitleTrackId = id
  dbgSub = ""
  if m.player.hasField("subtitleTrack") then
    dbgSub = m.player.subtitleTrack
    if dbgSub = invalid then dbgSub = ""
    dbgSub = dbgSub.ToStr().Trim()
  end if
  dbgCur = ""
  if m.player.hasField("currentSubtitleTrack") then
    dbgCur = m.player.currentSubtitleTrack
    if dbgCur = invalid then dbgCur = ""
    dbgCur = dbgCur.ToStr().Trim()
  end if
  dbgText = ""
  if m.player.hasField("textTrack") then
    dbgText = m.player.textTrack
    if dbgText = invalid then dbgText = ""
    dbgText = dbgText.ToStr().Trim()
  end if
  print "subtitle set id=" + id + " url=" + isUrl.ToStr() + " sub=" + dbgSub + " cur=" + dbgCur + " text=" + dbgText
end sub

sub _disableSubtitles()
  if m.player = invalid then return
  if m.player.hasField("captionMode") then m.player.captionMode = "Off"
  didSet = false
  if m.player.hasField("subtitleTrack") then
    m.player.subtitleTrack = "off"
    didSet = true
  end if
  if m.player.hasField("textTrack") then
    m.player.textTrack = "off"
    didSet = true
  end if
  if didSet <> true and m.player.hasField("currentSubtitleTrack") then m.player.currentSubtitleTrack = "off"
  m.lastSubtitleTrackId = "off"
  m.lastSubtitleTrackKey = "off"
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
    if type(t) = "roArray" then
      _mergeSubtitleTrackCache(t)

      ' Debug: print the raw track objects so we can see which ID field the
      ' firmware expects when setting subtitleTrack/textTrack.
      if m.debugPrintedSubtitleTracks <> true then
        m.debugPrintedSubtitleTracks = true
        dbgTracks = _currentSubtitleTracks()
        if type(dbgTracks) <> "roArray" then dbgTracks = []
        print "availableSubtitleTracks count=" + dbgTracks.Count().ToStr()
        i = 0
        for each tr in dbgTracks
          if type(tr) = "roAssociativeArray" then
            tid = _subtitleSetIdFromTrackObj(tr, i)
            key = _subtitleTrackPrefKeyFromObj(tr, i)
            lang = _trackLangFromTrackObj(tr)
            desc = _aaGetCi(tr, "Description")
            if desc = invalid then desc = ""
            forcedStr = "false"
            if _isForcedSubtitleTrack(tr) then forcedStr = "true"
            sdhStr = "false"
            if _isSdhSubtitleTrack(tr) then sdhStr = "true"
            idsDbg = _subtitleDebugIdFields(tr)
            print "  [" + (i + 1).ToStr() + "] id=" + tid + " key=" + key + " lang=" + lang + " forced=" + forcedStr + " sdh=" + sdhStr + " desc=" + desc.ToStr() + " ids={" + idsDbg + "}"
          else
            print "  [" + (i + 1).ToStr() + "] type=" + type(tr)
          end if
          i = i + 1
        end for
      end if
    end if
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
  if type(tracks) <> "roArray" or tracks.Count() = 0 then
    if type(m.availableAudioTracksCache) = "roArray" then tracks = m.availableAudioTracksCache
  end if
  if type(tracks) <> "roArray" then return

  _ensureDefaultVodPrefs()
  for each t in tracks
    if type(t) = "roAssociativeArray" then
      tid = _trackIdFromTrackObj(t)
      if tid <> "" and _trackIdMatches(cur, tid) then
        changed = false
        lang = normalizeLang(_trackLangFromTrackObj(t))
        if lang <> "" and normalizeLang(m.vodPrefs.audioLang) <> lang then
          print "player audioTrack changed -> save prefAudioLang=" + lang
          m.vodPrefs.audioLang = lang
          changed = true
        end if
        aKey = _audioTrackPrefKeyFromObj(t)
        if aKey <> "" and _normTrackToken(m.vodPrefs.audioKey) <> aKey then
          print "player audioTrack changed -> save prefAudioKey=" + aKey
          m.vodPrefs.audioKey = aKey
          changed = true
        end if
        if changed then _saveVodPrefs()
        exit for
      end if
    end if
  end for
end sub

sub onCurrentSubtitleTrackChanged()
  if m.player = invalid then return
  if m.player.visible <> true then return
  if m.playbackIsLive = true then return

  if _isCaptionModeOff() then
    m.lastSubtitleTrackId = "off"
    m.lastSubtitleTrackKey = "off"
    _ensureDefaultVodPrefs()
    changed = false
    if m.vodPrefs.subtitlesEnabled <> false then
      m.vodPrefs.subtitlesEnabled = false
      changed = true
    end if
    if _normTrackToken(m.vodPrefs.subtitleKey) <> "off" then
      m.vodPrefs.subtitleKey = "off"
      changed = true
    end if
    if changed then _saveVodPrefs()
    return
  end if

  cur = _getCurrentSubtitleTrackId()
  if cur = "" then return
  cur = cur.Trim()
  if cur = "" then return

  if LCase(cur) = "off" then
    tracksNow = _currentSubtitleTracks()
    hasSubs = (type(tracksNow) = "roArray" and tracksNow.Count() > 0)
    if m.trackPrefsAppliedSub <> true and hasSubs <> true and m.settingsOpen <> true then return

    m.lastSubtitleTrackId = "off"
    m.lastSubtitleTrackKey = "off"
    _ensureDefaultVodPrefs()
    changed = false
    if m.vodPrefs.subtitlesEnabled <> false then
      m.vodPrefs.subtitlesEnabled = false
      changed = true
    end if
    if _normTrackToken(m.vodPrefs.subtitleKey) <> "off" then
      m.vodPrefs.subtitleKey = "off"
      changed = true
    end if
    if changed then _saveVodPrefs()
    return
  end if

  tracks = _currentSubtitleTracks()
  if type(tracks) <> "roArray" then return

  _ensureDefaultVodPrefs()
  i = 0
  for each t in tracks
    if type(t) = "roAssociativeArray" then
      tid = _subtitleSetIdFromTrackObj(t, i)
      if tid <> "" and _trackIdMatches(cur, tid) then
        m.lastSubtitleTrackId = tid
        sKey = _subtitleTrackPrefKeyFromObj(t, i)
        if sKey <> "" then m.lastSubtitleTrackKey = sKey

        changed = false
        lang = normalizeLang(_trackLangFromTrackObj(t))
        if lang <> "" and normalizeLang(m.vodPrefs.subtitleLang) <> lang then
          print "player subtitleTrack changed -> save prefSubtitleLang=" + lang
          m.vodPrefs.subtitleLang = lang
          changed = true
        end if
        if sKey <> "" and _normTrackToken(m.vodPrefs.subtitleKey) <> sKey then
          print "player subtitleTrack changed -> save prefSubtitleKey=" + sKey
          m.vodPrefs.subtitleKey = sKey
          changed = true
        end if
        if m.vodPrefs.subtitlesEnabled <> true then
          m.vodPrefs.subtitlesEnabled = true
          changed = true
        end if
        if changed then _saveVodPrefs()
        exit for
      end if
    end if
    i = i + 1
  end for
end sub

function _overlayContent() as Object
  ' Legacy: overlay used to be a MarkupList. Kept for compatibility if reintroduced.
  return CreateObject("roSGNode", "ContentNode")
end function

sub _restartOsdHideTimer()
  if m.osdHideTimer = invalid then return
  m.osdHideTimer.control = "stop"
  m.osdHideTimer.control = "start"
end sub

sub _stopOsdTimers()
  if m.osdHideTimer <> invalid then m.osdHideTimer.control = "stop"
  if m.osdTickTimer <> invalid then m.osdTickTimer.control = "stop"
end sub

sub _updateOsdUi()
  if m.playerOverlay = invalid then return
  if m.player = invalid or m.player.visible <> true then return

  showGear = (m.playbackIsLive <> true)
  if m.playerOverlayCircle <> invalid then m.playerOverlayCircle.visible = showGear
  if m.playerOverlayIcon <> invalid then m.playerOverlayIcon.visible = showGear
  if m.playerOverlayHint <> invalid then m.playerOverlayHint.visible = showGear

  if m.osdGearFocus <> invalid then
    if showGear and m.osdFocus = "GEAR" then
      m.osdGearFocus.visible = true
    else
      m.osdGearFocus.visible = false
    end if
  end if

  curPos = 0
  durSec = 0
  if m.player.position <> invalid then curPos = Int(m.player.position)
  if m.player.duration <> invalid then durSec = Int(m.player.duration)

  displayPos = curPos
  if m.seekActive = true then displayPos = m.seekTargetSec

  if m.playbackIsLive = true then
    if m.osdTimeLabel <> invalid then
      m.osdTimeLabel.text = ""
      m.osdTimeLabel.visible = false
    end if
    if m.osdSeekLabel <> invalid then m.osdSeekLabel.visible = false
    if m.osdBarFill <> invalid then m.osdBarFill.width = m.osdBarMaxW
    return
  end if

  if m.osdTimeLabel <> invalid then m.osdTimeLabel.visible = true
  if durSec < 0 then durSec = 0
  if displayPos < 0 then displayPos = 0
  if durSec > 0 and displayPos > (durSec - 1) then displayPos = durSec - 1

  if m.osdTimeLabel <> invalid then
    m.osdTimeLabel.text = _fmtTime(displayPos) + " / " + _fmtTime(durSec)
  end if

  if m.osdSeekLabel <> invalid then
    if m.seekActive = true then
      m.osdSeekLabel.visible = true
      m.osdSeekLabel.text = ">> " + _fmtTime(m.seekTargetSec)
    else
      m.osdSeekLabel.visible = false
      m.osdSeekLabel.text = ""
    end if
  end if

  if m.osdBarFill <> invalid then
    w = m.osdBarMaxW
    if w < 1 then w = 1
    if durSec <= 0 then
      m.osdBarFill.width = 0
    else
      ratio = displayPos / durSec
      if ratio < 0 then ratio = 0
      if ratio > 1 then ratio = 1
      m.osdBarFill.width = Int(ratio * w)
    end if
  end if
end sub

function _focusNodeLabel() as String
  id = m.focusNodeId
  if id = invalid then id = ""
  id = id.Trim()
  if id = "" then id = "unknown"
  return id
end function

sub _setNodeFocus(node as Object, nodeId as String)
  id = nodeId
  if id = invalid then id = ""
  id = id.Trim()
  if id = "" then id = "unknown"

  if node <> invalid then node.setFocus(true)
  m.focusNodeId = id
end sub

sub _setPlaybackInputFocus()
  if m.settingsOpen = true then return
  if m.player <> invalid and m.player.visible = true then
    _setNodeFocus(m.player, "player.video")
  else
    _setNodeFocus(m.top, "scene.playback")
  end if
end sub

sub _setBrowseLiveInputEnabled(enabled as Boolean, reason as String)
  m.navListsInputLocked = (enabled <> true)

  nodes = [m.viewsList, m.itemsList, m.channelsList]
  for each n in nodes
    if n <> invalid and n.hasField("focusable") then
      n.focusable = enabled
    end if
  end for

  if enabled <> true then _setPlaybackInputFocus()

  r = reason
  if r = invalid then r = ""
  r = r.Trim()
  print "[focus] listsEnabled=" + enabled.ToStr() + " reason=" + r + " focusNode=" + _focusNodeLabel()
end sub

sub showPlayerOverlay()
  if m.playerOverlay = invalid then return
  if m.player = invalid or m.player.visible <> true then return
  if m.playbackIsLive = true then m.osdFocus = "TIMELINE"
  m.uiState = "OSD"
  m.overlayOpen = true
  m.playerOverlay.visible = true
  if m.osdTickTimer <> invalid then m.osdTickTimer.control = "start"
  _updateOsdUi()
  _restartOsdHideTimer()
  _setPlaybackInputFocus()
  print "[osd] show focus=" + m.osdFocus + " focusNode=" + _focusNodeLabel()
end sub

sub hidePlayerOverlay()
  if m.playerOverlay = invalid then return
  if m.player <> invalid and m.player.visible = true then
    m.uiState = "PLAYING"
  else
    m.uiState = "IDLE"
  end if
  m.overlayOpen = false
  m.playerOverlay.visible = false
  m.seekActive = false
  if m.osdSeekLabel <> invalid then m.osdSeekLabel.visible = false
  if m.osdGearFocus <> invalid then m.osdGearFocus.visible = false
  _stopOsdTimers()
  _setPlaybackInputFocus()
end sub

sub showPlayerSettings()
  if m.playerSettingsModal = invalid then return
  if m.player = invalid or m.player.visible <> true then return
  if m.playbackIsLive = true then return
  ' Avoid the overlay hint bleeding through behind the modal.
  if m.overlayOpen = true then hidePlayerOverlay()
  m.uiState = "SETTINGS"
  m.osdFocus = "GEAR"
  _stopOsdTimers()
  m.settingsOpen = true
  m.settingsOpenedAtMs = _nowMs()
  m.settingsCol = "audio"
  m.playerSettingsModal.visible = true
  _setNodeFocus(m.playerSettingsModal, "settings.modal")
  _requestPlaybackSubtitleSources()
  refreshPlayerSettingsLists()
  _setNodeFocus(m.playerSettingsAudioList, "settings.audioList")
  print "[ui] openSettings focusNode=" + _focusNodeLabel()
end sub

sub hidePlayerSettings()
  if m.playerSettingsModal = invalid then return
  print "[ui] closeSettings focusNode=" + _focusNodeLabel()
  m.settingsOpen = false
  m.playerSettingsModal.visible = false
  if m.player <> invalid and m.player.visible = true then
    ' Return to the OSD, focused on the gear (expected UX).
    m.uiState = "OSD"
    m.osdFocus = "GEAR"
    showPlayerOverlay()
  else
    m.uiState = "IDLE"
  end if
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
    if type(t) = "roArray" and t.Count() > 0 then tracksA = t
  end if
  if (type(tracksA) <> "roArray" or tracksA.Count() = 0) and type(m.availableAudioTracksCache) = "roArray" then tracksA = m.availableAudioTracksCache
  if type(tracksA) <> "roArray" then tracksA = []

  curAudio = ""
  if m.player <> invalid and m.player.hasField("audioTrack") then
    aCur = m.player.audioTrack
    if aCur <> invalid then curAudio = aCur.ToStr().Trim()
  end if
  prefAudioKey = ""
  if isVod and m.vodPrefs.audioKey <> invalid then prefAudioKey = _normTrackToken(m.vodPrefs.audioKey)

  for each tr in tracksA
    if type(tr) = "roAssociativeArray" then
      lang = _trackLangFromTrackObj(tr)
      title = _trackTitleFromTrackObj(tr, lang, "Audio")
      c = CreateObject("roSGNode", "ContentNode")
      c.addField("trackId", "string", false)
      c.addField("prefKey", "string", false)
      c.addField("lang", "string", false)
      c.addField("selected", "boolean", false)
      c.title = title
      c.trackId = _trackIdFromTrackObj(tr)
      c.prefKey = _audioTrackPrefKeyFromObj(tr)
      c.lang = normalizeLang(lang)
      c.selected = false
      if curAudio <> "" and _trackIdMatches(curAudio, c.trackId) then c.selected = true
      if c.selected <> true and prefAudioKey <> "" and c.prefKey = prefAudioKey then c.selected = true
      audioRoot.appendChild(c)
    end if
  end for
  m.playerSettingsAudioList.content = audioRoot
  aFocus = _selectedIndexInContent(audioRoot)
  if aFocus < 0 then aFocus = 0
  m.playerSettingsAudioList.itemFocused = aFocus

  ' Subtitles (first item: OFF)
  subRoot = CreateObject("roSGNode", "ContentNode")
  off = CreateObject("roSGNode", "ContentNode")
  off.addField("trackId", "string", false)
  off.addField("prefKey", "string", false)
  off.addField("sourceOnly", "boolean", false)
  off.addField("sourceUrl", "string", false)
  off.addField("streamIndex", "integer", false)
  off.addField("lang", "string", false)
  off.addField("selected", "boolean", false)
  off.title = _t("off")
  off.trackId = "off"
  off.prefKey = "off"
  off.sourceOnly = false
  off.sourceUrl = ""
  off.streamIndex = -1
  off.lang = ""
  off.selected = true
  subRoot.appendChild(off)

  tracksS = _currentSubtitleTracks()
  if type(tracksS) <> "roArray" then tracksS = []

  cur = _getCurrentSubtitleTrackId()
  subsOff = _areSubtitlesEffectivelyOff(isVod)
  if subsOff <> true and (cur = "" or LCase(cur) = "off") and m.lastSubtitleTrackId <> invalid then cur = m.lastSubtitleTrackId
  if cur = invalid then cur = ""
  cur = cur.ToStr().Trim()
  if cur = "" then cur = "off"

  prefSubKey = ""
  if isVod and m.vodPrefs.subtitleKey <> invalid then prefSubKey = _normTrackToken(m.vodPrefs.subtitleKey)
  lastSubKey = ""
  if m.lastSubtitleTrackKey <> invalid then lastSubKey = _normTrackToken(m.lastSubtitleTrackKey)

  off.selected = (subsOff = true or LCase(cur) = "off" or prefSubKey = "off")
  seenSub = {}
  nativeSubSig = {}

  sIdx = 0
  for each tr in tracksS
    if type(tr) = "roAssociativeArray" then
      prefKey = _subtitleTrackPrefKeyFromObj(tr, sIdx)
      if prefKey = "" then prefKey = "idx|" + sIdx.ToStr()
      tidKey = _subtitleSetIdFromTrackObj(tr, sIdx)
      dedupeKey = "id|" + tidKey
      if seenSub[dedupeKey] <> true then
        seenSub[dedupeKey] = true

        lang = _trackLangFromTrackObj(tr)
        title = _trackTitleFromTrackObj(tr, lang, "Legenda")
        tLow = LCase(title)
        isForced = _isForcedSubtitleTrack(tr)
        isSdh = _isSdhSubtitleTrack(tr)
        forcedSig = "0"
        if isForced then forcedSig = "1"
        sdhSig = "0"
        if isSdh then sdhSig = "1"
        nativeSigKey = normalizeLang(lang) + "|f" + forcedSig + "|s" + sdhSig
        nativeSubSig[nativeSigKey] = true
        if isForced then
          hasForcedLabel = (Instr(1, tLow, "forced") > 0 or Instr(1, tLow, "forcada") > 0 or Instr(1, tLow, "forçada") > 0)
          if hasForcedLabel <> true then
            title = title + " - FORCADA"
            tLow = tLow + " forcada"
          end if
        end if
        if isSdh and Instr(1, tLow, "sdh") = 0 and Instr(1, tLow, "hearing") = 0 then
          title = title + " (SDH)"
        end if
        c = CreateObject("roSGNode", "ContentNode")
        c.addField("trackId", "string", false)
        c.addField("trackIndex", "integer", false)
        c.addField("prefKey", "string", false)
        c.addField("sourceOnly", "boolean", false)
        c.addField("sourceUrl", "string", false)
        c.addField("streamIndex", "integer", false)
        c.addField("lang", "string", false)
        c.addField("selected", "boolean", false)
        c.title = title
        tid = _subtitleSetIdFromTrackObj(tr, sIdx)
        c.trackId = tid
        c.trackIndex = sIdx
        c.prefKey = prefKey
        c.sourceOnly = false
        c.sourceUrl = ""
        c.streamIndex = _sceneIntFromAny(tid)
        c.lang = normalizeLang(lang)
        c.selected = false
        if subsOff <> true and cur <> "" and cur <> "off" and _trackIdMatches(cur, c.trackId) then
          c.selected = true
          off.selected = false
        end if
        if c.selected <> true and subsOff <> true and lastSubKey <> "" and c.prefKey = lastSubKey then
          c.selected = true
          off.selected = false
        end if
        if c.selected <> true and subsOff <> true and prefSubKey <> "" and prefSubKey <> "off" and c.prefKey = prefSubKey then
          c.selected = true
          off.selected = false
        end if
        subRoot.appendChild(c)
      end if
    end if
    sIdx = sIdx + 1
  end for

  ' Fallback list from Jellyfin PlaybackInfo external subtitles (forced/SDH).
  if isVod and type(m.playbackSubtitleSources) = "roArray" and m.playbackSubtitleSources.Count() > 0 then
    print "settings subtitles ext sources=" + m.playbackSubtitleSources.Count().ToStr()
    extSeen = {}
    extPos = 0
    for each src in m.playbackSubtitleSources
      if type(src) = "roAssociativeArray" then
        srcIdx = _sceneIntFromAny(src.streamIndex)
        if srcIdx < 0 and src.StreamIndex <> invalid then srcIdx = _sceneIntFromAny(src.StreamIndex)
        if srcIdx < 0 and src.index <> invalid then srcIdx = _sceneIntFromAny(src.index)
        if srcIdx < 0 and src.Index <> invalid then srcIdx = _sceneIntFromAny(src.Index)

        srcPrefKey = _subtitleSourcePrefKey(src, extPos)
        dedupeKey = srcPrefKey
        if srcIdx >= 0 then dedupeKey = "ext|idx|" + srcIdx.ToStr()
        if extSeen[dedupeKey] <> true then
          extSeen[dedupeKey] = true

          srcTitle = ""
          if src.title <> invalid then srcTitle = src.title else if src.Title <> invalid then srcTitle = src.Title
          srcLang = ""
          if src.language <> invalid then srcLang = src.language else if src.Language <> invalid then srcLang = src.Language
          srcLangNorm = normalizeLang(srcLang)

          label = srcTitle
          if label = invalid then label = ""
          label = label.ToStr().Trim()
          if label = "" and srcLangNorm <> "" then label = displayLang(srcLangNorm)
          if label = "" then label = "Legenda"

          isForced = _subtitleSourceLooksForced(src)
          isSdh = _subtitleSourceLooksSdh(src)
          forcedSig = "0"
          if isForced then forcedSig = "1"
          sdhSig = "0"
          if isSdh then sdhSig = "1"
          extSigKey = srcLangNorm + "|f" + forcedSig + "|s" + sdhSig
          if nativeSubSig[extSigKey] = true then
            print "settings subtitles ext skip duplicate idx=" + srcIdx.ToStr() + " key=" + srcPrefKey + " sig=" + extSigKey
          else
          labelLow = LCase(label)
          if isForced then
            hasForcedLabel = (Instr(1, labelLow, "forced") > 0 or Instr(1, labelLow, "forcada") > 0 or Instr(1, labelLow, "forçada") > 0)
            if hasForcedLabel <> true then
              label = label + " - FORCADA"
              labelLow = labelLow + " forcada"
            end if
          end if
          if isSdh and Instr(1, labelLow, "sdh") = 0 and Instr(1, labelLow, "hearing") = 0 then
            label = label + " (SDH)"
          end if

          srcUrl = ""
          if srcIdx >= 0 then srcUrl = _externalSubtitleUrlForStreamIndex(srcIdx)
          if srcUrl = "" and src.url <> invalid then srcUrl = src.url.ToStr().Trim()
          if srcUrl = "" and src.Url <> invalid then srcUrl = src.Url.ToStr().Trim()
          if srcUrl = "" and src.path <> invalid then srcUrl = src.path.ToStr().Trim()
          if srcUrl = "" and src.Path <> invalid then srcUrl = src.Path.ToStr().Trim()
          if srcUrl <> "" and type(src.query) = "roAssociativeArray" and src.query.Count() > 0 then srcUrl = appendQuery(srcUrl, src.query)
          if srcUrl <> "" and type(src.Query) = "roAssociativeArray" and src.Query.Count() > 0 then srcUrl = appendQuery(srcUrl, src.Query)

          srcTrackId = ""
          if srcPrefKey <> "" then
            srcTrackId = "__ext_sub__" + srcPrefKey
          else if srcIdx >= 0 then
            srcTrackId = "__ext_sub__idx|" + srcIdx.ToStr()
          else
            srcTrackId = "__ext_sub__" + extPos.ToStr()
          end if
          if srcTrackId <> "" then
            c = CreateObject("roSGNode", "ContentNode")
            c.addField("trackId", "string", false)
            c.addField("trackIndex", "integer", false)
            c.addField("prefKey", "string", false)
            c.addField("sourceOnly", "boolean", false)
            c.addField("sourceUrl", "string", false)
            c.addField("streamIndex", "integer", false)
            c.addField("lang", "string", false)
            c.addField("selected", "boolean", false)
            c.title = label
            c.trackId = srcTrackId
            c.trackIndex = sIdx + extPos
            c.prefKey = srcPrefKey
            c.sourceOnly = true
            c.sourceUrl = srcUrl
            c.streamIndex = srcIdx
            c.lang = srcLangNorm
            c.selected = false
            if subsOff <> true and cur <> "" and cur <> "off" then
              if _trackIdMatches(cur, c.trackId) then
                c.selected = true
              else if c.sourceUrl <> "" and _trackIdMatches(cur, c.sourceUrl) then
                c.selected = true
              end if
              if c.selected = true then off.selected = false
            end if
            if c.selected <> true and subsOff <> true and lastSubKey <> "" and c.prefKey = lastSubKey then
              c.selected = true
              off.selected = false
            end if
            if c.selected <> true and subsOff <> true and prefSubKey <> "" and prefSubKey <> "off" and c.prefKey = prefSubKey then
              c.selected = true
              off.selected = false
            end if
            subRoot.appendChild(c)
            print "settings subtitles ext add idx=" + srcIdx.ToStr() + " key=" + srcPrefKey + " title=" + label
          end if
          end if
        end if
      end if
      extPos = extPos + 1
    end for
  end if

  ' If R2 VOD doesn't expose subtitle tracks, offer a "reload subtitles" action.
  ' The gateway will try to inject Jellyfin subtitles into the R2 master when
  ' roku=1&api_key=... is present.
  if isVod and m.playbackKind = "vod-r2" and subRoot.getChildCount() <= 1 then
    load = CreateObject("roSGNode", "ContentNode")
    load.addField("trackId", "string", false)
    load.addField("prefKey", "string", false)
    load.addField("sourceOnly", "boolean", false)
    load.addField("sourceUrl", "string", false)
    load.addField("streamIndex", "integer", false)
    load.addField("lang", "string", false)
    load.addField("selected", "boolean", false)
    load.title = _t("reload_subs")
    load.trackId = "__load_jellyfin__"
    load.prefKey = "__load_jellyfin__"
    load.sourceOnly = false
    load.sourceUrl = ""
    load.streamIndex = -1
    load.lang = ""
    load.selected = false
    subRoot.appendChild(load)
  end if

  ' Some devices don't update subtitleTrack/currentSubtitleTrack reliably, which
  ' can make the UI appear "unselected". Always keep exactly one item selected.
  anySelected = false
  for i = 0 to subRoot.getChildCount() - 1
    n = subRoot.getChild(i)
    if n <> invalid and n.selected = true then
      anySelected = true
      exit for
    end if
  end for

  if anySelected <> true and subsOff <> true then
    lastId = ""
    if m.lastSubtitleTrackId <> invalid then lastId = m.lastSubtitleTrackId.ToStr().Trim()
    if lastId <> "" and lastId <> "off" then
      for i = 1 to subRoot.getChildCount() - 1
        n = subRoot.getChild(i)
        if n <> invalid and n.trackId <> invalid and _trackIdMatches(n.trackId.ToStr(), lastId) then
          n.selected = true
          off.selected = false
          anySelected = true
          exit for
        end if
      end for
    end if
  end if

  if anySelected <> true and subsOff <> true and lastSubKey <> "" and lastSubKey <> "off" then
    for i = 1 to subRoot.getChildCount() - 1
      n = subRoot.getChild(i)
      if n <> invalid and n.prefKey <> invalid and _normTrackToken(n.prefKey) = lastSubKey then
        n.selected = true
        off.selected = false
        anySelected = true
        exit for
      end if
    end for
  end if

  if anySelected <> true and subsOff <> true and prefSubKey <> "" and prefSubKey <> "off" then
    for i = 1 to subRoot.getChildCount() - 1
      n = subRoot.getChild(i)
      if n <> invalid and n.prefKey <> invalid and _normTrackToken(n.prefKey) = prefSubKey then
        n.selected = true
        off.selected = false
        anySelected = true
        exit for
      end if
    end for
  end if

  if anySelected <> true then off.selected = true

  m.playerSettingsSubList.content = subRoot
  sFocus = _selectedIndexInContent(subRoot)
  if sFocus < 0 then sFocus = 0
  m.playerSettingsSubList.itemFocused = sFocus
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
  if it.selected = true then return
  trackId = it.trackId
  if trackId = invalid then trackId = ""
  trackId = trackId.ToStr().Trim()
  if trackId = "" then return
  prefKey = ""
  if it.prefKey <> invalid then prefKey = _normTrackToken(it.prefKey)
  if prefKey = "" then prefKey = _normTrackToken(trackId)

  if m.player <> invalid and m.player.hasField("audioTrack") then m.player.audioTrack = trackId

  if m.playbackIsLive <> true then
    _ensureDefaultVodPrefs()
    lang = it.lang
    if lang = invalid then lang = ""
    lang = normalizeLang(lang.ToStr())
    if lang <> "" then m.vodPrefs.audioLang = lang
    if prefKey <> "" then m.vodPrefs.audioKey = prefKey
    _saveVodPrefs()
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
  if it.selected = true then
    isVodSel = (m.playbackIsLive <> true)
    if LCase(trackId) = "off" then return
    if _areSubtitlesEffectivelyOff(isVodSel) <> true then return
    ' If subtitles are effectively off but a stale track appears selected,
    ' allow OK so the user can re-enable that track directly.
  end if
  prefKey = ""
  if it.prefKey <> invalid then prefKey = _normTrackToken(it.prefKey)
  if prefKey = "" then prefKey = _normTrackToken(trackId)

  if trackId = "off" then
    _disableSubtitles()
    m.lastSubtitleTrackId = "off"
    m.lastSubtitleTrackKey = "off"
    if m.playbackIsLive <> true then
      _ensureDefaultVodPrefs()
      m.vodPrefs.subtitlesEnabled = false
      m.vodPrefs.subtitleKey = "off"
      _saveVodPrefs()
    end if
    refreshPlayerSettingsLists()
    return
  end if

  if trackId = "__load_jellyfin__" then
    tryVodSubtitlesFromJellyfin()
    return
  end if

  sourceOnly = false
  if it.sourceOnly <> invalid and it.sourceOnly = true then sourceOnly = true
  sourceUrl = ""
  if it.sourceUrl <> invalid then sourceUrl = it.sourceUrl.ToStr().Trim()
  streamIndex = -1
  if it.streamIndex <> invalid then streamIndex = _sceneIntFromAny(it.streamIndex)

  print "settings subtitle select idx=" + idx.ToStr() + " trackId=" + trackId + " key=" + prefKey + " sourceOnly=" + sourceOnly.ToStr()
  appliedCur = ""
  if sourceOnly = true then
    if streamIndex >= 0 then
      nativeMapped = _nativeSubtitleTrackIdFromSourceIndex(streamIndex)
      if nativeMapped <> "" then
        _setSubtitleTrack(nativeMapped)
        mappedCur = _getCurrentSubtitleTrackId()
        if mappedCur = invalid then mappedCur = ""
        mappedCur = mappedCur.ToStr().Trim()
        if _trackIdMatches(mappedCur, nativeMapped) then
          print "settings subtitle source native_map idx=" + streamIndex.ToStr() + " track=" + nativeMapped
          m.lastSubtitleTrackId = mappedCur
          if prefKey <> "" then m.lastSubtitleTrackKey = prefKey
          if m.playbackIsLive <> true then
            _ensureDefaultVodPrefs()
            m.vodPrefs.subtitlesEnabled = true
            langM = it.lang
            if langM = invalid then langM = ""
            langM = normalizeLang(langM.ToStr())
            if langM <> "" then m.vodPrefs.subtitleLang = langM
            if prefKey <> "" then m.vodPrefs.subtitleKey = prefKey
            _saveVodPrefs()
          end if
          refreshPlayerSettingsLists()
          return
        else
          print "settings subtitle source native_map miss idx=" + streamIndex.ToStr() + " track=" + nativeMapped + " cur=" + mappedCur
        end if
      end if
    end if

    if m.pendingJob = "sign_subtitle" then
      print "settings subtitle source pending key=" + prefKey
      return
    end if
    if sourceUrl <> "" then
      langSel = ""
      if it.lang <> invalid then langSel = it.lang.ToStr()
      if _requestSignedSubtitleApply(sourceUrl, "", prefKey, langSel, streamIndex) then
        print "settings subtitle sign queued key=" + prefKey + " trackId=" + trackId
        return
      end if
    end if
    print "settings subtitle source sign_unavailable key=" + prefKey + " trackId=" + trackId
    refreshPlayerSettingsLists()
    return
  else
    _setSubtitleTrack(trackId)
    appliedCur = _getCurrentSubtitleTrackId()
  end if

  if appliedCur = invalid then appliedCur = ""
  appliedCur = appliedCur.ToStr().Trim()
  if appliedCur = "" then appliedCur = trackId
  m.lastSubtitleTrackId = appliedCur
  if prefKey <> "" then m.lastSubtitleTrackKey = prefKey
  print "settings subtitle applied cur=" + appliedCur
  if m.playbackIsLive <> true then
    _ensureDefaultVodPrefs()
    m.vodPrefs.subtitlesEnabled = true
    lang = it.lang
    if lang = invalid then lang = ""
    lang = normalizeLang(lang.ToStr())
    if lang <> "" then m.vodPrefs.subtitleLang = lang
    if prefKey <> "" then m.vodPrefs.subtitleKey = prefKey
    _saveVodPrefs()
  end if
  refreshPlayerSettingsLists()
end sub

function _selectedIndexInContent(root as Object) as Integer
  if root = invalid then return -1
  total = root.getChildCount()
  if total <= 0 then return -1
  for i = 0 to total - 1
    n = root.getChild(i)
    if n <> invalid and n.selected = true then return i
  end for
  return -1
end function

function _settingsActiveList() as Object
  if m.settingsCol = "sub" then
    if m.playerSettingsSubList <> invalid then return m.playerSettingsSubList
  end if
  if m.playerSettingsAudioList <> invalid then return m.playerSettingsAudioList
  return invalid
end function

sub _settingsMove(delta as Integer)
  lst = _settingsActiveList()
  if lst = invalid then return
  root = lst.content
  if root = invalid then return
  total = root.getChildCount()
  if total <= 0 then return

  idx = lst.itemFocused
  if idx = invalid then idx = 0
  nextIdx = Int(idx) + delta
  if nextIdx < 0 then nextIdx = 0
  if nextIdx > (total - 1) then nextIdx = total - 1
  lst.itemFocused = nextIdx
end sub

sub _settingsSelectFocused()
  lst = _settingsActiveList()
  if lst = invalid then return
  root = lst.content
  if root = invalid then return
  total = root.getChildCount()
  if total <= 0 then return

  idx = lst.itemFocused
  if idx = invalid then idx = 0
  i = Int(idx)
  if i < 0 then i = 0
  if i > (total - 1) then i = total - 1
  n = root.getChild(i)
  if n <> invalid and n.selected = true then return
  lst.itemSelected = i
end sub

sub signAndPlay(rawPath as String, title as String)
  target = parseTarget(rawPath, "/hls/master.m3u8")

  ' Live must always go through the LIVE gateway/worker routes (/hls/* or /live/*).
  ' Some Jellyfin LiveTv channel payloads can contain other paths/URLs (including legacy R2/VOD),
  ' which would cause the Roku to sign/play an invalid route.
  p = target.path
  if p = invalid then p = ""
  p = p.Trim()
  if Instr(1, p, "/hls/") <> 1 and Instr(1, p, "/live/") <> 1 then
    print "signAndPlay: invalid live path; forcing /hls/master.m3u8 (path=" + p + ")"
    target = { path: "/hls/master.m3u8", query: {} }
  end if

  beginSign(target.path, target.query, title, "hls", true, "live", "")
end sub

function _nodeResumePositionMs(n as Object) as Integer
  if n = invalid then return 0
  ms = -1
  if n.hasField("resumePositionMs") then ms = _sceneIntFromAny(n.resumePositionMs)
  if ms < 0 and n.hasField("positionMs") then ms = _sceneIntFromAny(n.positionMs)
  if ms < 0 and n.hasField("position_ms") then ms = _sceneIntFromAny(n.position_ms)
  if ms < 0 then ms = 0
  return ms
end function

sub showResumeDialog(itemId as String, title as String, resumeMs as Integer)
  if m.pendingDialog <> invalid then return

  id = itemId
  if id = invalid then id = ""
  id = id.ToStr().Trim()
  if id = "" then return

  t = title
  if t = invalid then t = ""
  t = t.ToStr().Trim()
  if t = "" then t = "Video"

  ms = resumeMs
  if ms < 0 then ms = 0
  if ms <= 0 then
    playVodById(id, t)
    return
  end if

  resumeSec = Int(ms / 1000)
  if resumeSec <= 0 then
    playVodById(id, t)
    return
  end if

  m.resumeDialogItemId = id
  m.resumeDialogTitle = t
  m.resumeDialogPositionMs = ms

  dlg = CreateObject("roSGNode", "Dialog")
  dlg.title = _t("resume_title")
  dlg.message = _t("resume_from_prefix") + _fmtTime(resumeSec)
  dlg.buttons = [_t("resume_cancel"), _t("resume_restart"), _t("resume_continue")]
  dlg.observeField("buttonSelected", "onResumeDialogDone")
  m.pendingDialog = dlg
  m.top.dialog = dlg
  dlg.setFocus(true)
end sub

sub onResumeDialogDone()
  dlg = m.pendingDialog
  if dlg = invalid then return

  idx = dlg.buttonSelected
  itemId = m.resumeDialogItemId
  title = m.resumeDialogTitle
  resumeMs = Int(m.resumeDialogPositionMs)

  m.top.dialog = invalid
  m.pendingDialog = invalid
  m.resumeDialogItemId = ""
  m.resumeDialogTitle = ""
  m.resumeDialogPositionMs = 0

  if itemId = invalid then itemId = ""
  itemId = itemId.ToStr().Trim()
  if itemId = "" then return
  if title = invalid then title = ""
  title = title.ToStr().Trim()

  if idx = 2 then
    _beginVodPlay(itemId, title, resumeMs)
  else if idx = 1 then
    _beginVodPlay(itemId, title, 0)
  else
    setStatus(_t("cancelled"))
    applyFocus()
  end if
end sub

sub playVodById(itemId as String, title as String)
  _beginVodPlay(itemId, title, 0)
end sub

sub _beginVodPlay(itemId as String, title as String, resumeMs as Integer)
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

  startMs = resumeMs
  if startMs < 0 then startMs = 0
  m.nextStartResumeMs = startMs

  m.playAttemptId = _nowMs().ToStr()
  m.playAttemptSignStarted = false
  m.pendingPlayAttemptId = m.playAttemptId
  if startMs > 0 then
    print "vod playAttemptId=" + m.playAttemptId + " itemId=" + id + " title=" + t + " resumeMs=" + startMs.ToStr()
  else
    print "vod playAttemptId=" + m.playAttemptId + " itemId=" + id + " title=" + t
  end if

  m.pendingPlaybackItemId = id
  m.pendingPlaybackTitle = t
  m.pendingVodStatusItemId = id
  m.pendingVodStatusTitle = t

  requestVodStatus(id)
end sub

sub requestVodStatus(vodKey as String)
  if m.gatewayTask = invalid then
    setStatus("gateway: missing task")
    return
  end if
  if m.pendingJob <> "" then
    setStatus(_t("please_wait"))
    return
  end if

  k = vodKey
  if k = invalid then k = ""
  k = k.Trim()
  if k = "" then
    setStatus("vod: missing key")
    return
  end if

  cfg = loadConfig()
  if cfg.apiBase = "" or cfg.appToken = "" then
    setStatus(_t("missing_app_token"))
    return
  end if

  setStatus(_t("vod_checking"))
  m.pendingJob = "vod_status"
  m.gatewayTask.kind = "vod_status"
  m.gatewayTask.apiBase = cfg.apiBase
  m.gatewayTask.appToken = cfg.appToken
  m.gatewayTask.itemId = k
  m.gatewayTask.control = "run"
end sub

sub playVodR2Now(itemId as String, title as String)
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

  r2 = r2VodPathForItemId(id)
  if r2 = invalid then r2 = ""
  r2 = r2.Trim()
  if r2 = "" then
    setStatus("vod: invalid r2 path")
    return
  end if

  target = parseTarget(r2, r2)
  attempt = m.playAttemptId
  if attempt = invalid then attempt = ""
  attempt = attempt.ToStr().Trim()
  if m.playAttemptSignStarted = true then
    print "vod sign already started playAttemptId=" + attempt + " itemId=" + id
    return
  end if
  m.playAttemptSignStarted = true
  ' Roku VOD: request subtitle tracks injection from the gateway.
  ' Include api_key so gateway can enrich subtitles from Jellyfin (forced + SDH),
  ' not only what's already present in the raw R2 master.
  q = { roku: "1" }
  cfg = loadConfig()
  hasApiKey = "false"
  if cfg.jellyfinToken <> invalid then
    tok = cfg.jellyfinToken.ToStr().Trim()
    if tok <> "" then
      q["api_key"] = tok
      hasApiKey = "true"
    end if
  end if
  print "vod sign extras roku=1 api_key=" + hasApiKey
  beginSign(target.path, q, t, "hls", false, "vod-r2", id)
end sub

function _isHlsContentType(ct as String) as Boolean
  v = ct
  if v = invalid then v = ""
  v = LCase(v.Trim())
  if v = "" then return false
  if Instr(1, v, "application/vnd.apple.mpegurl") > 0 then return true
  if Instr(1, v, "application/x-mpegurl") > 0 then return true
  if Instr(1, v, "audio/mpegurl") > 0 then return true
  if Instr(1, v, "text/plain") > 0 then return true
  return false
end function

sub _showLiveUnavailableDialog(message as String)
  msg = message
  if msg = invalid then msg = ""
  msg = msg.Trim()
  if msg = "" then msg = "LIVE indisponivel no momento. Tente novamente."

  if m.pendingDialog <> invalid then return
  dlg = CreateObject("roSGNode", "Dialog")
  dlg.title = "Live TV"
  dlg.message = msg
  dlg.buttons = ["OK"]
  dlg.observeField("buttonSelected", "onTokensDone")
  m.pendingDialog = dlg
  m.top.dialog = dlg
  dlg.setFocus(true)
end sub

sub onGatewayTaskStateChanged()
  if m.gatewayTask = invalid then return
  st = m.gatewayTask.state
  if st <> "done" and st <> "stop" then return

  job = m.pendingJob
  if job = "" then return
  m.pendingJob = ""

  if job = "progress_write" then
    posMs = Int(m.pendingProgressPosMs)
    durMs = Int(m.pendingProgressDurMs)
    pct = Int(m.pendingProgressPercent)
    played = (m.pendingProgressPlayed = true)
    reason = m.pendingProgressReason
    if reason = invalid then reason = ""
    reason = reason.ToStr().Trim()
    m.pendingProgressPosMs = -1
    m.pendingProgressDurMs = -1
    m.pendingProgressPercent = -1
    m.pendingProgressPlayed = false
    m.pendingProgressReason = ""

    if m.gatewayTask.ok = true then
      m.progressLastSentAtMs = _nowMs()
      if posMs >= 0 then m.progressLastSentPosMs = posMs
      print "progress write ok posMs=" + posMs.ToStr() + " durMs=" + durMs.ToStr() + " pct=" + pct.ToStr() + " played=" + played.ToStr() + " reason=" + reason
      if m.progressPendingFlush = true or m.progressPendingPlayed = true then
        ignore = _sendProgressReport("drain", m.progressPendingPlayed, true)
      end if
    else
      errProg = m.gatewayTask.error
      if errProg = invalid or errProg = "" then errProg = "unknown"
      print "progress write failed err=" + errProg + " reason=" + reason
      m.progressPendingFlush = true
      if played = true then m.progressPendingPlayed = true
      if reason <> "" then m.progressPendingReason = reason
    end if
    return
  end if

  if job = "login" then
    if m.gatewayTask.ok = true then
      cfg = loadConfig()
      saveConfig(m.apiBase, cfg.appToken, m.gatewayTask.accessToken, m.gatewayTask.userId)
      loadSavedIntoForm()
      enterBrowse()
    else
      err = m.gatewayTask.error
      if err = invalid or err = "" then err = "unknown"
      setStatus("login failed: " + err)
    end if
    return
  end if

  if job = "vod_status" then
    id = m.pendingVodStatusItemId
    t = m.pendingVodStatusTitle
    m.pendingVodStatusItemId = ""
    m.pendingVodStatusTitle = ""

    if id = invalid then id = ""
    id = id.Trim()
    if t = invalid then t = ""
    t = t.Trim()
    if t = "" then t = "Video"

    if m.gatewayTask.ok = true then
      raw = m.gatewayTask.resultJson
      data = ParseJson(raw)
      st = ""
      if type(data) = "roAssociativeArray" then
        if data.status <> invalid then st = data.status
        if (st = invalid or st = "") and data.Status <> invalid then st = data.Status
      end if
      if st = invalid then st = ""
      st = UCase(st.Trim())
      if st = "" then st = "ERROR"

      print "vod status id=" + id + " status=" + st

      if st = "READY" then
        setStatus("ready")
        playVodR2Now(id, t)
      else if st = "PROCESSING" then
        setStatus(_t("vod_processing"))
        if m.pendingDialog = invalid then
          dlg = CreateObject("roSGNode", "Dialog")
          dlg.title = t
          dlg.message = _t("vod_processing_msg")
          dlg.buttons = ["OK"]
          dlg.observeField("buttonSelected", "onTokensDone")
          m.pendingDialog = dlg
          m.top.dialog = dlg
          dlg.setFocus(true)
        end if
      else
        setStatus(_t("vod_unavailable"))
        if m.pendingDialog = invalid then
          dlg2 = CreateObject("roSGNode", "Dialog")
          dlg2.title = t
          dlg2.message = _t("vod_unavailable_msg")
          dlg2.buttons = ["OK"]
          dlg2.observeField("buttonSelected", "onTokensDone")
          m.pendingDialog = dlg2
          m.top.dialog = dlg2
          dlg2.setFocus(true)
        end if
      end if
    else
      err = m.gatewayTask.error
      if err = invalid or err = "" then err = "unknown"
      setStatus("vod status failed: " + err)
    end if

    return
  end if

  if job = "views" then
    if m.gatewayTask.ok = true then
      raw = m.gatewayTask.resultJson
      items = ParseJson(raw)
      if type(items) <> "roArray" then items = []

      root = CreateObject("roSGNode", "ContentNode")
      byType = {}

      for each v in items
        ctype0 = ""
        if v <> invalid and v.collectionType <> invalid then ctype0 = v.collectionType
        if ctype0 = invalid then ctype0 = ""
        ctype = LCase(ctype0.ToStr().Trim())

        ' Flutter-like library rail: only real Jellyfin libraries.
        if ctype <> "movies" and ctype <> "tvshows" and ctype <> "livetv" then
          continue for
        end if

        byType[ctype] = v
      end for

      ordered = ["movies", "livetv", "tvshows"]
      for each ctype in ordered
        v = byType[ctype]
        if v = invalid then continue for
        c = CreateObject("roSGNode", "ContentNode")
        c.addField("collectionType", "string", false)
        if v.id <> invalid then c.id = v.id
        if ctype = "movies" then
          c.title = _t("library_movies")
        else if ctype = "tvshows" then
          c.title = _t("library_series")
        else if ctype = "livetv" then
          c.title = _t("library_live")
        else if v.name <> invalid then
          c.title = v.name
        else
          c.title = ""
        end if
        c.collectionType = ctype
        root.appendChild(c)
      end for

      if m.viewsList <> invalid then m.viewsList.content = root

      ' Reset items list until a view is focused.
      if m.itemsList <> invalid then m.itemsList.content = CreateObject("roSGNode", "ContentNode")
      if m.browseEmptyLabel <> invalid then
        m.browseEmptyLabel.text = _t("no_items")
        m.browseEmptyLabel.visible = true
      end if

      setStatus("ready")

      ' Keep hero "Continuar" as primary action, but load a rich shelf by default.
      m.activeViewId = "__top10"
      m.activeViewCollection = "top10"
      if m.itemsTitle <> invalid then m.itemsTitle.text = _t("top10")
      m.heroContinueAutoplayPending = false
      loadShelfForView("__top10")

      if root.getChildCount() <= 0 then
        if m.browseEmptyLabel <> invalid then
          m.browseEmptyLabel.text = _t("no_libraries")
          m.browseEmptyLabel.visible = true
        end if
      end if

      if m.mode = "browse" and m.viewsList <> invalid then
        m.browseFocus = "hero_continue"
        applyFocus()
      end if
    else
      err = m.gatewayTask.error
      if err = invalid or err = "" then err = "unknown"
      setStatus("views failed: " + err)
      if m.browseEmptyLabel <> invalid then
        m.browseEmptyLabel.text = _t("views_failed")
        m.browseEmptyLabel.visible = true
      end if
    end if
    return
  end if

  if job = "shelf" then
    viewId = m.pendingShelfViewId
    m.pendingShelfViewId = ""
    if viewId = invalid then viewId = ""
    viewId = viewId.ToStr().Trim()

    if viewId = "__continue" and m.activeViewId <> "__continue" then
      m.heroContinueAutoplayPending = false
    end if

    if m.gatewayTask.ok = true then
      raw = m.gatewayTask.resultJson
      if viewId <> invalid and viewId <> "" then _shelfCachePut(viewId, raw)

      if m.activeViewId = viewId then
        renderShelfItems(raw)
      end if

      setStatus("ready")
    else
      err = m.gatewayTask.error
      if err = invalid or err = "" then err = "unknown"
      setStatus("shelf failed: " + err)
      if m.browseEmptyLabel <> invalid then
        m.browseEmptyLabel.text = _t("items_failed")
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

  if job = "live_preview" then
    if m.gatewayTask.ok = true then
      raw = m.gatewayTask.resultJson
      items = ParseJson(raw)
      if type(items) <> "roArray" then items = []

      cfgPrev = loadConfig()
      basePrev = cfgPrev.apiBase
      tokenPrev = cfgPrev.jellyfinToken
      baseNoSlash = basePrev
      if baseNoSlash = invalid then baseNoSlash = ""
      baseNoSlash = baseNoSlash.ToStr().Trim()
      if Right(baseNoSlash, 1) = "/" then baseNoSlash = Left(baseNoSlash, Len(baseNoSlash) - 1)

      root = CreateObject("roSGNode", "ContentNode")
      for each ch in items
        c = CreateObject("roSGNode", "ContentNode")
        c.addField("itemType", "string", false)
        c.addField("path", "string", false)
        c.addField("rank", "integer", false)
        c.addField("posterMode", "string", false)
        c.addField("hdPosterUrl", "string", false)
        c.addField("posterUrl", "string", false)
        if ch <> invalid then
          if ch.id <> invalid then c.id = ch.id
          if ch.name <> invalid then c.title = ch.name else c.title = ""
          c.itemType = "LiveTVChannel"
          if ch.path <> invalid then c.path = ch.path else c.path = ""
          poster = ""
          if ch.logoPath <> invalid then
            lp = ch.logoPath.ToStr().Trim()
            if lp <> "" then
              if Left(lp, 1) = "/" and baseNoSlash <> "" then
                poster = baseNoSlash + lp
              else
                poster = lp
              end if
            end if
          end if
          if poster = "" then poster = _browsePosterUri(c.id, basePrev, tokenPrev)
          if poster = "" then poster = _browseChannelPosterUri(c.id, basePrev, tokenPrev)
          if poster <> "" and tokenPrev <> invalid and tokenPrev.ToStr().Trim() <> "" and Instr(1, poster, "X-Emby-Token=") = 0 then
            poster = appendQuery(poster, { "X-Emby-Token": tokenPrev, "X-Jellyfin-Token": tokenPrev })
          end if
          if poster = "" then poster = "pkg:/images/logo.png"
          c.hdPosterUrl = poster
          c.posterUrl = poster
          c.posterMode = "scaleToFit"
        else
          c.title = ""
          c.itemType = "LiveTVChannel"
          c.path = ""
          c.posterMode = "scaleToFit"
          c.hdPosterUrl = ""
          c.posterUrl = ""
        end if
        c.rank = 0
        root.appendChild(c)
      end for

      if m.activeViewCollection = "livetv" then
        if m.itemsList <> invalid then m.itemsList.content = root
        if m.browseEmptyLabel <> invalid then
          m.browseEmptyLabel.text = _t("no_channels")
          m.browseEmptyLabel.visible = (root.getChildCount() = 0)
        end if
      end if

      setStatus("ready")
    else
      err = m.gatewayTask.error
      if err = invalid or err = "" then err = "unknown"
      setStatus("live preview failed: " + err)
      if m.activeViewCollection = "livetv" and m.browseEmptyLabel <> invalid then
        m.browseEmptyLabel.text = _t("channels_failed")
        m.browseEmptyLabel.visible = true
      end if
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
        m.liveEmptyLabel.text = _t("no_channels")
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
      errLow = LCase(err)
      authFailed = (Instr(1, errLow, "http_401") > 0 or Instr(1, errLow, "invalid_jellyfin_token") > 0 or Instr(1, errLow, "unauthorized") > 0)
      if authFailed then
        print "channels auth failed; forcing login"
        clearAuthSession()
        loadSavedIntoForm()
        enterLogin()
        setStatus(_t("session_expired"))
        return
      end if
      if m.liveEmptyLabel <> invalid then
        m.liveEmptyLabel.text = _t("channels_failed")
        m.liveEmptyLabel.visible = true
      end if
    end if
    return
  end if

  if job = "playback" then
    itemId = m.pendingPlaybackItemId
    if itemId = invalid then itemId = ""
    itemId = itemId.ToStr().Trim()
    title = m.pendingPlaybackTitle
    if title = invalid then title = ""
    title = title.ToStr().Trim()
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
      subtitleSources = []
      if info.path <> invalid then path = info.path
      if type(info.query) = "roAssociativeArray" then query = info.query
      if info.container <> invalid then container = info.container
      if type(info.subtitleSources) = "roArray" then subtitleSources = info.subtitleSources

      if path = invalid then path = ""
      path = path.Trim()

      fmt = inferStreamFormat(path, container)
      m.playbackSubtitleSources = subtitleSources
      if itemId <> "" and subtitleSources.Count() > 0 then
        m.subtitleSourcesRequestedItemId = itemId
      end if

      liveStr = "false"
      if isLive = true then liveStr = "true"
      print "playbackinfo ok path=" + path + " fmt=" + fmt + " kind=" + kind + " live=" + liveStr + " subSources=" + subtitleSources.Count().ToStr()

      ' Consume the pending flags (playback job is async).
      m.pendingPlaybackInfoIsLive = false
      m.pendingPlaybackInfoKind = ""

      ' Hint the gateway to do Roku-specific playlist rewriting (subtitle injection + signing)
      ' for Jellyfin HLS sessions.
      if kind = "vod-jellyfin" and type(query) = "roAssociativeArray" then
        query["roku"] = "1"
      end if

      beginSign(path, query, title, fmt, isLive, kind, itemId)
    else
      err = m.gatewayTask.error
      if err = invalid or err = "" then err = "unknown"
      m.pendingPlaybackInfoIsLive = false
      m.pendingPlaybackInfoKind = ""
      m.playbackSubtitleSources = []
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

  if job = "subtitle_sources" then
    reqItemId = m.pendingSubtitleSourcesItemId
    if reqItemId = invalid then reqItemId = ""
    reqItemId = reqItemId.ToStr().Trim()
    m.pendingSubtitleSourcesItemId = ""

    curItemId = m.playbackItemId
    if curItemId = invalid then curItemId = ""
    curItemId = curItemId.ToStr().Trim()
    if reqItemId <> "" and curItemId <> "" and reqItemId <> curItemId then
      print "subtitle sources stale itemId=" + reqItemId + " current=" + curItemId
      return
    end if

    if m.gatewayTask.ok = true then
      rawSubs = m.gatewayTask.resultJson
      dataSubs = ParseJson(rawSubs)
      sources = []
      if type(dataSubs) = "roAssociativeArray" and type(dataSubs.sources) = "roArray" then
        sources = dataSubs.sources
      end if
      m.playbackSubtitleSources = sources
      print "subtitle sources ok itemId=" + reqItemId + " count=" + sources.Count().ToStr()
      srcLogIdx = 0
      for each src in sources
        if type(src) = "roAssociativeArray" then
          srcIdxVal = -1
          if src.streamIndex <> invalid then srcIdxVal = _sceneIntFromAny(src.streamIndex)
          srcTitle = ""
          if src.title <> invalid then srcTitle = src.title.ToStr().Trim()
          srcLang = ""
          if src.language <> invalid then srcLang = src.language.ToStr().Trim()
          forcedStr = "false"
          if _sceneBoolFromAny(src.forced) then forcedStr = "true"
          sdhStr = "false"
          if _sceneBoolFromAny(src.hearingImpaired) then sdhStr = "true"
          print "  subtitle source[" + srcLogIdx.ToStr() + "] idx=" + srcIdxVal.ToStr() + " lang=" + srcLang + " forced=" + forcedStr + " sdh=" + sdhStr + " title=" + srcTitle
        end if
        srcLogIdx = srcLogIdx + 1
      end for
      if m.settingsOpen = true then refreshPlayerSettingsLists()
    else
      errSubs = m.gatewayTask.error
      if errSubs = invalid or errSubs = "" then errSubs = "unknown"
      print "subtitle sources failed itemId=" + reqItemId + " err=" + errSubs
      if reqItemId <> "" then m.subtitleSourcesRequestedItemId = ""
    end if
    return
  end if

  if job = "probe_live" then
    pUrl = m.pendingProbeUrl
    pTitle = m.pendingProbeTitle
    pFmt = m.pendingProbeStreamFormat
    pIsLive = (m.pendingProbeIsLive = true)
    pKind = m.pendingProbeKind
    pItemId = m.pendingProbeItemId

    if pUrl = invalid then pUrl = ""
    if pTitle = invalid then pTitle = ""
    if pFmt = invalid then pFmt = ""
    if pKind = invalid then pKind = ""
    if pItemId = invalid then pItemId = ""

    pUrl = pUrl.Trim()
    pTitle = pTitle.Trim()
    pFmt = pFmt.Trim()
    pKind = pKind.Trim()
    pItemId = pItemId.Trim()

    m.pendingProbeUrl = ""
    m.pendingProbeTitle = ""
    m.pendingProbeStreamFormat = ""
    m.pendingProbeIsLive = false
    m.pendingProbeKind = ""
    m.pendingProbeItemId = ""

    if m.gatewayTask.ok = true then
      rawProbe = m.gatewayTask.resultJson
      probe = ParseJson(rawProbe)
      if type(probe) <> "roAssociativeArray" then probe = {}

      pStatus = 0
      if probe.status <> invalid then pStatus = Int(probe.status)
      pCt = ""
      if probe.ct <> invalid then pCt = probe.ct
      pCe = ""
      if probe.ce <> invalid then pCe = probe.ce
      pCl = ""
      if probe.cl <> invalid then pCl = probe.cl
      pLoc = ""
      if probe.loc <> invalid then pLoc = probe.loc
      pBody = ""
      if probe.bodySnippet <> invalid then pBody = probe.bodySnippet

      pCt = pCt.Trim()
      pCe = pCe.Trim()
      pCl = pCl.Trim()
      pLoc = pLoc.Trim()
      pBody = pBody.Trim()

      print "[probe] kind=live status=" + pStatus.ToStr() + " ct=" + pCt + " ce=" + pCe + " cl=" + pCl + " loc=" + pLoc
      if pStatus <> 200 and pBody <> "" then
        print "[probe_body] " + pBody
      end if

      if pStatus = 200 and _isHlsContentType(pCt) then
        setStatus("opening...")
        startVideo(pUrl, pTitle, pFmt, pIsLive, pKind, pItemId)
      else
        m.liveResignPending = false
        setStatus("LIVE indisponivel")
        msg = "LIVE indisponivel no momento."
        if pStatus > 0 then msg = msg + " (HTTP " + pStatus.ToStr() + ")"
        _showLiveUnavailableDialog(msg)
      end if
    else
      perr = m.gatewayTask.error
      if perr = invalid or perr = "" then perr = "unknown"
      print "[probe] kind=live status=0 ct= ce= cl= loc="
      print "[probe_body] probe_failed: " + perr
      m.liveResignPending = false
      setStatus("LIVE indisponivel")
      _showLiveUnavailableDialog("LIVE indisponivel no momento.")
    end if
    return
  end if

  if job = "sign_subtitle" then
    fallbackId = m.pendingSubtitleSignTrackId
    if fallbackId = invalid then fallbackId = ""
    fallbackId = fallbackId.ToStr().Trim()
    prefKey = ""
    if m.pendingSubtitleSignPrefKey <> invalid then prefKey = _normTrackToken(m.pendingSubtitleSignPrefKey)
    lang = ""
    if m.pendingSubtitleSignLang <> invalid then lang = normalizeLang(m.pendingSubtitleSignLang.ToStr())
    sourceUrl = ""
    if m.pendingSubtitleSignSourceUrl <> invalid then sourceUrl = m.pendingSubtitleSignSourceUrl.ToStr().Trim()
    sourceStreamIndex = _sceneIntFromAny(m.pendingSubtitleSignStreamIndex)
    signExtra = m.pendingSubtitleSignExtraQuery
    if type(signExtra) <> "roAssociativeArray" then signExtra = {}

    m.pendingSubtitleSignTrackId = ""
    m.pendingSubtitleSignPrefKey = ""
    m.pendingSubtitleSignLang = ""
    m.pendingSubtitleSignStreamIndex = -1
    m.pendingSubtitleSignSourceUrl = ""
    m.pendingSubtitleSignExtraQuery = {}

    appliedCur = ""
    if m.gatewayTask.ok = true then
      cfg = loadConfig()
      sBase = _vodR2PlaybackBase(cfg.apiBase)
      signedSubUrl = sBase + m.gatewayTask.signedUrl
      signedSubUrl = appendQuery(signedSubUrl, signExtra)
      _setSubtitleTrack(signedSubUrl)
      appliedCur = _getCurrentSubtitleTrackId()
      strictCur = ""
      if m.player <> invalid and m.player.hasField("currentSubtitleTrack") then
        strictCur = m.player.currentSubtitleTrack
        if strictCur = invalid then strictCur = ""
        strictCur = strictCur.ToStr().Trim()
      end if
      if strictCur <> "" then appliedCur = strictCur

      urlApplied = false
      if _trackIdMatches(appliedCur, signedSubUrl) then
        urlApplied = true
      else if sourceUrl <> "" and _trackIdMatches(appliedCur, sourceUrl) then
        urlApplied = true
      end if
      if urlApplied <> true then
        print "subtitle sign not_applied key=" + prefKey + " current=" + appliedCur
        appliedCur = ""
      end if

      if (appliedCur = "" or LCase(appliedCur) = "off") and fallbackId <> "" then
        _setSubtitleTrack(fallbackId)
        appliedCur = _getCurrentSubtitleTrackId()
      end if
      if (appliedCur = "" or LCase(appliedCur) = "off") and sourceStreamIndex >= 0 then
        mappedFallback = _nativeSubtitleTrackIdFromSourceIndex(sourceStreamIndex)
        if mappedFallback <> "" then
          _setSubtitleTrack(mappedFallback)
          appliedCur = _getCurrentSubtitleTrackId()
          if _trackIdMatches(appliedCur, mappedFallback) then
            print "subtitle sign native_fallback idx=" + sourceStreamIndex.ToStr() + " track=" + mappedFallback
          else
            appliedCur = ""
          end if
        end if
      end if

      safeSubUrl = signedSubUrl
      qposSub = Instr(1, safeSubUrl, "?")
      if qposSub > 0 then safeSubUrl = Left(safeSubUrl, qposSub - 1)
      print "subtitle sign ok key=" + prefKey + " url=" + safeSubUrl + " applied=" + appliedCur
    else
      errSignSub = m.gatewayTask.error
      if errSignSub = invalid or errSignSub = "" then errSignSub = "unknown"
      print "subtitle sign failed key=" + prefKey + " err=" + errSignSub

      if sourceUrl <> "" then
        _setSubtitleTrack(sourceUrl)
        appliedCur = _getCurrentSubtitleTrackId()
      end if
      if (appliedCur = "" or LCase(appliedCur) = "off") and fallbackId <> "" then
        _setSubtitleTrack(fallbackId)
        appliedCur = _getCurrentSubtitleTrackId()
      end if
      if (appliedCur = "" or LCase(appliedCur) = "off") and sourceStreamIndex >= 0 then
        mappedFallback = _nativeSubtitleTrackIdFromSourceIndex(sourceStreamIndex)
        if mappedFallback <> "" then
          _setSubtitleTrack(mappedFallback)
          appliedCur = _getCurrentSubtitleTrackId()
          if _trackIdMatches(appliedCur, mappedFallback) then
            print "subtitle sign native_fallback idx=" + sourceStreamIndex.ToStr() + " track=" + mappedFallback
          else
            appliedCur = ""
          end if
        end if
      end if
    end if

    if appliedCur = invalid then appliedCur = ""
    appliedCur = appliedCur.ToStr().Trim()
    if appliedCur <> "" and LCase(appliedCur) <> "off" then
      m.lastSubtitleTrackId = appliedCur
      if prefKey <> "" then m.lastSubtitleTrackKey = prefKey
      m.trackPrefsAppliedSub = true

      if m.playbackIsLive <> true then
        _ensureDefaultVodPrefs()
        m.vodPrefs.subtitlesEnabled = true
        if lang <> "" then m.vodPrefs.subtitleLang = lang
        if prefKey <> "" then m.vodPrefs.subtitleKey = prefKey
        _saveVodPrefs()
      end if
    end if

    if m.settingsOpen = true then refreshPlayerSettingsLists()
    return
  end if

  if job = "sign" then
    if m.gatewayTask.ok = true then
      cfg = loadConfig()
      kind = m.pendingPlaybackKind
      if kind = invalid then kind = ""
      kind = kind.Trim()
      if kind = "" then kind = "unknown"

      base = cfg.apiBase
      isLive = (m.pendingPlayIsLive = true)

      ' LIVE must always use api.champions.place (Worker live-hls). VOD R2 may
      ' bypass Worker routes via api-vm.champions.place.
      if isLive = true then
        base = _livePlaybackBase(base)
      ' VOD R2 playback must bypass Cloudflare Worker routes that can intercept
      ' api.champions.place/r2/vod/* (we need the VM gateway to rewrite playlists
      ' and inject subtitles). Use api-vm.champions.place when applicable.
      else if kind = "vod-r2" then
        base = _vodR2PlaybackBase(base)
      end if
      url = base + m.gatewayTask.signedUrl
      url = appendQuery(url, m.pendingPlayExtraQuery)
      t = m.pendingPlayTitle
      if t = invalid then t = ""
      t = t.Trim()
      if t = "" then t = "Live"

      itemId = m.pendingPlaybackItemId
      if itemId = invalid then itemId = ""
      itemId = itemId.Trim()

      fmt = m.pendingPlayStreamFormat
      if fmt = invalid then fmt = ""
      fmt = fmt.Trim()
      if fmt = "" then fmt = inferStreamFormat(url, "")

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

      if isLive = true then
        m.pendingProbeUrl = url
        m.pendingProbeTitle = t
        m.pendingProbeStreamFormat = fmt
        m.pendingProbeIsLive = true
        m.pendingProbeKind = kind
        m.pendingProbeItemId = itemId

        m.pendingJob = "probe_live"
        m.gatewayTask.kind = "probe_live"
        m.gatewayTask.probeUrl = url
        m.gatewayTask.appToken = cfg.appToken
        m.gatewayTask.jellyfinToken = cfg.jellyfinToken
        m.gatewayTask.control = "run"
        return
      end if

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

  resumeMs = Int(m.nextStartResumeMs)
  if resumeMs < 0 then resumeMs = 0
  if isLive = true then resumeMs = 0
  m.nextStartResumeMs = 0
  resumeSec = Int(resumeMs / 1000)
  if resumeSec < 0 then resumeSec = 0
  m.playbackResumeTargetSec = -1
  m.playbackResumePending = false
  if isLive <> true and resumeSec > 0 then
    m.playbackResumeTargetSec = resumeSec
    m.playbackResumePending = true
  end if

  ' Reset per-playback track preference application.
  m.trackPrefsAppliedAudio = false
  m.trackPrefsAppliedSub = false
  m.availableAudioTracksCache = []
  m.availableSubtitleTracksCache = []
  m.playbackSubtitleSources = []
  m.pendingSubtitleSourcesItemId = ""
  m.subtitleSourcesRequestedItemId = ""
  m.pendingSubtitleSignTrackId = ""
  m.pendingSubtitleSignPrefKey = ""
  m.pendingSubtitleSignLang = ""
  m.pendingSubtitleSignStreamIndex = -1
  m.pendingSubtitleSignSourceUrl = ""
  m.pendingSubtitleSignExtraQuery = {}
  m.lastSubtitleTrackId = ""
  m.lastSubtitleTrackKey = ""
  m.debugPrintedSubtitleTracks = false
  m.progressLastSentPosMs = -1
  m.progressLastSentAtMs = 0
  m.progressPendingFlush = false
  m.progressPendingPlayed = false
  m.progressPendingReason = ""
  m.pendingProgressPosMs = -1
  m.pendingProgressDurMs = -1
  m.pendingProgressPercent = -1
  m.pendingProgressPlayed = false
  m.pendingProgressReason = ""
  if m.progressTimer <> invalid then m.progressTimer.control = "stop"

  ' Cancel any in-flight scrubbing.
  m.scrubActive = false
  m.scrubDir = 0
  if m.scrubTimer <> invalid then m.scrubTimer.control = "stop"

  ' Clear any prior selection so we don't carry track IDs across unrelated assets.
  ' We'll re-apply preferences once track lists become available.
  if m.player.hasField("audioTrack") then m.player.audioTrack = ""
  if m.player.hasField("textTrack") then m.player.textTrack = ""
  didClear = false
  if m.player.hasField("subtitleTrack") then
    m.player.subtitleTrack = ""
    didClear = true
  end if
  if m.player.hasField("currentSubtitleTrack") and didClear <> true then
    m.player.currentSubtitleTrack = ""
  end if

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

  end if

  if isLive <> true and resumeSec > 0 then
    if c.hasField("PlayStart") then
      c.PlayStart = resumeSec
    else if c.hasField("playStart") then
      c.playStart = resumeSec
    else if c.hasField("playstart") then
      c.playstart = resumeSec
    else
      c.addField("PlayStart", "float", false)
      c.PlayStart = resumeSec
    end if
    print "vod resume startSec=" + resumeSec.ToStr()
  end if

  ' Disable Roku built-in transport UI; we render our own OSD/settings.
  if c.hasField("VideoDisableUI") then
    c.VideoDisableUI = true
  else if c.hasField("videoDisableUI") then
    c.videoDisableUI = true
  else
    c.addField("VideoDisableUI", "boolean", false)
    c.VideoDisableUI = true
  end if

  m.playbackKind = kind
  m.playbackIsLive = isLive
  m.playbackItemId = itemId
  m.playbackTitle = title
  m.liveEdgeSnapped = false

  m.player.content = c
  m.player.visible = true
  m.player.control = "play"

  m.uiState = "PLAYING"
  m.osdFocus = "TIMELINE"
  m.seekActive = false
  m.seekTargetSec = 0
  m.lastHandledPlaybackKey = ""
  m.lastHandledPlaybackKeyMs = 0
  m.lastHandledPlaybackState = ""

  _setBrowseLiveInputEnabled(false, "playback_start")
  hidePlayerOverlay()
  ' Keep key input on our ChampionsVideo node during playback.
  _setPlaybackInputFocus()

  ' Close player settings if it was open (avoid returning to OSD unexpectedly).
  m.settingsOpen = false
  if m.playerSettingsModal <> invalid then m.playerSettingsModal.visible = false

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

  st = m.lastPlayerState
  if st = invalid then st = ""
  st = LCase(st.Trim())
  if st = "playing" then return

  id = m.playbackItemId
  t = m.playbackTitle
  if id = invalid then id = ""
  id = id.Trim()
  if id = "" then return

  print "VOD R2 timeout (state=" + st + "): stopping"
  setStatus(_t("vod_try_again"))
  stopPlaybackAndReturn("vod_r2_timeout")
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
  m.pendingProbeUrl = ""
  m.pendingProbeTitle = ""
  m.pendingProbeStreamFormat = ""
  m.pendingProbeIsLive = false
  m.pendingProbeKind = ""
  m.pendingProbeItemId = ""
  m.pendingSubtitleSourcesItemId = ""
  m.pendingSubtitleSignTrackId = ""
  m.pendingSubtitleSignPrefKey = ""
  m.pendingSubtitleSignLang = ""
  m.pendingSubtitleSignStreamIndex = -1
  m.pendingSubtitleSignSourceUrl = ""
  m.pendingSubtitleSignExtraQuery = {}
  if m.progressTimer <> invalid then m.progressTimer.control = "stop"
  playedStop = false
  rr = LCase(r.Trim())
  if rr = "finished" then playedStop = true
  ignore = _sendProgressReport("stop_" + rr, playedStop, true)

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
  m.liveFallbackAttempted = false
  m.lastPlayerState = ""
  m.playbackSubtitleSources = []
  m.subtitleSourcesRequestedItemId = ""
  m.playbackSignedExp = 0
  m.liveResignPending = false
  m.ignoreNextStopped = false
  ' Playback completion should refresh dynamic shelves (continue/top10) next time.
  if m.shelfCache <> invalid then
    if m.shelfCache["__continue"] <> invalid then m.shelfCache.Delete("__continue")
    if m.shelfCache["__top10"] <> invalid then m.shelfCache.Delete("__top10")
  end if
  m.settingsOpen = false
  m.overlayOpen = false
  m.uiState = "IDLE"
  m.osdFocus = "TIMELINE"
  m.seekActive = false
  m.seekTargetSec = 0
  m.lastHandledPlaybackKey = ""
  m.lastHandledPlaybackKeyMs = 0
  m.lastHandledPlaybackState = ""
  _stopOsdTimers()
  if m.playerOverlay <> invalid then m.playerOverlay.visible = false
  if m.playerSettingsModal <> invalid then m.playerSettingsModal.visible = false
  if m.osdSeekLabel <> invalid then m.osdSeekLabel.visible = false
  if m.osdGearFocus <> invalid then m.osdGearFocus.visible = false

  _setBrowseLiveInputEnabled(true, "playback_stop")
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

sub onProgressTimerFire()
  if _shouldTrackProgress() <> true then return
  if m.player = invalid or m.player.visible <> true then return
  if m.lastPlayerState <> "playing" and m.progressPendingFlush <> true then return
  ignore = _sendProgressReport("timer", false, false)
end sub

sub _togglePauseResume()
  if m.player = invalid or m.player.visible <> true then return
  st = ""
  if m.player.state <> invalid then st = m.player.state.ToStr()
  st = LCase(st.Trim())
  if st = "playing" then
    if m.player.hasField("control") then m.player.control = "pause"
  else
    if m.player.hasField("control") then m.player.control = "play"
  end if
end sub

sub _adjustOsdSeek(delta as Integer)
  if m.player = invalid or m.player.visible <> true then return
  if m.playbackIsLive = true then return

  dur = 0
  if m.player.duration <> invalid then dur = Int(m.player.duration)
  if dur <= 0 then return

  if m.seekActive <> true then
    p = 0
    if m.player.position <> invalid then p = Int(m.player.position)
    m.seekTargetSec = p
    m.seekActive = true
  end if

  t = m.seekTargetSec + delta
  if t < 0 then t = 0
  if t > (dur - 1) then t = dur - 1
  m.seekTargetSec = t
  _updateOsdUi()
end sub

sub _applyOsdSeek()
  if m.player = invalid or m.player.visible <> true then return
  if m.playbackIsLive = true then
    m.seekActive = false
    return
  end if

  if m.seekActive = true and m.player.hasField("seek") then
    m.player.seek = m.seekTargetSec
  end if
  m.seekActive = false
end sub

function handlePlaybackKey(kl as String) as Boolean
  if m.player = invalid or m.player.visible <> true then return false

  k = kl
  if k = invalid then k = ""
  k = LCase(k.Trim())
  if k = "select" then k = "ok"
  if k = "channelup" or k = "chanup" then k = "up"
  if k = "channeldown" or k = "chandown" then k = "down"
  if k = "" then return false

  st = m.uiState
  if st = invalid then st = ""
  st = UCase(st.Trim())
  if st = "" or st = "IDLE" then st = "PLAYING"
  m.uiState = st

  nowMs = _nowMs()
  prevKey = ""
  if m.lastHandledPlaybackKey <> invalid then prevKey = m.lastHandledPlaybackKey.ToStr().Trim()
  prevMs = 0
  if m.lastHandledPlaybackKeyMs <> invalid then prevMs = Int(m.lastHandledPlaybackKeyMs)
  prevState = ""
  if m.lastHandledPlaybackState <> invalid then prevState = m.lastHandledPlaybackState.ToStr().Trim()
  ageMs = nowMs - prevMs
  dedupEligible = (k <> "up" and k <> "down")
  if dedupEligible and prevKey = k and prevState = st and ageMs >= 0 and ageMs < 80 then
    print "[key] name=" + k + " state=" + m.uiState + " focus=" + m.osdFocus + " focusNode=" + _focusNodeLabel() + " consumed=true dedup=true"
    return true
  end if
  m.lastHandledPlaybackKey = k
  m.lastHandledPlaybackKeyMs = nowMs
  m.lastHandledPlaybackState = st

  f = m.osdFocus
  if f = invalid then f = ""
  f = UCase(f.Trim())
  if f <> "GEAR" then f = "TIMELINE"
  m.osdFocus = f

  ' Keep Scene focus during playback (except inside settings lists).
  if st <> "SETTINGS" then _setPlaybackInputFocus()

  consumed = false

  if st = "SETTINGS" then
    if k = "back" then
      hidePlayerSettings()
      consumed = true
    else if k = "left" then
      m.settingsCol = "audio"
      _setNodeFocus(m.playerSettingsAudioList, "settings.audioList")
      consumed = true
    else if k = "right" then
      m.settingsCol = "sub"
      _setNodeFocus(m.playerSettingsSubList, "settings.subList")
      consumed = true
    else if k = "up" then
      _settingsMove(-1)
      consumed = true
    else if k = "down" then
      _settingsMove(1)
      consumed = true
    else if k = "ok" then
      _settingsSelectFocused()
      consumed = true
    else if k = "options" or k = "info" then
      ' Avoid system menu: treat * as close.
      hidePlayerSettings()
      consumed = true
    else
      consumed = true
    end if

    print "[key] name=" + k + " state=" + m.uiState + " focus=" + m.osdFocus + " focusNode=" + _focusNodeLabel() + " consumed=" + consumed.ToStr()
    return consumed
  end if

  if st = "OSD" then
    ' Any interaction keeps OSD visible.
    _restartOsdHideTimer()

    if k = "back" then
      m.seekActive = false
      hidePlayerOverlay()
      consumed = true
    else if k = "ok" then
      if m.osdFocus = "GEAR" then
        if m.playbackIsLive <> true then showPlayerSettings()
        consumed = true
      else
        _applyOsdSeek()
        hidePlayerOverlay()
        consumed = true
      end if
    else if k = "up" or k = "down" then
      prevFocus = m.osdFocus
      if m.playbackIsLive = true then
        m.osdFocus = "TIMELINE"
      else
        ' Keep VOD deterministic even with duplicate key events.
        m.osdFocus = "GEAR"
      end if
      _updateOsdUi()
      if prevFocus <> m.osdFocus then
        print "[osd] focus " + prevFocus + "->" + m.osdFocus + " focusNode=" + _focusNodeLabel()
      end if
      consumed = true
    else if k = "left" or k = "right" then
      if m.osdFocus = "GEAR" then
        if k = "left" then
          prevFocus = m.osdFocus
          m.osdFocus = "TIMELINE"
          _updateOsdUi()
          if prevFocus <> m.osdFocus then
            print "[osd] focus " + prevFocus + "->" + m.osdFocus + " focusNode=" + _focusNodeLabel()
          end if
        end if
      else
        if m.playbackIsLive <> true then
          if k = "right" then _adjustOsdSeek(10) else _adjustOsdSeek(-10)
        end if
      end if
      consumed = true
    else if k = "playpause" then
      _togglePauseResume()
      consumed = true
    else if k = "options" or k = "info" then
      if m.playbackIsLive <> true then showPlayerSettings()
      consumed = true
    else
      consumed = false
    end if

    print "[key] name=" + k + " state=" + m.uiState + " focus=" + m.osdFocus + " focusNode=" + _focusNodeLabel() + " consumed=" + consumed.ToStr()
    return consumed
  end if

  ' PLAYING
  if k = "back" then
    setStatus("stopped")
    stopPlaybackAndReturn("back")
    consumed = true
  else if k = "ok" then
    m.osdFocus = "TIMELINE"
    showPlayerOverlay()
    consumed = true
  else if k = "up" then
    ' VOD shortcut: UP opens OSD directly on settings gear.
    if m.playbackIsLive = true then
      m.osdFocus = "TIMELINE"
    else
      m.osdFocus = "GEAR"
    end if
    showPlayerOverlay()
    consumed = true
  else if k = "down" then
    ' VOD shortcut: DOWN also opens OSD directly on settings gear.
    if m.playbackIsLive = true then
      m.osdFocus = "TIMELINE"
    else
      m.osdFocus = "GEAR"
    end if
    showPlayerOverlay()
    consumed = true
  else if k = "left" or k = "right" then
    m.osdFocus = "TIMELINE"
    if m.playbackIsLive <> true then
      if k = "right" then _adjustOsdSeek(10) else _adjustOsdSeek(-10)
      showPlayerOverlay()
      _restartOsdHideTimer()
    else
      showPlayerOverlay()
    end if
    consumed = true
  else if k = "playpause" then
    _togglePauseResume()
    consumed = true
  else if k = "options" or k = "info" then
    if m.playbackIsLive <> true then showPlayerSettings()
    consumed = true
  end if

  print "[key] name=" + k + " state=" + m.uiState + " focus=" + m.osdFocus + " focusNode=" + _focusNodeLabel() + " consumed=" + consumed.ToStr()
  return consumed
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
  if press <> true then return false

  k = key
  if k = invalid then k = ""
  kl = LCase(k.Trim())
  if kl = "select" then kl = "ok"
  if kl = "channelup" or kl = "chanup" then kl = "up"
  if kl = "channeldown" or kl = "chandown" then kl = "down"

  ' While the modal is open, prioritize settings navigation first.
  if m.player <> invalid and m.player.visible = true and m.settingsOpen = true then
    return handlePlaybackKey(kl)
  end if

  if m.player <> invalid and m.player.visible = true then
    return handlePlaybackKey(kl)
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

    if kl = "left" then
      if m.browseFocus = "items" then
        iIdx = _browseListFocusedIndex(m.itemsList)
        iCols = _browseItemCols()
        if iIdx > 0 and (iIdx mod iCols) > 0 then
          ' Let MarkupGrid move inside the row.
          return false
        end if
        m.browseFocus = "views"
        applyFocus()
        return true
      else if m.browseFocus = "views" then
        vIdx = _browseListFocusedIndex(m.viewsList)
        vCols = _browseViewCols()
        if vIdx > 0 and (vIdx mod vCols) > 0 then
          ' Let MarkupGrid move inside the row.
          return false
        end if
        m.browseFocus = "hero_logout"
        applyFocus()
        return true
      else if m.browseFocus = "hero_continue" then
        m.browseFocus = "hero_logout"
        applyFocus()
        return true
      end if
    end if

    if kl = "right" then
      if m.browseFocus = "views" then
        vIdx = _browseListFocusedIndex(m.viewsList)
        vCount = _browseListCount(m.viewsList)
        vCols = _browseViewCols()
        if vIdx >= 0 and vCount > 0 then
          col = vIdx mod vCols
          if col < (vCols - 1) and (vIdx + 1) < vCount then
            ' Let MarkupGrid move inside the row.
            return false
          end if
        end if
        if _browseListCount(m.itemsList) <= 0 then return true
        m.browseFocus = "items"
        applyFocus()
        return true
      else if m.browseFocus = "hero_logout" then
        m.browseFocus = "hero_continue"
        applyFocus()
        return true
      end if
    end if

    if kl = "up" then
      if m.browseFocus = "views" then
        vIdx = _browseListFocusedIndex(m.viewsList)
        if vIdx < _browseViewCols() then
          m.browseFocus = "hero_logout"
          applyFocus()
          return true
        end if
      else if m.browseFocus = "items" then
        iIdx = _browseListFocusedIndex(m.itemsList)
        if iIdx < _browseItemCols() then
          m.browseFocus = "hero_continue"
          applyFocus()
          return true
        end if
      else if m.browseFocus = "hero_logout" or m.browseFocus = "hero_continue" then
        return true
      end if
    end if

    if kl = "down" then
      if m.browseFocus = "hero_logout" then
        m.browseFocus = "views"
        applyFocus()
        return true
      else if m.browseFocus = "hero_continue" then
        m.browseFocus = "views"
        applyFocus()
        return true
      else if m.browseFocus = "views" then
        vIdx = _browseListFocusedIndex(m.viewsList)
        vCount = _browseListCount(m.viewsList)
        vCols = _browseViewCols()
        nextIdx = vIdx + vCols
        if vIdx >= 0 and nextIdx < vCount then
          ' Let MarkupGrid move down if there are multiple view rows in the future.
          return false
        end if
        if _browseListCount(m.itemsList) > 0 then
          m.browseFocus = "items"
          applyFocus()
          return true
        end if
      end if
    end if

    if kl = "ok" then
      if m.browseFocus = "hero_continue" then
        _triggerHeroContinue()
        return true
      else if m.browseFocus = "hero_logout" then
        doLogout()
        return true
      end if
    end if

    if kl = "back" then
      if m.browseFocus = "items" then
        m.browseFocus = "views"
        applyFocus()
        return true
      else if m.browseFocus = "views" then
        m.browseFocus = "hero_continue"
        applyFocus()
        return true
      else if m.browseFocus = "hero_logout" or m.browseFocus = "hero_continue" then
        m.browseFocus = "views"
        applyFocus()
        return true
      end if
      setStatus("ready")
      return true
    end if
  end if

  if kl = "up" then
    if m.player <> invalid and m.player.visible = true then return false
    if m.mode = "live" or m.mode = "browse" then return false
    if m.focusIndex > 0 then m.focusIndex = m.focusIndex - 1
    applyFocus()
    return true
  end if

  if kl = "down" then
    if m.player <> invalid and m.player.visible = true then return false
    if m.mode = "live" or m.mode = "browse" then return false
    if m.focusIndex < 2 then m.focusIndex = m.focusIndex + 1
    applyFocus()
    return true
  end if

  if kl = "ok" then
    if m.player <> invalid and m.player.visible = true then
      showPlayerOverlay()
      return true
    end if
    if m.mode = "home" then
      ageMs = _nowMs() - Int(m.appStartMs)
      if ageMs >= 0 and ageMs < 1200 then
        print "[guard] ignore startup ok ageMs=" + ageMs.ToStr()
        return true
      end if
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

  if kl = "back" then
    if m.mode = "live" then
      enterBrowse()
      return true
    end if

    if m.mode = "browse" then
      if m.browseFocus = "items" then
        m.browseFocus = "views"
        applyFocus()
        return true
      else if m.browseFocus = "views" then
        m.browseFocus = "hero_continue"
        applyFocus()
        return true
      end if
      setStatus("ready")
      return true
    end if
  end if

  if kl = "options" then
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

  if kl = "play" then
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
    profileFocused = (m.browseFocus = "hero_logout")
    continueFocused = (m.browseFocus = "hero_continue")
    _syncHeroAvatarVisual()

    if m.heroAvatarBg <> invalid then
      m.heroAvatarBg.uri = "pkg:/images/overlay_circle.png"
    end if
    if m.heroAvatarText <> invalid then
      if profileFocused then
        m.heroAvatarText.color = "0xD8B765"
      else
        m.heroAvatarText.color = "0xD0D6E0"
      end if
    end if
    if m.heroPromptBtnBg <> invalid then
      if continueFocused then
        m.heroPromptBtnBg.uri = "pkg:/images/button_focus.png"
      else
        m.heroPromptBtnBg.uri = "pkg:/images/field_normal.png"
      end if
    end if
    if m.heroPromptBtnText <> invalid then
      if continueFocused then
        m.heroPromptBtnText.color = "0x0B0F16"
      else
        m.heroPromptBtnText.color = "0xD0D6E0"
      end if
    end if

    if profileFocused or continueFocused then
      if m.top <> invalid then m.top.setFocus(true)
    else if m.browseFocus = "items" then
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
    ' Home/login cards are not focusable. Ensure the Scene owns focus so OK/BACK
    ' are handled by MainScene.onKeyEvent (otherwise a hidden MarkupList can
    ' keep focus and swallow key events, breaking the keyboard dialog).
    if m.top <> invalid then m.top.setFocus(true)
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

  ' Ensure we can open KeyboardDialog via OK on login fields.
  if m.top <> invalid then m.top.setFocus(true)
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
    skipPlayingProgress = false
    if m.playbackResumePending = true and m.playbackIsLive <> true then
      targetSec = Int(m.playbackResumeTargetSec)
      if targetSec > 0 then
        skipPlayingProgress = true
        curSec = 0
        if m.player.position <> invalid then curSec = Int(m.player.position)
        if curSec < (targetSec - 5) then
          if m.player.hasField("seek") then
            m.player.seek = targetSec
            print "vod resume seek targetSec=" + targetSec.ToStr() + " currentSec=" + curSec.ToStr()
          else
            print "vod resume seek unsupported targetSec=" + targetSec.ToStr()
          end if
        else
          print "vod resume already at target currentSec=" + curSec.ToStr() + " targetSec=" + targetSec.ToStr()
        end if
      end if
      m.playbackResumePending = false
    end if
    if m.playTimeoutTimer <> invalid then m.playTimeoutTimer.control = "stop"
    if m.progressTimer <> invalid and _shouldTrackProgress() then m.progressTimer.control = "start"
    if skipPlayingProgress <> true then
      ignore = _sendProgressReport("playing", false, false)
    end if
    ' Best-effort: apply preferred tracks once playback is stable.
    applyPreferredTracks()
    _requestPlaybackSubtitleSources()
  else if st = "paused" then
    ignore = _sendProgressReport("paused", false, true)
  else if st = "stopped" then
    if m.ignoreNextStopped = true then
      m.ignoreNextStopped = false
      return
    end if
    ' When the system/player stops playback (for example after the user presses BACK
    ' while the Video UI has focus), ensure we return to our UI.
    stopPlaybackAndReturn("state_stopped")
  else if st = "finished" then
    ignore = _sendProgressReport("finished", true, true)
    stopPlaybackAndReturn("finished")
  end if
end sub

sub onPlayerDurationChanged()
  ' no-op (avoid live seek logic for sync stability)
end sub

sub onPlayerError()
  msg = m.player.errorMsg
  if msg = invalid then msg = "unknown"
  codeStr = ""
  if m.player <> invalid and m.player.hasField("errorCode") then
    ec = m.player.errorCode
    if ec <> invalid then codeStr = ec.ToStr()
  end if
  sp = m.playbackSignPath
  if sp = invalid then sp = ""
  sp = sp.ToStr().Trim()
  print "player error kind=" + m.playbackKind + " code=" + codeStr + " msg=" + msg + " signPath=" + sp
  setStatus("player error: " + msg)
  if m.playTimeoutTimer <> invalid then m.playTimeoutTimer.control = "stop"

  if m.playbackKind = "vod-r2" then
    setStatus(_t("vod_unavailable"))
  end if

  ' If multi-channel LIVE path fails, fallback to the single-channel route.
  if m.playbackIsLive = true and m.liveFallbackAttempted <> true then
    p2 = m.playbackSignPath
    if p2 = invalid then p2 = ""
    p2 = p2.ToStr().Trim()
    if Instr(1, p2, "/hls/channel/") = 1 then
      m.liveFallbackAttempted = true
      t2 = m.playbackTitle
      if t2 = invalid then t2 = ""
      t2 = t2.Trim()
      print "live error; fallback to /hls/master.m3u8 (path=" + p2 + ")"
      ' Stop without leaving UI: we're switching source.
      m.ignoreNextStopped = true
      if m.player <> invalid then m.player.control = "stop"
      if m.player <> invalid then m.player.visible = false
      signAndPlay("/hls/master.m3u8", t2)
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

  ignore = _sendProgressReport("error", false, true)
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
  if m.pendingDialog <> invalid and m.top.dialog = invalid then m.pendingDialog = invalid
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
    setStatus(_t("cancelled"))
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
  m.pendingJob = ""
  m.pendingShelfViewId = ""
  m.queuedShelfViewId = ""
  m.pendingDialog = invalid
  if m.top <> invalid then m.top.dialog = invalid
  m.settingsOpen = false
  m.overlayOpen = false
  m.uiState = "IDLE"
  m.osdFocus = "TIMELINE"
  if m.player <> invalid then
    if m.player.visible = true then m.player.control = "stop"
    m.player.visible = false
    m.player.content = invalid
  end if
  if m.playerOverlay <> invalid then m.playerOverlay.visible = false
  if m.playerSettingsModal <> invalid then m.playerSettingsModal.visible = false
  if m.logoPoster <> invalid then m.logoPoster.visible = true
  if m.titleLabel <> invalid then m.titleLabel.visible = true
  if m.loginCard <> invalid then m.loginCard.visible = true
  if m.homeCard <> invalid then m.homeCard.visible = false
  if m.browseCard <> invalid then m.browseCard.visible = false
  if m.liveCard <> invalid then m.liveCard.visible = false
  layoutCards()
  if m.top <> invalid then m.top.setFocus(true)
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
  if m.top <> invalid then m.top.setFocus(true)
  if m.hintLabel <> invalid then m.hintLabel.visible = false
  applyFocus()
  setStatus("ready")
end sub

sub enterBrowse()
  m.mode = "browse"
  m.browseFocus = "hero_continue"
  m.heroContinueAutoplayPending = false
  _syncHeroAvatarVisual()

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
    m.browseEmptyLabel.text = _t("no_items")
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
    setStatus(_t("please_wait"))
    return
  end if

  cfg = loadConfig()
  if cfg.apiBase = "" or cfg.appToken = "" or cfg.jellyfinToken = "" or cfg.userId = "" then
    setStatus("views: missing config")
    if m.browseEmptyLabel <> invalid then
      m.browseEmptyLabel.text = _t("missing_config")
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
  if _isPlaybackVisible() then
    print "[guard] ignore onViewFocused while playback visible"
    return
  end if

  if m.mode <> "browse" then return
  if m.browseFocus = "hero_continue" or m.browseFocus = "hero_logout" then return
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
    ct = ctype
    if ct = invalid then ct = ""
    ct = LCase(ct.Trim())
    if ct = "continue" then
      m.itemsTitle.text = _t("continue")
    else if ct = "top10" then
      m.itemsTitle.text = _t("top10")
    else if ct = "movies" then
      m.itemsTitle.text = _t("recent_movies")
    else if ct = "tvshows" then
      m.itemsTitle.text = _t("recent_series")
    else if ct = "livetv" then
      m.itemsTitle.text = _t("recent_live")
    else if t = "" then
      m.itemsTitle.text = _t("recent")
    else
      m.itemsTitle.text = _t("recent_prefix") + t
    end if
  end if

  if ctype = "livetv" then
    loadLivePreview()
    return
  end if

  loadShelfForView(viewId)
end sub

sub onViewSelected()
  if _isPlaybackVisible() then
    print "[guard] ignore onViewSelected while playback visible"
    return
  end if

  if m.mode <> "browse" then return
  if m.browseFocus <> "views" then return
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
    m.browseFocus = "items"
    applyFocus()
    return
  end if

  m.browseFocus = "items"
  applyFocus()
end sub

function _isShortTtlShelfId(viewId as String) as Boolean
  id = viewId
  if id = invalid then id = ""
  id = id.Trim()
  return (id = "__continue" or id = "__top10")
end function

function _shelfCacheGet(viewId as String) as Dynamic
  if m.shelfCache = invalid then return invalid
  id = viewId
  if id = invalid then id = ""
  id = id.Trim()
  if id = "" then return invalid

  entry = m.shelfCache[id]
  if entry = invalid then return invalid

  if _isShortTtlShelfId(id) then
    if type(entry) = "roAssociativeArray" then
      raw = entry.raw
      ts = entry.tsMs
      ttl = entry.ttlMs
      if raw = invalid then raw = ""
      if ts = invalid then ts = 0
      if ttl = invalid then ttl = m.shelfShortTtlMs
      age = _nowMs() - Int(ts)
      if age < Int(ttl) and raw <> "" then return raw
    end if
    m.shelfCache.Delete(id)
    return invalid
  end if

  if type(entry) = "roString" then return entry
  if type(entry) = "roAssociativeArray" and entry.raw <> invalid then return entry.raw
  return invalid
end function

sub _shelfCachePut(viewId as String, raw as String)
  if m.shelfCache = invalid then return
  id = viewId
  if id = invalid then id = ""
  id = id.Trim()
  if id = "" then return
  if raw = invalid then raw = ""
  if _isShortTtlShelfId(id) then
    m.shelfCache[id] = { raw: raw, tsMs: _nowMs(), ttlMs: m.shelfShortTtlMs }
  else
    m.shelfCache[id] = raw
  end if
end sub

sub loadShelfForView(viewId as String)
  if viewId = invalid then return
  id = viewId.Trim()
  if id = "" then return

  if m.itemsList = invalid then return

  if m.pendingJob <> "" then
    if m.pendingJob = "shelf" and m.pendingShelfViewId = id then
      return
    end if
    if m.queuedShelfViewId = id then
      return
    end if
    m.queuedShelfViewId = id
    return
  end if

  cached = _shelfCacheGet(id)
  if cached <> invalid and cached <> "" then
    if _isShortTtlShelfId(id) then print "shelf cache HIT id=" + id
    renderShelfItems(cached)
    return
  end if
  if _isShortTtlShelfId(id) then print "shelf cache MISS id=" + id

  cfg = loadConfig()
  if cfg.apiBase = "" or cfg.appToken = "" or cfg.jellyfinToken = "" or cfg.userId = "" then
    setStatus("shelf: missing config")
    if m.browseEmptyLabel <> invalid then
      m.browseEmptyLabel.text = _t("missing_config")
      m.browseEmptyLabel.visible = true
    end if
    return
  end if

  if m.browseEmptyLabel <> invalid then
    m.browseEmptyLabel.text = _t("loading")
    m.browseEmptyLabel.visible = true
  end if

  setStatus(_t("loading_items"))
  m.pendingJob = "shelf"
  m.pendingShelfViewId = id
  if id = "__continue" then
    m.gatewayTask.kind = "continue"
  else if id = "__top10" then
    m.gatewayTask.kind = "top10"
  else
    m.gatewayTask.kind = "shelf"
  end if
  m.gatewayTask.apiBase = cfg.apiBase
  m.gatewayTask.appToken = cfg.appToken
  m.gatewayTask.jellyfinToken = cfg.jellyfinToken
  m.gatewayTask.userId = cfg.userId
  if id = "__continue" then
    m.gatewayTask.parentId = ""
    m.gatewayTask.limit = 12
  else if id = "__top10" then
    m.gatewayTask.parentId = ""
    m.gatewayTask.limit = 10
  else
    m.gatewayTask.parentId = id
    m.gatewayTask.limit = 12
  end if
  m.gatewayTask.control = "run"
end sub

sub loadLivePreview()
  if m.itemsList = invalid then return
  if m.gatewayTask = invalid then return

  if m.pendingJob <> "" then
    if m.pendingJob = "live_preview" then return
    return
  end if

  cfg = loadConfig()
  if cfg.apiBase = "" or cfg.appToken = "" or cfg.jellyfinToken = "" then
    if m.browseEmptyLabel <> invalid then
      m.browseEmptyLabel.text = _t("missing_config")
      m.browseEmptyLabel.visible = true
    end if
    return
  end if

  if m.browseEmptyLabel <> invalid then
    m.browseEmptyLabel.text = _t("loading_channels")
    m.browseEmptyLabel.visible = true
  end if

  m.pendingJob = "live_preview"
  m.gatewayTask.kind = "channels"
  m.gatewayTask.apiBase = cfg.apiBase
  m.gatewayTask.appToken = cfg.appToken
  m.gatewayTask.jellyfinToken = cfg.jellyfinToken
  m.gatewayTask.userId = cfg.userId
  m.gatewayTask.control = "run"
end sub

sub renderShelfItems(raw as String)
  if m.itemsList = invalid then return

  items = ParseJson(raw)
  if type(items) <> "roArray" then items = []

  cfg = loadConfig()
  posterBase = cfg.apiBase
  posterToken = cfg.jellyfinToken

  ctype = ""
  if m.activeViewCollection <> invalid then ctype = m.activeViewCollection
  if ctype = invalid then ctype = ""
  ctype = LCase(ctype.Trim())
  isTop10 = (ctype = "top10")

  root = CreateObject("roSGNode", "ContentNode")
  rank = 0
  for each it in items
     name0 = ""
     typ0 = ""
     path0 = ""
     if it <> invalid then
       if it.name <> invalid then name0 = it.name else name0 = ""
       if it.type <> invalid then typ0 = it.type else typ0 = ""
       if it.path <> invalid then path0 = it.path else path0 = ""
     end if
     if name0 = invalid then name0 = ""
     if typ0 = invalid then typ0 = ""
     if path0 = invalid then path0 = ""

     if isTop10 then
       tl = LCase(typ0.ToStr().Trim())
       nl = LCase(name0.ToStr().Trim())
       if tl = "livetvchannel" or tl = "livetv" then
         print "top10 filter: skip live item=" + name0.ToStr()
         continue for
       end if
       if Instr(1, nl, "hdmi") > 0 then
         print "top10 filter: skip hdmi item=" + name0.ToStr()
         continue for
       end if
     end if

    c = CreateObject("roSGNode", "ContentNode")
    c.addField("itemType", "string", false)
    c.addField("path", "string", false)
    c.addField("resumePositionMs", "integer", false)
    c.addField("resumeDurationMs", "integer", false)
    c.addField("resumePercent", "integer", false)
    c.addField("rank", "integer", false)
    c.addField("posterMode", "string", false)
    c.addField("hdPosterUrl", "string", false)
    c.addField("posterUrl", "string", false)
    if it <> invalid then
      if it.id <> invalid then c.id = it.id
      c.title = name0
      c.itemType = typ0
      c.path = path0
      posterUri = _browsePosterUri(c.id, posterBase, posterToken)
      c.hdPosterUrl = posterUri
      c.posterUrl = posterUri
      c.posterMode = "zoomToFill"
      rPos = -1
      if it.positionMs <> invalid then rPos = _sceneIntFromAny(it.positionMs)
      if rPos < 0 and it.position_ms <> invalid then rPos = _sceneIntFromAny(it.position_ms)
      if rPos < 0 then rPos = 0
      c.resumePositionMs = rPos

      rDur = -1
      if it.durationMs <> invalid then rDur = _sceneIntFromAny(it.durationMs)
      if rDur < 0 and it.duration_ms <> invalid then rDur = _sceneIntFromAny(it.duration_ms)
      if rDur < 0 then rDur = 0
      c.resumeDurationMs = rDur

      rPct = -1
      if it.percent <> invalid then rPct = _sceneIntFromAny(it.percent)
      if rPct < 0 then rPct = 0
      c.resumePercent = rPct
      if isTop10 then
        rank = rank + 1
        c.rank = rank
      else
        c.rank = 0
      end if
    else
      c.title = ""
      c.itemType = ""
      c.path = ""
      c.resumePositionMs = 0
      c.resumeDurationMs = 0
      c.resumePercent = 0
      c.rank = 0
      c.posterMode = "zoomToFill"
      c.hdPosterUrl = ""
      c.posterUrl = ""
    end if
    root.appendChild(c)
  end for

  m.itemsList.content = root

  if m.heroContinueAutoplayPending = true then
    if ctype = "continue" then
      m.heroContinueAutoplayPending = false
      if root.getChildCount() > 0 then
        firstContinue = root.getChild(0)
        if firstContinue <> invalid then
          _playBrowseItemNode(firstContinue)
          return
        end if
      end if
    end if
  end if

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
    m.browseEmptyLabel.text = _t("no_items")
    m.browseEmptyLabel.visible = (root.getChildCount() = 0)
  end if
end sub

sub _playBrowseItemNode(it as Object)
  if it = invalid then return
  itemId = ""
  if it.id <> invalid then itemId = it.id
  if itemId = invalid then itemId = ""
  itemId = itemId.ToStr().Trim()

  nowMs = _nowMs()
  if itemId <> "" then
    if m.lastBrowseOpenItemId = itemId and (nowMs - Int(m.lastBrowseOpenMs)) < 1200 then
      print "browse item debounce id=" + itemId
      return
    end if
    m.lastBrowseOpenItemId = itemId
    m.lastBrowseOpenMs = nowMs
  end if

  typ = ""
  if it.hasField("itemType") then typ = it.itemType
  if typ = invalid then typ = ""
  typ = typ.Trim()
  typL = LCase(typ)

  if typL = "livetvchannel" or typL = "livetv" then
    p = ""
    if it.hasField("path") then p = it.path
    if p = invalid then p = ""
    p = p.ToStr().Trim()
    if p = "" then p = "/hls/master.m3u8"
    signAndPlay(p, it.title)
    return
  end if

  ' TODO: Implement series -> resolve next episode; for now, show a clear message.
  if typL = "series" then
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

  resumeMs = _nodeResumePositionMs(it)
  if resumeMs > 5000 then
    showResumeDialog(it.id, it.title, resumeMs)
    return
  end if

  playVodById(it.id, it.title)
end sub

sub onItemSelected()
  if _isPlaybackVisible() then
    print "[guard] ignore onItemSelected while playback visible"
    return
  end if

  if m.mode <> "browse" then return
  if m.browseFocus <> "items" then return
  if m.itemsList = invalid then return

  idx = m.itemsList.itemSelected
  if idx = invalid or idx < 0 then return

  root = m.itemsList.content
  if root = invalid then return
  it = root.getChild(idx)
  if it = invalid then return
  _playBrowseItemNode(it)
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
    setStatus(_t("please_wait"))
    return
  end if

  cfg = loadConfig()
  if cfg.apiBase = "" or cfg.appToken = "" or cfg.jellyfinToken = "" then
    setStatus(_t("missing_config"))
    if m.liveEmptyLabel <> invalid then m.liveEmptyLabel.visible = true
    return
  end if

  print "channels request..."
  setStatus(_t("loading_channels"))
  m.pendingJob = "channels"
  m.gatewayTask.kind = "channels"
  m.gatewayTask.apiBase = cfg.apiBase
  m.gatewayTask.appToken = cfg.appToken
  m.gatewayTask.jellyfinToken = cfg.jellyfinToken
  m.gatewayTask.control = "run"
end sub

sub onChannelSelected()
  if _isPlaybackVisible() then
    print "[guard] ignore onChannelSelected while playback visible"
    return
  end if

  if m.mode <> "live" then return
  if m.channelsList = invalid then return
  m.liveFallbackAttempted = false

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

  ' Some Jellyfin LiveTV channel payloads omit Path; derive our canonical route.
  chId = ""
  if item.hasField("id") then chId = item.id
  if chId <> invalid then chId = chId.ToStr()
  chId = chId.Trim()
  ' NOTE: Multi-channel LIVE (/hls/channel/<id>/master.m3u8) is not always enabled
  ' on the server yet. Avoid hard-failing with 404 by using the single-channel
  ' master until the backend route is live.
  if chId <> "" then print "live: missing channel path; using /hls/master.m3u8 (channelId=" + chId + ")"
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

  ' Keep the client simple: always request by Jellyfin itemId.
  ' The gateway can resolve legacy/human-friendly R2 keys server-side.
  return "/r2/vod/" + norm + "/master.m3u8"
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

function _vodR2PlaybackBase(apiBase as String) as String
  b = apiBase
  if b = invalid then b = ""
  b = b.Trim()
  if b = "" then return b

  ' Cloudflare Worker route intercepts api.champions.place/r2/vod/*.
  ' For Roku we need the gateway playlist rewrite + Jellyfin subtitle injection,
  ' so we bypass the Worker via api-vm.champions.place (Cloudflare Tunnel -> gateway).
  if Instr(1, b, "api.champions.place") > 0 then
    if Left(b, 8) = "https://" then return "https://api-vm.champions.place"
    if Left(b, 7) = "http://" then return "http://api-vm.champions.place"
    return "https://api-vm.champions.place"
  end if

  return b
end function

function _livePlaybackBase(apiBase as String) as String
  b = apiBase
  if b = invalid then b = ""
  b = b.Trim()
  if b = "" then return "https://api.champions.place"

  ' LIVE must go through api.champions.place so the Worker route (live-hls) can
  ' cache/serve HLS reliably. If the device is configured to use api-vm for VOD,
  ' override only for LIVE.
  if Instr(1, b, "api-vm.champions.place") > 0 then
    if Left(b, 8) = "https://" then return "https://api.champions.place"
    if Left(b, 7) = "http://" then return "http://api.champions.place"
    return "https://api.champions.place"
  end if

  return b
end function

sub beginSign(path as String, extraQuery as Object, title as String, streamFormat as String, isLive as Boolean, playbackKind as String, itemId as String)
  if m.gatewayTask = invalid then
    setStatus("gateway: missing task")
    return
  end if
  if m.pendingJob <> "" then
    setStatus(_t("please_wait"))
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
  attemptStr = ""
  if playbackKind = "vod-r2" and m.playAttemptId <> invalid then
    a = m.playAttemptId.ToStr().Trim()
    if a <> "" then attemptStr = " attempt=" + a
  end if
  print "sign start kind=" + playbackKind + attemptStr + " live=" + liveStr + " fmt=" + fmtStr + " path=" + p
  m.pendingJob = "sign"
  m.gatewayTask.kind = "sign"
  apiBase = cfg.apiBase
  if isLive = true then apiBase = _livePlaybackBase(apiBase)
  m.gatewayTask.apiBase = apiBase
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
    setStatus(_t("please_wait"))
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

  ' Enable subs preference so when subtitle tracks are available, we auto-pick.
  _ensureDefaultVodPrefs()
  m.vodPrefs.subtitlesEnabled = true
  if _normTrackToken(m.vodPrefs.subtitleKey) = "off" then m.vodPrefs.subtitleKey = ""
  _saveVodPrefs()

  hidePlayerSettings()

  ' Reload the current R2 master. This gives the gateway a fresh chance to
  ' inject EXT-X-MEDIA subtitles into the playlist.
  setStatus("vod: atualizando legendas...")

  cfg = loadConfig()
  q = m.playbackSignExtraQuery
  if type(q) <> "roAssociativeArray" then q = {}
  q["roku"] = "1"
  if cfg.jellyfinToken <> invalid and cfg.jellyfinToken.Trim() <> "" then
    q["api_key"] = cfg.jellyfinToken.Trim()
  end if

  ' Stop without exiting UI (we are switching source).
  m.ignoreNextStopped = true
  m.player.control = "stop"
  m.player.visible = false

  beginSign(m.playbackSignPath, q, t, "hls", false, "vod-r2", id)
end sub

sub requestJellyfinPlayback(itemId as String, title as String, isLive as Boolean, playbackKind as String)
  ' For Roku VOD we prefer an HLS session (transcoding enabled) so the Video node
  ' can surface multiple audio/subtitle tracks when available.
  if isLive = true then
    requestJellyfinPlayback2(itemId, title, isLive, playbackKind, true, true)
  else
    requestJellyfinPlayback2(itemId, title, false, playbackKind, true, true)
  end if
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
