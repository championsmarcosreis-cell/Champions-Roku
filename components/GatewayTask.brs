' Runs gateway HTTP operations on a Task thread (roUrlTransfer is not allowed on the render thread).

sub init()
  ' Task must know which function to execute when control="run".
  m.top.functionName = "doWork"

  m.top.ok = false
  m.top.error = ""
  m.top.accessToken = ""
  m.top.userId = ""
  m.top.signedUrl = ""
  m.top.exp = 0
  m.top.resultJson = ""
end sub

sub doWork()
  kind = m.top.kind

  m.top.ok = false
  m.top.error = ""
  m.top.accessToken = ""
  m.top.signedUrl = ""
  m.top.exp = 0
  m.top.resultJson = ""

  if kind = "login" then
    resp = gatewayJellyfinAuth(m.top.apiBase, m.top.appToken, m.top.username, m.top.password)
    if resp.ok = true then
      m.top.ok = true
      m.top.accessToken = resp.accessToken
      m.top.userId = resp.userId
    else
      m.top.error = resp.error
    end if
    return
  end if

  if kind = "views" then
    resp = gatewayJellyfinViews(m.top.apiBase, m.top.appToken, m.top.jellyfinToken, m.top.userId)
    if resp.ok = true then
      m.top.ok = true
      m.top.resultJson = FormatJson(resp.items)
    else
      m.top.error = resp.error
    end if
    return
  end if

  if kind = "shelf" then
    lim = m.top.limit
    if lim = invalid then lim = 0
    if lim <= 0 then lim = 12
    resp = gatewayJellyfinShelfItems(m.top.apiBase, m.top.appToken, m.top.jellyfinToken, m.top.userId, m.top.parentId, lim)
    if resp.ok = true then
      m.top.ok = true
      m.top.resultJson = FormatJson(resp.items)
    else
      m.top.error = resp.error
    end if
    return
  end if

  if kind = "channels" then
    resp = gatewayJellyfinLiveChannels(m.top.apiBase, m.top.appToken, m.top.jellyfinToken)
    if resp.ok = true then
      m.top.ok = true
      m.top.resultJson = FormatJson(resp.items)
    else
      m.top.error = resp.error
    end if
    return
  end if

  if kind = "playback" then
    prefer = (m.top.preferDirectStream = true)
    allow = (m.top.allowTranscoding = true)
    resp = gatewayJellyfinPlaybackSource(m.top.apiBase, m.top.appToken, m.top.jellyfinToken, m.top.userId, m.top.itemId, prefer, allow)
    if resp.ok = true then
      m.top.ok = true
      m.top.resultJson = FormatJson({
        path: resp.path
        query: resp.query
        container: resp.container
      })
    else
      m.top.error = resp.error
    end if
    return
  end if

  if kind = "sign" then
    resp = gatewaySignPath(m.top.apiBase, m.top.appToken, m.top.jellyfinToken, m.top.path)
    if resp.ok = true then
      m.top.ok = true
      m.top.signedUrl = resp.url
      if resp.exp <> invalid then
        ' Gateway exp may come back as float/string; store a best-effort integer.
        m.top.exp = Int(resp.exp)
      end if
    else
      m.top.error = resp.error
    end if
    return
  end if

  m.top.error = "unknown_kind"
end sub
