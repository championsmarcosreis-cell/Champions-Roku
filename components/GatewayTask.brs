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
end sub

sub doWork()
  kind = m.top.kind

  m.top.ok = false
  m.top.error = ""
  m.top.accessToken = ""
  m.top.userId = ""
  m.top.signedUrl = ""
  m.top.exp = 0

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
