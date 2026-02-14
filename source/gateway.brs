' Gateway/Jellyfin helpers.

function _trimSlash(s as String) as String
  if s = invalid then return ""
  t = s.Trim()
  if t.EndsWith("/") then t = Left(t, Len(t) - 1)
  return t
end function

function gatewayJellyfinAuth(apiBase as String, appToken as String, username as String, password as String) as Object
  base = _trimSlash(apiBase)
  url = base + "/jellyfin/Users/AuthenticateByName"
  payload = {
    Username: username
    Pw: password
  }
  body = FormatJson(payload)
  headers = {
    "Content-Type": "application/json"
  }
  if appToken <> invalid and appToken <> "" then headers["X-App-Token"] = appToken
  ' Jellyfin requires X-Emby-Authorization on AuthenticateByName.
  headers["X-Emby-Authorization"] = "MediaBrowser Client=ChampionsRoku, Device=Roku, DeviceId=champions-roku, Version=1.0.0"
  resp = httpJson("POST", url, headers, body)
  if resp.ok <> true then
    return { ok: false, error: resp.error }
  end if

  data = resp.data
  tok = data.AccessToken
  user = data.User
  userId = invalid
  if user <> invalid then userId = user.Id

  if tok = invalid or tok = "" then
    return { ok: false, error: "missing_access_token" }
  end if
  if userId = invalid or userId = "" then
    userId = "unknown"
  end if

  return { ok: true, accessToken: tok, userId: userId }
end function

function gatewaySignPath(apiBase as String, appToken as String, jellyfinToken as String, path as String) as Object
  base = _trimSlash(apiBase)
  x = CreateObject("roUrlTransfer")
  qp = "path=" + x.Escape(path)
  url = base + "/sign?" + qp
  headers = {
    "X-App-Token": appToken
    "X-Emby-Token": jellyfinToken
  }
  resp = httpJson("GET", url, headers)
  if resp.ok <> true then
    return { ok: false, error: resp.error }
  end if

  data = resp.data
  if data.url = invalid or data.url = "" then
    return { ok: false, error: "missing_signed_url" }
  end if
  return { ok: true, url: data.url, exp: data.exp }
end function
