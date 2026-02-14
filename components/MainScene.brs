' Login screen styled like the Windows app (no "Baixados") + optional Live player.

sub init()
  m.top.backgroundColor = "0x0B0F16"
  m.form = {
    username: ""
    password: ""
  }

  m.mode = "login" ' login | home (will be applied after UI binds)
  m.focusIndex = 0 ' login: 0=username,1=password,2=login; home: 0=live,1=tokens,2=logout
  m.pendingPrompt = ""
  m.pendingDialog = invalid
  m.pendingJob = ""

  cfg0 = loadConfig()
  m.apiBase = cfg0.apiBase
  if m.apiBase = invalid or m.apiBase = "" then m.apiBase = "https://api.champions.place"

  if cfg0.jellyfinToken <> invalid and cfg0.jellyfinToken <> "" then
    m.startupMode = "home"
  else
    m.startupMode = "login"
  end if

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

  m.top.setFocus(true)
end sub

sub bindUiNodes()
  m.titleLabel = m.top.findNode("titleLabel")
  m.statusLabel = m.top.findNode("statusLabel")
  m.hintLabel = m.top.findNode("hintLabel")

  m.loginCard = m.top.findNode("loginCard")
  m.homeCard = m.top.findNode("homeCard")

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
  if m.player <> invalid and (m.playerObsSetup <> true) then
    m.player.observeField("state", "onPlayerStateChanged")
    m.player.observeField("errorMsg", "onPlayerError")
    m.playerObsSetup = true
  end if
end sub

function uiReady() as Boolean
  return (m.loginCard <> invalid and m.homeCard <> invalid and m.hintLabel <> invalid)
end function

sub onBindTimerFire()
  m.bindAttempts = m.bindAttempts + 1
  bindUiNodes()

  if uiReady() then
    renderForm()
    if m.startupMode = "home" then
      enterHome()
    else
      enterLogin()
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

sub layoutCards()
  ' Cards are 520x260 on a 1280x720 UI (manifest ui_resolutions=hd).
  x = 380 ' (1280-520)/2
  y = 390
  if m.loginCard <> invalid then m.loginCard.translation = [x, y]
  if m.homeCard <> invalid then m.homeCard.translation = [x, y]
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

  if t = "" or t = "ready" then
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

  setStatus("signing /hls/index.m3u8")
  m.pendingJob = "sign"
  m.gatewayTask.kind = "sign"
  m.gatewayTask.apiBase = cfg.apiBase
  m.gatewayTask.appToken = cfg.appToken
  m.gatewayTask.jellyfinToken = cfg.jellyfinToken
  m.gatewayTask.path = "/hls/index.m3u8"
  m.gatewayTask.control = "run"
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

  if job = "sign" then
    if m.gatewayTask.ok = true then
      cfg = loadConfig()
      url = cfg.apiBase + m.gatewayTask.signedUrl
      setStatus("opening live...")
      startVideo(url, "Live")
    else
      err = m.gatewayTask.error
      if err = invalid or err = "" then err = "unknown"
      setStatus("sign failed: " + err)
    end if
    return
  end if
end sub

sub startVideo(url as String, title as String)
  if m.player = invalid then
    setStatus("player: missing node")
    return
  end if

  c = CreateObject("roSGNode", "ContentNode")
  c.url = url
  c.streamFormat = "hls"
  c.title = title

  m.player.content = c
  m.player.visible = true
  m.player.control = "play"
  m.player.setFocus(true)
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
  if press <> true then return false

  if key = "up" then
    if m.player <> invalid and m.player.visible = true then return false
    if m.focusIndex > 0 then m.focusIndex = m.focusIndex - 1
    applyFocus()
    return true
  end if

  if key = "down" then
    if m.player <> invalid and m.player.visible = true then return false
    if m.focusIndex < 2 then m.focusIndex = m.focusIndex + 1
    applyFocus()
    return true
  end if

  if key = "OK" then
    if m.player <> invalid and m.player.visible = true then return false
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
        playLive()
      else if m.focusIndex = 1 then
        showTokens()
      else
        doLogout()
      end if
    end if
    return true
  end if

  if key = "back" then
    if m.player <> invalid and m.player.visible = true then
      m.player.control = "stop"
      m.player.visible = false
      setStatus("stopped")
      return true
    end if
  end if

  if key = "options" then
    showSettings()
    return true
  end if

  if key = "play" then
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
      m.loginBg.uri = "pkg:/images/button_focus.png"
    else
      m.loginBg.uri = "pkg:/images/button_normal.png"
    end if
  end if
  if m.loginText <> invalid then
    m.loginText.color = "0x0B0F16"
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
  dlg.message = "1) Configurar APP_TOKEN" + Chr(10) + "2) Limpar dados salvos"
  dlg.buttons = ["APP_TOKEN", "Limpar", "Cancelar"]
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
    clearSaved()
  else
    ' no-op
  end if
end sub

sub onPlayerStateChanged()
  st = m.player.state
  if st = invalid then return
  if st = "playing" then
    setStatus("playing")
  else if st = "buffering" then
    setStatus("buffering")
  else if st = "finished" then
    setStatus("finished")
  end if
end sub

sub onPlayerError()
  msg = m.player.errorMsg
  if msg = invalid then msg = "unknown"
  setStatus("player error: " + msg)
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
  if m.loginCard <> invalid then m.loginCard.visible = true
  if m.homeCard <> invalid then m.homeCard.visible = false
  layoutCards()
  loadSavedIntoForm()
  applyFocus()
  setStatus("ready")
end sub

sub enterHome()
  m.mode = "home"
  m.focusIndex = 0
  if m.loginCard <> invalid then m.loginCard.visible = false
  if m.homeCard <> invalid then m.homeCard.visible = true
  layoutCards()
  if m.hintLabel <> invalid then m.hintLabel.visible = false
  applyFocus()
  setStatus("ready")
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
end sub

function shortToken(t as String) as String
  if t = invalid then return ""
  v = t.Trim()
  if v = "" then return "-"
  if Len(v) <= 16 then return v
  return Left(v, 6) + "..." + Right(v, 4)
end function
