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

function _strLower(v as Dynamic) as String
  if v = invalid then return ""
  return LCase(v.ToStr().Trim())
end function

function _boolFromAny(v as Dynamic) as Boolean
  if v = invalid then return false
  if type(v) = "roBoolean" then return (v = true)
  s = _strLower(v)
  return (s = "1" or s = "true" or s = "yes" or s = "on")
end function

function _intFromAny(v as Dynamic)
  if v = invalid then return invalid
  if type(v) = "roInt" or type(v) = "roInteger" then return Int(v)
  if type(v) = "roFloat" or type(v) = "Float" then return Int(v)
  s = v.ToStr()
  if s = invalid then return invalid
  s = s.Trim()
  if s = "" then return invalid
  hasDigit = false
  for i = 1 to Len(s)
    ch = Mid(s, i, 1)
    if ch >= "0" and ch <= "9" then
      hasDigit = true
    else if i = 1 and (ch = "-" or ch = "+") then
      ' allow sign
    else
      return invalid
    end if
  end for
  if hasDigit <> true then return invalid
  n = Val(s)
  return Int(n)
end function

function _subtitleExtension(codec as String) as String
  c = _strLower(codec)
  if c = "subrip" or c = "srt" then return "srt"
  if c = "ass" then return "ass"
  if c = "ssa" then return "ssa"
  if c = "webvtt" or c = "vtt" then return "vtt"
  if c = "pgs" then return "pgs"
  if c = "dvdsub" then return "sub"
  return "srt"
end function

function _subtitleLooksHearingImpaired(title as String, deliveryUrl as String, codec as String, entry as Object) as Boolean
  if _boolFromAny(entry.IsHearingImpaired) then return true
  if _boolFromAny(entry.HearingImpaired) then return true
  if _boolFromAny(entry.IsSDH) then return true
  if _boolFromAny(entry.SDH) then return true

  t = _strLower(title)
  u = _strLower(deliveryUrl)
  c = _strLower(codec)
  if Instr(1, t, "sdh") > 0 then return true
  if Instr(1, u, ".sdh.") > 0 then return true
  if Instr(1, u, "sdh") > 0 then return true
  if Instr(1, c, "sdh") > 0 then return true
  if Instr(1, t, "hearing impaired") > 0 then return true
  if Instr(1, t, "hearing-impaired") > 0 then return true
  if Instr(1, t, "hearing") > 0 and Instr(1, t, "impaired") > 0 then return true
  return false
end function

function _extractExternalSubtitleSources(itemId as String, source as Object) as Object
  out = []
  if source = invalid then return out

  mediaSourceId = itemId
  if source.Id <> invalid and source.Id.ToStr().Trim() <> "" then
    mediaSourceId = source.Id.ToStr().Trim()
  else if source.MediaSourceId <> invalid and source.MediaSourceId.ToStr().Trim() <> "" then
    mediaSourceId = source.MediaSourceId.ToStr().Trim()
  end if
  if mediaSourceId = invalid or mediaSourceId.Trim() = "" then mediaSourceId = itemId

  streams = source.MediaStreams
  if type(streams) <> "roArray" then return out

  seen = {}
  for each entry in streams
    if type(entry) <> "roAssociativeArray" then
      ' skip
    else
      typ = _strLower(entry.Type)
      if typ <> "subtitle" then
        ' skip
      else
        deliveryMethod = _strLower(entry.DeliveryMethod)
        isExternal = (_boolFromAny(entry.IsExternal) or Instr(1, deliveryMethod, "external") > 0)
        if isExternal <> true then
          ' skip
        else
          title = ""
          if entry.Title <> invalid then title = entry.Title.ToStr().Trim()
          language = ""
          if entry.Language <> invalid then language = entry.Language.ToStr().Trim()
          codec = ""
          if entry.Codec <> invalid then codec = _strLower(entry.Codec)
          forced = _boolFromAny(entry.IsForced)

          deliveryUrl = ""
          if entry.DeliveryUrl <> invalid then deliveryUrl = entry.DeliveryUrl.ToStr().Trim()
          hearingImpaired = _subtitleLooksHearingImpaired(title, deliveryUrl, codec, entry)

          idx = _intFromAny(entry.Index)
          if idx = invalid then idx = _intFromAny(entry.StreamIndex)

          path = ""
          query = {}
          if deliveryUrl <> "" then
            parts = _splitUrlPathQuery(deliveryUrl)
            if parts.path <> invalid then path = parts.path
            if type(parts.query) = "roAssociativeArray" then query = parts.query
          end if

          if (path = invalid or path.Trim() = "") and idx <> invalid then
            ext = _subtitleExtension(codec)
            path = "/Videos/" + itemId + "/" + mediaSourceId + "/Subtitles/" + idx.ToStr() + "/0/Stream." + ext
          end if

          if path <> invalid then path = path.Trim() else path = ""
          if path <> "" then
            dedupeKey = path + "|" + language + "|" + title
            if idx <> invalid then dedupeKey = "idx:" + idx.ToStr() + "|" + dedupeKey
            if seen[dedupeKey] <> true then
              seen[dedupeKey] = true
              out.Push({
                path: path
                query: query
                title: title
                language: language
                codec: codec
                forced: forced
                hearingImpaired: hearingImpaired
                streamIndex: idx
              })
            end if
          end if
        end if
      end if
    end if
  end for

  return out
end function

function gatewayJellyfinExternalSubtitleSources(apiBase as String, appToken as String, jellyfinToken as String, userId as String, itemId as String) as Object
  base = _trimSlash(apiBase)

  uid = userId
  if uid = invalid then uid = ""
  uid = uid.Trim()
  if uid = "" then return { ok: false, error: "missing_user_id" }

  iid = itemId
  if iid = invalid then iid = ""
  iid = iid.Trim()
  if iid = "" then return { ok: false, error: "missing_item_id" }

  url = base + "/jellyfin/Items/" + iid + "/PlaybackInfo"
  payload = {
    UserId: uid
    EnableDirectPlay: true
    EnableDirectStream: true
    EnableTranscoding: false
  }
  body = FormatJson(payload)

  headers = {
    "Content-Type": "application/json"
    "X-Emby-Authorization": _jellyfinClientHeader()
    "X-Emby-Token": jellyfinToken
  }
  if appToken <> invalid and appToken <> "" then headers["X-App-Token"] = appToken

  resp = httpJson("POST", url, headers, body)
  if resp.ok <> true then return { ok: false, error: resp.error }

  data = resp.data
  mediaSources = invalid
  if data <> invalid then mediaSources = data.MediaSources
  if type(mediaSources) <> "roArray" or mediaSources.Count() <= 0 then
    return { ok: true, sources: [] }
  end if

  source = mediaSources[0]
  subtitleSources = _extractExternalSubtitleSources(iid, source)
  return { ok: true, sources: subtitleSources }
end function

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
  subtitleSources = _extractExternalSubtitleSources(iid, source)

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
    return { ok: true, path: path, query: q, container: container, subtitleSources: subtitleSources }
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
  return { ok: true, path: "/Videos/" + iid + "/stream", query: q2, container: container, subtitleSources: subtitleSources }
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

function _probeHeadersToMap(raw as Object) as Object
  out = {}

  if type(raw) = "roAssociativeArray" then
    for each k in raw
      if k <> invalid then
        kk = LCase(k.ToStr().Trim())
        if kk <> "" then
          v = raw[k]
          if v = invalid then v = ""
          if type(v) <> "roString" then v = v.ToStr()
          out[kk] = v.Trim()
        end if
      end if
    end for
    return out
  end if

  if type(raw) = "roArray" then
    for each line in raw
      s = line
      if s = invalid then s = ""
      if type(s) <> "roString" then s = s.ToStr()
      s = s.Trim()
      if s <> "" then
        sep = Instr(1, s, ":")
        if sep > 0 then
          hk = LCase(Left(s, sep - 1).Trim())
          hv = Mid(s, sep + 1).Trim()
          if hk <> "" then out[hk] = hv
        end if
      end if
    end for
  end if

  return out
end function

function _probeHeader(headers as Object, name as String) as String
  if type(headers) <> "roAssociativeArray" then return ""
  key = name
  if key = invalid then key = ""
  key = LCase(key.Trim())
  if key = "" then return ""

  if headers[key] = invalid then return ""
  v = headers[key]
  if v = invalid then return ""
  if type(v) <> "roString" then v = v.ToStr()
  return v.Trim()
end function

function _probeBodySnippet(raw as String, maxLen as Integer) as String
  s = raw
  if s = invalid then s = ""
  s = s.ToStr()
  s = s.Replace(Chr(13), " ")
  s = s.Replace(Chr(10), " ")
  s = s.Trim()
  if maxLen <= 0 then maxLen = 200
  if Len(s) > maxLen then s = Left(s, maxLen)
  return s
end function

function _httpProbe(method as String, url as String, headers as Object, timeoutMs as Integer) as Object
  m = method
  if m = invalid then m = ""
  m = UCase(m.Trim())
  if m <> "HEAD" then m = "GET"

  u = url
  if u = invalid then u = ""
  u = u.Trim()
  if u = "" then return { ok: false, error: "missing_probe_url" }

  port = CreateObject("roMessagePort")
  xfer = CreateObject("roUrlTransfer")
  xfer.SetMessagePort(port)
  xfer.SetUrl(u)

  if Left(u, 8) = "https://" then
    xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    xfer.InitClientCertificates()
  end if

  xfer.EnableEncodings(true)

  if type(headers) = "roAssociativeArray" then
    for each k in headers
      xfer.AddHeader(k, headers[k])
    end for
  end if

  if m = "HEAD" then xfer.SetRequest("HEAD")
  started = xfer.AsyncGetToString()
  if started <> true then
    return { ok: false, error: "request_start_failed" }
  end if

  ms = timeoutMs
  if ms <= 0 then ms = 8000
  msg = wait(ms, port)
  if type(msg) <> "roUrlEvent" then
    return { ok: false, error: "timeout" }
  end if

  code = msg.GetResponseCode()
  body = msg.GetString()
  if body = invalid then body = ""

  hdrRaw = msg.GetResponseHeaders()
  hdr = _probeHeadersToMap(hdrRaw)

  return {
    ok: true
    status: code
    headers: hdr
    body: body
  }
end function

function gatewayProbeLiveUrl(url as String, appToken as String, jellyfinToken as String) as Object
  u = url
  if u = invalid then u = ""
  u = u.Trim()
  if u = "" then
    return { ok: false, error: "missing_probe_url" }
  end if

  reqHeaders = {
    "Accept": "application/vnd.apple.mpegurl,application/x-mpegURL,text/plain,*/*"
  }
  if appToken <> invalid and appToken <> "" then reqHeaders["X-App-Token"] = appToken
  if jellyfinToken <> invalid and jellyfinToken <> "" then reqHeaders["X-Emby-Token"] = jellyfinToken

  head = _httpProbe("HEAD", u, reqHeaders, 8000)
  if head.ok <> true then
    return { ok: false, error: head.error }
  end if

  finalResp = head
  usedMethod = "HEAD"
  getResp = invalid
  snippet = ""

  if head.status = 405 or head.status = 501 or head.status = 0 then
    getHeaders = reqHeaders
    getHeaders["Range"] = "bytes=0-199"
    getResp = _httpProbe("GET", u, getHeaders, 8000)
    if getResp.ok <> true then
      return { ok: false, error: getResp.error }
    end if
    finalResp = getResp
    usedMethod = "GET"
    if finalResp.status <> 200 then snippet = _probeBodySnippet(finalResp.body, 200)
  else if head.status <> 200 then
    getHeaders2 = reqHeaders
    getHeaders2["Range"] = "bytes=0-199"
    getResp = _httpProbe("GET", u, getHeaders2, 8000)
    if getResp.ok = true then
      snippet = _probeBodySnippet(getResp.body, 200)
    end if
  end if

  finalHeaders = finalResp.headers
  if type(finalHeaders) <> "roAssociativeArray" then finalHeaders = {}

  ct = _probeHeader(finalHeaders, "content-type")
  ce = _probeHeader(finalHeaders, "content-encoding")
  cl = _probeHeader(finalHeaders, "content-length")
  loc = _probeHeader(finalHeaders, "location")

  if getResp <> invalid and getResp.ok = true then
    gh = getResp.headers
    if type(gh) = "roAssociativeArray" then
      if ct = "" then ct = _probeHeader(gh, "content-type")
      if ce = "" then ce = _probeHeader(gh, "content-encoding")
      if cl = "" then cl = _probeHeader(gh, "content-length")
      if loc = "" then loc = _probeHeader(gh, "location")
    end if
  end if

  return {
    ok: true
    method: usedMethod
    status: finalResp.status
    ct: ct
    ce: ce
    cl: cl
    loc: loc
    bodySnippet: snippet
  }
end function

' VOD + stats helpers (gateway endpoints, not Jellyfin bytes).

function gatewayVodStatus(apiBase as String, appToken as String, vodKey as String) as Object
  base = _trimSlash(apiBase)
  k = vodKey
  if k = invalid then k = ""
  k = k.Trim()
  if k = "" then
    return { ok: false, error: "missing_vod_key" }
  end if

  url = base + "/vod/status/" + k
  headers = {}
  if appToken <> invalid and appToken <> "" then headers["X-App-Token"] = appToken
  resp = httpJson("GET", url, headers)
  if resp.ok <> true then
    return { ok: false, error: resp.error }
  end if

  data = resp.data
  st = ""
  if type(data) = "roAssociativeArray" then
    if data.status <> invalid then st = data.status
    if st = invalid or st = "" then
      if data.Status <> invalid then st = data.Status
    end if
  end if
  if st = invalid then st = ""
  st = st.Trim()
  if st = "" then st = "ERROR"
  return { ok: true, status: st }
end function

function gatewayProgressContinue(apiBase as String, appToken as String, jellyfinToken as String, userId as String, limit as Integer) as Object
  base = _trimSlash(apiBase)
  uid = userId
  if uid = invalid then uid = ""
  uid = uid.Trim()
  if uid = "" then
    return { ok: false, error: "missing_user_id" }
  end if

  lim = limit
  if lim <= 0 then lim = 12

  url = base + "/progress/continue"
  url = _urlWithQuery(url, { userId: uid, limit: lim })
  headers = {}
  if appToken <> invalid and appToken <> "" then headers["X-App-Token"] = appToken
  ' Progress endpoints on the gateway resolve the user via Jellyfin token (server-side).
  ' Without this header we get 401 invalid_jellyfin_token.
  if jellyfinToken <> invalid and jellyfinToken.Trim() <> "" then
    headers["X-Emby-Token"] = jellyfinToken
    headers["X-Jellyfin-Token"] = jellyfinToken
  end if
  resp = httpJson("GET", url, headers)
  if resp.ok <> true then
    return { ok: false, error: resp.error }
  end if

  data = resp.data
  items = []
  if type(data) = "roAssociativeArray" then
    if data.items <> invalid then items = data.items
    if type(items) <> "roArray" then
      if data.Items <> invalid then items = data.Items
    end if
  else if type(data) = "roArray" then
    items = data
  end if
  if type(items) <> "roArray" then items = []

  return { ok: true, items: items }
end function

function gatewayStatsMostWatched(apiBase as String, appToken as String, days as Integer, limit as Integer) as Object
  base = _trimSlash(apiBase)
  d = days
  if d <= 0 then d = 7
  lim = limit
  if lim <= 0 then lim = 10

  url = base + "/stats/most-watched"
  url = _urlWithQuery(url, { days: d, limit: lim })
  headers = {}
  if appToken <> invalid and appToken <> "" then headers["X-App-Token"] = appToken
  resp = httpJson("GET", url, headers)
  if resp.ok <> true then
    return { ok: false, error: resp.error }
  end if

  data = resp.data
  rows = []
  if type(data) = "roArray" then
    rows = data
  else if type(data) = "roAssociativeArray" then
    if data.items <> invalid then rows = data.items
    if type(rows) <> "roArray" then
      if data.Items <> invalid then rows = data.Items
    end if
  end if
  if type(rows) <> "roArray" then rows = []
  return { ok: true, rows: rows }
end function

function gatewayJellyfinItemsByIds(apiBase as String, appToken as String, jellyfinToken as String, userId as String, ids as Object) as Object
  base = _trimSlash(apiBase)
  uid = userId
  if uid = invalid then uid = ""
  uid = uid.Trim()
  if uid = "" then
    return { ok: false, error: "missing_user_id" }
  end if

  if type(ids) <> "roArray" or ids.Count() <= 0 then
    return { ok: true, items: [] }
  end if

  joined = ""
  first = true
  for each raw in ids
    s = raw
    if s = invalid then s = ""
    if type(s) <> "roString" then s = s.ToStr()
    s = s.Trim()
    if s <> "" then
      if first then
        joined = s
        first = false
      else
        joined = joined + "," + s
      end if
    end if
  end for

  if joined = "" then
    return { ok: true, items: [] }
  end if

  url = base + "/jellyfin/Users/" + uid + "/Items"
  url = _urlWithQuery(url, {
    Ids: joined
    Limit: ids.Count()
    Recursive: true
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

function gatewayContinueWatchingShelf(apiBase as String, appToken as String, jellyfinToken as String, userId as String, limit as Integer) as Object
  lim = limit
  if lim <= 0 then lim = 12

  resp = gatewayProgressContinue(apiBase, appToken, jellyfinToken, userId, lim)
  if resp.ok <> true then return resp
  raw = resp.items
  if type(raw) <> "roArray" then raw = []

  ids = []
  for each row in raw
    iid = ""
    if row <> invalid then
      if row.itemId <> invalid then iid = row.itemId
      if (iid = invalid or iid = "") and row.item_id <> invalid then iid = row.item_id
      if (iid = invalid or iid = "") and row.id <> invalid then iid = row.id
    end if
    if iid = invalid then iid = ""
    iid = iid.Trim()
    if iid <> "" then ids.Push(iid)
  end for

  itemsResp = gatewayJellyfinItemsByIds(apiBase, appToken, jellyfinToken, userId, ids)
  if itemsResp.ok <> true then return itemsResp

  byId = {}
  for each it in itemsResp.items
    if it <> invalid and it.id <> invalid then
      kid = it.id
      if kid <> invalid then
        kk = kid.Trim()
        if kk <> "" then byId[kk] = it
      end if
    end if
  end for

  out = []
  for each iid in ids
    got = byId[iid]
    if got <> invalid then out.Push(got)
  end for

  return { ok: true, items: out }
end function

function gatewayMostWatchedShelf(apiBase as String, appToken as String, jellyfinToken as String, userId as String, days as Integer, limit as Integer) as Object
  d = days
  if d <= 0 then d = 7
  lim = limit
  if lim <= 0 then lim = 10

  resp = gatewayStatsMostWatched(apiBase, appToken, d, lim)
  if resp.ok <> true then return resp
  raw = resp.rows
  if type(raw) <> "roArray" then raw = []

  ids = []
  for each row in raw
    iid = ""
    if row <> invalid then
      if row.itemId <> invalid then iid = row.itemId
      if (iid = invalid or iid = "") and row.item_id <> invalid then iid = row.item_id
      if (iid = invalid or iid = "") and row.id <> invalid then iid = row.id
    end if
    if iid = invalid then iid = ""
    iid = iid.Trim()
    if iid <> "" then ids.Push(iid)
  end for

  itemsResp = gatewayJellyfinItemsByIds(apiBase, appToken, jellyfinToken, userId, ids)
  if itemsResp.ok <> true then return itemsResp

  byId = {}
  for each it in itemsResp.items
    if it <> invalid and it.id <> invalid then
      kid = it.id
      if kid <> invalid then
        kk = kid.Trim()
        if kk <> "" then byId[kk] = it
      end if
    end if
  end for

  out = []
  for each iid in ids
    got = byId[iid]
    if got <> invalid then out.Push(got)
  end for

  return { ok: true, items: out }
end function
