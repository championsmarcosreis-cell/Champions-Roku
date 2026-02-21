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
  m.liveProgramsLoaded = false
  m.livePrograms = []
  m.liveProgramMap = {}
  m.liveProgramMapDirty = true
  m.liveChannelIndex = 0
  m.liveEpgWindowMinutes = 180
  m.liveEpgTickMinutes = 30
  m.liveEpgMinorTickMinutes = 30
  m.liveEpgWidth = 1208
  m.liveEpgGutter = 0
  m.liveEpgRowHeight = 110
  m.liveEpgRowsMax = 1
  m.liveRowStartIndex = 0
  m.liveEpgOffsetTicks = 0
  m.liveEpgStartSec = 0
  m.liveFocusSec = 0
  m.liveFocusTarget = "time"
  m.liveHeaderFocusIndex = 0
  m.liveHeaderStartSec = 0
  m.liveMaxSegments = 20
  m.liveCursorSnapToProgram = true
  m.liveGridRows = invalid
  m.liveCursorDesiredSec = 0
  m.liveDebugPrinted = false
  m.liveInputDebug = false
  m.livePerfDebug = false
  m.liveInputTrace = false
  m.keyPerfDebug = false
  m.keyPerfWarnMs = 120
  m.keyPerfHotMs = 500
  m.keyPerfSeq = 0
  m.liveInputIsolateMode = false
  m.liveInputDebugCounter = 0
  m.liveRenderPending = false
  m.liveRenderReason = ""
  m.liveRenderKeySeq = 0
  m.liveKeySeq = 0
  m.liveRenderDebug = false
  m.liveLastRenderStartSec = 0
  m.liveLastRenderChannelIndex = -1
  m.liveProgramsVersion = 0
  m.liveDateTextCached = ""
  m.liveSelectedDateSec = 0
  m.liveSelectedDateForceToday = true
  m.liveSelectedDateKey = ""
  m.autoLoginAttempted = false
  m.liveDayStripOpen = false
  m.liveDayStripIndex = 0
  m.liveDayStripDates = []
  m.liveDayStripItems = []
  m.liveDayStripBaseKey = ""
  m.liveDayStripLabelsReady = false
  m.lastPlayerState = ""
  m.devAutoplay = ""
  m.devAutoplayDone = false
  m.browseFocus = "views" ' views | items | continue | movies | series | library_search | library_items | hero_logout | hero_continue
  m.viewsGridCols = 3
  m.itemsGridCols = 3
  m.itemsGridRows = 2
  m.libraryGridCols = 3
  m.homeShelfQueue = []
  m.pendingHomeShelfSection = ""
  m.browseMoviesViewId = ""
  m.browseSeriesViewId = ""
  m.browseLibraryOpen = false
  m.browseLibraryCollection = ""
  m.browseLibraryViewId = ""
  m.browseLibraryTitle = ""
  m.browseLibrarySearch = ""
  m.browseLibraryRawItems = []
  m.pendingLibraryViewId = ""
  m.pendingLibraryLoad = false
  m.pendingLiveLoad = false
  m.browseLibraryAutoFocusPending = false
  m.activeViewId = ""
  m.activeViewCollection = ""
  m.pendingSeriesDetailItemId = ""
  m.pendingSeriesDetailTitle = ""
  m.pendingSeriesDetailQueued = false
  m.pendingSeriesDetailQueuedItemId = ""
  m.pendingSeriesDetailQueuedTitle = ""
  m.seriesDetailPlayEpisodeId = ""
  m.seriesDetailPlayEpisodeTitle = ""
  m.seriesDetailOpen = false
  m.seriesDetailFocus = "header" ' back | header | seasons | episodes | cast
  m.seriesDetailMode = "series" ' series | episode
  m.seriesDetailEpisode = {}
  m.seriesDetailIsSeries = true
  m.seriesDetailSeasonIndex = -1
  m.seriesDetailData = {}
  m.seriesDetailSeasons = []
  m.seriesDetailEpisodes = []
  m.seriesDetailCast = []
  m.seriesDetailCastCount = 0
  m.seriesDetailHasTrailer = false
  m.seriesDetailTrailerUrl = ""
  m.seriesDetailTrailerId = ""
  m.trailerEnabled = false
  m.seriesDetailHeroUri = ""
  m.seriesDetailStatus = ""
  m.seriesDetailStatusItemId = ""
  m.seriesDetailActionFocus = 0
  m.seriesDetailScrollY = 0
  m.seriesDetailContentHeight = 1840
  m.seriesDetailRowHeight = 200
  m.seriesDetailYSeasons = 1010
  m.seriesDetailYEpisodes = 1250
  m.seriesDetailYCast = 1510
  m.pendingResumeProbeItemId = ""
  m.pendingResumeProbeTitle = ""
  m.pendingResumeProbeQueued = false
  m.pendingResumeProbeQueuedItemId = ""
  m.pendingResumeProbeQueuedTitle = ""
  m.trailerLaunchInFlight = false
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
  m.pendingSignAttemptId = ""
  m.playbackStarting = false
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
  m.liveLayout = _buildLiveLayoutMetrics()
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
  print "MainScene init apiBase=" + m.apiBase + " appTokenLen=" + appTokenLen.ToStr() + " jellyfinTokenLen=" + jellyfinLen.ToStr() + " devAutoplay=" + m.devAutoplay + " uiLang=" + m.uiLang + " metaLang=" + m.metaLang + " build=2026-02-21-liveui18"

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
  m.bindFallbackDone = false
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

  m.deferredBrowseTimer = CreateObject("roSGNode", "Timer")
  if m.deferredBrowseTimer <> invalid then
    m.deferredBrowseTimer.duration = 0.2
    m.deferredBrowseTimer.repeat = false
    m.deferredBrowseTimer.observeField("fire", "onDeferredBrowseTimerFire")
    m.top.appendChild(m.deferredBrowseTimer)
  end if

  m.liveLoadRetryTimer = CreateObject("roSGNode", "Timer")
  if m.liveLoadRetryTimer <> invalid then
    m.liveLoadRetryTimer.duration = 0.3
    m.liveLoadRetryTimer.repeat = false
    m.liveLoadRetryTimer.observeField("fire", "onLiveLoadRetryFire")
    m.top.appendChild(m.liveLoadRetryTimer)
  end if

  m.liveCursorTimer = CreateObject("roSGNode", "Timer")
  if m.liveCursorTimer <> invalid then
    m.liveCursorTimer.duration = 0.08
    m.liveCursorTimer.repeat = false
    m.liveCursorTimer.observeField("fire", "onLiveCursorTimer")
    m.top.appendChild(m.liveCursorTimer)
  end if

  m.liveRenderTimer = CreateObject("roSGNode", "Timer")
  if m.liveRenderTimer <> invalid then
    m.liveRenderTimer.duration = 0.016
    m.liveRenderTimer.repeat = false
    m.liveRenderTimer.observeField("fire", "onLiveRenderTimerFire")
    m.top.appendChild(m.liveRenderTimer)
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
  m.browseHomeGroup = m.top.findNode("browseHomeGroup")
  m.libraryGroup = m.top.findNode("libraryGroup")
  m.shelvesViewport = m.top.findNode("shelvesViewport")
  m.shelvesGroup = m.top.findNode("shelvesGroup")
  m.viewsList = m.top.findNode("viewsList")
  m.itemsList = m.top.findNode("itemsList")
  m.continueList = m.top.findNode("continueList")
  m.recentMoviesList = m.top.findNode("recentMoviesList")
  m.recentSeriesList = m.top.findNode("recentSeriesList")
  m.libraryTitle = m.top.findNode("libraryTitle")
  m.librarySearchBg = m.top.findNode("librarySearchBg")
  m.librarySearchText = m.top.findNode("librarySearchText")
  m.libraryItemsList = m.top.findNode("libraryItemsList")
  m.libraryEmptyLabel = m.top.findNode("libraryEmptyLabel")
  m.browseEmptyLabel = m.top.findNode("browseEmptyLabel")
  m.viewsTitle = m.top.findNode("viewsTitle")
  m.itemsTitle = m.top.findNode("itemsTitle")
  m.continueTitle = m.top.findNode("continueTitle")
  m.recentMoviesTitle = m.top.findNode("recentMoviesTitle")
  m.recentSeriesTitle = m.top.findNode("recentSeriesTitle")
  m.heroPromptBg = m.top.findNode("heroPromptBg")
  m.heroPromptText = m.top.findNode("heroPromptText")
  m.heroPromptBtnBg = m.top.findNode("heroPromptBtnBg")
  m.heroPromptBtnText = m.top.findNode("heroPromptBtnText")
  m.heroAvatarBg = m.top.findNode("heroAvatarBg")
  m.heroAvatarPhoto = m.top.findNode("heroAvatarPhoto")
  m.heroAvatarText = m.top.findNode("heroAvatarText")
  m.seriesDetailGroup = m.top.findNode("seriesDetailGroup")
  m.seriesDetailViewport = m.top.findNode("seriesDetailViewport")
  m.seriesDetailContent = m.top.findNode("seriesDetailContent")
  m.seriesDetailBackFocus = m.top.findNode("seriesDetailBackFocus")
  m.seriesDetailBack = m.top.findNode("seriesDetailBack")
  m.seriesDetailHero = m.top.findNode("seriesDetailHero")
  m.seriesDetailPosterGlow = m.top.findNode("seriesDetailPosterGlow")
  m.seriesDetailPoster = m.top.findNode("seriesDetailPoster")
  m.seriesDetailTitle = m.top.findNode("seriesDetailTitle")
  m.seriesDetailType = m.top.findNode("seriesDetailType")
  m.seriesDetailSynopsisTitle = m.top.findNode("seriesDetailSynopsisTitle")
  m.seriesDetailGenres = m.top.findNode("seriesDetailGenres")
  m.seriesDetailOverview = m.top.findNode("seriesDetailOverview")
  m.seriesDetailRuntime = m.top.findNode("seriesDetailRuntime")
  m.seriesDetailChipsGroup = m.top.findNode("seriesDetailChips")
  m.seriesDetailChipYear = m.top.findNode("seriesDetailChipYear")
  m.seriesDetailChipYearBg = m.top.findNode("seriesDetailChipYearBg")
  m.seriesDetailChipYearText = m.top.findNode("seriesDetailChipYearText")
  m.seriesDetailChipAge = m.top.findNode("seriesDetailChipAge")
  m.seriesDetailChipAgeBg = m.top.findNode("seriesDetailChipAgeBg")
  m.seriesDetailChipAgeText = m.top.findNode("seriesDetailChipAgeText")
  m.seriesDetailChipRating = m.top.findNode("seriesDetailChipRating")
  m.seriesDetailChipRatingBg = m.top.findNode("seriesDetailChipRatingBg")
  m.seriesDetailChipRatingText = m.top.findNode("seriesDetailChipRatingText")
  m.seriesDetailChipStatus = m.top.findNode("seriesDetailChipStatus")
  m.seriesDetailChipStatusBg = m.top.findNode("seriesDetailChipStatusBg")
  m.seriesDetailChipStatusText = m.top.findNode("seriesDetailChipStatusText")
  m.seriesDetailActionStatusFocus = m.top.findNode("seriesDetailActionStatusFocus")
  m.seriesDetailActionStatusBg = m.top.findNode("seriesDetailActionStatusBg")
  m.seriesDetailActionStatusText = m.top.findNode("seriesDetailActionStatusText")
  m.seriesDetailActionTrailerFocus = m.top.findNode("seriesDetailActionTrailerFocus")
  m.seriesDetailActionTrailerBg = m.top.findNode("seriesDetailActionTrailerBg")
  m.seriesDetailActionTrailerText = m.top.findNode("seriesDetailActionTrailerText")
  m.seriesDetailSeasonsTitle = m.top.findNode("seriesDetailSeasonsTitle")
  m.seriesDetailSeasonsList = m.top.findNode("seriesDetailSeasonsList")
  m.seriesDetailEpisodesTitle = m.top.findNode("seriesDetailEpisodesTitle")
  m.seriesDetailEpisodesList = m.top.findNode("seriesDetailEpisodesList")
  m.seriesDetailCastTitle = m.top.findNode("seriesDetailCastTitle")
  m.liveTitle = m.top.findNode("liveTitle")
  m.liveDate = m.top.findNode("liveDate")
  m.seriesDetailCastList = m.top.findNode("seriesDetailCastList")
  m.seriesDetailHint = m.top.findNode("seriesDetailHint")
  _ensureBrowseNodes()
  if m.viewsList <> invalid and m.viewsList.hasField("numColumns") then
    m.viewsGridCols = _gridCols(m.viewsList.numColumns, m.viewsGridCols)
  end if
  if m.itemsList <> invalid and m.itemsList.hasField("numColumns") then
    m.itemsGridCols = _gridCols(m.itemsList.numColumns, m.itemsGridCols)
  end if
  if m.itemsList <> invalid and m.itemsList.hasField("numRows") then
    m.itemsGridRows = _gridCols(m.itemsList.numRows, m.itemsGridRows)
  end if
  if m.libraryItemsList <> invalid and m.libraryItemsList.hasField("numColumns") then
    m.libraryGridCols = _gridCols(m.libraryItemsList.numColumns, m.libraryGridCols)
  end if
  if m.shelvesViewport <> invalid then
    if m.shelvesViewport.hasField("clippingRect") then m.shelvesViewport.clippingRect = [0, 0, 1240, 452]
    if m.shelvesViewport.hasField("clipRect") then m.shelvesViewport.clipRect = [0, 0, 1240, 452]
    if m.shelvesViewport.hasField("clipChildren") then m.shelvesViewport.clipChildren = true
  end if
  m.liveCard = m.top.findNode("liveCard")
  m.liveLayoutRoot = m.top.findNode("liveLayout")
  m.liveContentLayout = m.top.findNode("liveContentLayout")
  m.channelColumn = m.top.findNode("channelColumn")
  m.channelRows = m.top.findNode("channelRows")
  m.programTrack = m.top.findNode("programTrack")
  m.timeRulerFocus = m.top.findNode("timeRulerFocus")
  m.channelListFocus = m.top.findNode("channelListFocus")
  m.gridNowLine = m.top.findNode("gridNowLine")
  m.dateStripRow = m.top.findNode("dateStripRow")
  m.dateStripLabel = m.top.findNode("dateStripLabel")
  m.agendaButton = m.top.findNode("agendaButton")
  m.agendaFocus = m.top.findNode("agendaFocus")
  m.agendaFocusLine = m.top.findNode("agendaFocusLine")
  m.agendaLabel = m.top.findNode("agendaLabel")
  m.backIcon = m.top.findNode("backIcon")
  m.backFocus = m.top.findNode("backFocus")
  m.backFocusLine = m.top.findNode("backFocusLine")
  m.dayStripOverlay = m.top.findNode("dayStripOverlay")
  m.dayStripPanel = m.top.findNode("dayStripPanel")
  m.dayStripBg = m.top.findNode("dayStripBg")
  m.dayStripRow = m.top.findNode("dayStripRow")
  m.dayStripFocus = m.top.findNode("dayStripFocus")
  m.dayItem0 = m.top.findNode("dayItem0")
  m.dayItem1 = m.top.findNode("dayItem1")
  m.dayItem2 = m.top.findNode("dayItem2")
  m.dayItem3 = m.top.findNode("dayItem3")
  m.dayItem4 = m.top.findNode("dayItem4")
  m.dayItem5 = m.top.findNode("dayItem5")
  m.dayItem6 = m.top.findNode("dayItem6")
  m.dayItemLabel0 = m.top.findNode("dayItemLabel0")
  m.dayItemLabel1 = m.top.findNode("dayItemLabel1")
  m.dayItemLabel2 = m.top.findNode("dayItemLabel2")
  m.dayItemLabel3 = m.top.findNode("dayItemLabel3")
  m.dayItemLabel4 = m.top.findNode("dayItemLabel4")
  m.dayItemLabel5 = m.top.findNode("dayItemLabel5")
  m.dayItemLabel6 = m.top.findNode("dayItemLabel6")
  m.dayItemDate0 = m.top.findNode("dayItemDate0")
  m.dayItemDate1 = m.top.findNode("dayItemDate1")
  m.dayItemDate2 = m.top.findNode("dayItemDate2")
  m.dayItemDate3 = m.top.findNode("dayItemDate3")
  m.dayItemDate4 = m.top.findNode("dayItemDate4")
  m.dayItemDate5 = m.top.findNode("dayItemDate5")
  m.dayItemDate6 = m.top.findNode("dayItemDate6")
  m.liveHeader = m.top.findNode("liveHeader")
  m.liveTimeline = m.top.findNode("liveTimeline")
  m.channelsList = m.top.findNode("channelsList")
  m.liveEmptyLabel = m.top.findNode("emptyLabel")
  m.channelsBg = m.top.findNode("channelsBg")
  m.epgGroup = m.top.findNode("epgGroup")
  m.epgBg = m.top.findNode("epgBg")
  m.epgHeader = m.top.findNode("epgHeader")
  m.epgTick0 = m.top.findNode("epgTick0")
  m.epgTick1 = m.top.findNode("epgTick1")
  m.epgTick2 = m.top.findNode("epgTick2")
  m.epgTick3 = m.top.findNode("epgTick3")
  m.epgHeaderLine = m.top.findNode("epgHeaderLine")
  m.epgNowLine = m.top.findNode("epgNowLine")
  m.epgRows = m.top.findNode("epgRows")
  _ensureLiveNodes()

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

  if m.continueList <> invalid and (m.continueObsSetup <> true) then
    m.continueList.observeField("itemSelected", "onContinueItemSelected")
    m.continueObsSetup = true
  end if

  if m.recentMoviesList <> invalid and (m.recentMoviesObsSetup <> true) then
    m.recentMoviesList.observeField("itemSelected", "onRecentMoviesItemSelected")
    m.recentMoviesObsSetup = true
  end if

  if m.recentSeriesList <> invalid and (m.recentSeriesObsSetup <> true) then
    m.recentSeriesList.observeField("itemSelected", "onRecentSeriesItemSelected")
    m.recentSeriesObsSetup = true
  end if

  if m.libraryItemsList <> invalid and (m.libraryItemsObsSetup <> true) then
    m.libraryItemsList.observeField("itemSelected", "onLibraryItemSelected")
    m.libraryItemsObsSetup = true
  end if

  if m.seriesDetailSeasonsList <> invalid and (m.seriesDetailSeasonsObsSetup <> true) then
    m.seriesDetailSeasonsList.observeField("itemSelected", "onSeriesSeasonSelected")
    m.seriesDetailSeasonsObsSetup = true
  end if

  if m.seriesDetailEpisodesList <> invalid and (m.seriesDetailEpisodesObsSetup <> true) then
    m.seriesDetailEpisodesList.observeField("itemSelected", "onSeriesEpisodeSelected")
    m.seriesDetailEpisodesObsSetup = true
  end if
  if m.seriesDetailCastList <> invalid and (m.seriesDetailCastObsSetup <> true) then
    m.seriesDetailCastList.observeField("itemSelected", "onSeriesCastSelected")
    m.seriesDetailCastObsSetup = true
  end if
end sub

function uiReady() as Boolean
  _ensureBrowseNodes()
  _ensureLiveNodes()
  return (m.loginCard <> invalid and m.homeCard <> invalid and m.browseCard <> invalid and m.viewsList <> invalid and m.itemsList <> invalid and m.continueList <> invalid and m.recentMoviesList <> invalid and m.recentSeriesList <> invalid and m.libraryItemsList <> invalid and m.liveCard <> invalid and m.hintLabel <> invalid)
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
      if _tryAutoLogin() then return
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
  if m.bindFallbackDone <> true then
    m.bindFallbackDone = true
    renderForm()
    enterLogin()
    print "UI bind fallback: continuing with login mode"
    setStatus("ready")
  end if

  ' Keep trying in the background (some firmwares materialize nodes late).
  if m.bindTimer <> invalid then
    m.bindTimer.duration = 0.5
    m.bindTimer.control = "start"
  end if
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
  if m.liveCard <> invalid then m.liveCard.translation = [0, 0]
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

  tl = LCase(t)
  if tl = "" or tl = "ready" or tl = "playing" or tl = "buffering" or tl = "stopped" or tl = "finished" then
    m.statusLabel.visible = false
    m.statusLabel.text = ""
    return
  end if

  ' Only show critical errors; hide noisy endpoint/status chatter.
  isCritical = false
  if Instr(1, tl, "failed") > 0 then isCritical = true
  if Instr(1, tl, "falhou") > 0 then isCritical = true
  if Instr(1, tl, "error") > 0 then isCritical = true
  if Instr(1, tl, "erro") > 0 then isCritical = true
  if Instr(1, tl, "missing") > 0 then isCritical = true
  if Instr(1, tl, "faltou") > 0 then isCritical = true
  if Instr(1, tl, "indispon") > 0 then isCritical = true
  if Instr(1, tl, "expired") > 0 then isCritical = true
  if Instr(1, tl, "expir") > 0 then isCritical = true

  if isCritical then
    m.statusLabel.visible = true
    m.statusLabel.text = t
  else
    m.statusLabel.visible = false
    m.statusLabel.text = ""
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

function _nowEpochSec() as Integer
  dt = CreateObject("roDateTime")
  if dt = invalid then return Int(_nowMs() / 1000)
  return Int(dt.AsSeconds())
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
        library_search_hint: "Search"
        library_search_prefix: "Search: "
        library_search_title: "Search library"
        library_no_results: "No results"
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
        vod_processing_msg: "We are processing this content. It will be available soon."
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
        loading_details: "loading details..."
        details_failed: "Failed to load details"
        play_first_episode: "Play first episode"
        close: "Close"
        series_no_overview: "No synopsis available."
        series_seasons: "Seasons"
        series_episodes: "Episodes"
        series_cast: "Cast & crew"
        detail_back: "Detail"
        detail_trailer: "Trailer"
        detail_processing: "Processing"
        detail_play: "Play"
        detail_series: "Series"
        detail_movie: "Movie"
        detail_episode: "Episode"
        detail_runtime: "Runtime:"
        detail_synopsis: "Synopsis"
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
        library_search_hint: "Buscar"
        library_search_prefix: "Buscar: "
        library_search_title: "Buscar na biblioteca"
        library_no_results: "Sem resultados"
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
        vod_processing_msg: "Estamos processando este conteudo. Em breve estara disponivel."
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
        loading_details: "carregando detalhes..."
        details_failed: "Falhou ao carregar detalhes"
        play_first_episode: "Assistir primeiro episodio"
        close: "Fechar"
        series_no_overview: "Sem sinopse disponivel."
        series_seasons: "Temporadas"
        series_episodes: "Episodios"
        series_cast: "Elenco e equipe"
        detail_back: "Detalhe"
        detail_trailer: "Trailer"
        detail_processing: "Processando"
        detail_play: "Assistir"
        detail_series: "Serie"
        detail_movie: "Filme"
        detail_episode: "Episodio"
        detail_runtime: "Runtime:"
        detail_synopsis: "Sinopse"
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
        library_search_hint: "Buscar"
        library_search_prefix: "Buscar: "
        library_search_title: "Buscar en biblioteca"
        library_no_results: "Sin resultados"
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
        vod_processing_msg: "Estamos procesando este contenido. Estara disponible pronto."
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
        loading_details: "cargando detalles..."
        details_failed: "Fallo al cargar detalles"
        play_first_episode: "Ver primer episodio"
        close: "Cerrar"
        series_no_overview: "Sin sinopsis disponible."
        series_seasons: "Temporadas"
        series_episodes: "Episodios"
        series_cast: "Elenco y equipo"
        detail_back: "Detalle"
        detail_trailer: "Trailer"
        detail_processing: "Procesando"
        detail_play: "Reproducir"
        detail_series: "Serie"
        detail_movie: "Película"
        detail_episode: "Episodio"
        detail_runtime: "Runtime:"
        detail_synopsis: "Sinopsis"
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
        library_search_hint: "Cerca"
        library_search_prefix: "Cerca: "
        library_search_title: "Cerca nella libreria"
        library_no_results: "Nessun risultato"
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
        vod_processing_msg: "Stiamo elaborando questo contenuto. Sara disponibile a breve."
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
        loading_details: "caricamento dettagli..."
        details_failed: "Caricamento dettagli fallito"
        play_first_episode: "Guarda primo episodio"
        close: "Chiudi"
        series_no_overview: "Sinossi non disponibile."
        series_seasons: "Stagioni"
        series_episodes: "Episodi"
        series_cast: "Cast e crew"
        detail_back: "Dettaglio"
        detail_trailer: "Trailer"
        detail_processing: "In elaborazione"
        detail_play: "Guarda"
        detail_series: "Serie"
        detail_movie: "Film"
        detail_episode: "Episodio"
        detail_runtime: "Runtime:"
        detail_synopsis: "Sinossi"
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
  if m.itemsTitle <> invalid then m.itemsTitle.text = _t("top10")
  if m.continueTitle <> invalid then m.continueTitle.text = _t("resume_title")
  if m.recentMoviesTitle <> invalid then m.recentMoviesTitle.text = _t("recent_movies")
  if m.recentSeriesTitle <> invalid then m.recentSeriesTitle.text = _t("recent_series")
  if m.seriesDetailBack <> invalid then m.seriesDetailBack.text = "< " + _t("detail_back")
  if m.seriesDetailSynopsisTitle <> invalid then m.seriesDetailSynopsisTitle.text = _t("detail_synopsis")
  if m.seriesDetailSeasonsTitle <> invalid then m.seriesDetailSeasonsTitle.text = _t("series_seasons")
  if m.seriesDetailEpisodesTitle <> invalid then m.seriesDetailEpisodesTitle.text = _t("series_episodes")
  if m.seriesDetailCastTitle <> invalid then m.seriesDetailCastTitle.text = _t("series_cast")
  if m.seriesDetailActionTrailerText <> invalid then m.seriesDetailActionTrailerText.text = _t("detail_trailer")
  if m.heroPromptText <> invalid then m.heroPromptText.text = _t("hero_continue_text")
  if m.heroPromptBtnText <> invalid then m.heroPromptBtnText.text = _t("hero_continue_cta")
  _refreshBrowseLibraryHeader()
  if m.libraryEmptyLabel <> invalid and m.libraryEmptyLabel.visible <> true then
    m.libraryEmptyLabel.text = _t("no_items")
  end if
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

function _browseItemRows() as Integer
  return _gridCols(m.itemsGridRows, 1)
end function

function _browseLibraryCols() as Integer
  return _gridCols(m.libraryGridCols, 3)
end function

function _browseSectionHasItems(section as String) as Boolean
  s = section
  if s = invalid then s = ""
  s = LCase(s.Trim())
  if s = "items" then return (_browseListCount(m.itemsList) > 0)
  if s = "continue" then return (_browseListCount(m.continueList) > 0)
  if s = "movies" then return (_browseListCount(m.recentMoviesList) > 0)
  if s = "series" then return (_browseListCount(m.recentSeriesList) > 0)
  return false
end function

function _browseNextShelfSection(cur as String) as String
  if cur = "items" then
    if _browseSectionHasItems("continue") then return "continue"
    if _browseSectionHasItems("movies") then return "movies"
    if _browseSectionHasItems("series") then return "series"
    return ""
  end if
  if cur = "continue" then
    if _browseSectionHasItems("movies") then return "movies"
    if _browseSectionHasItems("series") then return "series"
    return ""
  end if
  if cur = "movies" then
    if _browseSectionHasItems("series") then return "series"
    return ""
  end if
  return ""
end function

function _browsePrevShelfSection(cur as String) as String
  if cur = "continue" then
    if _browseSectionHasItems("items") then return "items"
    return ""
  end if
  if cur = "movies" then
    if _browseSectionHasItems("continue") then return "continue"
    if _browseSectionHasItems("items") then return "items"
    return ""
  end if
  if cur = "series" then
    if _browseSectionHasItems("movies") then return "movies"
    if _browseSectionHasItems("continue") then return "continue"
    if _browseSectionHasItems("items") then return "items"
    return ""
  end if
  return ""
end function

function _browseSectionForCollection(collectionType as String) as String
  ct = collectionType
  if ct = invalid then ct = ""
  ct = LCase(ct.Trim())
  if ct = "movies" then return "movies"
  if ct = "tvshows" then return "series"
  if ct = "top10" then return "items"
  if ct = "continue" then return "continue"
  return "items"
end function

function _browseListNodeForFocus(focusName as String) as Object
  f = focusName
  if f = invalid then f = ""
  f = LCase(f.Trim())
  if f = "items" then return m.itemsList
  if f = "continue" then return m.continueList
  if f = "movies" then return m.recentMoviesList
  if f = "series" then return m.recentSeriesList
  if f = "library_items" then return m.libraryItemsList
  return invalid
end function

sub _setBrowseLibraryVisible(open as Boolean)
  showLibrary = (open = true)
  if m.browseHomeGroup = invalid or m.libraryGroup = invalid then
    bindUiNodes()
    _ensureBrowseNodes()
  end if
  if m.browseHomeGroup <> invalid then m.browseHomeGroup.visible = (showLibrary <> true)
  if m.libraryGroup <> invalid then m.libraryGroup.visible = showLibrary
  if showLibrary then
    if m.browseEmptyLabel <> invalid then m.browseEmptyLabel.visible = false
  else
    if m.libraryEmptyLabel <> invalid then m.libraryEmptyLabel.visible = false
  end if
end sub

sub _refreshBrowseLibraryHeader()
  titleTxt = m.browseLibraryTitle
  if titleTxt = invalid then titleTxt = ""
  titleTxt = titleTxt.ToStr().Trim()
  if titleTxt = "" then
    c = m.browseLibraryCollection
    if c = invalid then c = ""
    c = LCase(c.ToStr().Trim())
    if c = "tvshows" then
      titleTxt = _t("library_series")
    else if c = "movies" then
      titleTxt = _t("library_movies")
    else
      titleTxt = _t("libraries")
    end if
  end if
  if m.libraryTitle <> invalid then m.libraryTitle.text = titleTxt

  q = m.browseLibrarySearch
  if q = invalid then q = ""
  q = q.ToStr().Trim()
  if m.librarySearchText <> invalid then
    if q = "" then
      m.librarySearchText.text = _t("library_search_hint")
      m.librarySearchText.color = "0xAAB4C2"
    else
      m.librarySearchText.text = _t("library_search_prefix") + q
      m.librarySearchText.color = "0xE6EBF3"
    end if
  end if
end sub

function _hasDeferredBrowseActions() as Boolean
  if m.pendingLibraryLoad = true then return true
  if m.pendingSeriesDetailQueued = true then return true
  if m.pendingResumeProbeQueued = true then return true
  return false
end function

sub _scheduleDeferredBrowseActions()
  if _hasDeferredBrowseActions() <> true then return
  if m.deferredBrowseTimer <> invalid then
    m.deferredBrowseTimer.control = "start"
  else
    _runDeferredBrowseActions()
  end if
end sub

sub _runDeferredBrowseActions()
  if _hasDeferredBrowseActions() <> true then return

  if m.playbackStarting = true or (m.player <> invalid and m.player.visible = true) then
    if m.deferredBrowseTimer <> invalid then m.deferredBrowseTimer.control = "start"
    return
  end if

  if m.pendingJob <> "" then
    if m.deferredBrowseTimer <> invalid then m.deferredBrowseTimer.control = "start"
    return
  end if

  if m.pendingLibraryLoad = true then
    m.pendingLibraryLoad = false
    _loadBrowseLibraryItems()
    if m.pendingJob <> "" then return
  end if

  if m.pendingSeriesDetailQueued = true then
    qId = m.pendingSeriesDetailQueuedItemId
    qTitle = m.pendingSeriesDetailQueuedTitle
    m.pendingSeriesDetailQueued = false
    m.pendingSeriesDetailQueuedItemId = ""
    m.pendingSeriesDetailQueuedTitle = ""
    requestSeriesDetails(qId, qTitle)
    if m.pendingJob <> "" then return
  end if

  if m.pendingResumeProbeQueued = true then
    rId = m.pendingResumeProbeQueuedItemId
    rTitle = m.pendingResumeProbeQueuedTitle
    m.pendingResumeProbeQueued = false
    m.pendingResumeProbeQueuedItemId = ""
    m.pendingResumeProbeQueuedTitle = ""
    requestResumeProbe(rId, rTitle)
  end if
end sub

sub onDeferredBrowseTimerFire()
  _runDeferredBrowseActions()
end sub

sub _scheduleLiveLoadRetry()
  if m.liveLoadRetryTimer <> invalid then
    m.liveLoadRetryTimer.control = "start"
  end if
end sub

sub onLiveLoadRetryFire()
  if m.pendingLiveLoad <> true then return
  if m.mode <> "live" then
    m.pendingLiveLoad = false
    return
  end if
  if m.pendingJob <> "" then
    print "channels retry wait: pendingJob=" + m.pendingJob
    _scheduleLiveLoadRetry()
    return
  end if
  print "channels retry: requesting now"
  loadChannels()
end sub

function _nodeTranslationY(node as Object, fallback as Integer) as Integer
  if node = invalid then return fallback
  tr = node.translation
  if type(tr) = "roArray" and tr.Count() >= 2 then
    return _sceneIntFromAny(tr[1])
  end if
  return fallback
end function

sub _applyBrowseShelfScroll()
  if m.shelvesGroup = invalid then return

  anchorY = _nodeTranslationY(m.itemsList, 38)
  focusKey = m.browseFocus
  if focusKey = invalid then focusKey = ""
  focusKey = LCase(focusKey.ToStr().Trim())

  targetNode = m.itemsList
  if focusKey = "continue" and _browseSectionHasItems("continue") then
    targetNode = m.continueList
  else if focusKey = "movies" and _browseSectionHasItems("movies") then
    targetNode = m.recentMoviesList
  else if focusKey = "series" and _browseSectionHasItems("series") then
    targetNode = m.recentSeriesList
  end if

  targetY = _nodeTranslationY(targetNode, anchorY)
  if targetY < anchorY then targetY = anchorY
  m.shelvesGroup.translation = [0, anchorY - targetY]
end sub

sub _syncHeroAvatarVisual()
  if m.heroAvatarText = invalid then return
  label = "A"
  txt = ""
  if m.form <> invalid and m.form.username <> invalid then txt = m.form.username.ToStr()
  txt = txt.Trim()
  if txt <> "" then
    ch = UCase(Left(txt, 1))
    if Asc(ch) >= 65 and Asc(ch) <= 90 then label = ch
  end if
  m.heroAvatarText.text = label
  m.heroAvatarText.visible = true
  if m.heroAvatarPhoto <> invalid then
    m.heroAvatarPhoto.visible = false
    m.heroAvatarPhoto.uri = ""
  end if
end sub

sub _triggerHeroContinue()
  if m.mode <> "browse" then return
  if m.pendingJob <> "" and m.pendingJob <> "home_shelf" then
    print "hero continue pending job=" + m.pendingJob
    return
  end if
  if m.pendingJob = "home_shelf" then
    if m.continueList = invalid then
      print "hero continue waiting shelves"
      return
    end if
    rootWait = m.continueList.content
    if rootWait = invalid or rootWait.getChildCount() <= 0 then
      print "hero continue waiting shelves"
      return
    end if
  end if
  if m.heroContinueAutoplayPending = true then
    print "hero continue pending"
    return
  end if
  if m.pendingJob = "shelf" and m.pendingShelfViewId = "__continue" then
    print "hero continue pending"
    return
  end if
  if m.queuedShelfViewId = "__continue" then
    print "hero continue queued"
    return
  end if
  nowMs = _nowMs()
  if nowMs - Int(m.lastHeroContinueMs) < 1200 then
    print "hero continue debounce"
    return
  end if
  m.lastHeroContinueMs = nowMs

  if m.continueList <> invalid then
    root = m.continueList.content
    if root <> invalid and root.getChildCount() > 0 then
      first = root.getChild(0)
      if first <> invalid then
        _playBrowseItemNode(first)
        return
      end if
    end if
  end if

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
    q["api_key"] = tok
    q["X-Emby-Token"] = tok
    q["X-Jellyfin-Token"] = tok
  end if
  return appendQuery(u, q)
end function

function _browseBackdropUri(itemId as String, apiBase as String, jellyfinToken as String, tag as String) as String
  id = itemId
  if id = invalid then id = ""
  id = id.ToStr().Trim()
  if id = "" then return ""

  base = apiBase
  if base = invalid then base = ""
  base = base.ToStr().Trim()
  if base = "" then return ""
  if Right(base, 1) = "/" then base = Left(base, Len(base) - 1)

  u = base + "/jellyfin/Items/" + id + "/Images/Backdrop/0"
  q = {
    maxWidth: "1280"
    quality: "85"
  }
  tg = tag
  if tg = invalid then tg = ""
  tg = tg.ToStr().Trim()
  if tg <> "" then q["tag"] = tg

  tok = jellyfinToken
  if tok = invalid then tok = ""
  tok = tok.ToStr().Trim()
  if tok <> "" then
    q["X-Emby-Token"] = tok
    q["X-Jellyfin-Token"] = tok
  end if
  return appendQuery(u, q)
end function

function _minutesFromTicks(raw as Dynamic) as Integer
  if raw = invalid then return 0
  s = raw.ToStr().Trim()
  if s = "" then return 0
  t = Val(s)
  if t <= 0 then return 0
  mins = Int(t / 600000000)
  if mins < 0 then mins = 0
  return mins
end function

function _formatRating(raw as Dynamic) as String
  if raw = invalid then return ""
  s = raw.ToStr().Trim()
  if s = "" then return ""
  v = Val(s)
  if v <= 0 then return ""
  scaled = Int((v * 10) + 0.5)
  whole = Int(scaled / 10)
  frac = scaled - (whole * 10)
  if frac < 0 then frac = 0
  return whole.ToStr() + "." + frac.ToStr()
end function

function _seriesGenresText(raw as Dynamic) as String
  if raw = invalid then return ""
  if type(raw) = "roArray" then
    parts = []
    for each g in raw
      if g = invalid then
        continue for
      end if
      t = g.ToStr().Trim()
      if t <> "" then parts.Push(t)
    end for
    return _seriesJoin(parts, " • ")
  end if
  return raw.ToStr().Trim()
end function

sub _setDetailChip(chip as Object, bg as Object, label as Object, text as String)
  if chip = invalid then return
  t = text
  if t = invalid then t = ""
  t = t.ToStr().Trim()
  if t = "" then
    chip.visible = false
    return
  end if

  chip.visible = true
  if label <> invalid then label.text = t

  w = 20 + (Len(t) * 8)
  if w < 50 then w = 50
  if w > 160 then w = 160
  if bg <> invalid then bg.width = w
  if label <> invalid then label.width = w
end sub

sub _layoutDetailChips()
  if m.seriesDetailChipsGroup = invalid then return

  chips = [
    { g: m.seriesDetailChipYear, bg: m.seriesDetailChipYearBg },
    { g: m.seriesDetailChipAge, bg: m.seriesDetailChipAgeBg },
    { g: m.seriesDetailChipRating, bg: m.seriesDetailChipRatingBg },
    { g: m.seriesDetailChipStatus, bg: m.seriesDetailChipStatusBg }
  ]

  x = 0
  pad = 10
  hasAny = false
  for each c in chips
    g = c.g
    if g = invalid or g.visible <> true then
      continue for
    end if
    hasAny = true
    w = 0
    if c.bg <> invalid and c.bg.width <> invalid then w = Int(c.bg.width)
    g.translation = [x, 0]
    x = x + w + pad
  end for

  m.seriesDetailChipsGroup.visible = hasAny
end sub

sub _applySeriesDetailStatus(status as String)
  s = status
  if s = invalid then s = ""
  s = UCase(s.Trim())
  m.seriesDetailStatus = s

  isProcessing = (s = "PROCESSING")
  txt = _t("detail_play")
  if isProcessing then txt = _t("detail_processing")

  if m.seriesDetailChipStatus <> invalid then
    m.seriesDetailChipStatus.visible = false
  end if
  if m.seriesDetailChipStatusBg <> invalid then m.seriesDetailChipStatusBg.visible = false
  if m.seriesDetailChipStatusText <> invalid then m.seriesDetailChipStatusText.text = ""
  _layoutDetailChips()

  if m.seriesDetailActionStatusBg <> invalid then m.seriesDetailActionStatusBg.visible = true
  if m.seriesDetailActionStatusText <> invalid then
    m.seriesDetailActionStatusText.visible = true
    m.seriesDetailActionStatusText.text = txt
  end if

  _applySeriesDetailActionFocus()
end sub

sub _applySeriesDetailActionFocus()
  focus = m.seriesDetailFocus
  if focus = invalid then focus = ""
  headerFocused = (m.seriesDetailOpen = true and LCase(focus.ToStr()) = "header")
  statusVisible = false
  if m.seriesDetailActionStatusBg <> invalid and m.seriesDetailActionStatusBg.visible = true then
    statusVisible = true
  end if
  trailerVisible = (m.seriesDetailHasTrailer = true)

  if headerFocused then
    if trailerVisible <> true then
      m.seriesDetailActionFocus = 0
    end if
  end if

  if m.seriesDetailActionStatusFocus <> invalid then
    m.seriesDetailActionStatusFocus.visible = (headerFocused and m.seriesDetailActionFocus = 0)
  end if
  if m.seriesDetailActionTrailerFocus <> invalid then
    m.seriesDetailActionTrailerFocus.visible = (headerFocused and trailerVisible and m.seriesDetailActionFocus = 1)
  end if
end sub

sub _playSeriesDetailPrimary()
  if m.seriesDetailOpen <> true then return

  modeVal = m.seriesDetailMode
  if modeVal = invalid then modeVal = ""
  isEpisodeMode = (LCase(modeVal.ToStr().Trim()) = "episode")

  data = m.seriesDetailData
  if type(data) <> "roAssociativeArray" then data = {}
  series = data.series
  if type(series) <> "roAssociativeArray" then series = {}

  id = ""
  title = ""

  if isEpisodeMode then
    if m.seriesDetailStatusItemId <> invalid then id = m.seriesDetailStatusItemId
    if id = invalid or id = "" then
      ep = m.seriesDetailEpisode
      if type(ep) <> "roAssociativeArray" then ep = {}
      if ep.id <> invalid then id = ep.id
      if id = "" and ep.Id <> invalid then id = ep.Id
    end if
    if m.seriesDetailTitle <> invalid and m.seriesDetailTitle.text <> invalid then title = m.seriesDetailTitle.text
  else if m.seriesDetailIsSeries = true then
    if data.firstEpisodeId <> invalid then id = data.firstEpisodeId
    if data.firstEpisodeTitle <> invalid then title = data.firstEpisodeTitle
  else
    if series.id <> invalid then id = series.id
    if id = "" and series.Id <> invalid then id = series.Id
    if series.name <> invalid then title = series.name
  end if

  if id = invalid then id = ""
  id = id.ToStr().Trim()
  if id = "" then return

  if title = invalid then title = ""
  title = title.ToStr().Trim()
  if title = "" and m.seriesDetailTitle <> invalid and m.seriesDetailTitle.text <> invalid then
    title = m.seriesDetailTitle.text.ToStr().Trim()
  end if

  requestResumeProbe(id, title)
end sub

sub _applySeriesDetailBackFocus()
  if m.seriesDetailBackFocus = invalid then return
  focus = m.seriesDetailFocus
  if focus = invalid then focus = ""
  isBack = (m.seriesDetailOpen = true and LCase(focus.ToStr()) = "back")
  m.seriesDetailBackFocus.visible = isBack
end sub

sub _setSeriesDetailScroll(targetY as Integer)
  if m.seriesDetailContent = invalid then return

  maxScroll = m.seriesDetailContentHeight - 720
  if maxScroll < 0 then maxScroll = 0

  y = targetY
  if y < 0 then y = 0
  if y > maxScroll then y = maxScroll

  m.seriesDetailScrollY = y
  m.seriesDetailContent.translation = [0, -y]
end sub

sub _ensureSeriesDetailVisible(itemY as Integer, itemH as Integer)
  topPad = 80
  bottomPad = 80

  viewTop = m.seriesDetailScrollY
  viewBottom = viewTop + 720

  itTop = itemY
  itBottom = itemY + itemH

  if (itBottom + bottomPad) > viewBottom then
    viewTop = (itBottom + bottomPad) - 720
  else if (itTop - topPad) < viewTop then
    viewTop = itTop - topPad
  end if

  _setSeriesDetailScroll(viewTop)
end sub

function _browseChannelPosterUri(channelId as String, apiBase as String, jellyfinToken as String) as String
  return _browseChannelImageUri(channelId, apiBase, jellyfinToken, "Primary")
end function

function _browseChannelImageUri(channelId as String, apiBase as String, jellyfinToken as String, imageType as String) as String
  id = channelId
  if id = invalid then id = ""
  id = id.ToStr().Trim()
  if id = "" then return ""

  base = apiBase
  if base = invalid then base = ""
  base = base.ToStr().Trim()
  if base = "" then return ""
  if Right(base, 1) = "/" then base = Left(base, Len(base) - 1)

  imgType = imageType
  if imgType = invalid then imgType = ""
  imgType = imgType.ToStr().Trim()
  if imgType = "" then imgType = "Primary"

  u = base + "/jellyfin/Items/" + id + "/Images/" + imgType
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

  nodes = [m.viewsList, m.itemsList]
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
  if _ensurePlayerOverlayNodes() <> true then return
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
  if _ensurePlayerSettingsNodes() <> true then return
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

function _ensureBrowseNodes() as Boolean
  if m.browseCard = invalid then
    m.browseCard = m.top.findNode("browseCard")
  end if
  if m.browseCard <> invalid then
    if m.browseHomeGroup = invalid then m.browseHomeGroup = m.browseCard.findNode("browseHomeGroup")
    if m.libraryGroup = invalid then m.libraryGroup = m.browseCard.findNode("libraryGroup")
    if m.shelvesViewport = invalid then m.shelvesViewport = m.browseCard.findNode("shelvesViewport")
    if m.shelvesGroup = invalid then m.shelvesGroup = m.browseCard.findNode("shelvesGroup")
    if m.viewsList = invalid then m.viewsList = m.browseCard.findNode("viewsList")
    if m.itemsList = invalid then m.itemsList = m.browseCard.findNode("itemsList")
    if m.continueList = invalid then m.continueList = m.browseCard.findNode("continueList")
    if m.recentMoviesList = invalid then m.recentMoviesList = m.browseCard.findNode("recentMoviesList")
    if m.recentSeriesList = invalid then m.recentSeriesList = m.browseCard.findNode("recentSeriesList")
    if m.libraryTitle = invalid then m.libraryTitle = m.browseCard.findNode("libraryTitle")
    if m.librarySearchBg = invalid then m.librarySearchBg = m.browseCard.findNode("librarySearchBg")
    if m.librarySearchText = invalid then m.librarySearchText = m.browseCard.findNode("librarySearchText")
    if m.libraryItemsList = invalid then m.libraryItemsList = m.browseCard.findNode("libraryItemsList")
    if m.libraryEmptyLabel = invalid then m.libraryEmptyLabel = m.browseCard.findNode("libraryEmptyLabel")
    if m.browseEmptyLabel = invalid then m.browseEmptyLabel = m.browseCard.findNode("browseEmptyLabel")
    if m.viewsTitle = invalid then m.viewsTitle = m.browseCard.findNode("viewsTitle")
    if m.itemsTitle = invalid then m.itemsTitle = m.browseCard.findNode("itemsTitle")
    if m.continueTitle = invalid then m.continueTitle = m.browseCard.findNode("continueTitle")
    if m.recentMoviesTitle = invalid then m.recentMoviesTitle = m.browseCard.findNode("recentMoviesTitle")
    if m.recentSeriesTitle = invalid then m.recentSeriesTitle = m.browseCard.findNode("recentSeriesTitle")
    if m.heroPromptBg = invalid then m.heroPromptBg = m.browseCard.findNode("heroPromptBg")
    if m.heroPromptText = invalid then m.heroPromptText = m.browseCard.findNode("heroPromptText")
    if m.heroPromptBtnBg = invalid then m.heroPromptBtnBg = m.browseCard.findNode("heroPromptBtnBg")
    if m.heroPromptBtnText = invalid then m.heroPromptBtnText = m.browseCard.findNode("heroPromptBtnText")
    if m.heroAvatarBg = invalid then m.heroAvatarBg = m.browseCard.findNode("heroAvatarBg")
    if m.heroAvatarPhoto = invalid then m.heroAvatarPhoto = m.browseCard.findNode("heroAvatarPhoto")
    if m.heroAvatarText = invalid then m.heroAvatarText = m.browseCard.findNode("heroAvatarText")
  end if
  return (m.browseCard <> invalid and m.viewsList <> invalid)
end function

function _ensureLiveNodes() as Boolean
  if m.liveCard = invalid then m.liveCard = m.top.findNode("liveCard")
  if m.liveCard <> invalid then
    if m.liveLayoutRoot = invalid then m.liveLayoutRoot = m.liveCard.findNode("liveLayout")
    if m.liveContentLayout = invalid then m.liveContentLayout = m.liveCard.findNode("liveContentLayout")
    if m.channelColumn = invalid then m.channelColumn = m.liveCard.findNode("channelColumn")
    if m.channelRows = invalid then m.channelRows = m.liveCard.findNode("channelRows")
    if m.programTrack = invalid then m.programTrack = m.liveCard.findNode("programTrack")
    if m.timeRulerFocus = invalid then m.timeRulerFocus = m.liveCard.findNode("timeRulerFocus")
    if m.channelListFocus = invalid then m.channelListFocus = m.liveCard.findNode("channelListFocus")
    if m.gridNowLine = invalid then m.gridNowLine = m.liveCard.findNode("gridNowLine")
    if m.dateStripRow = invalid then m.dateStripRow = m.liveCard.findNode("dateStripRow")
    if m.dateStripLabel = invalid then m.dateStripLabel = m.liveCard.findNode("dateStripLabel")
    if m.agendaButton = invalid then m.agendaButton = m.liveCard.findNode("agendaButton")
    if m.agendaFocus = invalid then m.agendaFocus = m.liveCard.findNode("agendaFocus")
    if m.agendaLabel = invalid then m.agendaLabel = m.liveCard.findNode("agendaLabel")
    if m.backIcon = invalid then m.backIcon = m.liveCard.findNode("backIcon")
    if m.backFocus = invalid then m.backFocus = m.liveCard.findNode("backFocus")
    if m.dayStripOverlay = invalid then m.dayStripOverlay = m.liveCard.findNode("dayStripOverlay")
    if m.dayStripPanel = invalid then m.dayStripPanel = m.liveCard.findNode("dayStripPanel")
    if m.dayStripBg = invalid then m.dayStripBg = m.liveCard.findNode("dayStripBg")
    if m.dayStripRow = invalid then m.dayStripRow = m.liveCard.findNode("dayStripRow")
    if m.dayStripFocus = invalid then m.dayStripFocus = m.liveCard.findNode("dayStripFocus")
    if m.dayItem0 = invalid then m.dayItem0 = m.liveCard.findNode("dayItem0")
    if m.dayItem1 = invalid then m.dayItem1 = m.liveCard.findNode("dayItem1")
    if m.dayItem2 = invalid then m.dayItem2 = m.liveCard.findNode("dayItem2")
    if m.dayItem3 = invalid then m.dayItem3 = m.liveCard.findNode("dayItem3")
    if m.dayItem4 = invalid then m.dayItem4 = m.liveCard.findNode("dayItem4")
    if m.dayItem5 = invalid then m.dayItem5 = m.liveCard.findNode("dayItem5")
    if m.dayItem6 = invalid then m.dayItem6 = m.liveCard.findNode("dayItem6")
    if m.dayItemLabel0 = invalid then m.dayItemLabel0 = m.liveCard.findNode("dayItemLabel0")
    if m.dayItemLabel1 = invalid then m.dayItemLabel1 = m.liveCard.findNode("dayItemLabel1")
    if m.dayItemLabel2 = invalid then m.dayItemLabel2 = m.liveCard.findNode("dayItemLabel2")
    if m.dayItemLabel3 = invalid then m.dayItemLabel3 = m.liveCard.findNode("dayItemLabel3")
    if m.dayItemLabel4 = invalid then m.dayItemLabel4 = m.liveCard.findNode("dayItemLabel4")
    if m.dayItemLabel5 = invalid then m.dayItemLabel5 = m.liveCard.findNode("dayItemLabel5")
    if m.dayItemLabel6 = invalid then m.dayItemLabel6 = m.liveCard.findNode("dayItemLabel6")
    if m.dayItemDate0 = invalid then m.dayItemDate0 = m.liveCard.findNode("dayItemDate0")
    if m.dayItemDate1 = invalid then m.dayItemDate1 = m.liveCard.findNode("dayItemDate1")
    if m.dayItemDate2 = invalid then m.dayItemDate2 = m.liveCard.findNode("dayItemDate2")
    if m.dayItemDate3 = invalid then m.dayItemDate3 = m.liveCard.findNode("dayItemDate3")
    if m.dayItemDate4 = invalid then m.dayItemDate4 = m.liveCard.findNode("dayItemDate4")
    if m.dayItemDate5 = invalid then m.dayItemDate5 = m.liveCard.findNode("dayItemDate5")
    if m.dayItemDate6 = invalid then m.dayItemDate6 = m.liveCard.findNode("dayItemDate6")
    if m.liveHeader = invalid then m.liveHeader = m.liveCard.findNode("liveHeader")
    if m.liveTimeline = invalid then m.liveTimeline = m.liveCard.findNode("liveTimeline")
    if m.channelsList = invalid then m.channelsList = m.liveCard.findNode("channelsList")
    if m.liveEmptyLabel = invalid then m.liveEmptyLabel = m.liveCard.findNode("emptyLabel")
    if m.liveTitle = invalid then m.liveTitle = m.liveCard.findNode("liveTitle")
    if m.liveDate = invalid then m.liveDate = m.liveCard.findNode("liveDate")
    if m.epgGroup = invalid then m.epgGroup = m.liveCard.findNode("epgGroup")
    if m.epgBg = invalid then m.epgBg = m.liveCard.findNode("epgBg")
    if m.epgHeader = invalid then m.epgHeader = m.liveCard.findNode("epgHeader")
    if m.epgHeaderLine = invalid then m.epgHeaderLine = m.liveCard.findNode("epgHeaderLine")
    if m.epgNowLine = invalid then m.epgNowLine = m.liveCard.findNode("epgNowLine")
    if m.epgRows = invalid then m.epgRows = m.liveCard.findNode("epgRows")
  end if
  if m.channelsList <> invalid then
    if m.channelsList.hasField("focusable") then m.channelsList.focusable = false
  end if
  return (m.liveCard <> invalid and m.channelsList <> invalid)
end function

function _ensureLibraryListNodes() as Boolean
  if m.libraryGroup <> invalid and m.libraryItemsList <> invalid then return true
  _ensureBrowseNodes()
  if m.libraryGroup <> invalid and m.libraryItemsList <> invalid then return true

  parent = m.browseCard
  if parent = invalid then parent = m.top
  if parent = invalid then return false

  if m.libraryGroup = invalid then
    g = CreateObject("roSGNode", "Group")
    if g = invalid then return false
    g.id = "libraryGroup"
    g.visible = false
    parent.appendChild(g)
    m.libraryGroup = g
  end if

  if m.libraryTitle = invalid then
    t = CreateObject("roSGNode", "Label")
    if t <> invalid then
      t.id = "libraryTitle"
      t.translation = [20, 110]
      t.width = 860
      t.height = 34
      t.font = "font:MediumSystemFont"
      t.color = "0xE6EBF3"
      t.text = ""
      m.libraryGroup.appendChild(t)
      m.libraryTitle = t
    end if
  end if

  if m.librarySearchBg = invalid then
    p = CreateObject("roSGNode", "Poster")
    if p <> invalid then
      p.id = "librarySearchBg"
      p.translation = [20, 148]
      p.width = 1240
      p.height = 56
      p.uri = "pkg:/images/field_normal.png"
      m.libraryGroup.appendChild(p)
      m.librarySearchBg = p
    end if
  end if

  if m.librarySearchText = invalid then
    l = CreateObject("roSGNode", "Label")
    if l <> invalid then
      l.id = "librarySearchText"
      l.translation = [42, 164]
      l.width = 1188
      l.height = 24
      l.font = "font:MediumSystemFont"
      l.color = "0xAAB4C2"
      l.text = _t("library_search_hint")
      m.libraryGroup.appendChild(l)
      m.librarySearchText = l
    end if
  end if

  if m.libraryItemsList = invalid then
    lst = CreateObject("roSGNode", "MarkupGrid")
    if lst <> invalid then
      lst.id = "libraryItemsList"
      lst.translation = [20, 220]
      lst.itemSize = [400, 120]
      lst.numColumns = 3
      lst.numRows = 4
      lst.drawFocusFeedback = false
      lst.itemComponentName = "BrowseLibraryRowItem"
      m.libraryGroup.appendChild(lst)
      m.libraryItemsList = lst
    end if
  end if

  if m.libraryEmptyLabel = invalid then
    e = CreateObject("roSGNode", "Label")
    if e <> invalid then
      e.id = "libraryEmptyLabel"
      e.translation = [20, 710]
      e.width = 1240
      e.height = 30
      e.font = "font:SmallSystemFont"
      e.horizAlign = "center"
      e.color = "0xAAB4C2"
      e.visible = false
      e.text = _t("no_items")
      m.libraryGroup.appendChild(e)
      m.libraryEmptyLabel = e
    end if
  end if

  if m.libraryItemsList <> invalid and (m.libraryItemsObsSetup <> true) then
    m.libraryItemsList.observeField("itemSelected", "onLibraryItemSelected")
    m.libraryItemsObsSetup = true
  end if

  return (m.libraryGroup <> invalid and m.libraryItemsList <> invalid)
end function

function _ensureLiveListNodes() as Boolean
  if m.channelsList <> invalid then return true
  _ensureLiveNodes()
  if m.channelsList <> invalid then return true

  parent = m.liveCard
  if parent = invalid then parent = m.top
  if parent = invalid then return false

  if m.liveCard = invalid then
    g = CreateObject("roSGNode", "Group")
    if g = invalid then return false
    g.id = "liveCard"
    g.visible = false
    parent.appendChild(g)
    m.liveCard = g
  end if

  if m.channelsList = invalid then
    lst = CreateObject("roSGNode", "MarkupList")
    if lst <> invalid then
      lst.id = "channelsList"
      lst.translation = [-2000, -2000]
      lst.itemSize = [360, 92]
      lst.numRows = 5
      lst.itemComponentName = "LiveChannelItem"
      lst.visible = false
      if lst.hasField("opacity") then lst.opacity = 0
      if lst.hasField("focusable") then lst.focusable = false
      m.liveCard.appendChild(lst)
      m.channelsList = lst
    end if
  end if

  if m.channelsBg = invalid then
    cb = CreateObject("roSGNode", "Rectangle")
    if cb <> invalid then
      cb.id = "channelsBg"
      cb.translation = [12, 110]
      cb.width = 376
      cb.height = 470
      cb.color = "0x0F1623"
      cb.visible = false
      m.liveCard.appendChild(cb)
      m.channelsBg = cb
    end if
  end if

  if m.epgGroup = invalid then
    g = CreateObject("roSGNode", "Group")
    if g <> invalid then
      g.id = "epgGroup"
      g.translation = [20, 88]
      m.liveCard.appendChild(g)
      m.epgGroup = g
    end if
  end if

  if m.epgGroup <> invalid and m.epgBg = invalid then
    bg = CreateObject("roSGNode", "Rectangle")
    if bg <> invalid then
      bg.id = "epgBg"
      bg.translation = [0, 0]
      bg.width = 1240
      bg.height = 452
      bg.color = "0x0F1623"
      bg.visible = false
      m.epgGroup.appendChild(bg)
      m.epgBg = bg
    end if
  end if

  if m.epgGroup <> invalid and m.epgHeader = invalid then
    h = CreateObject("roSGNode", "Group")
    if h <> invalid then
      h.id = "epgHeader"
      h.translation = [0, 0]
      m.epgGroup.appendChild(h)
      m.epgHeader = h
    end if
  end if

  ' Tick labels are rendered dynamically based on the window size.

  if m.epgGroup <> invalid and m.epgHeaderLine = invalid then
    hl = CreateObject("roSGNode", "Rectangle")
    if hl <> invalid then
      hl.id = "epgHeaderLine"
      hl.translation = [0, 28]
      hl.width = 1240
      hl.height = 1
      hl.color = "0x1F2A3B"
      m.epgGroup.appendChild(hl)
      m.epgHeaderLine = hl
    end if
  end if

  if m.epgGroup <> invalid and m.epgNowLine = invalid then
    nl = CreateObject("roSGNode", "Rectangle")
    if nl <> invalid then
      nl.id = "epgNowLine"
      nl.translation = [0, 28]
      nl.width = 1
      nl.height = 400
      nl.color = "0xFFFFFF"
      m.epgGroup.appendChild(nl)
      m.epgNowLine = nl
    end if
  end if

  if m.epgGroup <> invalid and m.epgRows = invalid then
    rows = CreateObject("roSGNode", "Group")
    if rows <> invalid then
      rows.id = "epgRows"
      rows.translation = [0, 32]
      m.epgGroup.appendChild(rows)
      m.epgRows = rows
    end if
  end if

  if m.liveEmptyLabel = invalid then
    l = CreateObject("roSGNode", "Label")
    if l <> invalid then
      l.id = "emptyLabel"
      l.translation = [20, 330]
      l.width = 360
      l.height = 34
      l.font = "font:SmallSystemFont"
      l.horizAlign = "center"
      l.color = "0xAAB4C2"
      l.visible = false
      l.text = _t("no_channels")
      m.liveCard.appendChild(l)
      m.liveEmptyLabel = l
    end if
  end if

  return (m.channelsList <> invalid)
end function

function _ensurePlayerOverlayNodes() as Boolean
  if m.playerOverlay <> invalid then return true
  bindUiNodes()
  if m.playerOverlay <> invalid then return true

  ov = CreateObject("roSGNode", "Group")
  if ov = invalid then return false
  ov.id = "playerOverlay"
  ov.visible = false

  seekLabel = CreateObject("roSGNode", "Label")
  if seekLabel <> invalid then
    seekLabel.id = "osdSeekLabel"
    seekLabel.translation = [40, 532]
    seekLabel.width = 1070
    seekLabel.height = 28
    seekLabel.font = "font:SmallSystemFont"
    seekLabel.color = "0xD8B765"
    seekLabel.visible = false
    seekLabel.text = ""
    ov.appendChild(seekLabel)
    m.osdSeekLabel = seekLabel
  end if

  timeLabel = CreateObject("roSGNode", "Label")
  if timeLabel <> invalid then
    timeLabel.id = "osdTimeLabel"
    timeLabel.translation = [40, 560]
    timeLabel.width = 1070
    timeLabel.height = 28
    timeLabel.font = "font:SmallSystemFont"
    timeLabel.color = "0xAAB4C2"
    timeLabel.text = ""
    ov.appendChild(timeLabel)
    m.osdTimeLabel = timeLabel
  end if

  barBg = CreateObject("roSGNode", "Rectangle")
  if barBg <> invalid then
    barBg.id = "osdBarBg"
    barBg.translation = [40, 595]
    barBg.width = 1070
    barBg.height = 10
    barBg.color = "0x223040"
    ov.appendChild(barBg)
    m.osdBarBg = barBg
  end if

  barFill = CreateObject("roSGNode", "Rectangle")
  if barFill <> invalid then
    barFill.id = "osdBarFill"
    barFill.translation = [40, 595]
    barFill.width = 0
    barFill.height = 10
    barFill.color = "0xD8B765"
    ov.appendChild(barFill)
    m.osdBarFill = barFill
  end if

  hint = CreateObject("roSGNode", "Label")
  if hint <> invalid then
    hint.id = "playerOverlayHint"
    hint.translation = [40, 650]
    hint.width = 1200
    hint.height = 30
    hint.font = "font:SmallSystemFont"
    hint.color = "0xAAB4C2"
    hint.text = "OK: confirmar    UP/DOWN: Engrenagem/Barra (VOD)    *: Configuracoes (VOD)    BACK: Fechar"
    ov.appendChild(hint)
    m.playerOverlayHint = hint
  end if

  gearFocus = CreateObject("roSGNode", "Rectangle")
  if gearFocus <> invalid then
    gearFocus.id = "osdGearFocus"
    gearFocus.translation = [1138, 586]
    gearFocus.width = 108
    gearFocus.height = 108
    gearFocus.color = "0x33D8B765"
    gearFocus.visible = false
    ov.appendChild(gearFocus)
    m.osdGearFocus = gearFocus
  end if

  gearCircle = CreateObject("roSGNode", "Poster")
  if gearCircle <> invalid then
    gearCircle.id = "playerOverlayCircle"
    gearCircle.translation = [1144, 592]
    gearCircle.width = 96
    gearCircle.height = 96
    gearCircle.uri = "pkg:/images/overlay_circle.png"
    ov.appendChild(gearCircle)
    m.playerOverlayCircle = gearCircle
  end if

  gearIcon = CreateObject("roSGNode", "Poster")
  if gearIcon <> invalid then
    gearIcon.id = "playerOverlayIcon"
    gearIcon.translation = [1160, 608]
    gearIcon.width = 64
    gearIcon.height = 64
    gearIcon.uri = "pkg:/images/ico_settings.png"
    ov.appendChild(gearIcon)
    m.playerOverlayIcon = gearIcon
  end if

  m.top.appendChild(ov)
  m.playerOverlay = ov
  return true
end function

function _ensurePlayerSettingsNodes() as Boolean
  if m.playerSettingsModal <> invalid and m.playerSettingsAudioList <> invalid and m.playerSettingsSubList <> invalid then return true
  bindUiNodes()
  if m.playerSettingsModal <> invalid and m.playerSettingsAudioList <> invalid and m.playerSettingsSubList <> invalid then return true

  modal = CreateObject("roSGNode", "Group")
  if modal = invalid then return false
  modal.id = "playerSettingsModal"
  modal.visible = false

  bg = CreateObject("roSGNode", "Poster")
  if bg <> invalid then
    bg.id = "playerSettingsBg"
    bg.translation = [140, 80]
    bg.width = 1000
    bg.height = 560
    bg.uri = "pkg:/images/card.png"
    modal.appendChild(bg)
  end if

  title = CreateObject("roSGNode", "Label")
  if title <> invalid then
    title.id = "playerSettingsTitle"
    title.translation = [180, 110]
    title.width = 920
    title.height = 34
    title.font = "font:MediumSystemFont"
    title.color = "0xD8B765"
    title.text = "Configuracoes do Player"
    modal.appendChild(title)
  end if

  aTitle = CreateObject("roSGNode", "Label")
  if aTitle <> invalid then
    aTitle.id = "playerSettingsAudioTitle"
    aTitle.translation = [180, 160]
    aTitle.width = 440
    aTitle.height = 28
    aTitle.font = "font:SmallSystemFont"
    aTitle.color = "0xAAB4C2"
    aTitle.text = "Audio"
    modal.appendChild(aTitle)
  end if

  aList = CreateObject("roSGNode", "MarkupList")
  if aList <> invalid then
    aList.id = "playerSettingsAudioList"
    aList.translation = [180, 195]
    aList.itemSize = [440, 60]
    aList.numRows = 6
    aList.itemComponentName = "PlayerSettingItem"
    modal.appendChild(aList)
    m.playerSettingsAudioList = aList
  end if

  sTitle = CreateObject("roSGNode", "Label")
  if sTitle <> invalid then
    sTitle.id = "playerSettingsSubTitle"
    sTitle.translation = [660, 160]
    sTitle.width = 440
    sTitle.height = 28
    sTitle.font = "font:SmallSystemFont"
    sTitle.color = "0xAAB4C2"
    sTitle.text = "Legendas"
    modal.appendChild(sTitle)
  end if

  sList = CreateObject("roSGNode", "MarkupList")
  if sList <> invalid then
    sList.id = "playerSettingsSubList"
    sList.translation = [660, 195]
    sList.itemSize = [440, 60]
    sList.numRows = 6
    sList.itemComponentName = "PlayerSettingItem"
    modal.appendChild(sList)
    m.playerSettingsSubList = sList
  end if

  footer = CreateObject("roSGNode", "Label")
  if footer <> invalid then
    footer.id = "playerSettingsFooter"
    footer.translation = [180, 590]
    footer.width = 920
    footer.height = 28
    footer.font = "font:SmallSystemFont"
    footer.color = "0xAAB4C2"
    footer.text = "LEFT/RIGHT: trocar coluna    OK: selecionar    BACK: fechar"
    modal.appendChild(footer)
  end if

  m.top.appendChild(modal)
  m.playerSettingsModal = modal

  ' Rebind observers for the new lists.
  if m.playerSettingsAudioList <> invalid and (m.settingsObsSetup <> true) then
    m.playerSettingsAudioList.observeField("itemSelected", "onSettingsAudioSelected")
    if m.playerSettingsSubList <> invalid then m.playerSettingsSubList.observeField("itemSelected", "onSettingsSubSelected")
    m.settingsObsSetup = true
  end if
  return true
end function

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

function _isLiveRoutePath(path as String) as Boolean
  p = path
  if p = invalid then p = ""
  p = p.ToStr().Trim()
  if p = "" then return false
  if Instr(1, p, "/hls/") = 1 then return true
  if Instr(1, p, "/live/") = 1 then return true
  return false
end function

function _resolveLivePathFromItem(it as Object) as String
  if it = invalid then return "/hls/index.m3u8"

  p = ""
  if it.hasField("path") then p = it.path
  if p <> invalid then p = p.ToStr().Trim()
  if p <> "" then
    tgt = parseTarget(p, "/hls/index.m3u8")
    if _isLiveRoutePath(tgt.path) then return p
  end if

  id = ""
  if it.hasField("id") then id = it.id
  if id <> invalid then id = id.ToStr().Trim()
  if id <> "" then return "/hls/index.m3u8"

  return "/hls/index.m3u8"
end function

sub signAndPlay(rawPath as String, title as String)
  target = parseTarget(rawPath, "/hls/index.m3u8")
  p = target.path
  if p = invalid then p = ""
  p = p.ToStr().Trim()
  if p = "" then
    print "signAndPlay: empty path; fallback to /hls/index.m3u8"
    target = { path: "/hls/index.m3u8", query: {} }
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
  if m.pendingDialog <> invalid and m.top.dialog = invalid then m.pendingDialog = invalid
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
  m.playbackStarting = true

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

  normId = normalizeJellyfinId(k)
  if normId = invalid then normId = ""
  normId = normId.Trim()
  if normId = "" then normId = k

  base = _vodR2PlaybackBase(cfg.apiBase)

  setStatus(_t("vod_checking"))
  m.pendingJob = "vod_status"
  m.gatewayTask.kind = "vod_status"
  m.gatewayTask.apiBase = base
  m.gatewayTask.appToken = cfg.appToken
  m.gatewayTask.itemId = normId
  m.gatewayTask.control = "run"
end sub

sub requestSeriesStatus(itemId as String)
  if m.gatewayTask = invalid then return
  if m.pendingJob <> "" then return

  id = itemId
  if id = invalid then id = ""
  id = id.Trim()
  if id = "" then return

  cfg = loadConfig()
  if cfg.apiBase = "" or cfg.appToken = "" then return

  m.pendingJob = "series_status"
  m.gatewayTask.kind = "vod_status"
  m.gatewayTask.apiBase = cfg.apiBase
  m.gatewayTask.appToken = cfg.appToken
  m.gatewayTask.itemId = id
  m.gatewayTask.control = "run"
end sub

function _parseVodStatus(raw as String) as String
  st = ""
  data = ParseJson(raw)
  if type(data) = "roAssociativeArray" then
    if data.status <> invalid then st = data.status
    if (st = invalid or st = "") and data.Status <> invalid then st = data.Status
  end if
  if st = invalid then st = ""
  st = UCase(st.Trim())
  if st = "" then st = "ERROR"
  return st
end function

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
      saveLoginCreds(m.form.username, m.form.password)
      loadSavedIntoForm()
      enterBrowse()
    else
      err = m.gatewayTask.error
      if err = invalid or err = "" then err = "unknown"
      setStatus("login failed: " + err)
    end if
    return
  end if

  if job = "series_status" then
    st = _parseVodStatus(m.gatewayTask.resultJson)
    if m.seriesDetailOpen = true then _applySeriesDetailStatus(st)
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
      st = _parseVodStatus(m.gatewayTask.resultJson)

      print "vod status id=" + id + " status=" + st

      if st = "READY" then
        setStatus("ready")
        playVodR2Now(id, t)
      else if st = "PROCESSING" then
        m.playbackStarting = false
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
        m.playbackStarting = false
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
      m.playbackStarting = false
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
      m.browseMoviesViewId = ""
      m.browseSeriesViewId = ""
      mv = byType["movies"]
      if mv <> invalid and mv.id <> invalid then m.browseMoviesViewId = mv.id.ToStr().Trim()
      sv = byType["tvshows"]
      if sv <> invalid and sv.id <> invalid then m.browseSeriesViewId = sv.id.ToStr().Trim()

      if m.itemsList <> invalid then m.itemsList.content = CreateObject("roSGNode", "ContentNode")
      if m.continueList <> invalid then m.continueList.content = CreateObject("roSGNode", "ContentNode")
      if m.recentMoviesList <> invalid then m.recentMoviesList.content = CreateObject("roSGNode", "ContentNode")
      if m.recentSeriesList <> invalid then m.recentSeriesList.content = CreateObject("roSGNode", "ContentNode")
      if m.continueTitle <> invalid then m.continueTitle.visible = false
      if m.recentMoviesTitle <> invalid then m.recentMoviesTitle.visible = false
      if m.recentSeriesTitle <> invalid then m.recentSeriesTitle.visible = false
      if m.browseEmptyLabel <> invalid then
        m.browseEmptyLabel.text = _t("no_items")
        m.browseEmptyLabel.visible = true
      end if

      setStatus("ready")
      m.activeViewId = "__top10"
      m.activeViewCollection = "top10"
      if m.itemsTitle <> invalid then m.itemsTitle.text = _t("top10")
      m.heroContinueAutoplayPending = false
      _loadBrowseHomeShelves()

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

  if job = "home_shelf" then
    sec = m.pendingHomeShelfSection
    if sec = invalid then sec = ""
    sec = sec.ToStr().Trim()
    m.pendingHomeShelfSection = ""

    if m.gatewayTask.ok = true then
      raw = m.gatewayTask.resultJson
      _renderHomeShelf(sec, raw)
    else
      err = m.gatewayTask.error
      if err = invalid or err = "" then err = "unknown"
      print "home shelf failed section=" + sec + " err=" + err
      _renderHomeShelf(sec, "[]")
    end if

    _startNextHomeShelfRequest()
    if m.pendingLibraryLoad = true and m.pendingJob = "" then
      if m.playbackStarting = true or (m.player <> invalid and m.player.visible = true) then
        _scheduleDeferredBrowseActions()
      else
        m.pendingLibraryLoad = false
        _loadBrowseLibraryItems()
      end if
    end if
    if m.pendingSeriesDetailQueued = true and m.pendingJob = "" then
      if m.playbackStarting = true or (m.player <> invalid and m.player.visible = true) then
        _scheduleDeferredBrowseActions()
      else
        qId = m.pendingSeriesDetailQueuedItemId
        qTitle = m.pendingSeriesDetailQueuedTitle
        m.pendingSeriesDetailQueued = false
        m.pendingSeriesDetailQueuedItemId = ""
        m.pendingSeriesDetailQueuedTitle = ""
        requestSeriesDetails(qId, qTitle)
      end if
    end if
    return
  end if

  if job = "shelf" then
    viewId = m.pendingShelfViewId
    m.pendingShelfViewId = ""
    if viewId = invalid then viewId = ""
    viewId = viewId.ToStr().Trim()

    if viewId = "__continue" then
      if m.activeViewId <> "__continue" or m.gatewayTask.ok <> true then
        m.heroContinueAutoplayPending = false
      end if
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

  if job = "library_shelf" then
    reqViewId = m.pendingLibraryViewId
    if reqViewId = invalid then reqViewId = ""
    reqViewId = reqViewId.ToStr().Trim()
    m.pendingLibraryViewId = ""

    if m.gatewayTask.ok = true then
      raw = m.gatewayTask.resultJson
      parsed = ParseJson(raw)
      if type(parsed) <> "roArray" then parsed = []
      print "library response viewId=" + reqViewId + " count=" + parsed.Count().ToStr()

      currentViewId = m.browseLibraryViewId
      if currentViewId = invalid then currentViewId = ""
      currentViewId = currentViewId.ToStr().Trim()

      if m.browseLibraryOpen = true and reqViewId = currentViewId then
        _setBrowseLibraryVisible(true)
        m.browseLibraryRawItems = parsed
        _renderBrowseLibraryItems()
      end if
      setStatus("ready")
    else
      errLib = m.gatewayTask.error
      if errLib = invalid or errLib = "" then errLib = "unknown"
      setStatus("library failed: " + errLib)
      if m.browseLibraryOpen = true then
        m.browseLibraryRawItems = []
        _renderBrowseLibraryItems()
      end if
    end if
    return
  end if

  if job = "series_detail" then
    reqSeriesId = m.pendingSeriesDetailItemId
    if reqSeriesId = invalid then reqSeriesId = ""
    reqSeriesId = reqSeriesId.ToStr().Trim()

    if m.gatewayTask.ok = true then
      raw = m.gatewayTask.resultJson
      data = ParseJson(raw)
      if type(data) <> "roAssociativeArray" then data = {}
      _showSeriesDetailScreen(data)
      setStatus("ready")
    else
      errDet = m.gatewayTask.error
      if errDet = invalid or errDet = "" then errDet = "unknown"
      setStatus(_t("details_failed") + ": " + errDet)
      if m.pendingDialog = invalid then
        dlgDetErr = CreateObject("roSGNode", "Dialog")
        t0 = m.pendingSeriesDetailTitle
        if t0 = invalid then t0 = ""
        t0 = t0.ToStr().Trim()
        if t0 = "" then t0 = "Series"
        dlgDetErr.title = t0
        dlgDetErr.message = _t("details_failed")
        dlgDetErr.buttons = [_t("close")]
        dlgDetErr.observeField("buttonSelected", "onSeriesDetailDone")
        m.seriesDetailPlayEpisodeId = ""
        m.seriesDetailPlayEpisodeTitle = ""
        m.pendingDialog = dlgDetErr
        m.top.dialog = dlgDetErr
        dlgDetErr.setFocus(true)
      end if
    end if
    m.pendingSeriesDetailItemId = ""
    m.pendingSeriesDetailTitle = ""
    return
  end if

  if job = "resume_probe" then
    probeId = m.pendingResumeProbeItemId
    probeTitle = m.pendingResumeProbeTitle
    m.pendingResumeProbeItemId = ""
    m.pendingResumeProbeTitle = ""

    if probeId = invalid then probeId = ""
    probeId = probeId.ToStr().Trim()
    if probeTitle = invalid then probeTitle = ""
    probeTitle = probeTitle.ToStr().Trim()
    if probeTitle = "" then probeTitle = "Video"
    if probeId = "" then
      setStatus("ready")
      return
    end if

    resumeMsProbe = -1
    if m.gatewayTask.ok = true then
      pdata = ParseJson(m.gatewayTask.resultJson)
      if type(pdata) = "roAssociativeArray" then
        if pdata.positionMs <> invalid then resumeMsProbe = _sceneIntFromAny(pdata.positionMs)
        if resumeMsProbe < 0 and pdata.position_ms <> invalid then resumeMsProbe = _sceneIntFromAny(pdata.position_ms)
      end if
    end if

    print "resume probe result id=" + probeId + " resumeMs=" + resumeMsProbe.ToStr()
    if resumeMsProbe > 5000 then
      showResumeDialog(probeId, probeTitle, resumeMsProbe)
    else
      playVodById(probeId, probeTitle)
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
          if poster = "" and ch.logoFallbackPath <> invalid then
            lpf = ch.logoFallbackPath.ToStr().Trim()
            if lpf <> "" then
              if Left(lpf, 1) = "/" and baseNoSlash <> "" then
                poster = baseNoSlash + lpf
              else
                poster = lpf
              end if
            end if
          end if
          logoType = ""
          if ch.logoType <> invalid then logoType = ch.logoType.ToStr().Trim()
          if poster = "" and logoType <> "" then poster = _browseChannelImageUri(c.id, basePrev, tokenPrev, logoType)
          if poster = "" then poster = _browseChannelImageUri(c.id, basePrev, tokenPrev, "Logo")
          if poster = "" then poster = _browseChannelPosterUri(c.id, basePrev, tokenPrev)
          if poster = "" then poster = _browsePosterUri(c.id, basePrev, tokenPrev)
          if poster <> "" then
            q = {}
            if tokenPrev <> invalid and tokenPrev.ToStr().Trim() <> "" then
              if Instr(1, poster, "api_key=") = 0 then q["api_key"] = tokenPrev
              if Instr(1, poster, "X-Emby-Token=") = 0 then q["X-Emby-Token"] = tokenPrev
              if Instr(1, poster, "X-Jellyfin-Token=") = 0 then q["X-Jellyfin-Token"] = tokenPrev
            end if
            if cfgPrev.appToken <> invalid and cfgPrev.appToken.Trim() <> "" then
              if Instr(1, poster, "app_token=") = 0 and Instr(1, poster, "appToken=") = 0 then q["app_token"] = cfgPrev.appToken.Trim()
            end if
            if q.Count() > 0 then poster = appendQuery(poster, q)
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
      m.pendingLiveLoad = false
      cfg = loadConfig()
      raw = m.gatewayTask.resultJson
      items = ParseJson(raw)
      if type(items) <> "roArray" then items = []
      print "channels ok count=" + items.Count().ToStr()

      hasNonHdmi = false
      for each ch in items
        if ch <> invalid and ch.name <> invalid then
          n = LCase(ch.name.ToStr().Trim())
          if n <> "" and Instr(1, n, "hdmi") = 0 then
            hasNonHdmi = true
            exit for
          end if
        else
          hasNonHdmi = true
          exit for
        end if
      end for

      root = CreateObject("roSGNode", "ContentNode")
      for each ch in items
        if ch <> invalid and ch.name <> invalid then
          chNameLow = LCase(ch.name.ToStr().Trim())
          if hasNonHdmi = true and Instr(1, chNameLow, "hdmi") > 0 then
            continue for
          end if
        end if
        c = CreateObject("roSGNode", "ContentNode")
        c.addField("programTitle", "string", false)
        c.addField("programNextTitle", "string", false)
        c.addField("programTimeLabel", "string", false)
        c.addField("programProgress", "float", false)
        c.addField("logoUrl", "string", false)
        if ch <> invalid then
          if ch.id <> invalid then c.id = ch.id
          if ch.name <> invalid then c.title = ch.name else c.title = ""
          c.addField("path", "string", false)
          if ch.path <> invalid then c.path = ch.path else c.path = ""

          logo = ""
          basePrev = cfg.apiBase
          tokenPrev = cfg.jellyfinToken
          baseNoSlash = basePrev
          if baseNoSlash = invalid then baseNoSlash = ""
          baseNoSlash = baseNoSlash.ToStr().Trim()
          if Right(baseNoSlash, 1) = "/" then baseNoSlash = Left(baseNoSlash, Len(baseNoSlash) - 1)

          if ch.logoPath <> invalid then
            lp = ch.logoPath.ToStr().Trim()
            if lp <> "" then
              if Left(lp, 1) = "/" and baseNoSlash <> "" then
                logo = baseNoSlash + lp
              else
                logo = lp
              end if
            end if
          end if
          if logo = "" and ch.logoFallbackPath <> invalid then
            lpf = ch.logoFallbackPath.ToStr().Trim()
            if lpf <> "" then
              if Left(lpf, 1) = "/" and baseNoSlash <> "" then
                logo = baseNoSlash + lpf
              else
                logo = lpf
              end if
            end if
          end if
          if logo = "" then logo = _browseChannelImageUri(c.id, basePrev, tokenPrev, "Logo")
          if logo = "" then logo = _browseChannelPosterUri(c.id, basePrev, tokenPrev)
          if logo <> "" then
            q = {}
            if tokenPrev <> invalid and tokenPrev.ToStr().Trim() <> "" then
              if Instr(1, logo, "api_key=") = 0 then q["api_key"] = tokenPrev
              if Instr(1, logo, "X-Emby-Token=") = 0 then q["X-Emby-Token"] = tokenPrev
              if Instr(1, logo, "X-Jellyfin-Token=") = 0 then q["X-Jellyfin-Token"] = tokenPrev
            end if
            if cfg.appToken <> invalid and cfg.appToken.Trim() <> "" then
              if Instr(1, logo, "app_token=") = 0 and Instr(1, logo, "appToken=") = 0 then q["app_token"] = cfg.appToken.Trim()
            end if
            if q.Count() > 0 then logo = appendQuery(logo, q)
          end if
          if logo = "" then logo = "pkg:/images/logo.png"
          if m.liveLogoDebugPrinted <> true then
            print "live logo url=" + logo
            m.liveLogoDebugPrinted = true
          end if
          c.logoUrl = logo
          if c.hasField("hdPosterUrl") <> true then c.addField("hdPosterUrl", "string", false)
          if c.hasField("posterUrl") <> true then c.addField("posterUrl", "string", false)
          c.hdPosterUrl = logo
          c.posterUrl = logo
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

      m.liveChannelIndex = 0
      m.liveRowStartIndex = 0
      _renderLiveTimeline()
      setStatus("ready")
      if m.mode = "live" then applyFocus()

      if m.mode = "live" then
        print "programs trigger from channels mode=" + m.mode
        loadLivePrograms()
      else
        print "programs skip: mode=" + m.mode
      end if

      if m.devAutoplay = "live" and m.devAutoplayDone <> true then
        ' Helpful for debugging when we can't inject keypress events remotely.
        if root.getChildCount() > 0 then
          first = root.getChild(0)
          if first <> invalid then
            firstId = ""
            if first.hasField("id") then firstId = first.id
            if firstId <> invalid then firstId = firstId.ToStr().Trim()
            if firstId <> "" then
              m.devAutoplayDone = true
              print "DEV autoplay LIVE channel id: " + firstId
              livePath = _resolveLivePathFromItem(first)
              signAndPlay(livePath, first.title)
            else
              p = ""
              if first.hasField("path") then p = first.path
              if p <> invalid then p = p.Trim()
              if p <> "" then
                m.devAutoplayDone = true
                print "DEV autoplay LIVE path: " + p
                signAndPlay(p, first.title)
              else
                m.devAutoplayDone = true
                print "DEV autoplay LIVE: missing channel path; fallback to /hls/index.m3u8"
                signAndPlay("/hls/index.m3u8", first.title)
              end if
            end if
          end if
        end if
      end if
    else
      m.pendingLiveLoad = false
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

  if job = "programs" then
    if m.gatewayTask.ok = true then
      raw = m.gatewayTask.resultJson
      items = ParseJson(raw)
      if type(items) <> "roArray" then items = []
      print "programs ok count=" + items.Count().ToStr()
      minSec = 0
      maxSec = 0
      for each it in items
        if type(it) <> "roAssociativeArray" then continue for
        stRaw = ""
        enRaw = ""
        if it.startDate <> invalid then stRaw = it.startDate
        if it.endDate <> invalid then enRaw = it.endDate
        if stRaw <> invalid then stRaw = stRaw.ToStr().Trim()
        if enRaw <> invalid then enRaw = enRaw.ToStr().Trim()
        if stRaw <> "" then
          stSec = _parseIso8601ToEpochSec(stRaw)
          if stSec > 0 and (minSec = 0 or stSec < minSec) then minSec = stSec
        end if
        if enRaw <> "" then
          enSec = _parseIso8601ToEpochSec(enRaw)
          if enSec > 0 and (maxSec = 0 or enSec > maxSec) then maxSec = enSec
        end if
      end for
      if minSec > 0 and maxSec > 0 then
        print "programs range resp=" + _formatDateLong(minSec) + " -> " + _formatDateLong(maxSec)
      end if
      m.livePrograms = items
      m.liveProgramMapDirty = true
      m.liveProgramsVersion = m.liveProgramsVersion + 1
      _applyLivePrograms(items)
      m.liveProgramsLoaded = true
      _requestLiveRender("programs_loaded")
    else
      m.pendingLiveLoad = false
      err = m.gatewayTask.error
      if err = invalid or err = "" then err = "unknown"
      print "programs failed: " + err
      setStatus("programs failed: " + err)
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
    expectedAttempt = m.pendingSignAttemptId
    if expectedAttempt = invalid then expectedAttempt = ""
    expectedAttempt = expectedAttempt.ToStr().Trim()
    currentAttempt = m.pendingPlayAttemptId
    if currentAttempt = invalid then currentAttempt = ""
    currentAttempt = currentAttempt.ToStr().Trim()
    if expectedAttempt <> "" and currentAttempt <> "" and expectedAttempt <> currentAttempt then
      print "sign stale attempt expected=" + expectedAttempt + " current=" + currentAttempt
      return
    end if
    m.pendingSignAttemptId = ""

    if m.gatewayTask.ok = true then
      cfg = loadConfig()
      kind = m.pendingPlaybackKind
      if kind = invalid then kind = ""
      kind = kind.Trim()
      if kind = "" then kind = "unknown"

      base = cfg.apiBase
      isLive = (m.pendingPlayIsLive = true)
      if kind <> "" then
        kLower = LCase(kind)
        if Instr(1, kLower, "vod") = 1 then isLive = false
      end if

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
      m.playbackStarting = false
      setStatus("sign failed: " + err)
    end if
    return
  end if
end sub

sub startVideo(url as String, title as String, streamFormat as String, isLive as Boolean, kind as String, itemId as String)
  if m.player = invalid then
    bindUiNodes()
  end if
  if m.player = invalid then
    ' Fallback: create the Video node if it failed to bind from XML.
    p = CreateObject("roSGNode", "ChampionsVideo")
    if p <> invalid then
      p.translation = [0, 0]
      p.width = 1280
      p.height = 720
      p.visible = false
      m.top.appendChild(p)
      m.player = p
      m.playerObsSetup = false
      bindUiNodes()
    end if
  end if
  if m.player = invalid then
    print "startVideo abort: player missing"
    setStatus("player: missing node")
    return
  end if

  _setUiVisibleForPlayback(true)

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
  m.playbackStarting = false

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
  ' Ensure focus leaves the Video node after stop (avoid key capture when hidden).
  _setNodeFocus(m.top, "scene")

  m.playbackStarting = false
  _setUiVisibleForPlayback(false)

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
  applyFocus()
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
  kp = _keyPerfStart("overlay", kl, true)
  if m.player = invalid or m.player.visible <> true then return _returnKeyWithPerf(kp, false)

  k = kl
  if k = invalid then k = ""
  k = LCase(k.Trim())
  if k = "select" then k = "ok"
  if k = "channelup" or k = "chanup" then k = "up"
  if k = "channeldown" or k = "chandown" then k = "down"
  if k = "" then return _returnKeyWithPerf(kp, false)

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
    if m.keyPerfDebug = true then
      print "[key] name=" + k + " state=" + m.uiState + " focus=" + m.osdFocus + " focusNode=" + _focusNodeLabel() + " consumed=true dedup=true"
    end if
    return _returnKeyWithPerf(kp, true)
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

    if m.keyPerfDebug = true then
      print "[key] name=" + k + " state=" + m.uiState + " focus=" + m.osdFocus + " focusNode=" + _focusNodeLabel() + " consumed=" + consumed.ToStr()
    end if
    return _returnKeyWithPerf(kp, consumed)
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
      if prevFocus <> m.osdFocus and m.keyPerfDebug = true then
        print "[osd] focus " + prevFocus + "->" + m.osdFocus + " focusNode=" + _focusNodeLabel()
      end if
      consumed = true
    else if k = "left" or k = "right" then
      if m.osdFocus = "GEAR" then
        if k = "left" then
          prevFocus = m.osdFocus
          m.osdFocus = "TIMELINE"
          _updateOsdUi()
          if prevFocus <> m.osdFocus and m.keyPerfDebug = true then
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

    if m.keyPerfDebug = true then
      print "[key] name=" + k + " state=" + m.uiState + " focus=" + m.osdFocus + " focusNode=" + _focusNodeLabel() + " consumed=" + consumed.ToStr()
    end if
    return _returnKeyWithPerf(kp, consumed)
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

  if m.keyPerfDebug = true then
    print "[key] name=" + k + " state=" + m.uiState + " focus=" + m.osdFocus + " focusNode=" + _focusNodeLabel() + " consumed=" + consumed.ToStr()
  end if
  return _returnKeyWithPerf(kp, consumed)
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
  if m.liveInputTrace = true and m.mode = "live" then
    _traceLiveKeyEvent(key, press)
  end if
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

  if m.seriesDetailOpen = true then
    modeVal = m.seriesDetailMode
    if modeVal = invalid then modeVal = ""
    isEpisodeMode = (LCase(modeVal.ToStr().Trim()) = "episode")
    isSeries = (m.seriesDetailIsSeries = true)
    isSimple = (isEpisodeMode or isSeries <> true)
    if kl = "back" then
      _closeSeriesDetail()
      return true
    end if
    if kl = "up" then
      if m.seriesDetailFocus = "cast" then
        if isSimple then
          m.seriesDetailFocus = "header"
        else
          m.seriesDetailFocus = "episodes"
        end if
        applyFocus()
      else if m.seriesDetailFocus = "episodes" then
        if isSimple <> true then
          m.seriesDetailFocus = "seasons"
          applyFocus()
        end if
      else if m.seriesDetailFocus = "seasons" then
        m.seriesDetailFocus = "header"
        applyFocus()
      else if m.seriesDetailFocus = "header" then
        m.seriesDetailFocus = "back"
        applyFocus()
      end if
      return true
    end if
    if kl = "down" then
      if m.seriesDetailFocus = "back" then
        m.seriesDetailFocus = "header"
        applyFocus()
      else if m.seriesDetailFocus = "header" then
        if isSimple then
          if _browseListCount(m.seriesDetailCastList) > 0 then
            m.seriesDetailFocus = "cast"
            applyFocus()
          end if
        else
          if _browseListCount(m.seriesDetailSeasonsList) > 0 then
            m.seriesDetailFocus = "seasons"
          else if _browseListCount(m.seriesDetailEpisodesList) > 0 then
            m.seriesDetailFocus = "episodes"
          else if _browseListCount(m.seriesDetailCastList) > 0 then
            m.seriesDetailFocus = "cast"
          end if
          applyFocus()
        end if
      else if m.seriesDetailFocus = "seasons" then
        if isSimple <> true then
          m.seriesDetailFocus = "episodes"
          applyFocus()
        end if
      else if m.seriesDetailFocus = "episodes" then
        if isSimple <> true then
          if _browseListCount(m.seriesDetailCastList) > 0 then
            m.seriesDetailFocus = "cast"
            applyFocus()
          end if
        end if
      end if
      return true
    end if
    if kl = "left" or kl = "right" then
      if m.seriesDetailFocus = "header" then
        trailerVisible = (m.seriesDetailHasTrailer = true)
        if trailerVisible then
          if kl = "left" then
            if m.seriesDetailActionFocus = 1 then m.seriesDetailActionFocus = 0
          else if kl = "right" then
            if m.seriesDetailActionFocus = 0 then m.seriesDetailActionFocus = 1
          end if
        else
          m.seriesDetailActionFocus = 0
        end if
        _applySeriesDetailActionFocus()
        return true
      end if
    end if
    if kl = "ok" then
      if m.seriesDetailFocus = "back" then
        _closeSeriesDetail()
        return true
      else if m.seriesDetailFocus = "header" then
        if m.seriesDetailActionFocus = 1 and m.seriesDetailHasTrailer = true then
          _openTrailerFromSeries()
          return true
        end if
        _playSeriesDetailPrimary()
        return true
      end if
    end if
    if kl = "options" or kl = "info" then
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

    if m.browseLibraryOpen = true then
      if kl = "left" then
        if m.browseFocus = "library_items" then
          idxLib = _browseListFocusedIndex(m.libraryItemsList)
          if idxLib > 0 then return false
        end if
        return true
      end if

      if kl = "right" then
        if m.browseFocus = "library_items" then return false
        return true
      end if

      if kl = "up" then
        if m.browseFocus = "library_items" then
          idxLib2 = _browseListFocusedIndex(m.libraryItemsList)
          if idxLib2 >= _browseLibraryCols() then return false
          m.browseFocus = "library_search"
          applyFocus()
        end if
        return true
      end if

      if kl = "down" then
        if m.browseFocus = "library_search" then
          if _browseListCount(m.libraryItemsList) > 0 then
            m.browseFocus = "library_items"
            applyFocus()
          end if
          return true
        end if
        return false
      end if

      if kl = "ok" then
        if m.browseFocus = "library_search" then
          _promptBrowseLibrarySearch()
          return true
        else if m.browseFocus = "library_items" then
          onLibraryItemSelected()
          return true
        end if
      end if

      if kl = "options" then
        _promptBrowseLibrarySearch()
        return true
      end if

      if kl = "back" then
        _closeBrowseLibrary()
        return true
      end if
    end if

    if kl = "left" then
      if m.browseFocus = "items" or m.browseFocus = "continue" or m.browseFocus = "movies" or m.browseFocus = "series" then
        lst = _browseListNodeForFocus(m.browseFocus)
        idx = _browseListFocusedIndex(lst)
        if idx > 0 then return false
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
        if _browseSectionHasItems("items") then
          m.browseFocus = "items"
        else
          nxt = _browseNextShelfSection("items")
          if nxt = "" then return true
          m.browseFocus = nxt
        end if
        applyFocus()
        return true
      else if m.browseFocus = "hero_logout" then
        m.browseFocus = "hero_continue"
        applyFocus()
        return true
      else if m.browseFocus = "items" or m.browseFocus = "continue" or m.browseFocus = "movies" or m.browseFocus = "series" then
        return false
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
      else if m.browseFocus = "items" or m.browseFocus = "continue" or m.browseFocus = "movies" or m.browseFocus = "series" then
        prevShelf = _browsePrevShelfSection(m.browseFocus)
        if prevShelf <> "" then
          m.browseFocus = prevShelf
        else
          m.browseFocus = "views"
        end if
        applyFocus()
        return true
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
        if _browseSectionHasItems("items") then
          m.browseFocus = "items"
          applyFocus()
          return true
        end if
        n2 = _browseNextShelfSection("items")
        if n2 <> "" then
          m.browseFocus = n2
          applyFocus()
          return true
        end if
      else if m.browseFocus = "items" or m.browseFocus = "continue" or m.browseFocus = "movies" or m.browseFocus = "series" then
        nextShelf = _browseNextShelfSection(m.browseFocus)
        if nextShelf <> "" then
          m.browseFocus = nextShelf
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
      if m.browseFocus = "items" or m.browseFocus = "continue" or m.browseFocus = "movies" or m.browseFocus = "series" then
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

  if m.mode = "live" then
    kpLive = _keyPerfStart("live", kl, true)
    handledLive = _handleLiveKey(kl)
    return _returnKeyWithPerf(kpLive, handledLive)
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
      if m.browseFocus = "items" or m.browseFocus = "continue" or m.browseFocus = "movies" or m.browseFocus = "series" then
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

function _handleLiveKey(kl as String) as Boolean
  _enforceLiveFocusLock()
  if m.liveInputDebug = true then
    print "[live.key] key=" + kl + " focus=" + m.liveFocusTarget + " daystrip=" + m.liveDayStripOpen.ToStr()
  end if

  if m.liveInputIsolateMode = true then
    if kl = "left" or kl = "right" or kl = "up" or kl = "down" or kl = "back" then
      cnt = 0
      if m.liveInputDebugCounter <> invalid then cnt = Int(m.liveInputDebugCounter)
      cnt = cnt + 1
      m.liveInputDebugCounter = cnt
      if m.hintLabel <> invalid then
        m.hintLabel.visible = true
        m.hintLabel.text = "live input isolate " + cnt.ToStr()
      end if
      return true
    end if
  end if

  if m.liveDayStripOpen = true then
    if kl = "back" then
      _closeDayStrip()
      return true
    else if kl = "left" or kl = "right" then
      if m.liveDayStripDates = invalid then m.liveDayStripDates = _buildDayStripDates()
      totalDays = 0
      if type(m.liveDayStripDates) = "roArray" then totalDays = m.liveDayStripDates.Count()
      if totalDays <= 0 then return true
      idx = m.liveDayStripIndex
      if idx = invalid then idx = 0
      idx = Int(idx)
      if kl = "left" then idx = idx - 1 else idx = idx + 1
      if idx < 0 then idx = 0
      if idx > (totalDays - 1) then idx = totalDays - 1
      m.liveDayStripIndex = idx
      _updateDayStripUI()
      return true
    else if kl = "ok" then
      key = _dateKeyNow()
      if type(m.liveDayStripDates) = "roArray" and m.liveDayStripDates.Count() > 0 then
        idx = m.liveDayStripIndex
        if idx = invalid then idx = 0
        idx = Int(idx)
        if idx < 0 then idx = 0
        if idx > (m.liveDayStripDates.Count() - 1) then idx = m.liveDayStripDates.Count() - 1
        d = m.liveDayStripDates[idx]
        if d <> invalid and d.key <> invalid then key = d.key
      end if
      _closeDayStrip()
      _applySelectedDateKey(key, true)
      return true
    else if kl = "up" or kl = "down" then
      return true
    end if
  end if

  if kl = "info" then
    _openDayStrip()
    return true
  end if

  if kl = "back" then
    enterBrowse()
    return true
  end if

  if m.liveFocusTarget = "channels" then
    if kl = "up" then
      _moveLiveChannel(-1)
      return true
    end if
    if kl = "down" then
      _moveLiveChannel(1)
      return true
    end if
    if kl = "right" then
      _setLiveFocusTarget("time")
      return true
    end if
    if kl = "ok" then
      playSelectedLiveChannel()
      return true
    end if
    if kl = "left" then return true
  end if

  if m.liveFocusTarget = "header" then
    if kl = "left" or kl = "right" then
      idx = 0
      if m.liveHeaderFocusIndex <> invalid then idx = Int(m.liveHeaderFocusIndex)
      if idx < 0 then idx = 0
      if idx > 1 then idx = 1
      if kl = "left" then idx = idx - 1 else idx = idx + 1
      if idx < 0 then idx = 0
      if idx > 1 then idx = 1
      m.liveHeaderFocusIndex = idx
      _applyLiveFocusVisuals()
      return true
    end if
    if kl = "down" then
      _setLiveFocusTarget("time")
      return true
    end if
    if kl = "up" then return true
    if kl = "ok" then
      idx2 = 0
      if m.liveHeaderFocusIndex <> invalid then idx2 = Int(m.liveHeaderFocusIndex)
      if idx2 = 1 then
        _openDayStrip()
      else
        enterBrowse()
      end if
      return true
    end if
  end if

  ' Time ruler focus (default)
  if kl = "up" then
    _setLiveFocusTarget("header")
    return true
  end if
  if kl = "down" then
    _setLiveFocusTarget("channels")
    return true
  end if
  if kl = "left" then
    _queueLiveCursorShift(-1)
    return true
  end if
  if kl = "right" then
    _queueLiveCursorShift(1)
    return true
  end if
  if kl = "ok" then
    ch = _liveSelectedChannel()
    if ch = invalid then
      setStatus("Sem dados")
      return true
    end if
    cid = ""
    if ch.hasField("id") then cid = ch.id
    if cid <> invalid then cid = cid.ToStr().Trim()
    cursorSec = m.liveFocusSec
    if cursorSec = invalid or cursorSec <= 0 then cursorSec = _nowEpochSec()
    prog = _liveProgramForChannelAtTime(cid, cursorSec)
    if prog = invalid then
      setStatus("Sem dados")
      return true
    end if
    showLiveProgramDetails()
    return true
  end if

  return false
end function

sub applyFocus()
  if m.player <> invalid and m.player.visible = true then
    _setPlaybackInputFocus()
    return
  end if

  if m.seriesDetailOpen = true then
    if m.seriesDetailGroup <> invalid then m.seriesDetailGroup.visible = true
    _applySeriesDetailBackFocus()
    _applySeriesDetailActionFocus()
    focusTarget = m.seriesDetailFocus
    if focusTarget = invalid then focusTarget = ""
    focusTarget = LCase(focusTarget.ToStr().Trim())
    modeVal = m.seriesDetailMode
    if modeVal = invalid then modeVal = ""
    isEpisodeMode = (LCase(modeVal.ToStr().Trim()) = "episode")
    isSeries = (m.seriesDetailIsSeries = true)
    if (isEpisodeMode or isSeries <> true) and (focusTarget = "seasons" or focusTarget = "episodes") then
      focusTarget = "header"
    end if
    if focusTarget = "back" then
      if m.top <> invalid then m.top.setFocus(true)
      _setSeriesDetailScroll(0)
    else if focusTarget = "header" then
      if m.top <> invalid then m.top.setFocus(true)
      _setSeriesDetailScroll(0)
    else if focusTarget = "seasons" then
      if m.seriesDetailSeasonsList <> invalid then m.seriesDetailSeasonsList.setFocus(true)
      _ensureSeriesDetailVisible(m.seriesDetailYSeasons, m.seriesDetailRowHeight)
    else if focusTarget = "cast" then
      if m.seriesDetailCastList <> invalid then m.seriesDetailCastList.setFocus(true)
      _ensureSeriesDetailVisible(m.seriesDetailYCast, m.seriesDetailRowHeight)
    else
      if m.seriesDetailEpisodesList <> invalid then m.seriesDetailEpisodesList.setFocus(true)
      _ensureSeriesDetailVisible(m.seriesDetailYEpisodes, m.seriesDetailRowHeight)
    end if
    return
  end if

  if m.mode = "live" then
    _applyLiveFocusVisuals()
    _focusLiveTarget()
    _requestLiveRender("applyFocus")
    return
  end if

  if m.mode = "browse" then
    if m.browseLibraryOpen = true then
      _setBrowseLibraryVisible(true)
      _refreshBrowseLibraryHeader()
      searchFocused = (m.browseFocus = "library_search")
      if m.librarySearchBg <> invalid then
        if searchFocused then
          m.librarySearchBg.uri = "pkg:/images/field_focus.png"
        else
          m.librarySearchBg.uri = "pkg:/images/field_normal.png"
        end if
      end if
      if m.browseFocus = "library_items" then
        if m.libraryItemsList <> invalid then m.libraryItemsList.setFocus(true)
      else
        if m.top <> invalid then m.top.setFocus(true)
      end if
      return
    end if

    _setBrowseLibraryVisible(false)
    profileFocused = (m.browseFocus = "hero_logout")
    continueFocused = (m.browseFocus = "hero_continue")
    _syncHeroAvatarVisual()

    if m.heroPromptBg <> invalid then
      m.heroPromptBg.uri = "pkg:/images/field_normal.png"
    end if
    if m.heroAvatarBg <> invalid then
      m.heroAvatarBg.uri = "pkg:/images/overlay_circle.png"
    end if
    if m.heroAvatarText <> invalid then
      if profileFocused then
        m.heroAvatarText.color = "0xD7B25C"
      else
        m.heroAvatarText.color = "0xE6EBF3"
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

    _applyBrowseShelfScroll()

    if profileFocused or continueFocused then
      if m.top <> invalid then m.top.setFocus(true)
    else if m.browseFocus = "items" then
      if m.itemsList <> invalid then
        m.itemsList.setFocus(true)
      end if
    else if m.browseFocus = "continue" then
      if m.continueList <> invalid then m.continueList.setFocus(true)
    else if m.browseFocus = "movies" then
      if m.recentMoviesList <> invalid then m.recentMoviesList.setFocus(true)
    else if m.browseFocus = "series" then
      if m.recentSeriesList <> invalid then m.recentSeriesList.setFocus(true)
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
  stLower = LCase(st)
  if (stLower = "buffering" or stLower = "playing" or stLower = "paused") and m.settingsOpen <> true then
    ' Some firmwares steal focus when playback starts; re-assert video focus for key handling.
    _setPlaybackInputFocus()
  end if
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

  ' Fallback to /hls/master only when the signed LIVE path is absent/invalid.
  ' If a specific channel path failed, keep the error instead of forcing another channel.
  if m.playbackIsLive = true and m.liveFallbackAttempted <> true then
    p2 = m.playbackSignPath
    if p2 = invalid then p2 = ""
    p2 = p2.ToStr().Trim()
    isRoutableLivePath = (Instr(1, p2, "/hls/") = 1 or Instr(1, p2, "/live/") = 1)
    if isRoutableLivePath <> true then
      m.liveFallbackAttempted = true
      t2 = m.playbackTitle
      if t2 = invalid then t2 = ""
      t2 = t2.Trim()
      print "live error; invalid path fallback to /hls/master.m3u8 (path=" + p2 + ")"
      ' Stop without leaving UI: we're switching source.
      m.ignoreNextStopped = true
      if m.player <> invalid then m.player.control = "stop"
      if m.player <> invalid then m.player.visible = false
      signAndPlay("/hls/master.m3u8", t2)
      return
    else
      print "live error; keeping explicit path (no master fallback): " + p2
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
  exitApp()
end sub

sub exitApp()
  if m.top <> invalid and m.top.hasField("exitChannel") then
    m.top.exitChannel = true
  end if
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
  promptKind = m.pendingPrompt

  m.top.dialog = invalid
  m.pendingDialog = invalid

  if idx <> 0 then
    setStatus(_t("cancelled"))
    if promptKind = "librarySearch" then
      m.browseLibraryAutoFocusPending = true
      if _browseListCount(m.libraryItemsList) > 0 then
        m.browseFocus = "library_items"
      end if
    end if
    m.pendingPrompt = ""
    applyFocus()
    return
  end if

  if promptKind = "username" then
    m.form.username = txt.Trim()
  else if promptKind = "password" then
    m.form.password = txt
  else if promptKind = "appToken" then
    token = txt.Trim()
    cfg = loadConfig()
    saveConfig(m.apiBase, token, cfg.jellyfinToken, cfg.userId)
    setStatus("APP_TOKEN ok")
  else if promptKind = "librarySearch" then
    m.browseLibrarySearch = txt.Trim()
    m.browseLibraryAutoFocusPending = true
    _refreshBrowseLibraryHeader()
    _renderBrowseLibraryItems()
    if _browseListCount(m.libraryItemsList) > 0 then
      m.browseFocus = "library_items"
    else
      m.browseFocus = "library_search"
    end if
  end if

  m.pendingPrompt = ""
  renderForm()
  applyFocus()
end sub

sub loadSavedIntoForm()
  creds = loadLoginCreds()
  if creds <> invalid then
    u = creds.username
    p = creds.password
    if u <> invalid then m.form.username = u
    if p <> invalid then m.form.password = p
  end if
  cfg = loadConfig()
  if cfg.appToken = invalid or cfg.appToken = "" then
    if m.hintLabel <> invalid then m.hintLabel.visible = true
  else
    if m.hintLabel <> invalid then m.hintLabel.visible = false
  end if
  renderForm()
end sub

function _tryAutoLogin() as Boolean
  if m.autoLoginAttempted = true then return false
  creds = loadLoginCreds()
  if creds = invalid then return false
  u = creds.username
  p = creds.password
  if u = invalid then u = ""
  if p = invalid then p = ""
  if u.Trim() = "" or p = "" then return false
  cfg = loadConfig()
  if cfg.appToken = invalid or cfg.appToken = "" then return false
  m.form.username = u
  m.form.password = p
  renderForm()
  m.autoLoginAttempted = true
  doLogin()
  return true
end function

sub enterLogin()
  m.mode = "login"
  m.focusIndex = 0
  m.pendingJob = ""
  m.pendingLiveLoad = false
  m.pendingShelfViewId = ""
  m.queuedShelfViewId = ""
  m.pendingLibraryLoad = false
  m.pendingSeriesDetailQueued = false
  m.pendingSeriesDetailQueuedItemId = ""
  m.pendingSeriesDetailQueuedTitle = ""
  m.pendingResumeProbeQueued = false
  m.pendingResumeProbeQueuedItemId = ""
  m.pendingResumeProbeQueuedTitle = ""
  m.seriesDetailOpen = false
  if m.seriesDetailGroup <> invalid then m.seriesDetailGroup.visible = false
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
  m.pendingLiveLoad = false
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
  bindUiNodes()
  _ensureBrowseNodes()
  m.mode = "browse"
  m.pendingLiveLoad = false
  m.browseFocus = "hero_continue"
  m.heroContinueAutoplayPending = false
  m.browseLibraryOpen = false
  m.browseLibraryCollection = ""
  m.browseLibraryViewId = ""
  m.browseLibraryTitle = ""
  m.browseLibrarySearch = ""
  m.browseLibraryRawItems = []
  m.pendingLibraryViewId = ""
  m.pendingLibraryLoad = false
  m.pendingSeriesDetailQueued = false
  m.pendingSeriesDetailQueuedItemId = ""
  m.pendingSeriesDetailQueuedTitle = ""
  m.pendingResumeProbeQueued = false
  m.pendingResumeProbeQueuedItemId = ""
  m.pendingResumeProbeQueuedTitle = ""
  m.seriesDetailOpen = false
  if m.seriesDetailGroup <> invalid then m.seriesDetailGroup.visible = false
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
  m.pendingHomeShelfSection = ""
  m.homeShelfQueue = []
  m.browseMoviesViewId = ""
  m.browseSeriesViewId = ""
  m.shelfCache = {}

  if m.viewsList <> invalid then m.viewsList.content = CreateObject("roSGNode", "ContentNode")
  if m.itemsList <> invalid then m.itemsList.content = CreateObject("roSGNode", "ContentNode")
  if m.continueList <> invalid then m.continueList.content = CreateObject("roSGNode", "ContentNode")
  if m.recentMoviesList <> invalid then m.recentMoviesList.content = CreateObject("roSGNode", "ContentNode")
  if m.recentSeriesList <> invalid then m.recentSeriesList.content = CreateObject("roSGNode", "ContentNode")
  if m.libraryItemsList <> invalid then m.libraryItemsList.content = CreateObject("roSGNode", "ContentNode")
  if m.libraryEmptyLabel <> invalid then m.libraryEmptyLabel.visible = false
  if m.continueTitle <> invalid then m.continueTitle.visible = false
  if m.recentMoviesTitle <> invalid then m.recentMoviesTitle.visible = false
  if m.recentSeriesTitle <> invalid then m.recentSeriesTitle.visible = false
  _setBrowseLibraryVisible(false)
  _refreshBrowseLibraryHeader()
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
end sub

sub _setUiVisibleForPlayback(active as Boolean)
  if active = true then
    if m.seriesDetailGroup <> invalid then m.seriesDetailGroup.visible = false
    if m.loginCard <> invalid then m.loginCard.visible = false
    if m.homeCard <> invalid then m.homeCard.visible = false
    if m.browseCard <> invalid then m.browseCard.visible = false
    if m.liveCard <> invalid then m.liveCard.visible = false
    if m.hintLabel <> invalid then m.hintLabel.visible = false
    return
  end if

  if m.mode = "login" then
    if m.loginCard <> invalid then m.loginCard.visible = true
    if m.homeCard <> invalid then m.homeCard.visible = false
    if m.browseCard <> invalid then m.browseCard.visible = false
    if m.liveCard <> invalid then m.liveCard.visible = false
  else if m.mode = "home" then
    if m.loginCard <> invalid then m.loginCard.visible = false
    if m.homeCard <> invalid then m.homeCard.visible = true
    if m.browseCard <> invalid then m.browseCard.visible = false
    if m.liveCard <> invalid then m.liveCard.visible = false
  else if m.mode = "live" then
    if m.loginCard <> invalid then m.loginCard.visible = false
    if m.homeCard <> invalid then m.homeCard.visible = false
    if m.browseCard <> invalid then m.browseCard.visible = false
    if m.liveCard <> invalid then m.liveCard.visible = true
  else if m.mode = "browse" then
    if m.loginCard <> invalid then m.loginCard.visible = false
    if m.homeCard <> invalid then m.homeCard.visible = false
    if m.liveCard <> invalid then m.liveCard.visible = false
    if m.seriesDetailOpen = true then
      if m.seriesDetailGroup <> invalid then m.seriesDetailGroup.visible = true
      if m.browseCard <> invalid then m.browseCard.visible = false
    else
      if m.seriesDetailGroup <> invalid then m.seriesDetailGroup.visible = false
      if m.browseCard <> invalid then m.browseCard.visible = true
    end if
  end if
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
  viewId = ""
  if v.id <> invalid then viewId = v.id
  if viewId = invalid then viewId = ""
  viewId = viewId.ToStr().Trim()
  viewTitle = ""
  if v.title <> invalid then viewTitle = v.title
  if viewTitle = invalid then viewTitle = ""
  viewTitle = viewTitle.ToStr().Trim()

  ct = LCase(ctype.Trim())
  if ct = "livetv" then
    enterLive()
    return
  end if

  if ct = "movies" or ct = "tvshows" then
    if viewId = "" then return
    m.activeViewId = viewId
    m.activeViewCollection = ct
    _openBrowseLibrary(viewId, ct, viewTitle)
    return
  end if

  m.browseFocus = _browseSectionForCollection(ct)
  if m.browseFocus = "movies" and _browseSectionHasItems("movies") <> true then m.browseFocus = "items"
  if m.browseFocus = "series" and _browseSectionHasItems("series") <> true then
    if _browseSectionHasItems("movies") then
      m.browseFocus = "movies"
    else
      m.browseFocus = "items"
    end if
  end if
  if m.browseFocus = "items" and _browseSectionHasItems("items") <> true then
    if _browseSectionHasItems("continue") then
      m.browseFocus = "continue"
    else if _browseSectionHasItems("movies") then
      m.browseFocus = "movies"
    else if _browseSectionHasItems("series") then
      m.browseFocus = "series"
    end if
  end if
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
  isSeriesView = false
  sv = m.browseSeriesViewId
  if sv = invalid then sv = ""
  sv = sv.ToStr().Trim()
  if sv <> "" and id = sv then isSeriesView = true
  if id = "__continue" then
    m.gatewayTask.kind = "continue"
  else if id = "__top10" then
    m.gatewayTask.kind = "top10"
  else if isSeriesView then
    m.gatewayTask.kind = "shelf_series"
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

function _buildShelfContent(raw as String, rankEnabled as Boolean, section as String) as Object
  items = ParseJson(raw)
  if type(items) <> "roArray" then items = []

  cfg = loadConfig()
  posterBase = cfg.apiBase
  posterToken = cfg.jellyfinToken
  sec = section
  if sec = invalid then sec = ""
  sec = LCase(sec.Trim())

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

    if sec = "series" then
      typeL = LCase(typ0.ToStr().Trim())
      if typeL <> "series" then continue for
    end if

    if rankEnabled then
      tl = LCase(typ0.ToStr().Trim())
      nl = LCase(name0.ToStr().Trim())
      if tl = "livetvchannel" or tl = "livetv" then continue for
      if Instr(1, nl, "hdmi") > 0 then continue for
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
      if posterUri = "" then posterUri = _browseChannelPosterUri(c.id, posterBase, posterToken)
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

      if rankEnabled then
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
  return root
end function

function _browseAnyShelfItems() as Boolean
  if _browseSectionHasItems("items") then return true
  if _browseSectionHasItems("continue") then return true
  if _browseSectionHasItems("movies") then return true
  if _browseSectionHasItems("series") then return true
  return false
end function

sub _updateBrowseEmptyState()
  if m.browseEmptyLabel = invalid then return
  if m.browseLibraryOpen = true then
    m.browseEmptyLabel.visible = false
    return
  end if
  m.browseEmptyLabel.text = _t("no_items")
  m.browseEmptyLabel.visible = (_browseAnyShelfItems() <> true)
end sub

sub _renderHomeShelf(section as String, raw as String)
  sec = section
  if sec = invalid then sec = ""
  sec = LCase(sec.Trim())

  rankEnabled = (sec = "items")
  root = _buildShelfContent(raw, rankEnabled, sec)

  if sec = "items" then
    if m.itemsList <> invalid then m.itemsList.content = root
    if m.itemsTitle <> invalid then m.itemsTitle.visible = true
  else if sec = "continue" then
    if m.continueList <> invalid then m.continueList.content = root
    if m.continueTitle <> invalid then m.continueTitle.visible = (root.getChildCount() > 0)
  else if sec = "movies" then
    if m.recentMoviesList <> invalid then m.recentMoviesList.content = root
    if m.recentMoviesTitle <> invalid then m.recentMoviesTitle.visible = (root.getChildCount() > 0)
  else if sec = "series" then
    if m.recentSeriesList <> invalid then m.recentSeriesList.content = root
    if m.recentSeriesTitle <> invalid then m.recentSeriesTitle.visible = (root.getChildCount() > 0)
  end if

  _updateBrowseEmptyState()
end sub

sub _queueHomeShelf(section as String, kind as String, parentId as String, limit as Integer)
  if m.homeShelfQueue = invalid then m.homeShelfQueue = []
  req = {
    section: section
    kind: kind
    parentId: parentId
    limit: limit
  }
  m.homeShelfQueue.Push(req)
end sub

sub _startNextHomeShelfRequest()
  if m.gatewayTask = invalid then return
  if m.pendingJob <> "" then return
  if m.homeShelfQueue = invalid then return
  if m.homeShelfQueue.Count() <= 0 then
    setStatus("ready")
    return
  end if

  req = m.homeShelfQueue[0]
  m.homeShelfQueue.Delete(0)
  if type(req) <> "roAssociativeArray" then
    _startNextHomeShelfRequest()
    return
  end if

  cfg = loadConfig()
  if cfg.apiBase = "" or cfg.appToken = "" or cfg.jellyfinToken = "" or cfg.userId = "" then
    setStatus("shelf: missing config")
    return
  end if

  section = req.section
  if section = invalid then section = ""
  section = section.ToStr().Trim()
  if section = "" then
    _startNextHomeShelfRequest()
    return
  end if

  m.pendingHomeShelfSection = section
  m.pendingJob = "home_shelf"
  m.gatewayTask.kind = req.kind
  m.gatewayTask.apiBase = cfg.apiBase
  m.gatewayTask.appToken = cfg.appToken
  m.gatewayTask.jellyfinToken = cfg.jellyfinToken
  m.gatewayTask.userId = cfg.userId
  m.gatewayTask.parentId = req.parentId
  m.gatewayTask.limit = req.limit
  m.gatewayTask.control = "run"
end sub

sub _loadBrowseHomeShelves()
  m.homeShelfQueue = []
  _queueHomeShelf("items", "top10", "", 10)
  _queueHomeShelf("continue", "continue", "", 12)
  mv = m.browseMoviesViewId
  if mv = invalid then mv = ""
  mv = mv.ToStr().Trim()
  if mv <> "" then
    _queueHomeShelf("movies", "shelf", mv, 12)
  end if
  sv = m.browseSeriesViewId
  if sv = invalid then sv = ""
  sv = sv.ToStr().Trim()
  if sv <> "" then
    _queueHomeShelf("series", "shelf_series", sv, 12)
  end if
  _startNextHomeShelfRequest()
end sub

function _browseLibraryItemMatches(name as String, queryLower as String) as Boolean
  q = queryLower
  if q = invalid then q = ""
  q = LCase(q.ToStr().Trim())
  if q = "" then return true
  n = name
  if n = invalid then n = ""
  n = LCase(n.ToStr().Trim())
  if n = "" then return false
  return (Instr(1, n, q) > 0)
end function

sub _renderBrowseLibraryItems()
  if m.libraryItemsList = invalid then
    bindUiNodes()
    _ensureBrowseNodes()
    _ensureLibraryListNodes()
    if m.libraryItemsList = invalid then
      print "library render: missing list"
      return
    end if
  end if

  src = m.browseLibraryRawItems
  if type(src) <> "roArray" then src = []

  cfg = loadConfig()
  posterBase = cfg.apiBase
  posterToken = cfg.jellyfinToken

  coll = m.browseLibraryCollection
  if coll = invalid then coll = ""
  coll = LCase(coll.ToStr().Trim())

  query = m.browseLibrarySearch
  if query = invalid then query = ""
  query = query.ToStr().Trim()
  queryLower = LCase(query)

  root = CreateObject("roSGNode", "ContentNode")

  for each it in src
    name0 = ""
    typ0 = ""
    path0 = ""
    if it <> invalid then
      if it.name <> invalid then
        name0 = it.name
      else if it.Name <> invalid then
        name0 = it.Name
      end if
      if it.type <> invalid then
        typ0 = it.type
      else if it.Type <> invalid then
        typ0 = it.Type
      end if
      if it.path <> invalid then
        path0 = it.path
      else if it.Path <> invalid then
        path0 = it.Path
      end if
    end if
    if name0 = invalid then name0 = ""
    if typ0 = invalid then typ0 = ""
    if path0 = invalid then path0 = ""

    typeL = LCase(typ0.ToStr().Trim())
    if coll = "tvshows" and typeL <> "series" then continue for
    if coll = "movies" then
      if typeL = "series" or typeL = "season" or typeL = "episode" then continue for
    end if

    if _browseLibraryItemMatches(name0, queryLower) <> true then continue for

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
      if it.id <> invalid then
        c.id = it.id
      else if it.Id <> invalid then
        c.id = it.Id
      end if
      c.title = name0
      c.itemType = typ0
      c.path = path0
      posterUri = _browsePosterUri(c.id, posterBase, posterToken)
      if posterUri = "" then posterUri = _browseChannelPosterUri(c.id, posterBase, posterToken)
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
      c.rank = 0
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

  m.libraryItemsList.content = root

  if m.libraryEmptyLabel <> invalid then
    if queryLower <> "" then
      m.libraryEmptyLabel.text = _t("library_no_results")
    else
      m.libraryEmptyLabel.text = _t("no_items")
    end if
    m.libraryEmptyLabel.visible = (root.getChildCount() = 0)
  end if

  if root.getChildCount() > 0 and m.browseLibraryAutoFocusPending = true and m.pendingDialog = invalid then
    m.browseLibraryAutoFocusPending = false
    m.browseFocus = "library_items"
    applyFocus()
  end if

  if root.getChildCount() <= 0 and m.browseFocus = "library_items" then
    m.browseFocus = "library_search"
  end if
end sub

sub _loadBrowseLibraryItems()
  if m.browseLibraryOpen <> true then return
  if m.gatewayTask = invalid then return

  id = m.browseLibraryViewId
  if id = invalid then id = ""
  id = id.ToStr().Trim()
  if id = "" then return

  if m.pendingJob <> "" then
    if m.pendingJob = "home_shelf" then m.homeShelfQueue = []
    m.pendingLibraryLoad = true
    _scheduleDeferredBrowseActions()
    setStatus(_t("please_wait"))
    return
  end if

  cfg = loadConfig()
  if cfg.apiBase = "" or cfg.appToken = "" or cfg.jellyfinToken = "" or cfg.userId = "" then
    if m.libraryEmptyLabel <> invalid then
      m.libraryEmptyLabel.text = _t("missing_config")
      m.libraryEmptyLabel.visible = true
    end if
    return
  end if

  if m.libraryEmptyLabel <> invalid then
    m.libraryEmptyLabel.text = _t("loading")
    m.libraryEmptyLabel.visible = true
  end if

  coll = m.browseLibraryCollection
  if coll = invalid then coll = ""
  coll = LCase(coll.ToStr().Trim())

  print "library request viewId=" + id + " coll=" + coll
  m.pendingLibraryLoad = false
  setStatus(_t("loading_items"))
  m.pendingLibraryViewId = id
  m.pendingJob = "library_shelf"
  if coll = "tvshows" then
    m.gatewayTask.kind = "shelf_series"
  else
    m.gatewayTask.kind = "shelf"
  end if
  m.gatewayTask.apiBase = cfg.apiBase
  m.gatewayTask.appToken = cfg.appToken
  m.gatewayTask.jellyfinToken = cfg.jellyfinToken
  m.gatewayTask.userId = cfg.userId
  m.gatewayTask.parentId = id
  m.gatewayTask.limit = 240
  m.gatewayTask.control = "run"
end sub

sub _promptBrowseLibrarySearch()
  if m.browseLibraryOpen <> true then return
  title = _t("library_search_title")
  t = m.browseLibraryTitle
  if t = invalid then t = ""
  t = t.ToStr().Trim()
  if t <> "" then title = title + ": " + t
  promptKeyboard("librarySearch", title, m.browseLibrarySearch, false)
end sub

sub _openBrowseLibrary(viewId as String, collectionType as String, title as String)
  bindUiNodes()
  _ensureBrowseNodes()
  _ensureLibraryListNodes()
  id = viewId
  if id = invalid then id = ""
  id = id.ToStr().Trim()
  if id = "" then return

  ct = collectionType
  if ct = invalid then ct = ""
  ct = LCase(ct.ToStr().Trim())
  if ct <> "movies" and ct <> "tvshows" then return

  m.browseLibraryOpen = true
  m.pendingLibraryLoad = false
  m.browseLibraryViewId = id
  m.browseLibraryCollection = ct

  ttl = title
  if ttl = invalid then ttl = ""
  ttl = ttl.ToStr().Trim()
  if ttl = "" then
    if ct = "tvshows" then
      ttl = _t("library_series")
    else
      ttl = _t("library_movies")
    end if
  end if
  m.browseLibraryTitle = ttl
  m.browseLibrarySearch = ""
  m.browseLibraryRawItems = []
  m.browseLibraryAutoFocusPending = false
  m.pendingLibraryViewId = ""
  if m.libraryItemsList <> invalid then m.libraryItemsList.content = CreateObject("roSGNode", "ContentNode")
  if m.libraryEmptyLabel <> invalid then
    m.libraryEmptyLabel.text = _t("loading")
    m.libraryEmptyLabel.visible = true
  end if

  _setBrowseLibraryVisible(true)
  _refreshBrowseLibraryHeader()
  m.browseFocus = "library_items"
  applyFocus()

  if m.pendingJob = "home_shelf" then m.homeShelfQueue = []
  _loadBrowseLibraryItems()
end sub

sub _closeBrowseLibrary()
  if m.browseLibraryOpen <> true then return

  m.browseLibraryOpen = false
  m.browseLibraryCollection = ""
  m.browseLibraryViewId = ""
  m.browseLibraryTitle = ""
  m.browseLibrarySearch = ""
  m.browseLibraryRawItems = []
  m.browseLibraryAutoFocusPending = false
  m.pendingLibraryViewId = ""
  m.pendingLibraryLoad = false
  m.pendingSeriesDetailQueued = false
  m.pendingSeriesDetailQueuedItemId = ""
  m.pendingSeriesDetailQueuedTitle = ""
  m.pendingSeriesDetailItemId = ""
  m.pendingSeriesDetailTitle = ""
  m.seriesDetailPlayEpisodeId = ""
  m.seriesDetailPlayEpisodeTitle = ""

  if m.libraryItemsList <> invalid then m.libraryItemsList.content = CreateObject("roSGNode", "ContentNode")
  if m.libraryEmptyLabel <> invalid then m.libraryEmptyLabel.visible = false

  _setBrowseLibraryVisible(false)
  m.browseFocus = "views"
  _updateBrowseEmptyState()
  applyFocus()
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
      if posterUri = "" then posterUri = _browseChannelPosterUri(c.id, posterBase, posterToken)
      if posterUri = "" then posterUri = _browseChannelImageUri(c.id, posterBase, posterToken, "Logo")
      if posterUri = "" then posterUri = "pkg:/images/logo.png"
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

sub requestSeriesDetails(itemId as String, title as String)
  id = itemId
  if id = invalid then id = ""
  id = id.ToStr().Trim()
  if id = "" then return

  if m.gatewayTask = invalid then
    setStatus("gateway: missing task")
    return
  end if
  if m.pendingJob <> "" then
    if m.pendingJob = "home_shelf" then m.homeShelfQueue = []
    m.pendingSeriesDetailQueued = true
    m.pendingSeriesDetailQueuedItemId = id
    m.pendingSeriesDetailQueuedTitle = title
    print "series detail queued id=" + id + " pendingJob=" + m.pendingJob
    setStatus(_t("loading_details"))
    _scheduleDeferredBrowseActions()
    return
  end if

  cfg = loadConfig()
  if cfg.apiBase = "" or cfg.appToken = "" or cfg.jellyfinToken = "" or cfg.userId = "" then
    setStatus(_t("missing_config"))
    return
  end if

  t = title
  if t = invalid then t = ""
  t = t.ToStr().Trim()
  if t = "" then t = "Series"

  m.pendingSeriesDetailItemId = id
  m.pendingSeriesDetailTitle = t
  m.seriesDetailPlayEpisodeId = ""
  m.seriesDetailPlayEpisodeTitle = ""

  print "series detail request id=" + id + " title=" + t
  setStatus(_t("loading_details"))
  m.pendingJob = "series_detail"
  m.gatewayTask.kind = "series_detail"
  m.gatewayTask.apiBase = cfg.apiBase
  m.gatewayTask.appToken = cfg.appToken
  m.gatewayTask.jellyfinToken = cfg.jellyfinToken
  m.gatewayTask.userId = cfg.userId
  m.gatewayTask.itemId = id
  m.gatewayTask.limit = 24
  m.gatewayTask.control = "run"
end sub

sub requestResumeProbe(itemId as String, title as String)
  id = itemId
  if id = invalid then id = ""
  id = id.ToStr().Trim()
  if id = "" then
    playVodById(itemId, title)
    return
  end if

  t = title
  if t = invalid then t = ""
  t = t.ToStr().Trim()
  if t = "" then t = "Video"

  if m.gatewayTask = invalid then
    playVodById(id, t)
    return
  end if

  if m.pendingJob <> "" then
    m.pendingResumeProbeQueued = true
    m.pendingResumeProbeQueuedItemId = id
    m.pendingResumeProbeQueuedTitle = t
    print "resume probe queued id=" + id + " pendingJob=" + m.pendingJob
    _scheduleDeferredBrowseActions()
    return
  end if

  cfg = loadConfig()
  if cfg.apiBase = "" or cfg.appToken = "" or cfg.jellyfinToken = "" or cfg.userId = "" then
    playVodById(id, t)
    return
  end if

  m.pendingResumeProbeItemId = id
  m.pendingResumeProbeTitle = t
  print "resume probe request id=" + id + " title=" + t
  m.pendingJob = "resume_probe"
  m.gatewayTask.kind = "progress_item"
  m.gatewayTask.apiBase = cfg.apiBase
  m.gatewayTask.appToken = cfg.appToken
  m.gatewayTask.jellyfinToken = cfg.jellyfinToken
  m.gatewayTask.userId = cfg.userId
  m.gatewayTask.itemId = id
  m.gatewayTask.limit = 180
  m.gatewayTask.control = "run"
end sub

function _seriesIntText(v as Dynamic) as String
  if v = invalid then return ""
  n = _sceneIntFromAny(v)
  if n < 0 then return ""
  return n.ToStr()
end function

function _compactDialogText(raw as Dynamic, maxChars as Integer) as String
  s = raw
  if s = invalid then s = ""
  s = s.ToStr().Trim()
  if s = "" then return ""

  lim = maxChars
  if lim <= 0 then lim = 240
  if Len(s) <= lim then return s
  if lim <= 3 then return Left(s, lim)
  return Left(s, lim - 3).Trim() + "..."
end function

function _buildSeriesDetailsMessage(payload as Object) as String
  data = payload
  if type(data) <> "roAssociativeArray" then data = {}

  series = data.series
  if type(series) <> "roAssociativeArray" then series = {}

  overview = ""
  if series.overview <> invalid then overview = series.overview.ToStr().Trim()
  overview = _compactDialogText(overview, 420)
  if overview = "" then overview = _t("series_no_overview")

  seasons = data.seasons
  if type(seasons) <> "roArray" then seasons = []
  eps = data.episodes
  if type(eps) <> "roArray" then eps = []

  msg = overview + Chr(10) + Chr(10)
  msg = msg + _t("series_seasons") + ": " + seasons.Count().ToStr() + Chr(10)
  msg = msg + _t("series_episodes") + ": " + eps.Count().ToStr()

  if eps.Count() > 0 then
    msg = msg + Chr(10) + Chr(10)
    maxEps = eps.Count()
    if maxEps > 12 then maxEps = 12
    j = 0
    while j < maxEps
      e = eps[j]
      eName = ""
      seasonNum = ""
      episodeNum = ""
      if e <> invalid then
        if e.name <> invalid then eName = e.name.ToStr().Trim()
        if e.parentIndexNumber <> invalid then seasonNum = _seriesIntText(e.parentIndexNumber)
        if e.indexNumber <> invalid then episodeNum = _seriesIntText(e.indexNumber)
      end if
      if eName = "" then eName = "Episode " + (j + 1).ToStr()
      eName = _compactDialogText(eName, 68)
      prefix = ""
      if seasonNum <> "" or episodeNum <> "" then
        prefix = "S"
        if seasonNum <> "" then prefix = prefix + seasonNum else prefix = prefix + "?"
        prefix = prefix + "E"
        if episodeNum <> "" then prefix = prefix + episodeNum else prefix = prefix + "?"
        prefix = " - " + prefix + " "
      else
        prefix = " - "
      end if
      msg = msg + prefix + eName + Chr(10)
      j = j + 1
    end while
    if eps.Count() > maxEps then
      msg = msg + " - ..." + Chr(10)
    end if
  end if

  return msg.Trim()
end function

function _seriesSeasonIndexFromObj(s as Object, fallbackIdx as Integer) as Integer
  idx = -1
  if s <> invalid and s.indexNumber <> invalid then
    idx = _sceneIntFromAny(s.indexNumber)
  end if
  if idx < 0 then idx = fallbackIdx
  return idx
end function

function _seriesEpisodeSeasonIndex(ep as Object) as Integer
  if ep = invalid then return -1
  if ep.parentIndexNumber <> invalid then return _sceneIntFromAny(ep.parentIndexNumber)
  return -1
end function

function _seriesEpisodeIndex(ep as Object) as Integer
  if ep = invalid then return -1
  if ep.indexNumber <> invalid then return _sceneIntFromAny(ep.indexNumber)
  return -1
end function

function _seriesJoin(parts as Object, sep as String) as String
  if type(parts) <> "roArray" then return ""
  s = ""
  for each p in parts
    if p = invalid then
      continue for
    end if
    v = p.ToStr().Trim()
    if v = "" then
      continue for
    end if
    if s = "" then
      s = v
    else
      s = s + sep + v
    end if
  end for
  return s
end function

function _countEpisodesForSeason(seasonIdx as Integer, episodes as Object) as Integer
  if seasonIdx <= 0 then return 0
  if type(episodes) <> "roArray" then return 0
  cnt = 0
  for each ep in episodes
    if _seriesEpisodeSeasonIndex(ep) = seasonIdx then cnt = cnt + 1
  end for
  return cnt
end function

function _hasTrailerFromItem(item as Object) as Boolean
  if type(item) <> "roAssociativeArray" then return false

  if item.HasLocalTrailer = true then return true

  sawCount = false
  if item.LocalTrailerCount <> invalid then
    sawCount = true
    if _sceneIntFromAny(item.LocalTrailerCount) > 0 then return true
  end if
  if item.TrailerCount <> invalid then
    sawCount = true
    if _sceneIntFromAny(item.TrailerCount) > 0 then return true
  end if

  if item.TrailerUrl <> invalid and item.TrailerUrl.ToStr().Trim() <> "" then return true
  if item.trailerUrl <> invalid and item.trailerUrl.ToStr().Trim() <> "" then return true

  arr = item.RemoteTrailers
  if type(arr) = "roArray" and arr.Count() > 0 then return true
  arr2 = item.remoteTrailers
  if type(arr2) = "roArray" and arr2.Count() > 0 then return true
  arr3 = item.Trailers
  if type(arr3) = "roArray" and arr3.Count() > 0 then return true

  if sawCount = true then return false
  return true
end function

function _pickTrailerUrlFromArray(arr as Object) as String
  if type(arr) <> "roArray" then return ""
  best = ""
  yt = ""
  for each t in arr
    if t = invalid then continue for
    u = ""
    if t.Url <> invalid then u = t.Url.ToStr().Trim()
    if u = "" and t.url <> invalid then u = t.url.ToStr().Trim()
    if u = "" then
      continue for
    end if
    low = LCase(u)
    if Instr(1, low, "youtube") > 0 or Instr(1, low, "youtu.be") > 0 then
      if yt = "" then yt = u
    else
      return u
    end if
    if best = "" then best = u
  end for
  if yt <> "" then return yt
  return best
end function

function _resolveTrailerUrlFromSeries(series as Object) as String
  if type(series) <> "roAssociativeArray" then return ""

  u = ""
  if series.trailerUrl <> invalid then u = series.trailerUrl.ToStr().Trim()
  if u = "" and series.TrailerUrl <> invalid then u = series.TrailerUrl.ToStr().Trim()
  if u <> "" then return u

  u = _pickTrailerUrlFromArray(series.remoteTrailers)
  if u <> "" then return u
  u = _pickTrailerUrlFromArray(series.RemoteTrailers)
  if u <> "" then return u

  u = _pickTrailerUrlFromArray(series.trailers)
  if u <> "" then return u
  u = _pickTrailerUrlFromArray(series.Trailers)
  return u
end function

function _extractYoutubeId(rawUrl as String) as String
  if rawUrl = invalid then return ""
  s = rawUrl.ToStr()
  if s = invalid then return ""
  s = s.Trim()
  if s = "" then return ""

  re = CreateObject("roRegex", "(?:v=|youtu\\.be/|/embed/|/shorts/|/v/)([A-Za-z0-9_-]+)", "i")
  if re = invalid then return ""
  m = re.Match(s)
  if m = invalid or m.Count() < 2 then return ""

  return m[1].ToStr().Trim()
end function

sub _openTrailerFromSeries()
  url = m.seriesDetailTrailerUrl
  if url = invalid then url = ""
  url = url.ToStr().Trim()
  if url = "" then
    setStatus("trailer: missing url")
    return
  end if

  title = _t("detail_trailer")
  if m.seriesDetailTitle <> invalid and m.seriesDetailTitle.text <> invalid then
    t = m.seriesDetailTitle.text.ToStr().Trim()
    if t <> "" then title = t
  end if

  lowUrl = LCase(url)
  isYouTube = (Instr(1, lowUrl, "youtube") > 0 or Instr(1, lowUrl, "youtu.be") > 0)

  vid = m.seriesDetailTrailerId
  if vid = invalid then vid = ""
  vid = vid.ToStr().Trim()
  if vid = "" and isYouTube then vid = _extractYoutubeId(url)
  if isYouTube then
    ytUrl = "https://www.youtube.com/watch?v=" + vid
    print "trailer manual fallback vid=" + vid + " url=" + ytUrl
    if m.pendingDialog = invalid then
      dlg = CreateObject("roSGNode", "Dialog")
      dlg.title = "Trailer"
      q = title
      if q = invalid or q = "" then q = "Trailer"
      dlg.message = "Abra o YouTube e busque por:" + Chr(10) + q + " trailer"
      dlg.buttons = ["OK"]
      dlg.observeField("buttonSelected", "onTokensDone")
      m.pendingDialog = dlg
      m.top.dialog = dlg
      dlg.setFocus(true)
    end if
    return
  end if

  fmt = inferStreamFormat(url, "")
  startVideo(url, title, fmt, false, "trailer", "")
end sub

sub _renderSeriesDetailCast(people as Object)
  if m.seriesDetailCastList = invalid then return

  arr = people
  if type(arr) <> "roArray" then arr = []

  cfg = loadConfig()
  castRoot = CreateObject("roSGNode", "ContentNode")
  for each p in arr
    if p = invalid then
      continue for
    end if
    pid = ""
    pname = ""
    if p.Id <> invalid then pid = p.Id.ToStr().Trim()
    if p.Name <> invalid then pname = p.Name.ToStr().Trim()
    if pname = "" then
      continue for
    end if
    c2 = CreateObject("roSGNode", "ContentNode")
    c2.addField("itemType", "string", false)
    c2.addField("meta", "string", false)
    c2.itemType = "person"
    c2.title = pname
    role = ""
    if p.Role <> invalid then role = p.Role.ToStr().Trim()
    if role = "" and p.Character <> invalid then role = p.Character.ToStr().Trim()
    if role = "" and p.Type <> invalid then role = p.Type.ToStr().Trim()
    c2.meta = role
    if pid <> "" then
      pPoster = _browsePosterUri(pid, cfg.apiBase, cfg.jellyfinToken)
      if pPoster <> "" then c2.hdPosterUrl = pPoster
    end if
    castRoot.appendChild(c2)
  end for
  m.seriesDetailCastList.content = castRoot
  if castRoot.getChildCount() > 0 then
    m.seriesDetailCastList.itemFocused = 0
  end if
  m.seriesDetailCastCount = castRoot.getChildCount()
  if m.seriesDetailCastTitle <> invalid then
    m.seriesDetailCastTitle.visible = (m.seriesDetailCastCount > 0)
  end if
  m.seriesDetailCastList.visible = (m.seriesDetailCastCount > 0)
end sub

sub _renderSeriesDetailEpisodes(seasonIdx as Integer)
  if m.seriesDetailEpisodesList = invalid then return

  eps = m.seriesDetailEpisodes
  if type(eps) <> "roArray" then eps = []

  cfg = loadConfig()
  posterBase = cfg.apiBase
  posterToken = cfg.jellyfinToken
  fallbackPoster = ""
  if m.seriesDetailPoster <> invalid and m.seriesDetailPoster.uri <> invalid then
    fallbackPoster = m.seriesDetailPoster.uri.ToStr().Trim()
  end if

  root = CreateObject("roSGNode", "ContentNode")
  for each ep in eps
    if seasonIdx > 0 then
      sIdx = _seriesEpisodeSeasonIndex(ep)
      if sIdx <> seasonIdx then
        continue for
      end if
    end if

    eid = ""
    ename = ""
    eover = ""
    pidx = _seriesEpisodeSeasonIndex(ep)
    eidx = _seriesEpisodeIndex(ep)
    if ep <> invalid then
      if ep.id <> invalid then eid = ep.id
      if ep.name <> invalid then ename = ep.name.ToStr().Trim()
      if ep.overview <> invalid then eover = ep.overview.ToStr().Trim()
    end if
    if ename = "" then ename = "Episode"

    c = CreateObject("roSGNode", "ContentNode")
    c.addField("itemType", "string", false)
    c.addField("meta", "string", false)
    if eid <> invalid and eid.Trim() <> "" then c.id = eid.Trim()
    c.title = ename
    c.itemType = "episode"
    c.meta = _compactDialogText(eover, 140)

    posterUri = ""
    if eid <> "" then posterUri = _browsePosterUri(eid, posterBase, posterToken)
    if posterUri = "" then posterUri = fallbackPoster
    if posterUri <> "" then c.hdPosterUrl = posterUri

    root.appendChild(c)
  end for

  m.seriesDetailEpisodesList.content = root
  if root.getChildCount() > 0 then
    m.seriesDetailEpisodesList.itemFocused = 0
  end if
end sub

sub _renderSeriesDetail(payload as Object)
  data = payload
  if type(data) <> "roAssociativeArray" then data = {}
  series = data.series
  if type(series) <> "roAssociativeArray" then series = {}
  seasons = data.seasons
  if type(seasons) <> "roArray" then seasons = []
  eps = data.episodes
  if type(eps) <> "roArray" then eps = []

  m.seriesDetailData = data
  m.seriesDetailSeasons = seasons
  m.seriesDetailEpisodes = eps

  title = ""
  if series.name <> invalid then title = series.name.ToStr().Trim()
  if title = "" and m.pendingSeriesDetailTitle <> invalid then title = m.pendingSeriesDetailTitle.ToStr().Trim()
  if title = "" then title = "Series"
  if m.seriesDetailTitle <> invalid then m.seriesDetailTitle.text = title

  typRaw = ""
  if series.type <> invalid then typRaw = series.type.ToStr().Trim()
  if typRaw = "" and series.Type <> invalid then typRaw = series.Type.ToStr().Trim()
  typL = LCase(typRaw)
  isSeries = (typL = "series" or typL = "tvshow" or typL = "tvshows")
  m.seriesDetailIsSeries = (isSeries = true)
  if m.seriesDetailType <> invalid then
    if isSeries then
      m.seriesDetailType.text = _t("detail_series")
    else if typL = "movie" then
      m.seriesDetailType.text = _t("detail_movie")
    else if typRaw <> "" then
      m.seriesDetailType.text = typRaw
    else
      m.seriesDetailType.text = _t("detail_movie")
    end if
  end if

  trailerUrl = _resolveTrailerUrlFromSeries(series)
  trailerId = _extractYoutubeId(trailerUrl)
  m.seriesDetailTrailerUrl = trailerUrl
  m.seriesDetailTrailerId = trailerId
  m.seriesDetailHasTrailer = (trailerUrl <> "")
  if m.trailerEnabled <> true then
    m.seriesDetailHasTrailer = false
    m.seriesDetailTrailerUrl = ""
    m.seriesDetailTrailerId = ""
  end if

  yr = 0
  if series.productionYear <> invalid then yr = _sceneIntFromAny(series.productionYear)
  yrText = ""
  if yr > 0 then yrText = yr.ToStr()

  ratingText = _formatRating(series.communityRating)

  ageText = ""
  if series.officialRating <> invalid then ageText = series.officialRating.ToStr().Trim()
  if ageText = "" and series.OfficialRating <> invalid then ageText = series.OfficialRating.ToStr().Trim()

  _setDetailChip(m.seriesDetailChipYear, m.seriesDetailChipYearBg, m.seriesDetailChipYearText, yrText)
  _setDetailChip(m.seriesDetailChipAge, m.seriesDetailChipAgeBg, m.seriesDetailChipAgeText, ageText)
  _setDetailChip(m.seriesDetailChipRating, m.seriesDetailChipRatingBg, m.seriesDetailChipRatingText, ratingText)
  _layoutDetailChips()

  genresText = _seriesGenresText(series.genres)
  if genresText = "" and series.Genres <> invalid then genresText = _seriesGenresText(series.Genres)
  if m.seriesDetailGenres <> invalid then
    m.seriesDetailGenres.text = genresText
    m.seriesDetailGenres.visible = (genresText <> "")
  end if

  overview = ""
  if series.overview <> invalid then overview = series.overview.ToStr().Trim()
  if overview = "" then overview = _t("series_no_overview")
  if m.seriesDetailOverview <> invalid then m.seriesDetailOverview.text = _compactDialogText(overview, 700)

  runtimeMin = _minutesFromTicks(series.runTimeTicks)
  if runtimeMin <= 0 and series.RunTimeTicks <> invalid then runtimeMin = _minutesFromTicks(series.RunTimeTicks)
  if runtimeMin < 0 then runtimeMin = 0
  runtimeText = _t("detail_runtime") + " " + runtimeMin.ToStr() + " min"
  if m.seriesDetailRuntime <> invalid then
    m.seriesDetailRuntime.text = runtimeText
    m.seriesDetailRuntime.visible = true
  end if

  cfg = loadConfig()
  posterUri = _browsePosterUri(series.id, cfg.apiBase, cfg.jellyfinToken)
  if posterUri = "" then posterUri = "pkg:/images/logo.png"
  if m.seriesDetailPoster <> invalid then m.seriesDetailPoster.uri = posterUri

  backdropTag = ""
  if series.backdropTags <> invalid and type(series.backdropTags) = "roArray" and series.backdropTags.Count() > 0 then
    backdropTag = series.backdropTags[0].ToStr().Trim()
  else if series.BackdropImageTags <> invalid and type(series.BackdropImageTags) = "roArray" and series.BackdropImageTags.Count() > 0 then
    backdropTag = series.BackdropImageTags[0].ToStr().Trim()
  end if
  heroUri = _browseBackdropUri(series.id, cfg.apiBase, cfg.jellyfinToken, backdropTag)
  if heroUri = "" then heroUri = posterUri
  if m.seriesDetailHero <> invalid then m.seriesDetailHero.uri = heroUri
  m.seriesDetailHeroUri = heroUri

  people = series.people
  if people = invalid then people = series.People
  if type(people) <> "roArray" then people = []
  m.seriesDetailCast = people
  _renderSeriesDetailCast(people)
  if m.seriesDetailCastCount > 0 then
    if m.seriesDetailIsSeries = true then
      m.seriesDetailContentHeight = 1840
    else
      m.seriesDetailContentHeight = 1290
    end if
  else
    if m.seriesDetailIsSeries = true then
      m.seriesDetailContentHeight = 1590
    else
      m.seriesDetailContentHeight = 1140
    end if
  end if

  if m.seriesDetailSeasonsList <> invalid then
    sRoot = CreateObject("roSGNode", "ContentNode")
    idx = 1
    for each s in seasons
      sIdx = _seriesSeasonIndexFromObj(s, idx)
      sName = ""
      if s <> invalid and s.name <> invalid then sName = s.name.ToStr().Trim()
      if sName = "" then sName = _t("series_seasons") + " " + sIdx.ToStr()
      c = CreateObject("roSGNode", "ContentNode")
      c.addField("seasonIndex", "integer", false)
      c.title = sName
      c.seasonIndex = sIdx
      seasonPoster = ""
      if s <> invalid and s.id <> invalid then seasonPoster = _browsePosterUri(s.id, cfg.apiBase, cfg.jellyfinToken)
      if seasonPoster = "" then seasonPoster = posterUri
      if seasonPoster <> "" then c.hdPosterUrl = seasonPoster
      sRoot.appendChild(c)
      idx = idx + 1
    end for
    m.seriesDetailSeasonsList.content = sRoot
    if sRoot.getChildCount() > 0 then
      m.seriesDetailSeasonsList.itemFocused = 0
      first = sRoot.getChild(0)
      if first <> invalid and first.hasField("seasonIndex") then
        m.seriesDetailSeasonIndex = _sceneIntFromAny(first.seasonIndex)
      else
        m.seriesDetailSeasonIndex = -1
      end if
    else
      m.seriesDetailSeasonIndex = -1
    end if
  end if

  _renderSeriesDetailEpisodes(m.seriesDetailSeasonIndex)
end sub

sub _renderEpisodeDetail(ep as Object)
  data = m.seriesDetailData
  if type(data) <> "roAssociativeArray" then data = {}
  series = data.series
  if type(series) <> "roAssociativeArray" then series = {}

  e = ep
  if type(e) <> "roAssociativeArray" then e = {}

  title = ""
  if e.name <> invalid then title = e.name.ToStr().Trim()
  if title = "" and e.Name <> invalid then title = e.Name.ToStr().Trim()
  if title = "" then title = "Episode"
  if m.seriesDetailTitle <> invalid then m.seriesDetailTitle.text = title

  if m.seriesDetailType <> invalid then m.seriesDetailType.text = _t("detail_episode")
  m.seriesDetailHasTrailer = false
  m.seriesDetailTrailerUrl = ""
  m.seriesDetailTrailerId = ""

  yr = 0
  if e.productionYear <> invalid then yr = _sceneIntFromAny(e.productionYear)
  if yr <= 0 and e.ProductionYear <> invalid then yr = _sceneIntFromAny(e.ProductionYear)
  if yr <= 0 and series.productionYear <> invalid then yr = _sceneIntFromAny(series.productionYear)
  if yr <= 0 and series.ProductionYear <> invalid then yr = _sceneIntFromAny(series.ProductionYear)
  yrText = ""
  if yr > 0 then yrText = yr.ToStr()

  ratingText = _formatRating(e.communityRating)
  if ratingText = "" then ratingText = _formatRating(series.communityRating)

  ageText = ""
  if e.officialRating <> invalid then ageText = e.officialRating.ToStr().Trim()
  if ageText = "" and e.OfficialRating <> invalid then ageText = e.OfficialRating.ToStr().Trim()
  if ageText = "" and series.officialRating <> invalid then ageText = series.officialRating.ToStr().Trim()
  if ageText = "" and series.OfficialRating <> invalid then ageText = series.OfficialRating.ToStr().Trim()

  _setDetailChip(m.seriesDetailChipYear, m.seriesDetailChipYearBg, m.seriesDetailChipYearText, yrText)
  _setDetailChip(m.seriesDetailChipAge, m.seriesDetailChipAgeBg, m.seriesDetailChipAgeText, ageText)
  _setDetailChip(m.seriesDetailChipRating, m.seriesDetailChipRatingBg, m.seriesDetailChipRatingText, ratingText)
  _layoutDetailChips()

  if m.seriesDetailGenres <> invalid then
    m.seriesDetailGenres.text = ""
    m.seriesDetailGenres.visible = false
  end if

  overview = ""
  if e.overview <> invalid then overview = e.overview.ToStr().Trim()
  if overview = "" and e.Overview <> invalid then overview = e.Overview.ToStr().Trim()
  if overview = "" then overview = _t("series_no_overview")
  if m.seriesDetailOverview <> invalid then m.seriesDetailOverview.text = _compactDialogText(overview, 700)

  runtimeMin = _minutesFromTicks(e.runTimeTicks)
  if runtimeMin <= 0 and e.RunTimeTicks <> invalid then runtimeMin = _minutesFromTicks(e.RunTimeTicks)
  if runtimeMin < 0 then runtimeMin = 0
  runtimeText = _t("detail_runtime") + " " + runtimeMin.ToStr() + " min"
  if m.seriesDetailRuntime <> invalid then
    m.seriesDetailRuntime.text = runtimeText
    m.seriesDetailRuntime.visible = true
  end if

  cfg = loadConfig()
  seriesId = ""
  if series.id <> invalid then seriesId = series.id.ToStr().Trim()
  if seriesId = "" and series.Id <> invalid then seriesId = series.Id.ToStr().Trim()
  posterUri = ""
  epId = ""
  if e.id <> invalid then epId = e.id.ToStr().Trim()
  if epId = "" and e.Id <> invalid then epId = e.Id.ToStr().Trim()
  if epId <> "" then posterUri = _browsePosterUri(epId, cfg.apiBase, cfg.jellyfinToken)
  if posterUri = "" and seriesId <> "" then posterUri = _browsePosterUri(seriesId, cfg.apiBase, cfg.jellyfinToken)
  if posterUri = "" then posterUri = "pkg:/images/logo.png"
  if m.seriesDetailPoster <> invalid then m.seriesDetailPoster.uri = posterUri

  backdropTag = ""
  if e.backdropTags <> invalid and type(e.backdropTags) = "roArray" and e.backdropTags.Count() > 0 then
    backdropTag = e.backdropTags[0].ToStr().Trim()
  else if e.BackdropImageTags <> invalid and type(e.BackdropImageTags) = "roArray" and e.BackdropImageTags.Count() > 0 then
    backdropTag = e.BackdropImageTags[0].ToStr().Trim()
  end if

  heroId = ""
  if epId <> "" then heroId = epId
  if backdropTag = "" and e.ParentBackdropImageTags <> invalid and type(e.ParentBackdropImageTags) = "roArray" and e.ParentBackdropImageTags.Count() > 0 then
    backdropTag = e.ParentBackdropImageTags[0].ToStr().Trim()
    if seriesId <> "" then heroId = seriesId
  end if

  heroUri = m.seriesDetailHeroUri
  if heroUri = invalid then heroUri = ""
  heroUri = heroUri.ToStr().Trim()
  if heroUri = "" then
    if heroId <> "" and backdropTag <> "" then
      heroUri = _browseBackdropUri(heroId, cfg.apiBase, cfg.jellyfinToken, backdropTag)
    end if
  end if
  if heroUri = "" then heroUri = posterUri
  if m.seriesDetailHero <> invalid then m.seriesDetailHero.uri = heroUri

  people = e.people
  if people = invalid then people = e.People
  if type(people) <> "roArray" then people = m.seriesDetailCast
  _renderSeriesDetailCast(people)
end sub

sub _applySeriesDetailModeLayout()
  modeVal = m.seriesDetailMode
  if modeVal = invalid then modeVal = ""
  isEpisodeMode = (LCase(modeVal.ToStr().Trim()) = "episode")
  isSeries = (m.seriesDetailIsSeries = true)
  isSimple = (isEpisodeMode or isSeries <> true)

  if m.seriesDetailSeasonsTitle <> invalid then m.seriesDetailSeasonsTitle.visible = (isSimple <> true)
  if m.seriesDetailSeasonsList <> invalid then m.seriesDetailSeasonsList.visible = (isSimple <> true)
  if m.seriesDetailEpisodesTitle <> invalid then m.seriesDetailEpisodesTitle.visible = (isSimple <> true)
  if m.seriesDetailEpisodesList <> invalid then m.seriesDetailEpisodesList.visible = (isSimple <> true)

  if m.seriesDetailActionTrailerBg <> invalid then m.seriesDetailActionTrailerBg.visible = (isEpisodeMode <> true)
  if m.seriesDetailActionTrailerText <> invalid then m.seriesDetailActionTrailerText.visible = (isEpisodeMode <> true)
  if m.seriesDetailActionTrailerFocus <> invalid then m.seriesDetailActionTrailerFocus.visible = (isEpisodeMode <> true)
  if isEpisodeMode <> true then
    hasTrailer = (m.seriesDetailHasTrailer = true)
    if m.seriesDetailActionTrailerBg <> invalid then m.seriesDetailActionTrailerBg.visible = hasTrailer
    if m.seriesDetailActionTrailerText <> invalid then m.seriesDetailActionTrailerText.visible = hasTrailer
    if m.seriesDetailActionTrailerFocus <> invalid then m.seriesDetailActionTrailerFocus.visible = false
  end if

  if isSimple then
    if m.seriesDetailCastTitle <> invalid then m.seriesDetailCastTitle.translation = [60, 990]
    if m.seriesDetailCastList <> invalid then m.seriesDetailCastList.translation = [60, 1010]
    m.seriesDetailYCast = 1010
    if m.seriesDetailCastCount > 0 then
      m.seriesDetailContentHeight = 1290
    else
      m.seriesDetailContentHeight = 1140
    end if
    m.seriesDetailActionFocus = 0
  else
    if m.seriesDetailCastTitle <> invalid then m.seriesDetailCastTitle.translation = [60, 1490]
    if m.seriesDetailCastList <> invalid then m.seriesDetailCastList.translation = [60, 1510]
    m.seriesDetailYCast = 1510
    if m.seriesDetailHasTrailer <> true then m.seriesDetailActionFocus = 0
  end if
end sub

sub _showSeriesDetailScreen(payload as Object)
  if m.seriesDetailGroup = invalid then
    _showSeriesDetailDialog(payload)
    return
  end if
  if m.pendingDialog <> invalid and m.top.dialog = invalid then m.pendingDialog = invalid
  if m.pendingDialog <> invalid then return

  m.seriesDetailMode = "series"
  m.seriesDetailEpisode = {}
  _renderSeriesDetail(payload)
  _applySeriesDetailModeLayout()
  statusId = ""
  if payload <> invalid then
    if m.seriesDetailIsSeries = true then
      if payload.firstEpisodeId <> invalid then statusId = payload.firstEpisodeId.ToStr().Trim()
    else
      series0 = payload.series
      if type(series0) <> "roAssociativeArray" then series0 = {}
      if series0.id <> invalid then statusId = series0.id.ToStr().Trim()
      if statusId = "" and series0.Id <> invalid then statusId = series0.Id.ToStr().Trim()
    end if
  end if
  m.seriesDetailStatusItemId = statusId
  m.seriesDetailActionFocus = 0
  _applySeriesDetailStatus("")
  _setSeriesDetailScroll(0)
  m.seriesDetailOpen = true
  m.seriesDetailFocus = "header"
  if m.seriesDetailGroup <> invalid then m.seriesDetailGroup.visible = true
  if m.browseCard <> invalid then m.browseCard.visible = false
  applyFocus()
end sub

sub _showEpisodeDetailScreen(it as Object)
  if m.seriesDetailOpen <> true then return

  eid = ""
  if it <> invalid and it.id <> invalid then eid = it.id.ToStr().Trim()

  ep = invalid
  if eid <> "" and type(m.seriesDetailEpisodes) = "roArray" then
    for each e in m.seriesDetailEpisodes
      if e <> invalid then
        eid2 = ""
        if e.id <> invalid then eid2 = e.id.ToStr().Trim()
        if eid2 = "" and e.Id <> invalid then eid2 = e.Id.ToStr().Trim()
        if eid2 <> "" and eid2 = eid then
          ep = e
          exit for
        end if
      end if
    end for
  end if

  if ep = invalid then
    ep = {}
    if eid <> "" then ep.id = eid
    if it <> invalid and it.title <> invalid then ep.name = it.title
    if it <> invalid and it.meta <> invalid then ep.overview = it.meta
  end if

  m.seriesDetailMode = "episode"
  m.seriesDetailEpisode = ep
  _renderEpisodeDetail(ep)
  _applySeriesDetailModeLayout()
  m.seriesDetailStatusItemId = eid
  m.seriesDetailActionFocus = 0
  _applySeriesDetailStatus("")
  _setSeriesDetailScroll(0)
  m.seriesDetailFocus = "header"
  applyFocus()
end sub

sub _closeSeriesDetail()
  if m.seriesDetailOpen <> true then return
  if m.seriesDetailMode <> invalid and LCase(m.seriesDetailMode.ToStr().Trim()) = "episode" then
    _exitEpisodeDetail()
    return
  end if
  m.seriesDetailOpen = false
  m.seriesDetailFocus = "header"
  m.seriesDetailMode = "series"
  m.seriesDetailEpisode = {}
  m.seriesDetailSeasonIndex = -1
  m.seriesDetailStatus = ""
  m.seriesDetailStatusItemId = ""
  m.seriesDetailActionFocus = 0
  _applySeriesDetailStatus("")
  _setSeriesDetailScroll(0)
  if m.seriesDetailGroup <> invalid then m.seriesDetailGroup.visible = false
  if m.mode = "browse" and m.browseCard <> invalid then m.browseCard.visible = true
  applyFocus()
end sub

sub _exitEpisodeDetail()
  m.seriesDetailMode = "series"
  m.seriesDetailEpisode = {}
  _renderSeriesDetail(m.seriesDetailData)
  _applySeriesDetailModeLayout()
  statusId = ""
  if m.seriesDetailData <> invalid and m.seriesDetailData.firstEpisodeId <> invalid then
    statusId = m.seriesDetailData.firstEpisodeId.ToStr().Trim()
  end if
  m.seriesDetailStatusItemId = statusId
  m.seriesDetailActionFocus = 0
  _applySeriesDetailStatus("")
  _setSeriesDetailScroll(0)
  m.seriesDetailFocus = "header"
  applyFocus()
end sub

sub onSeriesSeasonSelected()
  if m.seriesDetailOpen <> true then return
  if m.seriesDetailSeasonsList = invalid then return
  idx = m.seriesDetailSeasonsList.itemSelected
  if idx = invalid or idx < 0 then return
  root = m.seriesDetailSeasonsList.content
  if root = invalid then return
  n = root.getChild(idx)
  if n = invalid then return
  sIdx = -1
  if n.hasField("seasonIndex") then sIdx = _sceneIntFromAny(n.seasonIndex)
  m.seriesDetailSeasonIndex = sIdx
  m.seriesDetailFocus = "episodes"
  _renderSeriesDetailEpisodes(sIdx)
  applyFocus()
end sub

sub onSeriesEpisodeSelected()
  if m.seriesDetailOpen <> true then return
  if m.seriesDetailEpisodesList = invalid then return
  idx = m.seriesDetailEpisodesList.itemSelected
  if idx = invalid or idx < 0 then return
  root = m.seriesDetailEpisodesList.content
  if root = invalid then return
  it = root.getChild(idx)
  if it = invalid then return
  _showEpisodeDetailScreen(it)
end sub

sub onSeriesCastSelected()
  ' Cast items are informational only for now.
  return
end sub

sub _showSeriesDetailDialog(payload as Object)
  if m.pendingDialog <> invalid and m.top.dialog = invalid then m.pendingDialog = invalid
  if m.pendingDialog <> invalid then return

  data = payload
  if type(data) <> "roAssociativeArray" then data = {}
  series = data.series
  if type(series) <> "roAssociativeArray" then series = {}

  t = ""
  if series.name <> invalid then t = series.name.ToStr().Trim()
  if t = "" then
    if m.pendingSeriesDetailTitle <> invalid then t = m.pendingSeriesDetailTitle.ToStr().Trim()
  end if
  if t = "" then t = "Series"

  firstEpId = ""
  if data.firstEpisodeId <> invalid then firstEpId = data.firstEpisodeId.ToStr().Trim()
  firstEpTitle = ""
  if data.firstEpisodeTitle <> invalid then firstEpTitle = data.firstEpisodeTitle.ToStr().Trim()
  if firstEpTitle = "" then firstEpTitle = t

  dlg = CreateObject("roSGNode", "Dialog")
  dlg.title = t
  dlg.message = _buildSeriesDetailsMessage(data)
  if firstEpId <> "" then
    dlg.buttons = [_t("play_first_episode"), _t("close")]
  else
    dlg.buttons = [_t("close")]
  end if
  dlg.observeField("buttonSelected", "onSeriesDetailDone")
  m.seriesDetailPlayEpisodeId = firstEpId
  m.seriesDetailPlayEpisodeTitle = firstEpTitle
  m.pendingDialog = dlg
  m.top.dialog = dlg
  dlg.setFocus(true)
end sub


sub onSeriesDetailDone()
  dlg = m.pendingDialog
  if dlg = invalid then return

  idx = dlg.buttonSelected
  playId = m.seriesDetailPlayEpisodeId
  playTitle = m.seriesDetailPlayEpisodeTitle

  m.top.dialog = invalid
  m.pendingDialog = invalid
  m.seriesDetailPlayEpisodeId = ""
  m.seriesDetailPlayEpisodeTitle = ""

  if playId = invalid then playId = ""
  playId = playId.ToStr().Trim()
  if playTitle = invalid then playTitle = ""
  playTitle = playTitle.ToStr().Trim()
  if playTitle = "" then playTitle = "Episode"

  if playId <> "" and idx = 0 then
    playVodById(playId, playTitle)
    return
  end if

  setStatus("ready")
  applyFocus()
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
    livePath = _resolveLivePathFromItem(it)
    signAndPlay(livePath, it.title)
    return
  end if

  resumeMs = _nodeResumePositionMs(it)
  if resumeMs > 5000 then
    showResumeDialog(it.id, it.title, resumeMs)
    return
  end if

  if typL = "series" or typL = "movie" then
    requestSeriesDetails(it.id, it.title)
    return
  end if

  requestResumeProbe(it.id, it.title)
end sub

sub _onBrowseListItemSelected(lst as Object, requiredFocus as String, label as String)
  if _isPlaybackVisible() then
    print "[guard] ignore " + label + " while playback visible"
    return
  end if

  if m.mode <> "browse" then return
  if requiredFocus = "library_items" and m.browseLibraryOpen = true and m.browseFocus = "library_search" then
    print "[guard] ignore " + label + " while library search focused"
    return
  end if
  if m.browseFocus <> requiredFocus then
    if requiredFocus = "library_items" and m.browseLibraryOpen = true and lst = m.libraryItemsList then
      ' Accept delayed focus transitions while library content is loading.
    else
      return
    end if
  end if
  if lst = invalid then return

  idx = lst.itemSelected
  if idx = invalid or idx < 0 then return

  root = lst.content
  if root = invalid then return
  it = root.getChild(idx)
  if it = invalid then return
  _playBrowseItemNode(it)
end sub

sub onItemSelected()
  _onBrowseListItemSelected(m.itemsList, "items", "onItemSelected")
end sub

sub onContinueItemSelected()
  _onBrowseListItemSelected(m.continueList, "continue", "onContinueItemSelected")
end sub

sub onRecentMoviesItemSelected()
  _onBrowseListItemSelected(m.recentMoviesList, "movies", "onRecentMoviesItemSelected")
end sub

sub onRecentSeriesItemSelected()
  _onBrowseListItemSelected(m.recentSeriesList, "series", "onRecentSeriesItemSelected")
end sub

sub onLibraryItemSelected()
  _onBrowseListItemSelected(m.libraryItemsList, "library_items", "onLibraryItemSelected")
end sub

sub enterLive()
  bindUiNodes()
  _ensureLiveNodes()
  print "enterLive()"
  m.mode = "live"
  m.liveDateTextCached = ""
  m.liveFocusTarget = "time"
  m.liveHeaderFocusIndex = 0
  m.liveChannelIndex = 0
  m.liveRowStartIndex = 0
  m.liveFocusSec = 0
  m.liveEpgStartSec = 0
  m.pendingLiveLoad = false
  m.seriesDetailOpen = false
  if m.seriesDetailGroup <> invalid then m.seriesDetailGroup.visible = false
  if m.logoPoster <> invalid then m.logoPoster.visible = false
  if m.titleLabel <> invalid then m.titleLabel.visible = false
  if m.loginCard <> invalid then m.loginCard.visible = false
  if m.homeCard <> invalid then m.homeCard.visible = false
  if m.browseCard <> invalid then m.browseCard.visible = false
  if m.liveCard <> invalid then m.liveCard.visible = true
  _configureLiveLayout()
  if m.liveHeader <> invalid then
    if m.liveHeader.hasField("titleText") then m.liveHeader.titleText = _t("library_live")
    if m.liveHeader.hasField("dateText") then m.liveHeader.dateText = _formatLiveDate()
  end if
  if m.liveTitle <> invalid then m.liveTitle.text = _t("library_live")
  if m.liveDate <> invalid then m.liveDate.text = _formatLiveDate()
  if m.dayStripOverlay <> invalid then m.dayStripOverlay.visible = false
  m.liveDayStripOpen = false
  _applySelectedDateKey(_dateKeyNow(), false)
  m.liveSelectedDateForceToday = true
  _logLiveState("open")
  if m.hintLabel <> invalid then m.hintLabel.visible = false
  layoutCards()
  applyFocus()
  loadChannels()
end sub

sub _setLiveFocusTarget(target as String)
  t = target
  if t = invalid then t = ""
  t = LCase(t.ToStr().Trim())
  if t <> "time" and t <> "channels" and t <> "header" then t = "time"
  m.liveFocusTarget = t
  _applyLiveFocusVisuals()
  _focusLiveTarget()
end sub

sub _applyLiveFocusVisuals()
  focusedTime = (m.liveFocusTarget = "time")
  focusedHeader = (m.liveFocusTarget = "header")

  if m.timeRulerFocus <> invalid then m.timeRulerFocus.visible = focusedTime
  _updateChannelListFocus()

  if m.agendaFocus <> invalid then m.agendaFocus.visible = false
  if m.agendaFocusLine <> invalid then m.agendaFocusLine.visible = false
  if m.agendaButton <> invalid then
    agBg = m.agendaButton.findNode("agendaBg")
    if agBg <> invalid then
      if agBg.hasField("visible") then agBg.visible = false
      if agBg.hasField("opacity") then agBg.opacity = 0
      agBg.color = "0x172234"
    end if
  end if
  if m.agendaLabel <> invalid then m.agendaLabel.color = "0xF2F5FA"
  if m.backFocus <> invalid then m.backFocus.visible = false
  if m.backFocusLine <> invalid then m.backFocusLine.visible = false
  if m.backIcon <> invalid then m.backIcon.color = "0xF2F5FA"

  if focusedHeader then
    idx = 0
    if m.liveHeaderFocusIndex <> invalid then idx = Int(m.liveHeaderFocusIndex)
    if idx < 0 then idx = 0
    if idx > 1 then idx = 1
    m.liveHeaderFocusIndex = idx

    if idx = 1 then
      if m.agendaLabel <> invalid then m.agendaLabel.color = "0xD7B25C"
      if m.backIcon <> invalid then m.backIcon.color = "0xF2F5FA"
    else
      if m.backIcon <> invalid then m.backIcon.color = "0xD7B25C"
      if m.agendaLabel <> invalid then m.agendaLabel.color = "0xF2F5FA"
    end if
  end if
end sub

function _nodeInFocusChain(n as Object) as Boolean
  if n = invalid then return false
  if GetInterface(n, "ifSGNodeFocus") = invalid then return false
  if n.hasFocus() then return true
  if n.isInFocusChain() then return true
  return false
end function

sub _focusLiveTarget()
  if m.mode <> "live" then return
  if m.liveDayStripOpen = true then return

  if m.liveFocusTarget = "header" then
    if m.top <> invalid then m.top.setFocus(true)
    return
  end if

  if m.liveFocusTarget = "channels" then
    if m.channelListFocus <> invalid then
      m.channelListFocus.setFocus(true)
      return
    end if
  else
    if m.timeRulerFocus <> invalid then
      m.timeRulerFocus.setFocus(true)
      return
    end if
  end if

  if m.top <> invalid then m.top.setFocus(true)
end sub

sub _enforceLiveFocusLock()
  if m.mode <> "live" then return
  if m.liveDayStripOpen = true then return

  if _nodeInFocusChain(m.programTrack) or _nodeInFocusChain(m.epgGroup) or _nodeInFocusChain(m.epgRows) then
    _focusLiveTarget()
  end if
end sub

sub _updateChannelListFocus()
  if m.channelListFocus = invalid then return

  if m.liveFocusTarget <> "channels" then
    m.channelListFocus.visible = false
    return
  end if

  rowsMax = m.liveEpgRowsMax
  if rowsMax = invalid or rowsMax <= 0 then rowsMax = 1
  rowH = m.liveEpgRowHeight
  if rowH = invalid or rowH <= 0 then rowH = 110

  idx = m.liveChannelIndex
  if idx = invalid then idx = 0
  idx = Int(idx)
  if idx < 0 then idx = 0

  rowStart = m.liveRowStartIndex
  if rowStart = invalid then rowStart = 0

  if idx < rowStart or idx >= rowStart + rowsMax then
    m.channelListFocus.visible = false
    return
  end if

  localRow = idx - rowStart
  if localRow < 0 then localRow = 0
  if localRow >= rowsMax then localRow = rowsMax - 1

  channelW = 0
  if m.liveLayout <> invalid and type(m.liveLayout) = "roAssociativeArray" then
    if m.liveLayout.channelW <> invalid then channelW = Int(m.liveLayout.channelW)
  end if
  if channelW <= 0 and m.channelColumn <> invalid and m.channelColumn.width <> invalid then
    channelW = Int(m.channelColumn.width)
  end if
  if channelW <= 0 then channelW = 180

  if m.channelListFocus.hasField("width") then m.channelListFocus.width = channelW
  if m.channelListFocus.hasField("height") then m.channelListFocus.height = rowH
  m.channelListFocus.translation = [0, localRow * rowH]
  m.channelListFocus.visible = true
end sub

function _nodeFocusDbg(n as Object) as String
  if n = invalid then return "inv"
  if n.GetInterface("ifSGNodeFocus") = invalid then return "nofocus"
  inChain = n.isInFocusChain()
  has = n.hasFocus()
  return inChain.ToStr() + "/" + has.ToStr()
end function

sub _traceLiveKeyEvent(key as String, press as Boolean)
  if m.liveInputTrace <> true then return
  k = key
  if k = invalid then k = ""
  t = _nowMs()
  focusNode = _focusNodeLabel()
  trace = "[live.input] key=" + k + " press=" + press.ToStr() + " ms=" + t.ToStr()
  trace = trace + " focusTarget=" + m.liveFocusTarget + " focusNode=" + focusNode
  trace = trace + " time=" + _nodeFocusDbg(m.timeRulerFocus)
  trace = trace + " channels=" + _nodeFocusDbg(m.channelListFocus)
  trace = trace + " track=" + _nodeFocusDbg(m.programTrack)
  trace = trace + " daystrip=" + _nodeFocusDbg(m.dayStripOverlay)
  print trace
end sub

function _keyPerfStart(scope as String, key as String, press as Boolean) as Object
  if m.keyPerfDebug <> true then return invalid
  if press <> true then return invalid

  seq = 0
  if m.keyPerfSeq <> invalid then seq = Int(m.keyPerfSeq)
  seq = seq + 1
  m.keyPerfSeq = seq

  k = key
  if k = invalid then k = ""
  sc = scope
  if sc = invalid then sc = ""
  sc = sc.Trim()
  if sc = "" then sc = "scene"

  t = CreateObject("roTimespan")
  if t <> invalid then t.Mark()

  print "KEY START seq=" + seq.ToStr() + " scope=" + sc + " mode=" + m.mode + " key=" + k + " press=" + press.ToStr() + " focus=" + _focusNodeLabel()
  return { seq: seq, scope: sc, key: k, ts: t }
end function

sub _keyPerfEnd(p as Object, consumed as Boolean)
  if p = invalid then return
  ms = 0
  if p.ts <> invalid then ms = p.ts.TotalMilliseconds()
  print "KEY END seq=" + p.seq.ToStr() + " scope=" + p.scope + " key=" + p.key + " consumed=" + consumed.ToStr() + " ms=" + ms.ToStr()

  hot = 500
  if m.keyPerfHotMs <> invalid then hot = Int(m.keyPerfHotMs)
  if ms >= hot then
    print "[key.hot] seq=" + p.seq.ToStr() + " scope=" + p.scope + " key=" + p.key + " ms=" + ms.ToStr()
  end if
end sub

function _returnKeyWithPerf(p as Object, consumed as Boolean) as Boolean
  _keyPerfEnd(p, consumed)
  return consumed
end function

function _perfStart(name as String) as Object
  if m.livePerfDebug <> true and m.keyPerfDebug <> true then return invalid
  t = CreateObject("roTimespan")
  if t <> invalid then t.Mark()
  return { name: name, ts: t }
end function

sub _perfEnd(p as Object, thresholdMs as Integer)
  if p = invalid then return
  ms = 0
  if p.ts <> invalid then ms = p.ts.TotalMilliseconds()

  limit = thresholdMs
  if limit = invalid or limit < 0 then limit = 0
  hot = 500
  if m.keyPerfHotMs <> invalid then hot = Int(m.keyPerfHotMs)

  shouldPrint = false
  if m.livePerfDebug = true then
    if ms >= limit then shouldPrint = true
  else
    if ms >= hot then shouldPrint = true
  end if

  if shouldPrint then
    print "[perf] " + p.name + " ms=" + ms.ToStr()
  end if
end sub

sub _initDayStripItems()
  if m.liveDayStripItems = invalid then m.liveDayStripItems = []
  m.liveDayStripItems.Clear()
  if m.dayItem0 <> invalid then m.liveDayStripItems.Push({ group: m.dayItem0, label: m.dayItemLabel0, date: m.dayItemDate0 })
  if m.dayItem1 <> invalid then m.liveDayStripItems.Push({ group: m.dayItem1, label: m.dayItemLabel1, date: m.dayItemDate1 })
  if m.dayItem2 <> invalid then m.liveDayStripItems.Push({ group: m.dayItem2, label: m.dayItemLabel2, date: m.dayItemDate2 })
  if m.dayItem3 <> invalid then m.liveDayStripItems.Push({ group: m.dayItem3, label: m.dayItemLabel3, date: m.dayItemDate3 })
  if m.dayItem4 <> invalid then m.liveDayStripItems.Push({ group: m.dayItem4, label: m.dayItemLabel4, date: m.dayItemDate4 })
  if m.dayItem5 <> invalid then m.liveDayStripItems.Push({ group: m.dayItem5, label: m.dayItemLabel5, date: m.dayItemDate5 })
  if m.dayItem6 <> invalid then m.liveDayStripItems.Push({ group: m.dayItem6, label: m.dayItemLabel6, date: m.dayItemDate6 })
end sub

function _buildDayStripDates() as Object
  baseKey = _dateKeyNow()
  out = []
  for i = 0 to 6
    key = _dateKeyAddDays(baseKey, i)
    sec = _utcEpochFromLocalDateKey(key)
    out.Push({ sec: sec, key: key })
  end for
  return out
end function

function _ensureDayStripDates() as Object
  baseKey = _dateKeyNow()
  if m.liveDayStripBaseKey = invalid then m.liveDayStripBaseKey = ""
  if m.liveDayStripBaseKey <> baseKey or m.liveDayStripDates = invalid or m.liveDayStripDates.Count() = 0 then
    m.liveDayStripBaseKey = baseKey
    m.liveDayStripDates = _buildDayStripDates()
    m.liveDayStripLabelsReady = false
  end if
  return m.liveDayStripDates
end function

sub _updateDayStripUI()
  _initDayStripItems()
  m.liveDayStripDates = _ensureDayStripDates()

  selKey = m.liveSelectedDateKey
  if selKey = invalid or selKey.Trim() = "" then selKey = _dateKeyNow()

  selIdx = 0
  for i = 0 to m.liveDayStripDates.Count() - 1
    d = m.liveDayStripDates[i]
    if d <> invalid and d.key <> invalid then
      if d.key = selKey then
        selIdx = i
        exit for
      end if
    end if
  end for
  if m.liveDayStripOpen = true then
    curIdx = m.liveDayStripIndex
    if curIdx <> invalid then
      curIdx = Int(curIdx)
      if curIdx >= 0 and curIdx < m.liveDayStripDates.Count() then
        selIdx = curIdx
      end if
    end if
  end if
  m.liveDayStripIndex = selIdx

  itemW = 110
  itemH = 56
  if m.liveDayStripItems <> invalid then
    for i = 0 to m.liveDayStripItems.Count() - 1
      it = m.liveDayStripItems[i]
      if it = invalid then continue for
      dsec = 0
      dkey = ""
      d = m.liveDayStripDates[i]
      if d <> invalid then
        if d.sec <> invalid then dsec = Int(d.sec)
        if d.key <> invalid then dkey = d.key
      end if
      if m.liveDayStripLabelsReady <> true then
        lbl = ""
        if i = 0 then
          lbl = "Hoje"
        else
          lbl = _weekdayShortFromKey(dkey)
        end if
        if it.label <> invalid then it.label.text = lbl
        if it.date <> invalid then it.date.text = _dayFromKey(dkey)
      end if
      if it.label <> invalid then
        if i = selIdx then
          it.label.color = "0xF2F5FA"
        else
          it.label.color = "0xC9D4E3"
        end if
      end if
      if it.date <> invalid then
        if i = selIdx then
          it.date.color = "0xD7B25C"
        else
          it.date.color = "0x8EA0B8"
        end if
      end if
    end for
  end if
  m.liveDayStripLabelsReady = true

  if m.dayStripFocus <> invalid then
    if m.liveDayStripItems.Count() > 0 then
      gi = m.liveDayStripItems[selIdx]
      if gi <> invalid and gi.group <> invalid then
        tr = gi.group.translation
        fx = 0
        fy = 0
        if type(tr) = "roArray" and tr.Count() >= 2 then
          fx = Int(tr[0])
          fy = Int(tr[1])
        end if
        m.dayStripFocus.translation = [fx - 6, fy - 6]
        m.dayStripFocus.width = itemW + 12
        m.dayStripFocus.height = itemH + 12
        m.dayStripFocus.visible = true
      end if
    end if
  end if
end sub

sub _openDayStrip()
  p0 = _perfStart("openAgenda")
  m.liveDayStripOpen = false
  _updateDayStripUI()
  if m.dayStripOverlay <> invalid then m.dayStripOverlay.visible = true
  m.liveDayStripOpen = true
  if m.top <> invalid then m.top.setFocus(true)
  _perfEnd(p0, 20)
end sub

sub _closeDayStrip()
  p0 = _perfStart("closeAgenda")
  if m.dayStripOverlay <> invalid then m.dayStripOverlay.visible = false
  m.liveDayStripOpen = false
  _setLiveFocusTarget("time")
  _perfEnd(p0, 20)
end sub

sub _applySelectedDateKey(key as String, reload as Boolean)
  p0 = _perfStart("applySelectedDate")
  k = key
  if k = invalid then k = ""
  k = k.Trim()
  if k = "" then k = _dateKeyNow()
  m.liveDateTextCached = ""
  m.liveSelectedDateKey = k
  m.liveSelectedDateSec = _utcEpochFromLocalDateKey(k)
  m.liveSelectedDateForceToday = false
  if m.liveDate <> invalid then m.liveDate.text = _formatDateLongFromKey(k)
  if m.dateStripLabel <> invalid then m.dateStripLabel.text = ""
  _resetLiveTimeWindow()
  m.liveHeaderStartSec = 0
  _updateDayStripUI()
  if reload then
    m.liveProgramsLoaded = false
    m.livePrograms = []
    m.liveProgramMap = {}
    m.liveProgramMapDirty = true
    m.liveProgramsVersion = m.liveProgramsVersion + 1
    loadLivePrograms()
  end if
  _logLiveState("date")
  _requestLiveRender("date_apply")
  _perfEnd(p0, 30)
end sub

sub _logLiveState(reason as String)
  r = reason
  if r = invalid then r = "state"
  sel = m.liveSelectedDateSec
  if sel = invalid then sel = 0
  selKey = m.liveSelectedDateKey
  if selKey = invalid then selKey = ""
  epgCount = 0
  if type(m.livePrograms) = "roArray" then epgCount = m.livePrograms.Count()
  windowStart = m.liveEpgStartSec
  windowEnd = windowStart + (m.liveEpgWindowMinutes * 60)
  trackW = m.liveEpgWidth
  trackH = m.liveEpgRowHeight * m.liveEpgRowsMax
  tzMin = _localTimezoneOffsetMin()
  print "live state " + r + " selectedDateKey=" + selKey + " selectedDate=" + _formatDateLong(sel) + " tzOffsetMin=" + tzMin.ToStr() + " epgCount=" + epgCount.ToStr() + " window=" + windowStart.ToStr() + "-" + windowEnd.ToStr() + " track=" + trackW.ToStr() + "x" + trackH.ToStr()
end sub

sub _moveLiveChannel(delta as Integer)
  p0 = _perfStart("moveChannel")
  if m.mode <> "live" then return
  if m.channelsList = invalid then return
  root = m.channelsList.content
  if root = invalid then return
  total = root.getChildCount()
  if total <= 0 then return

  idx = m.liveChannelIndex
  if idx = invalid then idx = 0
  idx = Int(idx) + Int(delta)
  if idx < 0 then idx = 0
  if idx > (total - 1) then idx = total - 1
  m.liveChannelIndex = idx
  _requestLiveRender("channel")
  _perfEnd(p0, 20)
end sub

sub playSelectedLiveChannel()
  if m.mode <> "live" then return
  if m.channelsList = invalid then return
  root = m.channelsList.content
  if root = invalid then return
  total = root.getChildCount()
  if total <= 0 then return

  idx = m.liveChannelIndex
  if idx = invalid then idx = 0
  idx = Int(idx)
  if idx < 0 then idx = 0
  if idx > (total - 1) then idx = total - 1

  item = root.getChild(idx)
  if item = invalid then return
  m.liveFallbackAttempted = false
  livePath = _resolveLivePathFromItem(item)
  signAndPlay(livePath, item.title)
end sub

sub showLiveProgramDetails()
  if m.mode <> "live" then return
  if m.pendingDialog <> invalid then return
  if m.channelsList = invalid then return
  root = m.channelsList.content
  if root = invalid then return
  total = root.getChildCount()
  if total <= 0 then return

  idx = m.liveChannelIndex
  if idx = invalid then idx = 0
  idx = Int(idx)
  if idx < 0 then idx = 0
  if idx > (total - 1) then idx = total - 1
  item = root.getChild(idx)
  if item = invalid then return

  cursorSec = m.liveFocusSec
  if cursorSec = invalid or cursorSec <= 0 then cursorSec = _nowEpochSec()
  cid = ""
  if item.hasField("id") then cid = item.id
  if cid <> invalid then cid = cid.ToStr().Trim()

  prog = invalid
  nextProg = invalid
  nextStart = 0
  if cid <> "" and type(m.liveProgramMap) = "roAssociativeArray" then
    arr = m.liveProgramMap[cid]
    if type(arr) = "roArray" then
      for each p in arr
        if type(p) <> "roAssociativeArray" then continue for
        st = p.start
        en = p.finish
        if cursorSec >= st and cursorSec < en then
          prog = p
        end if
        if st > cursorSec and (nextProg = invalid or st < nextStart) then
          nextProg = p
          nextStart = st
        end if
      end for
    end if
  end if

  title = ""
  desc = ""
  tm = "--:-- - --:--"
  if prog <> invalid then
    if prog.title <> invalid then title = prog.title.ToStr().Trim()
    if prog.desc <> invalid then desc = prog.desc.ToStr().Trim()
    st = prog.start
    en = prog.finish
    if en > st then tm = _formatTimeLabel(st) + " - " + _formatTimeLabel(en)
  end if
  if title = "" then title = "Sem dados"

  nextTxt = ""
  if nextProg <> invalid and nextProg.title <> invalid then nextTxt = nextProg.title.ToStr().Trim()
  if nextTxt = "" then nextTxt = "Sem dados"

  chName = ""
  if item.title <> invalid then chName = item.title.ToStr().Trim()
  if chName = "" then chName = "Live TV"

  msg = chName + Chr(10) + title + Chr(10) + tm
  if desc <> "" and desc <> title then msg = msg + Chr(10) + desc
  msg = msg + Chr(10) + "Proximo: " + nextTxt
  dlg = CreateObject("roSGNode", "Dialog")
  dlg.title = "Detalhes"
  dlg.message = msg
  dlg.buttons = ["Assistir", "Voltar"]
  dlg.observeField("buttonSelected", "onLiveProgramDetailsDone")
  dlg.addField("liveIndex", "integer", false)
  dlg.liveIndex = idx
  m.pendingDialog = dlg
  m.top.dialog = dlg
  dlg.setFocus(true)
end sub

function _liveProgramForChannelAtTime(cid as String, tSec as Integer) as Object
  if cid = invalid then return invalid
  id = cid.ToStr().Trim()
  if id = "" then return invalid
  if type(m.liveProgramMap) <> "roAssociativeArray" then return invalid
  arr = m.liveProgramMap[id]
  if type(arr) <> "roArray" then return invalid
  for each p in arr
    if type(p) <> "roAssociativeArray" then continue for
    st = p.start
    en = p.finish
    if tSec >= st and tSec < en then return p
  end for
  return invalid
end function

function _liveSnapCursorToProgramBoundary(currSec as Integer, desiredSec as Integer, delta as Integer) as Integer
  if delta = 0 then return desiredSec
  ch = _liveSelectedChannel()
  if ch = invalid then return desiredSec
  cid = ""
  if ch.hasField("id") then cid = ch.id
  if cid = invalid then return desiredSec
  cid = cid.ToStr().Trim()
  if cid = "" then return desiredSec

  if currSec <= 0 then currSec = _nowEpochSec()
  currProg = _liveProgramForChannelAtTime(cid, currSec)
  nextProg = _liveProgramForChannelAtTime(cid, desiredSec)
  if currProg <> invalid and nextProg <> invalid then
    if currProg.start = nextProg.start and currProg.finish = nextProg.finish then
      if delta > 0 then
        desiredSec = currProg.finish + 1
      else
        desiredSec = currProg.start - 1
      end if
    end if
  end if

  if desiredSec < 0 then desiredSec = 0
  return desiredSec
end function

function _liveSelectedProgramIsNow() as Boolean
  ch = _liveSelectedChannel()
  if ch = invalid then return false
  cid = ""
  if ch.hasField("id") then cid = ch.id
  if cid = invalid then return false
  cursorSec = m.liveFocusSec
  if cursorSec = invalid or cursorSec <= 0 then cursorSec = _nowEpochSec()
  prog = _liveProgramForChannelAtTime(cid, cursorSec)
  if prog = invalid then return false
  nowSec = _nowEpochSec()
  st = prog.start
  en = prog.finish
  return (nowSec >= st and nowSec < en)
end function

sub onLiveProgramDetailsDone()
  dlg = m.pendingDialog
  if dlg = invalid then return
  idx = dlg.buttonSelected
  playIdx = -1
  if dlg.hasField("liveIndex") then playIdx = dlg.liveIndex
  m.top.dialog = invalid
  m.pendingDialog = invalid

  if idx = 0 then
    if playIdx >= 0 then m.liveChannelIndex = playIdx
    playSelectedLiveChannel()
  else
    applyFocus()
  end if
end sub

function _liveSelectedChannel() as Object
  if m.channelsList = invalid then return invalid
  root = m.channelsList.content
  if root = invalid then return invalid
  total = root.getChildCount()
  if total <= 0 then return invalid

  idx = m.liveChannelIndex
  if idx = invalid then idx = 0
  idx = Int(idx)
  if idx < 0 then idx = 0
  if idx > (total - 1) then idx = total - 1
  m.liveChannelIndex = idx
  return root.getChild(idx)
end function

sub _refreshLiveHero(ch as Object)
  ' No-op: Guide grid rows are rendered in _renderLiveTimeline().
end sub

function _buildLiveLayoutMetrics() as Object
  w = 1280
  h = 720
  di = CreateObject("roDeviceInfo")
  if di <> invalid then
    ds = di.GetDisplaySize()
    if type(ds) = "roAssociativeArray" then
      if ds.w <> invalid then w = Int(ds.w)
      if ds.width <> invalid then w = Int(ds.width)
      if ds.h <> invalid then h = Int(ds.h)
      if ds.height <> invalid then h = Int(ds.height)
    end if
  end if
  ' SceneGraph runs in hd (1280x720) for this channel; clamp physical TV size.
  if w > 1280 then w = 1280
  if h > 720 then h = 720

  scale = w / 1920.0
  if scale <= 0 then scale = 1.0
  safeMargin = Int(60 * scale)
  if safeMargin < 28 then safeMargin = 28
  gutter = Int(18 * scale)
  if gutter < 10 then gutter = 10

  headerH = Int(64 * scale)
  if headerH < 44 then headerH = 44
  dateStripH = 0
  timelineH = Int(52 * scale)
  if timelineH < 36 then timelineH = 36

  rowH = Int(110 * scale)
  if rowH < 88 then rowH = 88

  channelW = Int(180 * scale)
  if channelW < 140 then channelW = 140
  trackInset = 0

  usableW = w - (safeMargin * 2)
  trackW = usableW - channelW - gutter
  if trackW < Int(540 * scale) then trackW = Int(540 * scale)
  if trackW < 360 then trackW = 360

  contentY = safeMargin + headerH + dateStripH + timelineH + (gutter * 2)
  contentH = h - contentY - safeMargin
  if contentH < rowH then contentH = rowH

  rowsMax = Int(contentH / rowH)
  if rowsMax < 1 then rowsMax = 1
  contentH = rowsMax * rowH

  return {
    width: w
    height: h
    scale: scale
    safeMargin: safeMargin
    gutter: gutter
    headerH: headerH
    dateStripH: dateStripH
    timelineH: timelineH
    rowH: rowH
    rowsMax: rowsMax
    channelW: channelW
    trackW: trackW
    trackInset: trackInset
    contentH: contentH
  }
end function

sub _configureLiveLayout()
  m.liveLayout = _buildLiveLayoutMetrics()
  if m.liveLayout = invalid then return
  if type(m.liveLayout) <> "roAssociativeArray" then return

  safeMargin = Int(m.liveLayout.safeMargin)
  gutter = Int(m.liveLayout.gutter)
  headerH = Int(m.liveLayout.headerH)
  dateStripH = Int(m.liveLayout.dateStripH)
  timelineH = Int(m.liveLayout.timelineH)
  rowH = Int(m.liveLayout.rowH)
  rowsMax = Int(m.liveLayout.rowsMax)
  channelW = Int(m.liveLayout.channelW)
  trackW = Int(m.liveLayout.trackW)
  trackInset = Int(m.liveLayout.trackInset)
  contentH = Int(m.liveLayout.contentH)

  contentW = channelW + gutter + trackW
  timelineX = channelW + gutter
  timelineY = headerH + dateStripH + gutter
  contentY = headerH + dateStripH + timelineH + (gutter * 2)

  m.liveEpgWidth = trackW - (trackInset * 2)
  if m.liveEpgWidth < 200 then m.liveEpgWidth = 200
  m.liveEpgRowHeight = rowH
  if rowsMax < 1 then rowsMax = 1
  m.liveEpgRowsMax = rowsMax

  if m.liveLayoutRoot <> invalid then m.liveLayoutRoot.translation = [safeMargin, safeMargin]

  if m.liveHeader <> invalid then
    m.liveHeader.translation = [0, 0]
    if m.liveHeader.hasField("width") then m.liveHeader.width = contentW
    if m.liveHeader.hasField("height") then m.liveHeader.height = headerH
  end if
  if m.backIcon <> invalid then
    scale = 1.0
    if m.liveLayout.scale <> invalid then scale = m.liveLayout.scale
    iconW = Int(24 * scale)
    if iconW < 18 then iconW = 18
    iconH = Int(36 * scale)
    if iconH < 28 then iconH = 28
    iconY = Int((headerH - iconH) / 2)
    m.backIcon.translation = [0, iconY]
    if m.backIcon.hasField("width") then m.backIcon.width = iconW
    if m.backIcon.hasField("height") then m.backIcon.height = iconH
    if m.liveTitle <> invalid then
      titleX = iconW + Int(10 * scale)
      titleY = Int((headerH - 40) / 2)
      if titleY < 0 then titleY = 0
      m.liveTitle.translation = [titleX, titleY]
    end if
    if m.backFocus <> invalid then
      glowH = Int(18 * scale)
      if glowH < 12 then glowH = 12
      if glowH > 22 then glowH = 22
      glowY = iconY + Int((iconH - glowH) / 2)
      if glowY + glowH > headerH then glowY = headerH - glowH
      if glowY < 0 then glowY = 0
      glowW = iconW + Int(10 * scale)
      if glowW < iconW then glowW = iconW
      glowX = -Int(5 * scale)
      m.backFocus.translation = [glowX, glowY]
      m.backFocus.width = glowW
      m.backFocus.height = glowH
      if m.backFocusLine <> invalid then
        lineH = Int(2 * scale)
        if lineH < 2 then lineH = 2
        if lineH > 3 then lineH = 3
        lineY = glowY + Int((glowH - lineH) / 2)
        m.backFocusLine.translation = [0, lineY]
        m.backFocusLine.width = iconW
        m.backFocusLine.height = lineH
      end if
    end if
  end if
  if m.dateStripRow <> invalid then
    m.dateStripRow.translation = [0, headerH]
    m.dateStripRow.visible = false
  end if
  if m.liveTimeline <> invalid then
    m.liveTimeline.translation = [timelineX, timelineY]
    tlBg = m.liveTimeline.findNode("timelineBg")
    if tlBg <> invalid then tlBg.width = trackW
    if tlBg <> invalid then tlBg.height = timelineH
    tlHeader = m.liveTimeline.findNode("epgHeader")
    if tlHeader <> invalid then tlHeader.translation = [0, 4]
    tlLine = m.liveTimeline.findNode("epgHeaderLine")
    if tlLine <> invalid then
      tlLine.translation = [0, timelineH - 6]
      tlLine.width = trackW
    end if
    nowLine = m.liveTimeline.findNode("epgNowLine")
    if nowLine <> invalid then nowLine.height = timelineH - 8
  end if
  if m.timeRulerFocus <> invalid then
    trScale = 1.0
    if m.liveLayout.scale <> invalid then trScale = m.liveLayout.scale
    barH = Int(4 * trScale)
    if barH < 3 then barH = 3
    if barH > 6 then barH = 6
    barOffset = Int(6 * trScale)
    if barOffset < barH then barOffset = barH
    m.timeRulerFocus.translation = [timelineX, timelineY + timelineH - barOffset]
    if m.timeRulerFocus.hasField("width") then m.timeRulerFocus.width = trackW
    if m.timeRulerFocus.hasField("height") then m.timeRulerFocus.height = barH
  end if

  if m.liveContentLayout <> invalid then
    m.liveContentLayout.translation = [0, contentY]
  end if
  if m.channelColumn <> invalid then
    m.channelColumn.translation = [0, 0]
  end if
  if m.channelListFocus <> invalid then
    m.channelListFocus.translation = [0, 0]
    if m.channelListFocus.hasField("width") then m.channelListFocus.width = channelW
    if m.channelListFocus.hasField("height") then m.channelListFocus.height = rowH
  end if
  if m.programTrack <> invalid then
    m.programTrack.translation = [channelW + gutter, 0]
  end if
  if m.channelColumn <> invalid then
    if m.channelColumn.hasField("width") then m.channelColumn.width = channelW
    if m.channelColumn.hasField("height") then m.channelColumn.height = contentH
    colBg = m.channelColumn.findNode("channelColumnBg")
    if colBg <> invalid then
      colBg.width = channelW
      colBg.height = contentH
    end if
  end if
  if m.epgBg <> invalid then
    m.epgBg.width = trackW
    m.epgBg.height = contentH
  end if
  if m.epgGroup <> invalid then m.epgGroup.translation = [0, 0]
  if m.gridNowLine <> invalid then m.gridNowLine.height = contentH
  if m.programTrack <> invalid then
    if m.programTrack.hasField("width") then m.programTrack.width = trackW
    if m.programTrack.hasField("height") then m.programTrack.height = contentH
    if trackW > 0 and contentH > 0 then
      if m.programTrack.hasField("clippingRect") then m.programTrack.clippingRect = [0, 0, trackW, contentH]
      if m.programTrack.hasField("clipRect") then m.programTrack.clipRect = [0, 0, trackW, contentH]
    else
      if m.programTrack.hasField("clippingRect") then m.programTrack.clippingRect = invalid
      if m.programTrack.hasField("clipRect") then m.programTrack.clipRect = invalid
    end if
    if m.programTrack.hasField("clipChildren") then m.programTrack.clipChildren = true
  end if
  if m.channelColumn <> invalid then
    cbg = m.channelColumn.findNode("channelColumnBg")
    if cbg <> invalid then
      cbg.width = channelW
      cbg.height = contentH
    end if
  end if
  if m.agendaButton <> invalid then
    scale = 1.0
    if m.liveLayout.scale <> invalid then scale = m.liveLayout.scale
    agendaW = Int(200 * scale)
    if agendaW < 140 then agendaW = 140
    agendaH = Int(36 * scale)
    if agendaH < 28 then agendaH = 28
    m.agendaButton.translation = [contentW - agendaW, 0]
    agBg = m.agendaButton.findNode("agendaBg")
    if agBg <> invalid then
      agBg.width = agendaW
      agBg.height = agendaH
    end if
    agFocus = m.agendaButton.findNode("agendaFocus")
    if agFocus <> invalid then
      glowH = Int(18 * scale)
      if glowH < 12 then glowH = 12
      if glowH > 22 then glowH = 22
      agFocus.width = agendaW
      agFocus.height = glowH
      agFocus.translation = [0, Int((agendaH - glowH) / 2)]
    end if
    agLine = m.agendaButton.findNode("agendaFocusLine")
    if agLine <> invalid then
      lineH = Int(2 * scale)
      if lineH < 2 then lineH = 2
      if lineH > 3 then lineH = 3
      agLine.width = agendaW
      agLine.height = lineH
      agLine.translation = [0, Int((agendaH - lineH) / 2)]
    end if
  end if
  if m.liveEmptyLabel <> invalid then
    m.liveEmptyLabel.translation = [0, contentY + Int(contentH / 2)]
    m.liveEmptyLabel.width = contentW
  end if
  if m.liveCard <> invalid then
    bgTop = m.liveCard.findNode("liveBgTop")
    if bgTop <> invalid then
      bgTop.width = m.liveLayout.width
      bgTop.height = m.liveLayout.height
    end if
  end if
  if m.channelsList <> invalid then
    m.channelsList.translation = [-2000, -2000]
    m.channelsList.visible = false
    if m.channelsList.hasField("opacity") then m.channelsList.opacity = 0
    if m.channelsList.hasField("focusable") then m.channelsList.focusable = false
  end if
  if m.agendaButton <> invalid then
    if m.agendaButton.hasField("focusable") then m.agendaButton.focusable = false
    if m.agendaButton.hasField("visible") then m.agendaButton.visible = true
  end if
  _updateChannelListFocus()
end sub

sub _resetLiveTimeWindow()
  tickMin = m.liveEpgTickMinutes
  if tickMin = invalid or tickMin <= 0 then tickMin = 30
  tickSec = tickMin * 60
  if tickSec <= 0 then tickSec = 1800

  nowSec = _nowEpochSec()
  selDay = m.liveSelectedDateSec
  if selDay = invalid or selDay <= 0 then selDay = _utcEpochFromLocalDateKey(_dateKeyNow())
  selKey = m.liveSelectedDateKey
  if selKey = invalid or selKey.Trim() = "" then selKey = _dateKeyNow()
  if selKey = _dateKeyNow() then
    startSec = nowSec - (nowSec mod tickSec) - tickSec
    m.liveFocusSec = nowSec
  else
    startSec = selDay + (4 * 3600)
    m.liveFocusSec = startSec
  end if
  m.liveEpgStartSec = startSec
  m.liveHeaderStartSec = 0
end sub

sub _requestLiveRender(reason as String)
  if m.mode <> "live" then return
  seq = 0
  if m.liveKeySeq <> invalid then seq = Int(m.liveKeySeq)
  seq = seq + 1
  m.liveKeySeq = seq
  m.liveRenderKeySeq = seq

  r = reason
  if r = invalid then r = ""
  m.liveRenderReason = r

  if m.liveRenderPending = true then return
  m.liveRenderPending = true
  if m.liveRenderTimer <> invalid then
    m.liveRenderTimer.control = "start"
  else
    m.liveRenderPending = false
    _renderLiveTimeline()
  end if
end sub

sub onLiveRenderTimerFire()
  _enforceLiveFocusLock()
  if m.liveRenderPending <> true then return
  m.liveRenderPending = false

  reason = m.liveRenderReason
  keySeq = m.liveRenderKeySeq

  t = CreateObject("roTimespan")
  if t <> invalid then t.Mark()

  didLight = false
  lightEligible = false
  if reason = "cursor" or reason = "cursor_no_timer" then
    lightEligible = true
  else if reason = "channel" then
    lightEligible = true
    rowStart = m.liveRowStartIndex
    if rowStart = invalid then rowStart = 0
    rowsMax = m.liveEpgRowsMax
    if rowsMax = invalid or rowsMax <= 0 then rowsMax = 1
    idx = m.liveChannelIndex
    if idx = invalid then idx = 0
    idx = Int(idx)
    if idx < rowStart or idx >= (rowStart + rowsMax) then lightEligible = false
  end if

  if lightEligible then
    startSec = m.liveEpgStartSec
    windowMin = m.liveEpgWindowMinutes
    if windowMin = invalid or windowMin <= 0 then windowMin = 180
    windowSec = windowMin * 60
    if startSec = invalid or startSec <= 0 or windowSec <= 0 then
      lightEligible = false
    end if

    if lightEligible then
      if m.liveLastRenderStartSec <> startSec then lightEligible = false
      if m.liveLastRenderChannelIndex <> m.liveChannelIndex then lightEligible = false
    end if

    if lightEligible then
      focusSec = m.liveFocusSec
      if focusSec = invalid or focusSec <= 0 then focusSec = _nowEpochSec()
      endSec = startSec + windowSec
      if focusSec < startSec or focusSec > endSec then lightEligible = false
    end if
  end if

  if lightEligible then
    didLight = _renderLiveHighlightOnly()
  end if
  if didLight <> true then
    _renderLiveTimeline()
  end if

  ms = 0
  if t <> invalid then ms = t.TotalMilliseconds()
  if ms >= 50 or m.liveRenderDebug = true then
    mode = "heavy"
    if didLight = true then mode = "light"
    print "[live.render] ms=" + ms.ToStr() + " reason=" + reason + " keySeq=" + keySeq.ToStr() + " mode=" + mode
  end if
  if didLight = true then
    if m.liveEpgStartSec <> invalid then m.liveLastRenderStartSec = m.liveEpgStartSec
    if m.liveChannelIndex <> invalid then m.liveLastRenderChannelIndex = m.liveChannelIndex
  end if
end sub

sub _queueLiveCursorShift(delta as Integer)
  p0 = _perfStart("moveCursor")
  tickMin = m.liveEpgTickMinutes
  if tickMin = invalid or tickMin <= 0 then tickMin = 30
  tickSec = tickMin * 60
  if tickSec <= 0 then return

  desired = m.liveCursorDesiredSec
  curr = m.liveFocusSec
  if curr = invalid or curr <= 0 then curr = _nowEpochSec()
  if desired = invalid or desired <= 0 then desired = curr

  desired = desired + (delta * tickSec)
  if m.liveCursorSnapToProgram = true then
    desired = _liveSnapCursorToProgramBoundary(curr, desired, delta)
  end if
  m.liveCursorDesiredSec = desired
  if m.liveCursorTimer <> invalid then
    m.liveCursorTimer.control = "stop"
    m.liveCursorTimer.control = "start"
  else
    m.liveFocusSec = desired
    m.liveCursorDesiredSec = 0
    _requestLiveRender("cursor_no_timer")
  end if
  _perfEnd(p0, 20)
end sub

sub onLiveCursorTimer()
  p0 = _perfStart("moveCursor.flush")
  desired = m.liveCursorDesiredSec
  if desired = invalid or desired <= 0 then return
  m.liveFocusSec = desired
  m.liveCursorDesiredSec = 0
  reason = "cursor"
  startSec = m.liveEpgStartSec
  windowMin = m.liveEpgWindowMinutes
  if windowMin = invalid or windowMin <= 0 then windowMin = 180
  windowSec = windowMin * 60
  if startSec = invalid or startSec <= 0 then startSec = 0
  endSec = startSec + windowSec
  if startSec > 0 and windowSec > 0 then
    if desired < startSec then
      tickMin = m.liveEpgTickMinutes
      if tickMin = invalid or tickMin <= 0 then tickMin = 30
      tickSec = tickMin * 60
      if tickSec <= 0 then tickSec = 1800
      startSec = desired - tickSec
      m.liveEpgStartSec = startSec
      m.liveHeaderStartSec = 0
      reason = "window"
    else if desired > endSec then
      tickMin2 = m.liveEpgTickMinutes
      if tickMin2 = invalid or tickMin2 <= 0 then tickMin2 = 30
      tickSec2 = tickMin2 * 60
      if tickSec2 <= 0 then tickSec2 = 1800
      startSec = desired - windowSec + tickSec2
      m.liveEpgStartSec = startSec
      m.liveHeaderStartSec = 0
      reason = "window"
    end if
  end if
  _requestLiveRender(reason)
  _perfEnd(p0, 20)
end sub

sub loadChannels()
  if m.gatewayTask = invalid then
    m.pendingLiveLoad = false
    setStatus("gateway: missing task")
    return
  end if
  if m.channelsList = invalid then
    _ensureLiveListNodes()
    if m.channelsList = invalid then
      m.pendingLiveLoad = false
      setStatus("channels: missing list")
      return
    end if
  end if

  if m.mode <> "live" then
    m.pendingLiveLoad = false
    return
  end if

  if m.pendingJob <> "" then
    m.pendingLiveLoad = true
    print "channels queued: pendingJob=" + m.pendingJob
    setStatus(_t("please_wait"))
    _scheduleLiveLoadRetry()
    return
  end if

  m.pendingLiveLoad = false
  if m.liveEmptyLabel <> invalid then m.liveEmptyLabel.visible = false
  m.channelsList.content = CreateObject("roSGNode", "ContentNode")
  m.liveProgramsLoaded = false
  m.livePrograms = []
  m.liveProgramMap = {}
  m.liveProgramMapDirty = true
  m.liveProgramsVersion = m.liveProgramsVersion + 1
  m.liveChannelIndex = 0
  m.liveEpgOffsetTicks = 0
  m.liveFocusSec = 0
  m.liveEpgStartSec = 0
  _requestLiveRender("channels_reset")

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

sub loadLivePrograms()
  p0 = _perfStart("fetchEpg.dispatch")
  if m.mode <> "live" then print "programs warn: mode=" + m.mode
  if m.gatewayTask = invalid then
    print "programs abort: missing gateway"
    _perfEnd(p0, 20)
    return
  end if
  if m.channelsList = invalid then
    print "programs abort: missing list"
    _perfEnd(p0, 20)
    return
  end if
  root = m.channelsList.content
  if root = invalid then
    print "programs abort: missing content"
    _perfEnd(p0, 20)
    return
  end if
  if root.getChildCount() = 0 then
    print "programs abort: empty channels"
    _perfEnd(p0, 20)
    return
  end if
  if m.pendingJob <> "" then
    print "programs abort: pendingJob=" + m.pendingJob
    _perfEnd(p0, 20)
    return
  end if

  cfg = loadConfig()
  if cfg.apiBase = "" or cfg.appToken = "" or cfg.jellyfinToken = "" or cfg.userId = "" then
    print "programs abort: missing config"
    _perfEnd(p0, 20)
    return
  end if

  ids = []
  for i = 0 to root.getChildCount() - 1
    c = root.getChild(i)
    if c = invalid then continue for
    cid = ""
    if c.hasField("id") then cid = c.id
    if cid <> invalid then cid = cid.ToStr().Trim()
    if cid <> "" then ids.Push(cid)
  end for
  if ids.Count() = 0 then
    _perfEnd(p0, 20)
    return
  end if

  idsStr = ""
  for i = 0 to ids.Count() - 1
    if i > 0 then idsStr = idsStr + ","
    idsStr = idsStr + ids[i]
  end for

  selKey = m.liveSelectedDateKey
  if selKey = invalid or selKey.Trim() = "" then selKey = _dateKeyNow()
  startIso = selKey + "T00:00:00"
  nextKey = _dateKeyAddDays(selKey, 1)
  endIso = nextKey + "T00:00:00"
  tzMin = _localTimezoneOffsetMin()

  print "programs request channels=" + ids.Count().ToStr() + " selectedDateKey=" + selKey + " range=" + startIso + " -> " + endIso + " tzOffsetMin=" + tzMin.ToStr()
  m.pendingJob = "programs"
  m.gatewayTask.kind = "programs"
  m.gatewayTask.apiBase = cfg.apiBase
  m.gatewayTask.appToken = cfg.appToken
  m.gatewayTask.jellyfinToken = cfg.jellyfinToken
  m.gatewayTask.userId = cfg.userId
  m.gatewayTask.channelIds = idsStr
  m.gatewayTask.startDate = startIso
  m.gatewayTask.endDate = endIso
  baseNoSlash = cfg.apiBase
  if baseNoSlash = invalid then baseNoSlash = ""
  baseNoSlash = baseNoSlash.ToStr().Trim()
  if Right(baseNoSlash, 1) = "/" then baseNoSlash = Left(baseNoSlash, Len(baseNoSlash) - 1)
  logUrl = baseNoSlash + "/jellyfin/LiveTv/Programs?UserId=" + cfg.userId + "&ChannelIds=" + idsStr + "&StartDate=" + startIso + "&EndDate=" + endIso + "&SortBy=StartDate&SortOrder=Ascending"
  print "programs url=" + logUrl
  m.gatewayTask.control = "run"
  _perfEnd(p0, 20)
end sub

sub _applyLivePrograms(items as Object)
  p0 = _perfStart("applyLivePrograms")
  if m.channelsList = invalid then return
  root = m.channelsList.content
  if root = invalid then return

  if m.liveProgramMapDirty = true or type(m.liveProgramMap) <> "roAssociativeArray" then
    m.liveProgramMap = _buildLiveProgramMap(items)
    m.liveProgramMapDirty = false
  end if
  progMap = m.liveProgramMap
  cursorSec = m.liveFocusSec
  nowSec = _nowEpochSec()
  if cursorSec = invalid or cursorSec <= 0 then cursorSec = nowSec

  for i = 0 to root.getChildCount() - 1
    c = root.getChild(i)
    if c = invalid then continue for
    if c.hasField("programTitle") <> true then c.addField("programTitle", "string", false)
    if c.hasField("programNextTitle") <> true then c.addField("programNextTitle", "string", false)

    cid = ""
    if c.hasField("id") then cid = c.id
    if cid <> invalid then cid = cid.ToStr().Trim()

    programs = progMap[cid]
    if type(programs) <> "roArray" then programs = []
    cur = invalid
    nextProg = invalid
    nextStart = 0
    nowProg = invalid
    for each p in programs
      if type(p) <> "roAssociativeArray" then continue for
      st = p.start
      en = p.finish
      if cursorSec >= st and cursorSec < en then
        cur = p
        exit for
      end if
      if st > cursorSec and (nextProg = invalid or st < nextStart) then
        nextProg = p
        nextStart = st
      end if
    end for

    nowTitle = ""
    nextTitle = ""
    timeLabel = ""
    prog = -1.0
    if cur <> invalid then
      if cur.title <> invalid then nowTitle = cur.title
      st = cur.start
      en = cur.finish
      if en > st then
        timeLabel = _formatTimeLabel(st) + " - " + _formatTimeLabel(en)
      end if
    end if
    if nextProg <> invalid and nextProg.title <> invalid then nextTitle = nextProg.title
    if nowTitle = "" then nowTitle = "Sem dados"
    if nextTitle = "" then nextTitle = "Sem dados"

    c.programTitle = nowTitle
    c.programNextTitle = nextTitle
    if c.hasField("programTimeLabel") then c.programTimeLabel = timeLabel
    if c.hasField("programProgress") then
      prog = -1.0
      for each pNow in programs
        if type(pNow) <> "roAssociativeArray" then continue for
        stn = pNow.start
        enn = pNow.finish
        if nowSec >= stn and nowSec < enn then
          if enn > stn then prog = (nowSec - stn) / (enn - stn)
          exit for
        end if
      end for
      c.programProgress = prog
    end if
  end for
  _perfEnd(p0, 50)
end sub

function _pad2(v as Integer) as String
  s = v.ToStr()
  if Len(s) < 2 then return "0" + s
  return s
end function

function _formatTimeLabel(epochSec as Integer) as String
  dt = CreateObject("roDateTime")
  if dt = invalid then return ""
  dt.FromSeconds(epochSec)
  dt.ToLocalTime()
  h = dt.GetHours()
  m = dt.GetMinutes()
  return _pad2(h) + ":" + _pad2(m)
end function

function _formatLiveDate() as String
  if m.liveSelectedDateForceToday = true then
    return _formatDateLongNow()
  end if
  key = m.liveSelectedDateKey
  if key <> invalid and key.Trim() <> "" then
    return _formatDateLongFromKey(key)
  end if
  sel = m.liveSelectedDateSec
  if sel = invalid or sel <= 0 then return _formatDateLongNow()
  return _formatDateLong(sel)
end function

function _formatDateLongFromParts(y as Integer, m as Integer, d as Integer) as String
  if d < 1 then d = 1
  if m < 1 then m = 1
  if m > 12 then m = 12
  if y < 1 then y = 1
  monthsPt = ["janeiro","fevereiro","marco","abril","maio","junho","julho","agosto","setembro","outubro","novembro","dezembro"]
  daysPt = ["domingo","segunda-feira","terca-feira","quarta-feira","quinta-feira","sexta-feira","sabado"]
  dow = _weekdayIndex(y, m, d)
  return daysPt[dow] + ", " + d.ToStr() + " de " + monthsPt[m - 1] + " de " + y.ToStr()
end function

function _formatDateLongNow() as String
  dt = CreateObject("roDateTime")
  if dt = invalid then return ""
  dt.ToLocalTime()
  y = dt.GetYear()
  m = dt.GetMonth()
  d = dt.GetDayOfMonth()
  return _formatDateLongFromParts(y, m, d)
end function

function _localDatePartsNow() as Object
  dt = CreateObject("roDateTime")
  if dt = invalid then return { y: 1970, m: 1, d: 1 }
  dt.ToLocalTime()
  return { y: dt.GetYear(), m: dt.GetMonth(), d: dt.GetDayOfMonth() }
end function

function _localDatePartsFromEpoch(epochSec as Integer) as Object
  dt = CreateObject("roDateTime")
  if dt = invalid then return { y: 1970, m: 1, d: 1 }
  dt.FromSeconds(epochSec)
  dt.ToLocalTime()
  return { y: dt.GetYear(), m: dt.GetMonth(), d: dt.GetDayOfMonth() }
end function

function _dateKeyFromParts(y as Integer, m as Integer, d as Integer) as String
  return y.ToStr() + "-" + _pad2(m) + "-" + _pad2(d)
end function

function _dateKeyNow() as String
  p = _localDatePartsNow()
  return _dateKeyFromParts(p.y, p.m, p.d)
end function

function _dateKeyFromEpoch(epochSec as Integer) as String
  p = _localDatePartsFromEpoch(epochSec)
  return _dateKeyFromParts(p.y, p.m, p.d)
end function

function _dateKeyAddDays(baseKey as String, delta as Integer) as String
  parts = _parseDateKey(baseKey)
  days = _daysFromCivil(parts.y, parts.m, parts.d)
  parts2 = _civilFromDays(days + Int(delta))
  return _dateKeyFromParts(parts2.y, parts2.m, parts2.d)
end function

function _civilFromDays(z as Integer) as Object
  zz = Int(z) + 719468
  era = Int(zz / 146097)
  if zz < 0 then era = Int((zz - 146096) / 146097)
  doe = zz - (era * 146097)
  yoe = Int((doe - Int(doe / 1460) + Int(doe / 36524) - Int(doe / 146096)) / 365)
  y = yoe + (era * 400)
  doy = doe - (365 * yoe + Int(yoe / 4) - Int(yoe / 100))
  mp = Int((5 * doy + 2) / 153)
  d = doy - Int((153 * mp + 2) / 5) + 1
  m = mp + 3
  if m > 12 then m = m - 12
  if m <= 2 then y = y + 1
  return { y: y, m: m, d: d }
end function

function _weekdayShortFromKey(key as String) as String
  parts = _parseDateKey(key)
  shortPt = ["dom","seg","ter","qua","qui","sex","sab"]
  idx = _weekdayIndex(parts.y, parts.m, parts.d)
  if idx < 0 then idx = 0
  if idx > 6 then idx = 6
  return shortPt[idx]
end function

function _dayFromKey(key as String) as String
  parts = _parseDateKey(key)
  return parts.d.ToStr()
end function

function _utcEpochFromLocalDateKey(key as String) as Integer
  parts = _parseDateKey(key)
  days = _daysFromCivil(parts.y, parts.m, parts.d)
  offsetSec = _localTimezoneOffsetMin() * 60
  return (days * 86400) - offsetSec
end function

function _parseDateKey(key as String) as Object
  k = key
  if k = invalid then k = ""
  k = k.Trim()
  if Len(k) < 10 then return { y: 1970, m: 1, d: 1 }
  y = Int(Val(Mid(k, 1, 4)))
  m = Int(Val(Mid(k, 6, 2)))
  d = Int(Val(Mid(k, 9, 2)))
  return { y: y, m: m, d: d }
end function

function _formatDateLongFromKey(key as String) as String
  parts = _parseDateKey(key)
  return _formatDateLongFromParts(parts.y, parts.m, parts.d)
end function

function _localTimezoneOffsetMin() as Integer
  utcSec = _nowEpochSec()
  dt = CreateObject("roDateTime")
  if dt = invalid then return 0
  dt.FromSeconds(utcSec)
  dt.ToLocalTime()
  y = dt.GetYear()
  m = dt.GetMonth()
  d = dt.GetDayOfMonth()
  hh = dt.GetHours()
  mm = dt.GetMinutes()
  ss = dt.GetSeconds()
  days = _daysFromCivil(y, m, d)
  localAsUtc = (days * 86400) + (hh * 3600) + (mm * 60) + ss
  offsetSec = localAsUtc - utcSec
  return Int(offsetSec / 60)
end function

function _formatIsoLocal(epochSec as Integer) as String
  dt = CreateObject("roDateTime")
  if dt = invalid then return ""
  dt.FromSeconds(epochSec)
  dt.ToLocalTime()
  y = dt.GetYear()
  m = dt.GetMonth()
  d = dt.GetDayOfMonth()
  hh = dt.GetHours()
  mm = dt.GetMinutes()
  ss = dt.GetSeconds()
  return y.ToStr() + "-" + _pad2(m) + "-" + _pad2(d) + "T" + _pad2(hh) + ":" + _pad2(mm) + ":" + _pad2(ss)
end function

function _daysFromCivil(y as Integer, m as Integer, d as Integer) as Integer
  yy = y
  mm = m
  if mm <= 2 then yy = yy - 1
  era = Int(yy / 400)
  yoe = yy - (era * 400)
  mp = mm
  if mp > 2 then mp = mp - 3 else mp = mp + 9
  doy = Int((153 * mp + 2) / 5) + d - 1
  doe = yoe * 365 + Int(yoe / 4) - Int(yoe / 100) + doy
  return (era * 146097 + doe - 719468)
end function

function _parseIso8601ToEpochSec(raw as String) as Integer
  s = raw
  if s = invalid then return 0
  s = s.Trim()
  if Len(s) < 19 then return 0

  y = Int(Val(Mid(s, 1, 4)))
  m = Int(Val(Mid(s, 6, 2)))
  d = Int(Val(Mid(s, 9, 2)))
  hh = Int(Val(Mid(s, 12, 2)))
  mm = Int(Val(Mid(s, 15, 2)))
  ss = Int(Val(Mid(s, 18, 2)))

  offsetSec = 0
  if Instr(1, s, "Z") > 0 then
    offsetSec = 0
  else
    tzPos = 0
    tzSign = ""
    tzPlus = Instr(20, s, "+")
    tzMinus = Instr(20, s, "-")
    if tzPlus > 0 then
      tzPos = tzPlus
      tzSign = "+"
    end if
    if tzMinus > 0 and (tzPos = 0 or tzMinus < tzPos) then
      tzPos = tzMinus
      tzSign = "-"
    end if
    if tzPos > 0 then
      oh = 0
      om = 0
      if Len(s) >= tzPos + 2 then oh = Int(Val(Mid(s, tzPos + 1, 2)))
      if Len(s) >= tzPos + 5 then om = Int(Val(Mid(s, tzPos + 4, 2)))
      offsetSec = oh * 3600 + om * 60
      if tzSign = "+" then
        offsetSec = offsetSec
      else if tzSign = "-" then
        offsetSec = -offsetSec
      end if
    end if
  end if

  days = _daysFromCivil(y, m, d)
  return days * 86400 + hh * 3600 + mm * 60 + ss - offsetSec
end function

function _buildLiveProgramMap(items as Object) as Object
  out = {}
  if type(items) <> "roArray" then return out
  for each it in items
    if it = invalid then continue for
    cid = ""
    if it.channelId <> invalid then cid = it.channelId
    if cid <> invalid then cid = cid.ToStr().Trim()
    if cid = "" then continue for

    stRaw = ""
    enRaw = ""
    if it.startDate <> invalid then stRaw = it.startDate
    if it.endDate <> invalid then enRaw = it.endDate
    st = _parseIso8601ToEpochSec(stRaw)
    en = _parseIso8601ToEpochSec(enRaw)
    if en <= st then continue for

    title = ""
    desc = ""
    if it.name <> invalid then title = it.name
    if title = invalid then title = ""
    title = title.ToStr().Trim()
    if it.episodeTitle <> invalid then desc = it.episodeTitle.ToStr().Trim()
    if title = "" and desc <> "" then title = desc
    if title = "" then title = "(Sem titulo)"

    arr = out[cid]
    if type(arr) <> "roArray" then arr = []
    arr.Push({ start: st, finish: en, title: title, desc: desc })
    out[cid] = arr
  end for
  for each k in out
    arr0 = out[k]
    if type(arr0) = "roArray" and arr0.Count() > 1 then
      out[k] = _sortProgramsAsc(arr0)
    end if
  end for
  return out
end function

function _sortProgramsAsc(programs as Object) as Object
  out = []
  if type(programs) <> "roArray" then return out
  for each p in programs
    if type(p) = "roAssociativeArray" then out.Push(p)
  end for
  if out.Count() < 2 then return out
  for i = 1 to out.Count() - 1
    key = out[i]
    j = i - 1
    ks = 0
    if key <> invalid and key.start <> invalid then ks = Int(key.start)
    while j >= 0
      js = 0
      if out[j] <> invalid and out[j].start <> invalid then js = Int(out[j].start)
      if js <= ks then exit while
      out[j + 1] = out[j]
      j = j - 1
    end while
    out[j + 1] = key
  end for
  return out
end function

sub _clearChildren(n as Object)
  if n = invalid then return
  while n.getChildCount() > 0
    n.removeChildIndex(0)
  end while
end sub

function _mapTimeToX(tSec as Integer, startSec as Integer, windowSec as Integer, width as Integer, startX as Integer) as Integer
  if windowSec <= 0 then return startX
  rel = tSec - startSec
  if rel < 0 then rel = 0
  if rel > windowSec then rel = windowSec
  return startX + Int((rel * width) / windowSec)
end function

function _epochSecFromCivil(y as Integer, m as Integer, d as Integer, hh as Integer, mm as Integer, ss as Integer) as Integer
  dt = CreateObject("roDateTime")
  if dt = invalid then return 0
  iso = y.ToStr() + "-" + _pad2(m) + "-" + _pad2(d) + "T" + _pad2(hh) + ":" + _pad2(mm) + ":" + _pad2(ss)
  dt.FromISO8601String(iso)
  return Int(dt.AsSeconds())
end function

function _todayMidnight() as Integer
  nowSec = _nowEpochSec()
  return _startOfDayEpoch(nowSec)
end function

function _startOfDayEpoch(epochSec as Integer) as Integer
  if epochSec = invalid then return 0
  dt = CreateObject("roDateTime")
  if dt = invalid then return 0
  dt.FromSeconds(epochSec)
  dt.ToLocalTime()
  hh = dt.GetHours()
  mm = dt.GetMinutes()
  ss = dt.GetSeconds()
  if hh = invalid then hh = 0
  if mm = invalid then mm = 0
  if ss = invalid then ss = 0
  return Int(epochSec) - (Int(hh) * 3600) - (Int(mm) * 60) - Int(ss)
end function

function _datePartsFromEpoch(epochSec as Integer) as Object
  dt = CreateObject("roDateTime")
  if dt = invalid then return { y: 1970, m: 1, d: 1 }
  dt.FromSeconds(epochSec)
  dt.ToLocalTime()
  return { y: dt.GetYear(), m: dt.GetMonth(), d: dt.GetDayOfMonth() }
end function

function _weekdayIndex(y as Integer, m as Integer, d as Integer) as Integer
  days = _daysFromCivil(y, m, d)
  dow = (days + 4) mod 7 ' 1970-01-01 was a Thursday (4 when Sunday=0)
  if dow < 0 then dow = dow + 7
  if dow < 0 then dow = 0
  if dow > 6 then dow = 6
  return dow
end function

function _formatDateLong(epochSec as Integer) as String
  parts = _datePartsFromEpoch(epochSec)
  y = parts.y
  m = parts.m
  d = parts.d
  if d < 1 then d = 1
  if m < 1 then m = 1
  if m > 12 then m = 12
  if y < 1 then y = 1
  monthsPt = ["janeiro","fevereiro","marco","abril","maio","junho","julho","agosto","setembro","outubro","novembro","dezembro"]
  daysPt = ["domingo","segunda-feira","terca-feira","quarta-feira","quinta-feira","sexta-feira","sabado"]
  dow = _weekdayIndex(y, m, d)
  return daysPt[dow] + ", " + d.ToStr() + " de " + monthsPt[m - 1] + " de " + y.ToStr()
end function

function _formatDateShort(epochSec as Integer) as String
  parts = _datePartsFromEpoch(epochSec)
  d = parts.d
  if d < 1 then d = 1
  return d.ToStr()
end function

function _formatWeekdayShort(epochSec as Integer) as String
  parts = _datePartsFromEpoch(epochSec)
  y = parts.y
  m = parts.m
  d = parts.d
  shortPt = ["dom","seg","ter","qua","qui","sex","sab"]
  return shortPt[_weekdayIndex(y, m, d)]
end function

function _sameDay(aSec as Integer, bSec as Integer) as Boolean
  if aSec = invalid or bSec = invalid then return false
  pa = _datePartsFromEpoch(aSec)
  pb = _datePartsFromEpoch(bSec)
  if pa = invalid or pb = invalid then return false
  return (pa.y = pb.y and pa.m = pb.m and pa.d = pb.d)
end function

function _sortedPrograms(programs as Object) as Object
  out = []
  if type(programs) <> "roArray" then return out
  for each p in programs
    if type(p) = "roAssociativeArray" then out.Push(p)
  end for
  for i = 0 to out.Count() - 2
    for j = i + 1 to out.Count() - 1
      a = out[i]
      b = out[j]
      sa = Int(a.start)
      sb = Int(b.start)
      if sb < sa then
        tmp = out[i]
        out[i] = out[j]
        out[j] = tmp
      end if
    end for
  end for
  return out
end function

function _ensureLiveProgramMap() as Object
  if m.liveProgramMapDirty = true or type(m.liveProgramMap) <> "roAssociativeArray" then
    m.liveProgramMap = _buildLiveProgramMap(m.livePrograms)
    m.liveProgramMapDirty = false
  end if
  return m.liveProgramMap
end function

sub _applyLiveProgramForChannelIndex(idx as Integer)
  p0 = _perfStart("applyLiveProgramForChannelIndex")
  if m.channelsList = invalid then return
  root = m.channelsList.content
  if root = invalid then return
  total = root.getChildCount()
  if total <= 0 then return
  if idx < 0 then idx = 0
  if idx > (total - 1) then idx = total - 1

  c = root.getChild(idx)
  if c = invalid then return
  if c.hasField("programTitle") <> true then c.addField("programTitle", "string", false)
  if c.hasField("programNextTitle") <> true then c.addField("programNextTitle", "string", false)

  cursorSec = m.liveFocusSec
  nowSec = _nowEpochSec()
  if cursorSec = invalid or cursorSec <= 0 then cursorSec = nowSec

  progMap = _ensureLiveProgramMap()
  cid = ""
  if c.hasField("id") then cid = c.id
  if cid <> invalid then cid = cid.ToStr().Trim()
  programs = progMap[cid]
  if type(programs) <> "roArray" then programs = []

  cur = invalid
  nextProg = invalid
  nextStart = 0
  for each p in programs
    if type(p) <> "roAssociativeArray" then continue for
    st = p.start
    en = p.finish
    if cursorSec >= st and cursorSec < en then
      cur = p
      exit for
    end if
    if st > cursorSec and (nextProg = invalid or st < nextStart) then
      nextProg = p
      nextStart = st
    end if
  end for

  nowTitle = ""
  nextTitle = ""
  if cur <> invalid and cur.title <> invalid then nowTitle = cur.title
  if nextProg <> invalid and nextProg.title <> invalid then nextTitle = nextProg.title
  if nowTitle = "" then nowTitle = "Sem dados"
  if nextTitle = "" then nextTitle = "Sem dados"
  c.programTitle = nowTitle
  c.programNextTitle = nextTitle
  _perfEnd(p0, 20)
end sub

function _buildGuideSegments(programs as Object, windowStart as Integer, windowEnd as Integer) as Object
  t0 = CreateObject("roTimespan")
  if t0 <> invalid then t0.Mark()
  p0 = _perfStart("buildGuideSegments")
  segs = []
  if windowEnd <= windowStart then return segs
  ordered = programs
  if type(ordered) <> "roArray" then ordered = []
  cursor = windowStart
  for each p in ordered
    st = Int(p.start)
    en = Int(p.finish)
    if en <= windowStart then continue for
    if st >= windowEnd then exit for

    if st > cursor then
      segs.Push({ start: cursor, finish: st, title: "Sem dados", isGap: true })
    end if

    segStart = st
    if segStart < windowStart then segStart = windowStart
    segEnd = en
    if segEnd > windowEnd then segEnd = windowEnd
    segs.Push({
      start: segStart,
      finish: segEnd,
      title: p.title,
      desc: p.desc,
      isGap: false,
      rawStart: st,
      rawFinish: en
    })
    cursor = segEnd
  end for

  if cursor < windowEnd then
    segs.Push({ start: cursor, finish: windowEnd, title: "Sem dados", isGap: true })
  end if

  if segs.Count() = 0 then
    segs.Push({ start: windowStart, finish: windowEnd, title: "Sem dados", isGap: true })
  end if

  _perfEnd(p0, 20)
  ms = 0
  if t0 <> invalid then ms = t0.TotalMilliseconds()
  if ms >= 50 then
    print "[perf] buildGuideSegments ms=" + ms.ToStr()
  end if
  return segs
end function

sub _updateEpgHeader(startSec as Integer, tickSec as Integer, windowSec as Integer, width as Integer, startX as Integer)
  if m.epgHeader = invalid then return
  _clearChildren(m.epgHeader)
  if tickSec <= 0 or windowSec <= 0 then return

  minorSec = tickSec
  minorMin = m.liveEpgMinorTickMinutes
  if minorMin <> invalid then
    mm = Int(minorMin)
    if mm > 0 then minorSec = mm * 60
  end if
  if minorSec <= 0 then minorSec = tickSec
  if minorSec > tickSec then minorSec = tickSec

  if minorSec > 0 then
    minorSteps = Int(windowSec / minorSec)
    if minorSteps < 1 then minorSteps = 1
    minorStepPx = width / minorSteps

    for i = 0 to minorSteps
      tick = CreateObject("roSGNode", "Rectangle")
      if tick = invalid then continue for
      tick.translation = [startX + Int(i * minorStepPx), 18]
      tick.width = 1
      tick.height = 8
      tick.color = "0xAAB4C2"
      m.epgHeader.appendChild(tick)
    end for
  end if

  steps = Int(windowSec / tickSec)
  if steps < 1 then steps = 1
  stepPx = width / steps

  for i = 0 to steps
    t = startSec + (i * tickSec)
    x = startX + Int(i * stepPx)
    w = Int(stepPx)
    maxW = (startX + width) - x
    if w > maxW then w = maxW
    if w <= 0 then continue for
    lbl = CreateObject("roSGNode", "Label")
    if lbl <> invalid then
      lbl.translation = [x, 0]
      lbl.width = w
      lbl.height = 30
      lbl.font = "font:MediumSystemFont"
      lbl.color = "0xC6D2E4"
      lbl.horizAlign = "left"
      lbl.text = _formatTimeLabel(t)
      m.epgHeader.appendChild(lbl)
    end if
  end for
end sub

function _renderLiveHighlightOnly() as Boolean
  if m.channelsList = invalid then return false
  root = m.channelsList.content
  if root = invalid then return false
  if m.liveGridRows = invalid or m.liveGridRows.Count() <= 0 then return false

  total = root.getChildCount()
  if total <= 0 then return false

  idx = m.liveChannelIndex
  if idx = invalid then idx = 0
  idx = Int(idx)
  if idx < 0 then idx = 0
  if idx > (total - 1) then idx = total - 1

  rowsMax = m.liveEpgRowsMax
  if rowsMax = invalid or rowsMax <= 0 then rowsMax = 1
  rowStart = m.liveRowStartIndex
  if rowStart = invalid then rowStart = 0
  if idx < rowStart or idx >= rowStart + rowsMax then return false

  r = idx - rowStart
  rowAA = invalid
  if r >= 0 and r < m.liveGridRows.Count() then rowAA = m.liveGridRows[r]
  if rowAA = invalid then return false

  _updateChannelListFocus()

  for each rr in m.liveGridRows
    if rr <> invalid and rr.focusRect <> invalid then rr.focusRect.visible = false
  end for

  startSec = m.liveEpgStartSec
  if startSec = invalid or startSec <= 0 then return false
  windowMin = m.liveEpgWindowMinutes
  if windowMin = invalid or windowMin <= 0 then windowMin = 180
  windowSec = windowMin * 60
  if windowSec <= 0 then return false

  focusSec = m.liveFocusSec
  if focusSec = invalid or focusSec <= 0 then focusSec = _nowEpochSec()
  endSec = startSec + windowSec
  if focusSec < startSec or focusSec > endSec then return false

  width = m.liveEpgWidth
  if width = invalid or width <= 0 then width = 1208
  hdrX = 0
  if m.epgHeaderLine <> invalid then
    if m.epgHeaderLine.width <> invalid and m.epgHeaderLine.width > 0 then width = Int(m.epgHeaderLine.width)
    trHdr0 = m.epgHeaderLine.translation
    if type(trHdr0) = "roArray" and trHdr0.Count() >= 2 then hdrX = Int(trHdr0[0])
  end if

  uiScale = 1.0
  trackW = width
  if m.liveLayout <> invalid and type(m.liveLayout) = "roAssociativeArray" then
    if m.liveLayout.scale <> invalid then uiScale = m.liveLayout.scale
    if m.liveLayout.trackW <> invalid then trackW = Int(m.liveLayout.trackW)
  end if
  if m.epgBg <> invalid and m.epgBg.width <> invalid then trackW = Int(m.epgBg.width)

  blockPad = Int(10 * uiScale)
  if blockPad < 6 then blockPad = 6
  rowH = m.liveEpgRowHeight
  if rowH = invalid or rowH <= 0 then rowH = 110
  blockH = rowH - (blockPad * 2)
  if blockH < 72 then blockH = 72

  minW = Int(72 * uiScale)
  if minW < 40 then minW = 40
  padR = Int(8 * uiScale)
  if padR < 6 then padR = 6

  ch = root.getChild(idx)
  if ch = invalid then return false

  cid = ""
  if ch.hasField("id") then cid = ch.id
  if cid <> invalid then cid = cid.ToStr().Trim()

  programs = []
  if cid <> "" and type(m.liveProgramMap) = "roAssociativeArray" then
    p = m.liveProgramMap[cid]
    if type(p) = "roArray" then programs = p
  end if

  segs = invalid
  verNow = 0
  if m.liveProgramsVersion <> invalid then verNow = Int(m.liveProgramsVersion)
  cacheCid = ""
  if rowAA.segCacheCid <> invalid then cacheCid = rowAA.segCacheCid.ToStr()
  cacheStart = -1
  if rowAA.segCacheStart <> invalid then cacheStart = Int(rowAA.segCacheStart)
  cacheEnd = -1
  if rowAA.segCacheEnd <> invalid then cacheEnd = Int(rowAA.segCacheEnd)
  cacheVer = -1
  if rowAA.segCacheVer <> invalid then cacheVer = Int(rowAA.segCacheVer)
  if rowAA.segCache <> invalid and cacheCid = cid and cacheStart = startSec and cacheEnd = endSec and cacheVer = verNow then
    segs = rowAA.segCache
  else
    segs = _buildGuideSegments(programs, startSec, endSec)
    rowAA.segCache = segs
    rowAA.segCacheCid = cid
    rowAA.segCacheStart = startSec
    rowAA.segCacheEnd = endSec
    rowAA.segCacheVer = verNow
  end if
  if type(segs) <> "roArray" then segs = []

  segStart = invalid
  segEnd = invalid
  for each seg in segs
    if seg = invalid then continue for
    if focusSec >= seg.start and focusSec < seg.finish then
      segStart = seg.start
      segEnd = seg.finish
      exit for
    end if
  end for

  if rowAA.focusRect = invalid then return false
  if segStart = invalid or segEnd = invalid or segEnd <= segStart then
    rowAA.focusRect.visible = false
    return true
  end if

  x0 = _mapTimeToX(segStart, startSec, windowSec, width, hdrX)
  x1 = _mapTimeToX(segEnd, startSec, windowSec, width, hdrX)
  w = x1 - x0

  if x0 < 0 then x0 = 0
  maxX = trackW - minW - padR
  if maxX < 0 then maxX = 0
  if x0 > maxX then x0 = maxX
  if w < minW then w = minW
  maxW = trackW - x0 - padR
  if maxW < minW then
    x0 = trackW - minW - padR
    if x0 < 0 then x0 = 0
    w = minW
  else
    if w > maxW then w = maxW
  end if

  rowAA.focusRect.visible = true
  rowAA.focusRect.translation = [x0 - 2, blockPad - 2]
  rowAA.focusRect.width = w + 4
  rowAA.focusRect.height = blockH + 4
  return true
end function

sub _renderLiveTimeline()
  _enforceLiveFocusLock()
  p0 = _perfStart("renderLiveTimeline")
  if m.epgRows = invalid then return
  if m.channelsList = invalid then return
  root = m.channelsList.content
  if root = invalid then return

  nowSec = _nowEpochSec()
  dateText = _formatLiveDate()
  if m.liveDateTextCached = invalid then m.liveDateTextCached = ""
  if dateText <> m.liveDateTextCached then
    if m.liveHeader <> invalid and m.liveHeader.hasField("dateText") then
      m.liveHeader.dateText = dateText
    end if
    if m.liveDate <> invalid then m.liveDate.text = dateText
    m.liveDateTextCached = dateText
  end if

  tickMin = m.liveEpgTickMinutes
  if tickMin = invalid or tickMin <= 0 then tickMin = 30
  windowMin = m.liveEpgWindowMinutes
  if windowMin = invalid or windowMin <= 0 then windowMin = 180

  tickSec = tickMin * 60
  windowSec = windowMin * 60
  if tickSec <= 0 then tickSec = 1800
  if windowSec <= 0 then windowSec = 10800

  startSec = m.liveEpgStartSec
  if startSec = invalid or startSec <= 0 then
    startSec = nowSec - (nowSec mod tickSec) - tickSec
    m.liveEpgStartSec = startSec
  end if
  endSec = startSec + windowSec

  focusSec = m.liveFocusSec
  if focusSec = invalid or focusSec <= 0 then
    focusSec = nowSec
    m.liveFocusSec = focusSec
  end if

  if focusSec < startSec then
    startSec = focusSec - tickSec
    m.liveEpgStartSec = startSec
    endSec = startSec + windowSec
  else if focusSec > endSec then
    startSec = focusSec - windowSec + tickSec
    m.liveEpgStartSec = startSec
    endSec = startSec + windowSec
  end if

  width = m.liveEpgWidth
  if width = invalid or width <= 0 then width = 1208
  hdrX = 0
  if m.epgHeaderLine <> invalid then
    if m.epgHeaderLine.width <> invalid and m.epgHeaderLine.width > 0 then width = Int(m.epgHeaderLine.width)
    trHdr0 = m.epgHeaderLine.translation
    if type(trHdr0) = "roArray" and trHdr0.Count() >= 2 then hdrX = Int(trHdr0[0])
  end if
  if m.liveHeaderStartSec <> startSec then
    _updateEpgHeader(startSec, tickSec, windowSec, width, hdrX)
    m.liveHeaderStartSec = startSec
  end if

  if m.epgNowLine <> invalid then
    nx = _mapTimeToX(nowSec, startSec, windowSec, width, hdrX)
    trNow = m.epgNowLine.translation
    yNow = 0
    if type(trNow) = "roArray" and trNow.Count() >= 2 then yNow = Int(trNow[1])
    m.epgNowLine.translation = [nx, yNow]
    m.epgNowLine.color = "0xD7B25C"
  end if
  if m.gridNowLine <> invalid then
    nx = _mapTimeToX(nowSec, startSec, windowSec, width, hdrX)
    trGrid = m.gridNowLine.translation
    yGrid = 0
    if type(trGrid) = "roArray" and trGrid.Count() >= 2 then yGrid = Int(trGrid[1])
    m.gridNowLine.translation = [nx, yGrid]
  end if

  _ensureLiveGridNodes()
  if m.liveGridRows = invalid or m.liveGridRows.Count() <= 0 then return
  if m.liveDebugPrinted <> true then
    m.liveDebugPrinted = true
    if m.programTrack <> invalid then
      trkTr = m.programTrack.translation
      tx = 0
      ty = 0
      if type(trkTr) = "roArray" and trkTr.Count() >= 2 then
        tx = Int(trkTr[0])
        ty = Int(trkTr[1])
      end if
      tw = m.programTrack.width
      th = m.programTrack.height
      if tw = invalid then tw = -1
      if th = invalid then th = -1
      vis = m.programTrack.visible
      op = m.programTrack.opacity
      if vis = invalid then vis = "invalid"
      if op = invalid then op = "invalid"
      print "live debug track x,y,w,h=" + tx.ToStr() + "," + ty.ToStr() + "," + tw.ToStr() + "," + th.ToStr()
      print "live debug track visible/opacity=" + vis.ToStr() + "/" + op.ToStr()
      print "live debug track children=" + m.programTrack.getChildCount().ToStr()
    end if
    if m.epgRows <> invalid then
      print "live debug epgRows children=" + m.epgRows.getChildCount().ToStr()
      if m.epgRows.getChildCount() > 0 then
        c0 = m.epgRows.getChild(0)
        if c0 <> invalid then
          cTr = c0.translation
          cx = 0
          cy = 0
          if type(cTr) = "roArray" and cTr.Count() >= 2 then
            cx = Int(cTr[0])
            cy = Int(cTr[1])
          end if
          cw = c0.width
          ch = c0.height
          if cw = invalid then cw = -1
          if ch = invalid then ch = -1
          cv = c0.visible
          co = c0.opacity
          if cv = invalid then cv = "invalid"
          if co = invalid then co = "invalid"
          print "live debug first child x,w,visible,opacity=" + cx.ToStr() + "," + cw.ToStr() + "," + cv.ToStr() + "," + co.ToStr()
        end if
      end if
    end if
    if m.channelsList <> invalid and root <> invalid then
      print "live debug channelCount=" + root.getChildCount().ToStr()
    end if
    if type(m.livePrograms) = "roArray" then
      print "live debug epgCount=" + m.livePrograms.Count().ToStr()
    end if
  end if

  total = root.getChildCount()
  if total <= 0 then return

  idx = m.liveChannelIndex
  if idx = invalid then idx = 0
  idx = Int(idx)
  if idx < 0 then idx = 0
  if idx > (total - 1) then idx = total - 1
  m.liveChannelIndex = idx

  rowH = m.liveEpgRowHeight
  if rowH = invalid or rowH <= 0 then rowH = 110
  rowsMax = m.liveEpgRowsMax
  if rowsMax = invalid or rowsMax <= 0 then rowsMax = 1

  rowStart = m.liveRowStartIndex
  if rowStart = invalid then rowStart = 0
  if idx < rowStart then rowStart = idx
  if idx >= rowStart + rowsMax then rowStart = idx - rowsMax + 1
  maxStart = total - rowsMax
  if maxStart < 0 then maxStart = 0
  if rowStart < 0 then rowStart = 0
  if rowStart > maxStart then rowStart = maxStart
  m.liveRowStartIndex = rowStart
  _updateChannelListFocus()

  syncListFields = false
  if m.channelsList <> invalid and m.channelsList.visible = true then
    syncListFields = true
  end if
  if syncListFields and m.liveProgramsLoaded = true then
    endIdx = rowStart + rowsMax - 1
    if endIdx > (total - 1) then endIdx = total - 1
    for vi = rowStart to endIdx
      _applyLiveProgramForChannelIndex(vi)
    end for
  end if

  uiScale = 1.0
  channelW = 180
  trackW = width
  if m.liveLayout <> invalid and type(m.liveLayout) = "roAssociativeArray" then
    if m.liveLayout.scale <> invalid then uiScale = m.liveLayout.scale
    if m.liveLayout.channelW <> invalid then channelW = Int(m.liveLayout.channelW)
    if m.liveLayout.trackW <> invalid then trackW = Int(m.liveLayout.trackW)
  end if
  if m.epgBg <> invalid and m.epgBg.width <> invalid then trackW = Int(m.epgBg.width)

  blockPad = Int(10 * uiScale)
  if blockPad < 6 then blockPad = 6
  blockH = rowH - (blockPad * 2)
  if blockH < 72 then blockH = 72

  maxSeg = m.liveMaxSegments
  if maxSeg = invalid or maxSeg <= 0 then maxSeg = 16

  minW = Int(72 * uiScale)
  if minW < 40 then minW = 40
  padR = Int(8 * uiScale)
  if padR < 6 then padR = 6

  for r = 0 to rowsMax - 1
    rowIdx = rowStart + r
    rowY = r * rowH

    rowAA = invalid
    if m.liveGridRows <> invalid and r < m.liveGridRows.Count() then rowAA = m.liveGridRows[r]
    if rowAA = invalid then continue for

    if rowIdx > (total - 1) then
      if rowAA.chGroup <> invalid then rowAA.chGroup.visible = false
      if rowAA.progGroup <> invalid then rowAA.progGroup.visible = false
      if rowAA.focusRect <> invalid then rowAA.focusRect.visible = false
      blocks0 = rowAA.blocks
      if type(blocks0) <> "roArray" then blocks0 = []
      for bi = 0 to blocks0.Count() - 1
        b0 = blocks0[bi]
        if b0 <> invalid and b0.group <> invalid then b0.group.visible = false
      end for
      continue for
    end if

    ch = root.getChild(rowIdx)
    if ch = invalid then continue for
    selectedRow = (rowIdx = idx)

    if rowAA.chGroup <> invalid then
      rowAA.chGroup.visible = true
      rowAA.chGroup.translation = [0, rowY]
    end if
    if rowAA.chBg <> invalid then
      rowAA.chBg.width = channelW
      rowAA.chBg.height = rowH
      rowAA.chBg.color = "0x101827"
    end if
    logoSize = Int(48 * uiScale)
    if logoSize < 36 then logoSize = 36
    logoX = Int(12 * uiScale)
    if logoX < 8 then logoX = 8
    logoY = Int((rowH - logoSize) / 2)
    if rowAA.chLogo <> invalid then
      rowAA.chLogo.translation = [logoX, logoY]
      rowAA.chLogo.width = logoSize
      rowAA.chLogo.height = logoSize
      logoUri = ""
      if ch.logoUrl <> invalid then logoUri = ch.logoUrl.ToStr().Trim()
      if logoUri = "" and ch.hdPosterUrl <> invalid then logoUri = ch.hdPosterUrl.ToStr().Trim()
      if logoUri = "" and ch.posterUrl <> invalid then logoUri = ch.posterUrl.ToStr().Trim()
      prevLogo = ""
      if rowAA.chLogoUri <> invalid then prevLogo = rowAA.chLogoUri.ToStr()
      if prevLogo <> logoUri then
        rowAA.chLogo.uri = logoUri
        rowAA.chLogoUri = logoUri
      end if
    end if
    if rowAA.chName <> invalid then
      rowAA.chName.translation = [logoX + logoSize + 10, Int((rowH - 28) / 2)]
      rowAA.chName.width = channelW - (logoX + logoSize + 18)
      if rowAA.chName.width < 80 then rowAA.chName.width = 80
      rowAA.chName.height = 28
      if selectedRow then
        rowAA.chName.color = "0xF2F5FA"
      else
        rowAA.chName.color = "0xC8D3E2"
      end if
      nm = ""
      if ch.title <> invalid then nm = ch.title.ToStr().Trim()
      if nm = "" then nm = "Live TV"
      rowAA.chName.text = nm
    end if

    if rowAA.progGroup <> invalid then
      rowAA.progGroup.visible = true
      rowAA.progGroup.translation = [0, rowY]
    end if
    if rowAA.rowBg <> invalid then
      rowAA.rowBg.width = trackW
      rowAA.rowBg.height = rowH
      rowAA.rowBg.color = "0x0D1524"
    end if

    programs = []
    cid = ""
    if ch.hasField("id") then cid = ch.id
    if cid <> invalid then cid = cid.ToStr().Trim()
    if cid <> "" and type(m.liveProgramMap) = "roAssociativeArray" then
      p = m.liveProgramMap[cid]
      if type(p) = "roArray" then programs = p
    end if

    segs = invalid
    verNow = 0
    if m.liveProgramsVersion <> invalid then verNow = Int(m.liveProgramsVersion)
    cacheCid = ""
    if rowAA.segCacheCid <> invalid then cacheCid = rowAA.segCacheCid.ToStr()
    cacheStart = -1
    if rowAA.segCacheStart <> invalid then cacheStart = Int(rowAA.segCacheStart)
    cacheEnd = -1
    if rowAA.segCacheEnd <> invalid then cacheEnd = Int(rowAA.segCacheEnd)
    cacheVer = -1
    if rowAA.segCacheVer <> invalid then cacheVer = Int(rowAA.segCacheVer)
    if rowAA.segCache <> invalid and cacheCid = cid and cacheStart = startSec and cacheEnd = endSec and cacheVer = verNow then
      segs = rowAA.segCache
    else
      segs = _buildGuideSegments(programs, startSec, endSec)
      rowAA.segCache = segs
      rowAA.segCacheCid = cid
      rowAA.segCacheStart = startSec
      rowAA.segCacheEnd = endSec
      rowAA.segCacheVer = verNow
    end if
    if type(segs) <> "roArray" then segs = []
    focusShown = false
    blocks = rowAA.blocks
    if type(blocks) <> "roArray" then blocks = []

    for s = 0 to maxSeg - 1
      b = invalid
      if s < blocks.Count() then b = blocks[s]
      if b = invalid then continue for

      if s < segs.Count() then
        seg = segs[s]
        segStart = seg.start
        segEnd = seg.finish
        if segEnd <= segStart then
          if b.group <> invalid then b.group.visible = false
          continue for
        end if

        x0 = _mapTimeToX(segStart, startSec, windowSec, width, hdrX)
        x1 = _mapTimeToX(segEnd, startSec, windowSec, width, hdrX)
        w = x1 - x0

        if x0 < 0 then x0 = 0
        maxX = trackW - minW - padR
        if maxX < 0 then maxX = 0
        if x0 > maxX then x0 = maxX
        if w < minW then w = minW
        maxW = trackW - x0 - padR
        if maxW < minW then
          x0 = trackW - minW - padR
          if x0 < 0 then x0 = 0
          w = minW
        else
          if w > maxW then w = maxW
        end if

        isGap = (seg.isGap = true)
        isSelected = (selectedRow and focusSec >= segStart and focusSec < segEnd)
        isNow = false
        if isGap <> true then
          rs = seg.rawStart
          re = seg.rawFinish
          if rs <> invalid and re <> invalid then
            if nowSec >= rs and nowSec < re then isNow = true
          end if
        end if

        if rowAA.focusRect <> invalid then
          if isSelected then
            rowAA.focusRect.visible = true
            rowAA.focusRect.translation = [x0 - 2, blockPad - 2]
            rowAA.focusRect.width = w + 4
            rowAA.focusRect.height = blockH + 4
            focusShown = true
          end if
        end if

        if b.group <> invalid then
          b.group.visible = true
          b.group.translation = [x0, blockPad]
        end if
        if b.rect <> invalid then
          b.rect.width = w
          b.rect.height = blockH
          if isGap then
            b.rect.color = "0x141B28"
          else if isSelected then
            b.rect.color = "0x2A3B56"
          else
            b.rect.color = "0x1C2B42"
          end if
        end if
        if b.label <> invalid then
          txt = ""
          if seg.title <> invalid then txt = seg.title.ToStr().Trim()
          if txt = "" then txt = "Sem dados"
          maxChars = Int((w - 16) / (10 * uiScale))
          if maxChars < 6 then maxChars = 6
          if Len(txt) > maxChars then txt = Left(txt, maxChars - 1) + "..."
          b.label.translation = [8, 8]
          b.label.width = w - 16
          if b.label.width < 16 then b.label.width = 16
          b.label.height = 26
          if isGap then
            b.label.color = "0x7D8AA1"
          else
            b.label.color = "0xE3EBF7"
          end if
          b.label.text = txt
        end if
        if b.progress <> invalid then
          if isNow then
            rs = seg.rawStart
            re = seg.rawFinish
            pct = 0.0
            if re > rs then pct = (nowSec - rs) / (re - rs)
            if pct < 0 then pct = 0
            if pct > 1 then pct = 1
            b.progress.visible = true
            b.progress.translation = [0, blockH - 4]
            b.progress.width = Int(w * pct)
            if b.progress.width < 4 then b.progress.width = 4
            if b.progress.width > w then b.progress.width = w
            b.progress.height = 4
          else
            b.progress.visible = false
          end if
        end if
      else
        if b.group <> invalid then b.group.visible = false
      end if
    end for

    if rowAA.focusRect <> invalid and focusShown <> true then
      rowAA.focusRect.visible = false
    end if
  end for
  _perfEnd(p0, 30)
  if m.liveEpgStartSec <> invalid then m.liveLastRenderStartSec = m.liveEpgStartSec
  if m.liveChannelIndex <> invalid then m.liveLastRenderChannelIndex = m.liveChannelIndex
end sub

sub _ensureLiveGridNodes()
  _enforceLiveFocusLock()
  t0 = CreateObject("roTimespan")
  if t0 <> invalid then t0.Mark()
  p0 = _perfStart("rebuildBlocks")
  if m.channelRows = invalid or m.epgRows = invalid then
    _perfEnd(p0, 20)
    return
  end if

  rowsMax = m.liveEpgRowsMax
  if rowsMax = invalid or rowsMax <= 0 then rowsMax = 1
  if m.liveGridRows <> invalid and m.liveGridRows.Count() = rowsMax then
    _perfEnd(p0, 20)
    return
  end if

  _clearChildren(m.channelRows)
  _clearChildren(m.epgRows)
  m.liveGridRows = []

  maxSeg = m.liveMaxSegments
  if maxSeg = invalid or maxSeg <= 0 then maxSeg = 16
  m.liveMaxSegments = maxSeg

  for r = 0 to rowsMax - 1
    chGroup = CreateObject("roSGNode", "Group")
    if chGroup <> invalid then
      chGroup.translation = [0, 0]
      if chGroup.hasField("focusable") then chGroup.focusable = false
      m.channelRows.appendChild(chGroup)
    end if

    chBg = CreateObject("roSGNode", "Rectangle")
    if chBg <> invalid then
      chBg.translation = [0, 0]
      chBg.width = 140
      chBg.height = 90
      chBg.color = "0x101827"
      if chBg.hasField("focusable") then chBg.focusable = false
      if chGroup <> invalid then chGroup.appendChild(chBg)
    end if

    chLogo = CreateObject("roSGNode", "Poster")
    if chLogo <> invalid then
      chLogo.translation = [8, 8]
      chLogo.width = 40
      chLogo.height = 40
      chLogo.loadDisplayMode = "scaleToFit"
      if chLogo.hasField("focusable") then chLogo.focusable = false
      if chGroup <> invalid then chGroup.appendChild(chLogo)
    end if

    chName = CreateObject("roSGNode", "Label")
    if chName <> invalid then
      chName.translation = [60, 10]
      chName.width = 140
      chName.height = 28
      chName.font = "font:MediumSystemFont"
      chName.color = "0xC8D3E2"
      if chName.hasField("focusable") then chName.focusable = false
      if chGroup <> invalid then chGroup.appendChild(chName)
    end if

    progGroup = CreateObject("roSGNode", "Group")
    if progGroup <> invalid then
      progGroup.translation = [0, 0]
      if progGroup.hasField("focusable") then progGroup.focusable = false
      m.epgRows.appendChild(progGroup)
    end if

    rowBg = CreateObject("roSGNode", "Rectangle")
    if rowBg <> invalid then
      rowBg.translation = [0, 0]
      rowBg.width = 400
      rowBg.height = 90
      rowBg.color = "0x0D1524"
      if rowBg.hasField("focusable") then rowBg.focusable = false
      if progGroup <> invalid then progGroup.appendChild(rowBg)
    end if

    focusRect = CreateObject("roSGNode", "Rectangle")
    if focusRect <> invalid then
      focusRect.translation = [0, 0]
      focusRect.width = 0
      focusRect.height = 0
      focusRect.color = "0x2FD7B25C"
      focusRect.visible = false
      if focusRect.hasField("focusable") then focusRect.focusable = false
    end if

    blocks = []
    for i = 0 to maxSeg - 1
      bGroup = CreateObject("roSGNode", "Group")
      if bGroup <> invalid then
        bGroup.translation = [0, 0]
        bGroup.visible = false
        if bGroup.hasField("focusable") then bGroup.focusable = false
        if progGroup <> invalid then progGroup.appendChild(bGroup)
      end if

      bRect = CreateObject("roSGNode", "Rectangle")
      if bRect <> invalid then
        bRect.translation = [0, 0]
        bRect.width = 80
        bRect.height = 60
        bRect.color = "0x1C2B42"
        if bRect.hasField("focusable") then bRect.focusable = false
        if bGroup <> invalid then bGroup.appendChild(bRect)
      end if

      bLabel = CreateObject("roSGNode", "Label")
      if bLabel <> invalid then
        bLabel.translation = [8, 8]
        bLabel.width = 120
        bLabel.height = 26
        bLabel.font = "font:MediumSystemFont"
        bLabel.wrap = false
        bLabel.numLines = 1
        bLabel.color = "0xE3EBF7"
        if bLabel.hasField("focusable") then bLabel.focusable = false
        if bGroup <> invalid then bGroup.appendChild(bLabel)
      end if

      bProg = CreateObject("roSGNode", "Rectangle")
      if bProg <> invalid then
        bProg.translation = [0, 0]
        bProg.width = 0
        bProg.height = 4
        bProg.color = "0xD7B25C"
        bProg.visible = false
        if bProg.hasField("focusable") then bProg.focusable = false
        if bGroup <> invalid then bGroup.appendChild(bProg)
      end if

      blocks.Push({
        group: bGroup,
        rect: bRect,
        label: bLabel,
        progress: bProg
      })
    end for

    if progGroup <> invalid and focusRect <> invalid then
      progGroup.appendChild(focusRect)
    end if

    m.liveGridRows.Push({
      chGroup: chGroup,
      chBg: chBg,
      chLogo: chLogo,
      chLogoUri: "",
      chName: chName,
      progGroup: progGroup,
      rowBg: rowBg,
      focusRect: focusRect,
      segCache: invalid,
      segCacheCid: "",
      segCacheStart: 0,
      segCacheEnd: 0,
      segCacheVer: -1,
      blocks: blocks
    })
  end for
  _perfEnd(p0, 30)
  ms = 0
  if t0 <> invalid then ms = t0.TotalMilliseconds()
  if ms >= 50 then
    print "[perf] rebuildBlocks ms=" + ms.ToStr()
  end if
end sub

sub onChannelSelected()
  if _isPlaybackVisible() then
    print "[guard] ignore onChannelSelected while playback visible"
    return
  end if

  if m.mode <> "live" then return
  playSelectedLiveChannel()
end sub

sub onChannelFocused()
  if m.mode <> "live" then return
  if m.channelsList <> invalid and m.channelsList.itemFocused <> invalid then
    idx = Int(m.channelsList.itemFocused)
    if idx >= 0 then m.liveChannelIndex = idx
  end if
  _requestLiveRender("channel_focus")
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

  attempt = m.pendingPlayAttemptId
  if attempt = invalid then attempt = ""
  attempt = attempt.ToStr().Trim()
  if attempt = "" then
    attempt = m.playAttemptId
    if attempt = invalid then attempt = ""
    attempt = attempt.ToStr().Trim()
  end if
  m.pendingSignAttemptId = attempt

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
  if isLive = true then
    apiBase = _livePlaybackBase(apiBase)
  else if playbackKind = "vod-r2" then
    apiBase = _vodR2PlaybackBase(apiBase)
  end if
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
