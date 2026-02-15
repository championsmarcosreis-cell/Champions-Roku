' Gateway/Jellyfin helpers.

function _trimSlash(s as String) as String
  if s = invalid then return ""
  t = s.Trim()
  if t.EndsWith("/") then t = Left(t, Len(t) - 1)
  return t
end function

function _jellyfinClientHeader() as String
  ' Jellyfin expects this header on many API calls.
  return "MediaBrowser Client=ChampionsRoku, Device=Roku, DeviceId=champions-roku, Version=1.0.0"
end function

function _jellyfinExtractPath(item as Object) as String
  if item = invalid then return ""

  if item.Path <> invalid then
    p = item.Path
    if p <> invalid then
      t = p.Trim()
      if t <> "" then return t
    end if
  end if

  ms = item.MediaSources
  if type(ms) = "roArray" and ms.Count() > 0 then
    first = ms[0]
    if first <> invalid then
      if first.Path <> invalid then
        t2 = first.Path
        if t2 <> invalid then
          tt2 = t2.Trim()
          if tt2 <> "" then return tt2
        end if
      end if
      if first.DirectStreamUrl <> invalid then
        t3 = first.DirectStreamUrl
        if t3 <> invalid then
          tt3 = t3.Trim()
          if tt3 <> "" then return tt3
        end if
      end if
    end if
  end if

  return ""
end function

function _urlWithQuery(url as String, params as Object) as String
  if params = invalid then return url

  x = CreateObject("roUrlTransfer")
  out = url
  first = true

  for each k in params
    v = params[k]
    if v = invalid then v = ""

    if type(v) = "roBoolean" then
      if v = true then v = "true" else v = "false"
    else if type(v) <> "roString" then
      v = v.ToStr()
    end if

    sep = "&"
    if first then sep = "?"
    out = out + sep + k + "=" + x.Escape(v)
    first = false
  end for

  return out
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
  headers["X-Emby-Authorization"] = _jellyfinClientHeader()
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

function gatewayJellyfinViews(apiBase as String, appToken as String, jellyfinToken as String, userId as String) as Object
  base = _trimSlash(apiBase)

  uid = userId
  if uid = invalid then uid = ""
  uid = uid.Trim()
  if uid = "" then
    return { ok: false, error: "missing_user_id" }
  end if

  url = base + "/jellyfin/Users/" + uid + "/Views"

  headers = {
    "X-Emby-Authorization": _jellyfinClientHeader()
    "X-Emby-Token": jellyfinToken
  }
  if appToken <> invalid and appToken <> "" then headers["X-App-Token"] = appToken

  resp = httpJson("GET", url, headers)
  if resp.ok <> true then
    return { ok: false, error: resp.error }
  end if

  data = resp.data
  items = invalid
  if data <> invalid then items = data.Items
  if type(items) <> "roArray" then items = []

  out = []
  for each it in items
    id = ""
    name = ""
    ctype = ""

    if it <> invalid then
      if it.Id <> invalid then id = it.Id
      if it.Name <> invalid then name = it.Name
      if it.CollectionType <> invalid then ctype = it.CollectionType
    end if

    out.Push({ id: id, name: name, collectionType: ctype })
  end for

  return { ok: true, items: out }
end function

function gatewayJellyfinShelfItems(apiBase as String, appToken as String, jellyfinToken as String, userId as String, parentId as String, limit as Integer) as Object
  base = _trimSlash(apiBase)

  uid = userId
  if uid = invalid then uid = ""
  uid = uid.Trim()
  if uid = "" then
    return { ok: false, error: "missing_user_id" }
  end if

  pid = parentId
  if pid = invalid then pid = ""
  pid = pid.Trim()
  if pid = "" then
    return { ok: false, error: "missing_parent_id" }
  end if

  lim = limit
  if lim <= 0 then lim = 12

  url = base + "/jellyfin/Users/" + uid + "/Items"
  url = _urlWithQuery(url, {
    ParentId: pid
    Recursive: true
    Limit: lim
    SortBy: "DateCreated"
    SortOrder: "Descending"
    ExcludeItemTypes: "Folder,CollectionFolder"
    IsMissing: false
    Fields: "RunTimeTicks,Path,MediaSources"
  })

  headers = {
    "X-Emby-Authorization": _jellyfinClientHeader()
    "X-Emby-Token": jellyfinToken
  }
  if appToken <> invalid and appToken <> "" then headers["X-App-Token"] = appToken

  resp = httpJson("GET", url, headers)
  if resp.ok <> true then
    return { ok: false, error: resp.error }
  end if

  data = resp.data
  items = invalid
  if data <> invalid then items = data.Items
  if type(items) <> "roArray" then items = []

  out = []
  for each it in items
    id = ""
    name = ""
    typ = ""
    path = ""

    if it <> invalid then
      if it.Id <> invalid then id = it.Id
      if it.Name <> invalid then name = it.Name
      if it.Type <> invalid then typ = it.Type
      path = _jellyfinExtractPath(it)
    end if

    out.Push({ id: id, name: name, type: typ, path: path })
  end for

  return { ok: true, items: out }
end function

function gatewayJellyfinLiveChannels(apiBase as String, appToken as String, jellyfinToken as String) as Object
  base = _trimSlash(apiBase)
  url = base + "/jellyfin/LiveTv/Channels"

  headers = {
    "X-Emby-Authorization": _jellyfinClientHeader()
    "X-Emby-Token": jellyfinToken
  }
  if appToken <> invalid and appToken <> "" then headers["X-App-Token"] = appToken

  resp = httpJson("GET", url, headers)
  if resp.ok <> true then
    return { ok: false, error: resp.error }
  end if

  data = resp.data
  items = invalid
  if data <> invalid then items = data.Items
  if type(items) <> "roArray" then items = []

  out = []
  for each it in items
    id = ""
    name = ""
    path = ""

    if it <> invalid then
      if it.Id <> invalid then id = it.Id
      if it.Name <> invalid then name = it.Name
      path = _jellyfinExtractPath(it)
    end if

    out.Push({ id: id, name: name, path: path })
  end for

  return { ok: true, items: out }
end function

function _parseQueryString(qs as String) as Object
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

function _splitUrlPathQuery(rawUrl as String) as Object
  out = { path: "", query: {} }
  if rawUrl = invalid then return out
  v = rawUrl.Trim()
  if v = "" then return out

  ' Strip scheme/authority when a full URL is provided.
  scheme = Instr(1, v, "://") ' 1-based; returns 0 when not found
  if scheme > 0 then
    slash = Instr(scheme + 3, v, "/")
    if slash > 0 then
      v = Mid(v, slash)
    else
      v = "/"
    end if
  end if

  if Left(v, 1) <> "/" then v = "/" + v

  qpos = Instr(1, v, "?") ' 1-based; returns 0 when not found
  if qpos > 0 then
    pathLen = qpos - 1
    if pathLen < 0 then pathLen = 0
    out.path = Left(v, pathLen)
    out.query = _parseQueryString(Mid(v, qpos + 1))
  else
    out.path = v
    out.query = {}
  end if

  return out
end function

function _sanitizePlaybackQuery(raw as Object, forceStatic as Boolean) as Object
  allowed = {
    mediasourceid: true
    tag: true
    static: true
    playsessionid: true
    audiostreamindex: true
  }
  out = {}

  if type(raw) = "roAssociativeArray" then
    for each k in raw
      if k <> invalid then
        kl = LCase(k)
        if allowed[kl] = true then
          v = raw[k]
          if v = invalid then v = ""
          if type(v) <> "roString" then v = v.ToStr()
          out[k] = v
        end if
      end if
    end for
  end if

  if forceStatic = true then out["Static"] = "true"
  return out
end function

sub _maybeSelectAudioStreamIndex(source as Object, query as Object)
  if query = invalid then return

  for each k in query
    if k <> invalid and LCase(k) = "audiostreamindex" then return
  end for

  streams = invalid
  if source <> invalid then streams = source.MediaStreams
  if type(streams) <> "roArray" then return

  preferred = {
    aac: true
    mp3: true
    ac3: true
    eac3: true
    opus: true
  }

  chosen = invalid
  fallback = invalid

  for each s in streams
    if s = invalid then
      ' skip
    else

      typ = s.Type
      if typ = invalid then typ = ""
      if LCase(typ) = "audio" then

        idx = invalid
        if s.Index <> invalid then
          idx = s.Index
        else if s.StreamIndex <> invalid then
          idx = s.StreamIndex
        end if
        if idx <> invalid then
          if fallback = invalid then fallback = idx

          codec = s.Codec
          if codec = invalid then codec = ""
          if preferred[LCase(codec)] = true then
            chosen = idx
            exit for
          end if
        end if
      end if
    end if
  end for

  if chosen = invalid then chosen = fallback
  if chosen <> invalid then query["AudioStreamIndex"] = chosen.ToStr()
end sub

function gatewayJellyfinPlaybackSource(apiBase as String, appToken as String, jellyfinToken as String, userId as String, itemId as String, preferDirectStream as Boolean, allowTranscoding as Boolean) as Object
  base = _trimSlash(apiBase)
  print "PlaybackInfo start preferDirectStream=" + preferDirectStream.ToStr() + " allowTranscoding=" + allowTranscoding.ToStr()

  uid = userId
  if uid = invalid then uid = ""
  uid = uid.Trim()
  if uid = "" then
    return { ok: false, error: "missing_user_id" }
  end if

  iid = itemId
  if iid = invalid then iid = ""
  iid = iid.Trim()
  if iid = "" then
    return { ok: false, error: "missing_item_id" }
  end if

  url = base + "/jellyfin/Items/" + iid + "/PlaybackInfo"
  enableDirectPlay = true
  enableDirectStream = true
  enableTranscoding = false
  ' For Live TV we prefer a transcoded HLS session (lower latency + codec safety).
  if allowTranscoding = true then
    enableDirectPlay = false
    enableDirectStream = false
    enableTranscoding = true
    print "PlaybackInfo flags directPlay=" + enableDirectPlay.ToStr() + " directStream=" + enableDirectStream.ToStr() + " transcode=" + enableTranscoding.ToStr()
  end if
  payload = {
    UserId: uid
    EnableDirectPlay: enableDirectPlay
    EnableDirectStream: enableDirectStream
    EnableTranscoding: enableTranscoding
  }
  body = FormatJson(payload)

  headers = {
    "Content-Type": "application/json"
    "X-Emby-Authorization": _jellyfinClientHeader()
    "X-Emby-Token": jellyfinToken
  }
  if appToken <> invalid and appToken <> "" then headers["X-App-Token"] = appToken

  resp = httpJson("POST", url, headers, body)
  if resp.ok <> true then
    return { ok: false, error: resp.error }
  end if

  data = resp.data
  mediaSources = invalid
  if data <> invalid then mediaSources = data.MediaSources
  if type(mediaSources) <> "roArray" or mediaSources.Count() <= 0 then
    return { ok: false, error: "no_media_sources" }
  end if

  source = mediaSources[0]

  transcode = ""
  if source <> invalid and source.TranscodingUrl <> invalid then
    tu = source.TranscodingUrl
    if tu <> invalid then
      ttrim = tu.Trim()
      if ttrim <> "" then
        if allowTranscoding = true then
          transcode = ttrim
        else
          return { ok: false, error: "transcode_forbidden" }
        end if
      end if
    end if
  end if

  supportsDirectPlay = false
  supportsDirectStream = false
  if source <> invalid then
    if source.SupportsDirectPlay = true then supportsDirectPlay = true
    if source.SupportsDirectStream = true then supportsDirectStream = true
  end if
  if supportsDirectPlay <> true and supportsDirectStream <> true and transcode = "" then
    return { ok: false, error: "direct_disabled" }
  end if

  directPlay = ""
  directStream = ""
  if source <> invalid then
    if source.DirectPlayUrl <> invalid then directPlay = source.DirectPlayUrl
    if source.DirectStreamUrl <> invalid then directStream = source.DirectStreamUrl
  end if

  if directPlay = invalid then directPlay = ""
  if directStream = invalid then directStream = ""
  directPlay = directPlay.Trim()
  directStream = directStream.Trim()

  container = ""
  if source <> invalid and source.Container <> invalid then container = source.Container
  if container = invalid then container = ""

  hasDirectPlay = (directPlay <> "")
  hasDirectStream = (directStream <> "")
  preferStream = (preferDirectStream = true)

  chosenUrl = ""
  usedDirectPlay = false
  usedTranscode = false
  if transcode <> "" then
    chosenUrl = transcode
    usedTranscode = true
    usedDirectPlay = false
  else if preferStream and hasDirectStream then
    chosenUrl = directStream
    usedDirectPlay = false
  else if hasDirectPlay then
    chosenUrl = directPlay
    usedDirectPlay = true
  else
    chosenUrl = directStream
    usedDirectPlay = false
  end if

  if chosenUrl <> "" then
    parts = _splitUrlPathQuery(chosenUrl)
    path = parts.path
    if path = invalid then path = ""
    path = path.Trim()
    if path = "" then path = "/Videos/" + iid + "/stream"

    if usedTranscode = true then
      q = parts.query
      if type(q) <> "roAssociativeArray" then q = {}
    else if allowTranscoding = true then
      ' For Live TV keep Jellyfin's full query (LiveStreamId, etc.).
      q = parts.query
      if type(q) <> "roAssociativeArray" then q = {}
    else
      q = _sanitizePlaybackQuery(parts.query, usedDirectPlay)
      _maybeSelectAudioStreamIndex(source, q)
    end if
    ' Video node can't send headers; append token as query so the gateway proxy can
    ' forward it to Jellyfin upstream (api_key auth).
    if jellyfinToken <> invalid and jellyfinToken.Trim() <> "" then q["api_key"] = jellyfinToken.Trim()
    return { ok: true, path: path, query: q, container: container }
  end if

  ' Fallback: build /Videos/<id>/stream with a minimal safe query.
  mediaSourceId = iid
  tag = ""
  playSessionId = ""
  if source <> invalid then
    if source.Id <> invalid then mediaSourceId = source.Id
    if source.ETag <> invalid then tag = source.ETag
  end if
  if data <> invalid and data.PlaySessionId <> invalid then playSessionId = data.PlaySessionId

  rawQ = {
    MediaSourceId: mediaSourceId
    Tag: tag
    PlaySessionId: playSessionId
  }

  q2 = _sanitizePlaybackQuery(rawQ, supportsDirectPlay)
  _maybeSelectAudioStreamIndex(source, q2)
  if jellyfinToken <> invalid and jellyfinToken.Trim() <> "" then q2["api_key"] = jellyfinToken.Trim()
  return { ok: true, path: "/Videos/" + iid + "/stream", query: q2, container: container }
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
