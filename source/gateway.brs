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

function gatewayJellyfinSeriesShelfItems(apiBase as String, appToken as String, jellyfinToken as String, userId as String, parentId as String, limit as Integer) as Object
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
    IncludeItemTypes: "Series"
    ExcludeItemTypes: "Folder,CollectionFolder"
    IsMissing: false
    Fields: "Path,MediaSources"
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
    typ = "Series"
    path = ""

    if it <> invalid then
      if it.Id <> invalid then id = it.Id
      if it.Name <> invalid then name = it.Name
      if it.Type <> invalid and it.Type.ToStr().Trim() <> "" then typ = it.Type
      path = _jellyfinExtractPath(it)
    end if

    out.Push({ id: id, name: name, type: typ, path: path })
  end for

  return { ok: true, items: out }
end function

function gatewayJellyfinSeriesDetails(apiBase as String, appToken as String, jellyfinToken as String, userId as String, seriesId as String, episodeLimit as Integer) as Object
  base = _trimSlash(apiBase)

  uid = userId
  if uid = invalid then uid = ""
  uid = uid.Trim()
  if uid = "" then
    return { ok: false, error: "missing_user_id" }
  end if

  sid = seriesId
  if sid = invalid then sid = ""
  sid = sid.Trim()
  if sid = "" then
    return { ok: false, error: "missing_series_id" }
  end if

  lim = episodeLimit
  if lim <= 0 then lim = 24

  headers = {
    "X-Emby-Authorization": _jellyfinClientHeader()
    "X-Emby-Token": jellyfinToken
  }
  if appToken <> invalid and appToken <> "" then headers["X-App-Token"] = appToken

  seriesUrl = base + "/jellyfin/Users/" + uid + "/Items/" + sid
  seriesUrl = _urlWithQuery(seriesUrl, {
    Fields: "Overview,Genres,CommunityRating,ProductionYear,OfficialRating,RunTimeTicks,BackdropImageTags,People,Path,MediaSources,RemoteTrailers,LocalTrailerCount,TrailerCount,Trailers"
  })
  seriesResp = httpJson("GET", seriesUrl, headers)
  if seriesResp.ok <> true then
    return { ok: false, error: seriesResp.error }
  end if

  seriesData = seriesResp.data
  if type(seriesData) <> "roAssociativeArray" then seriesData = {}

  seriesName = ""
  seriesType = "Series"
  seriesOverview = ""
  seriesPath = ""
  seriesYear = 0
  seriesRating = ""
  seriesOfficialRating = ""
  seriesRuntimeTicks = ""
  seriesGenres = []
  seriesBackdropTags = []
  seriesPeople = []
  seriesRemoteTrailers = []
  seriesTrailers = []
  seriesLocalTrailerCount = 0
  seriesTrailerCount = 0
  seriesTrailerUrl = ""
  if seriesData.Name <> invalid then seriesName = seriesData.Name
  if seriesData.Type <> invalid and seriesData.Type.ToStr().Trim() <> "" then seriesType = seriesData.Type
  if seriesData.Overview <> invalid then seriesOverview = seriesData.Overview
  seriesPath = _jellyfinExtractPath(seriesData)
  if seriesData.ProductionYear <> invalid then seriesYear = Int(Val(seriesData.ProductionYear.ToStr()))
  if seriesData.CommunityRating <> invalid then seriesRating = seriesData.CommunityRating.ToStr()
  if seriesData.OfficialRating <> invalid then seriesOfficialRating = seriesData.OfficialRating
  if seriesData.RunTimeTicks <> invalid then seriesRuntimeTicks = seriesData.RunTimeTicks.ToStr()
  if seriesData.Genres <> invalid then seriesGenres = seriesData.Genres
  if type(seriesGenres) <> "roArray" then seriesGenres = []
  if seriesData.BackdropImageTags <> invalid then seriesBackdropTags = seriesData.BackdropImageTags
  if type(seriesBackdropTags) <> "roArray" then seriesBackdropTags = []
  if seriesData.People <> invalid then seriesPeople = seriesData.People
  if type(seriesPeople) <> "roArray" then seriesPeople = []
  if seriesData.RemoteTrailers <> invalid then seriesRemoteTrailers = seriesData.RemoteTrailers
  if type(seriesRemoteTrailers) <> "roArray" then seriesRemoteTrailers = []
  if seriesData.Trailers <> invalid then seriesTrailers = seriesData.Trailers
  if type(seriesTrailers) <> "roArray" then seriesTrailers = []
  if seriesData.LocalTrailerCount <> invalid then seriesLocalTrailerCount = Int(Val(seriesData.LocalTrailerCount.ToStr()))
  if seriesData.TrailerCount <> invalid then seriesTrailerCount = Int(Val(seriesData.TrailerCount.ToStr()))
  if seriesData.TrailerUrl <> invalid then seriesTrailerUrl = seriesData.TrailerUrl.ToStr()

  seasons = []
  seasonsUrl = base + "/jellyfin/Shows/" + sid + "/Seasons"
  seasonsUrl = _urlWithQuery(seasonsUrl, {
    UserId: uid
    Fields: "Overview,Path,MediaSources"
    SortBy: "SortName"
    SortOrder: "Ascending"
  })
  seasonsResp = httpJson("GET", seasonsUrl, headers)
  if seasonsResp.ok = true then
    seasonsData = seasonsResp.data
    seasonItems = invalid
    if type(seasonsData) = "roAssociativeArray" then seasonItems = seasonsData.Items
    if type(seasonItems) <> "roArray" then seasonItems = []

    for each s in seasonItems
      sid0 = ""
      sname = ""
      sover = ""
      sidx = -1
      if s <> invalid then
        if s.Id <> invalid then sid0 = s.Id
        if s.Name <> invalid then sname = s.Name
        if s.Overview <> invalid then sover = s.Overview
        if s.IndexNumber <> invalid then sidx = Int(Val(s.IndexNumber.ToStr()))
      end if
      seasons.Push({
        id: sid0
        name: sname
        overview: sover
        indexNumber: sidx
      })
    end for
  end if

  episodes = []
  firstEpisodeId = ""
  firstEpisodeTitle = ""
  epsUrl = base + "/jellyfin/Shows/" + sid + "/Episodes"
  epsUrl = _urlWithQuery(epsUrl, {
    UserId: uid
    Limit: lim
    Fields: "Overview,Path,MediaSources"
    SortBy: "ParentIndexNumber,IndexNumber,SortName"
    SortOrder: "Ascending"
  })
  epsResp = httpJson("GET", epsUrl, headers)

  episodeItems = []
  if epsResp.ok = true then
    epsData = epsResp.data
    if type(epsData) = "roAssociativeArray" and type(epsData.Items) = "roArray" then
      episodeItems = epsData.Items
    end if
  end if

  if type(episodeItems) <> "roArray" or episodeItems.Count() <= 0 then
    fallbackUrl = base + "/jellyfin/Users/" + uid + "/Items"
    fallbackUrl = _urlWithQuery(fallbackUrl, {
      ParentId: sid
      Recursive: true
      IncludeItemTypes: "Episode"
      Limit: lim
      Fields: "Overview,Path,MediaSources"
      SortBy: "ParentIndexNumber,IndexNumber,SortName"
      SortOrder: "Ascending"
    })
    fallbackResp = httpJson("GET", fallbackUrl, headers)
    if fallbackResp.ok = true then
      fdata = fallbackResp.data
      if type(fdata) = "roAssociativeArray" and type(fdata.Items) = "roArray" then
        episodeItems = fdata.Items
      end if
    end if
  end if
  if type(episodeItems) <> "roArray" then episodeItems = []

  for each ep in episodeItems
    eid = ""
    ename = ""
    eover = ""
    epath = ""
    pidx = -1
    eidx = -1
    if ep <> invalid then
      if ep.Id <> invalid then eid = ep.Id
      if ep.Name <> invalid then ename = ep.Name
      if ep.Overview <> invalid then eover = ep.Overview
      if ep.ParentIndexNumber <> invalid then pidx = Int(Val(ep.ParentIndexNumber.ToStr()))
      if ep.IndexNumber <> invalid then eidx = Int(Val(ep.IndexNumber.ToStr()))
      epath = _jellyfinExtractPath(ep)
    end if

    if firstEpisodeId = "" and eid <> invalid and eid.Trim() <> "" then
      firstEpisodeId = eid.Trim()
      firstEpisodeTitle = ename
    end if

    episodes.Push({
      id: eid
      name: ename
      overview: eover
      path: epath
      parentIndexNumber: pidx
      indexNumber: eidx
    })
  end for

  return {
    ok: true
    series: {
      id: sid
      name: seriesName
      type: seriesType
      overview: seriesOverview
      path: seriesPath
      productionYear: seriesYear
      communityRating: seriesRating
      officialRating: seriesOfficialRating
      runTimeTicks: seriesRuntimeTicks
      genres: seriesGenres
      backdropTags: seriesBackdropTags
      people: seriesPeople
      remoteTrailers: seriesRemoteTrailers
      trailers: seriesTrailers
      localTrailerCount: seriesLocalTrailerCount
      trailerCount: seriesTrailerCount
      trailerUrl: seriesTrailerUrl
    }
    seasons: seasons
    episodes: episodes
    firstEpisodeId: firstEpisodeId
    firstEpisodeTitle: firstEpisodeTitle
  }
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
    logoPath = ""
    logoFallbackPath = ""
    logoTag = ""
    logoType = "Primary"
    primaryTag = ""
    logoTagCandidate = ""
    thumbTag = ""

    if it <> invalid then
      if it.Id <> invalid then id = it.Id
      if it.Name <> invalid then name = it.Name
      path = _jellyfinExtractPath(it)
      if it.ImageTags <> invalid then
        tags = it.ImageTags
        if tags.Primary <> invalid then primaryTag = tags.Primary.ToStr().Trim()
        if tags.Logo <> invalid then logoTagCandidate = tags.Logo.ToStr().Trim()
        if tags.Thumb <> invalid then thumbTag = tags.Thumb.ToStr().Trim()
      end if

      if logoTagCandidate <> "" then
        logoType = "Logo"
        logoTag = logoTagCandidate
      else if primaryTag <> "" then
        logoType = "Primary"
        logoTag = primaryTag
      else if thumbTag <> "" then
        logoType = "Thumb"
        logoTag = thumbTag
      end if
    end if

    if id <> invalid and id.Trim() <> "" then
      cid = id.Trim()
      logoPath = "/jellyfin/LiveTv/Channels/" + cid + "/Images/" + logoType
      if logoTag <> "" then
        logoPath = _urlWithQuery(logoPath, { tag: logoTag })
      end if

      logoFallbackPath = "/jellyfin/Items/" + cid + "/Images/Primary"
      if primaryTag <> "" then
        logoFallbackPath = _urlWithQuery(logoFallbackPath, { tag: primaryTag })
      end if
    end if

    out.Push({
      id: id
      name: name
      path: path
      logoPath: logoPath
      logoFallbackPath: logoFallbackPath
      logoTag: logoTag
      logoType: logoType
      primaryTag: primaryTag
    })
  end for

  return { ok: true, items: out }
end function

function gatewayJellyfinLivePrograms(apiBase as String, appToken as String, jellyfinToken as String, userId as String, channelIds as String, startDate as String, endDate as String) as Object
  base = _trimSlash(apiBase)
  url = base + "/jellyfin/LiveTv/Programs"

  qs = {}
  if userId <> invalid and userId.Trim() <> "" then qs.UserId = userId.Trim()
  if channelIds <> invalid and channelIds.Trim() <> "" then qs.ChannelIds = channelIds.Trim()
  if startDate <> invalid and startDate.Trim() <> "" then qs.StartDate = startDate.Trim()
  if endDate <> invalid and endDate.Trim() <> "" then qs.EndDate = endDate.Trim()
  qs.SortBy = "StartDate"
  qs.SortOrder = "Ascending"
  url = _urlWithQuery(url, qs)

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
    channelId = ""
    name = ""
    episodeTitle = ""
    startDateStr = ""
    endDateStr = ""
    if it <> invalid then
      if it.ChannelId <> invalid then channelId = it.ChannelId
      if it.Name <> invalid then name = it.Name
      if it.EpisodeTitle <> invalid then episodeTitle = it.EpisodeTitle
      if it.StartDate <> invalid then startDateStr = it.StartDate
      if it.EndDate <> invalid then endDateStr = it.EndDate
    end if
    out.Push({
      channelId: channelId
      name: name
      episodeTitle: episodeTitle
      startDate: startDateStr
      endDate: endDateStr
    })
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

function _csvFromArray(values as Object) as String
  if type(values) <> "roArray" then return ""
  out = ""
  for each v in values
    if v = invalid then
      continue for
    end if
    s = v.ToStr().Trim()
    if s = "" then
      continue for
    end if
    if out <> "" then out = out + ","
    out = out + s
  end for
  return out
end function

function gatewayProgressBatch(apiBase as String, appToken as String, jellyfinToken as String, userId as String, itemIds as Object) as Object
  base = _trimSlash(apiBase)
  uid = userId
  if uid = invalid then uid = ""
  uid = uid.Trim()
  if uid = "" then
    return { ok: false, error: "missing_user_id" }
  end if

  idsCsv = _csvFromArray(itemIds)
  if idsCsv = "" then return { ok: true, items: [] }

  url = base + "/progress/batch"
  url = _urlWithQuery(url, {
    userId: uid
    ids: idsCsv
  })

  headers = {}
  if appToken <> invalid and appToken <> "" then headers["X-App-Token"] = appToken
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
    if type(items) <> "roArray" and data.Items <> invalid then
      items = data.Items
    end if
  else if type(data) = "roArray" then
    items = data
  end if
  if type(items) <> "roArray" then items = []

  return { ok: true, items: items }
end function

function gatewayProgressUpsert(apiBase as String, appToken as String, jellyfinToken as String, userId as String, payloadJson as String) as Object
  base = _trimSlash(apiBase)
  if base = "" then
    return { ok: false, error: "missing_api_base" }
  end if

  raw = payloadJson
  if raw = invalid then raw = ""
  raw = raw.ToStr().Trim()
  if raw = "" then
    return { ok: false, error: "missing_progress_payload" }
  end if

  payload = ParseJson(raw)
  if type(payload) <> "roAssociativeArray" then
    return { ok: false, error: "invalid_progress_payload" }
  end if

  uid = userId
  if uid = invalid then uid = ""
  uid = uid.ToStr().Trim()
  hasUid = false
  if payload.user_id <> invalid then hasUid = true
  if payload.userId <> invalid then hasUid = true
  if payload.userid <> invalid then hasUid = true
  if uid <> "" and hasUid <> true then
    payload.user_id = uid
  end if

  url = base + "/progress"
  headers = {
    "Content-Type": "application/json"
  }
  if appToken <> invalid and appToken.Trim() <> "" then headers["X-App-Token"] = appToken
  if jellyfinToken <> invalid and jellyfinToken.Trim() <> "" then
    headers["X-Emby-Token"] = jellyfinToken
    headers["X-Jellyfin-Token"] = jellyfinToken
  end if

  resp = httpJson("POST", url, headers, FormatJson(payload))
  if resp.ok <> true then
    return { ok: false, error: resp.error }
  end if
  return { ok: true }
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
    Fields: "RunTimeTicks,Path,MediaSources,SeriesId,CollectionType"
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
    ctype = ""
    seriesId = ""
    if it <> invalid then
      if it.Id <> invalid then id = it.Id
      if it.Name <> invalid then name = it.Name
      if it.Type <> invalid then typ = it.Type
      if it.CollectionType <> invalid then ctype = it.CollectionType
      if it.SeriesId <> invalid then seriesId = it.SeriesId
      path = _jellyfinExtractPath(it)
    end if
    out.Push({
      id: id
      name: name
      type: typ
      path: path
      collectionType: ctype
      seriesId: seriesId
    })
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
  progressById = {}
  for each row in raw
    iid = ""
    posMs = -1
    durMs = -1
    pct = -1
    played = false
    if row <> invalid then
      if row.itemId <> invalid then iid = row.itemId
      if (iid = invalid or iid = "") and row.item_id <> invalid then iid = row.item_id
      if (iid = invalid or iid = "") and row.id <> invalid then iid = row.id

      p0 = invalid
      if row.positionMs <> invalid then p0 = row.positionMs
      if (p0 = invalid or p0 = "") and row.position_ms <> invalid then p0 = row.position_ms
      if p0 <> invalid then
        ps = p0.ToStr()
        if ps <> invalid then
          ps = ps.Trim()
          if ps <> "" then posMs = Int(Val(ps))
        end if
      end if

      d0 = invalid
      if row.durationMs <> invalid then d0 = row.durationMs
      if (d0 = invalid or d0 = "") and row.duration_ms <> invalid then d0 = row.duration_ms
      if d0 <> invalid then
        ds = d0.ToStr()
        if ds <> invalid then
          ds = ds.Trim()
          if ds <> "" then durMs = Int(Val(ds))
        end if
      end if

      pct0 = invalid
      if row.percent <> invalid then pct0 = row.percent
      if pct0 <> invalid then
        pcts = pct0.ToStr()
        if pcts <> invalid then
          pcts = pcts.Trim()
          if pcts <> "" then pct = Int(Val(pcts))
        end if
      end if

      played0 = invalid
      if row.played <> invalid then played0 = row.played
      if played0 <> invalid then
        if type(played0) = "roBoolean" then
          played = (played0 = true)
        else
          pbs = LCase(played0.ToStr().Trim())
          played = (pbs = "1" or pbs = "true" or pbs = "yes" or pbs = "on")
        end if
      end if
    end if
    if iid = invalid then iid = ""
    iid = iid.Trim()
    if iid <> "" then
      ids.Push(iid)
      progressById[iid] = {
        positionMs: posMs
        durationMs: durMs
        percent: pct
        played: played
      }
    end if
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
    if got <> invalid then
      merged = {
        id: got.id
        name: got.name
        type: got.type
        path: got.path
      }

      pinfo = progressById[iid]
      if type(pinfo) = "roAssociativeArray" then
        if pinfo.positionMs <> invalid and Int(pinfo.positionMs) >= 0 then merged.positionMs = Int(pinfo.positionMs)
        if pinfo.durationMs <> invalid and Int(pinfo.durationMs) >= 0 then merged.durationMs = Int(pinfo.durationMs)
        if pinfo.percent <> invalid and Int(pinfo.percent) >= 0 then merged.percent = Int(pinfo.percent)
        if pinfo.played = true then merged.played = true
      end if

      out.Push(merged)
    end if
  end for

  return { ok: true, items: out }
end function

function gatewayMostWatchedShelf(apiBase as String, appToken as String, jellyfinToken as String, userId as String, days as Integer, limit as Integer) as Object
  baseDays = days
  if baseDays <= 0 then baseDays = 7

  lim = limit
  if lim <= 0 then lim = 10

  minWatchSeconds = 120
  lastErr = ""
  hadStats = false
  windows = [baseDays, 14, 30]

  ' Keep behavior aligned with Flutter home ranking:
  ' - try 7/14/30 day windows
  ' - require at least 120 watched seconds
  ' - collapse episodes by seriesId
  ' - sort by watchSeconds, then plays
  for each d in windows
    resp = gatewayStatsMostWatched(apiBase, appToken, d, 20)
    if resp.ok <> true then
      if resp.error <> invalid then
        e = resp.error.ToStr().Trim()
        if e <> "" then lastErr = e
      end if
      continue for
    end if

    hadStats = true
    raw = resp.rows
    if type(raw) <> "roArray" then raw = []
    if raw.Count() <= 0 then continue for

    filtered = []
    sourceIds = []
    for each row in raw
      iid = ""
      if row <> invalid then
        if row.itemId <> invalid then iid = row.itemId
        if (iid = invalid or iid = "") and row.item_id <> invalid then iid = row.item_id
        if (iid = invalid or iid = "") and row.id <> invalid then iid = row.id
      end if
      if iid = invalid then iid = ""
      iid = iid.Trim()
      if iid = "" then continue for

      watchSeconds = invalid
      if row <> invalid then
        if row.watchSeconds <> invalid then watchSeconds = _intFromAny(row.watchSeconds)
        if watchSeconds = invalid and row.watch_seconds <> invalid then watchSeconds = _intFromAny(row.watch_seconds)
      end if
      if watchSeconds = invalid then watchSeconds = 0
      if watchSeconds < minWatchSeconds then continue for

      plays = invalid
      if row <> invalid and row.plays <> invalid then plays = _intFromAny(row.plays)
      if plays = invalid then plays = 0

      filtered.Push({
        itemId: iid
        watchSeconds: watchSeconds
        plays: plays
      })
      sourceIds.Push(iid)
    end for
    if sourceIds.Count() <= 0 then continue for

    sourceItemsResp = gatewayJellyfinItemsByIds(apiBase, appToken, jellyfinToken, userId, sourceIds)
    if sourceItemsResp.ok <> true then
      if sourceItemsResp.error <> invalid then
        e2 = sourceItemsResp.error.ToStr().Trim()
        if e2 <> "" then lastErr = e2
      end if
      continue for
    end if

    sourceById = {}
    for each it in sourceItemsResp.items
      if it <> invalid and it.id <> invalid then
        kid = it.id
        if kid <> invalid then
          kk = kid.Trim()
          if kk <> "" then sourceById[kk] = it
        end if
      end if
    end for

    watchById = {}
    playsById = {}
    for each entry in filtered
      iid = ""
      if entry <> invalid and entry.itemId <> invalid then iid = entry.itemId
      if iid = invalid then iid = ""
      iid = iid.Trim()
      if iid = "" then continue for

      item = sourceById[iid]
      if item = invalid then continue for

      typL = _strLower(item.type)
      colL = _strLower(item.collectionType)
      isLive = false
      if Instr(1, typL, "channel") > 0 then isLive = true
      if Instr(1, typL, "livetv") > 0 then isLive = true
      if colL = "livetv" then isLive = true
      if isLive then continue for

      keyId = ""
      if item.id <> invalid then keyId = item.id
      if keyId = invalid then keyId = ""
      keyId = keyId.Trim()
      if typL = "episode" then
        sid = ""
        if item.seriesId <> invalid then sid = item.seriesId
        if sid = invalid then sid = ""
        sid = sid.Trim()
        if sid <> "" then keyId = sid
      end if
      if keyId = "" then continue for

      watchSeconds = 0
      if entry <> invalid and entry.watchSeconds <> invalid then
        w0 = _intFromAny(entry.watchSeconds)
        if w0 <> invalid and w0 > 0 then watchSeconds = w0
      end if

      plays = 0
      if entry <> invalid and entry.plays <> invalid then
        p0 = _intFromAny(entry.plays)
        if p0 <> invalid and p0 > 0 then plays = p0
      end if

      prevWatch = _intFromAny(watchById[keyId])
      if prevWatch = invalid then prevWatch = 0
      prevPlays = _intFromAny(playsById[keyId])
      if prevPlays = invalid then prevPlays = 0

      watchById[keyId] = prevWatch + watchSeconds
      playsById[keyId] = prevPlays + plays
    end for
    if watchById.Count() <= 0 then continue for

    candidateIds = []
    for each kid in watchById
      if kid <> invalid then
        ks = kid.ToStr().Trim()
        if ks <> "" then candidateIds.Push(ks)
      end if
    end for
    if candidateIds.Count() <= 0 then continue for

    rankedIds = []
    while candidateIds.Count() > 0
      bestIdx = 0
      bestId = candidateIds[0]
      bestWatch = _intFromAny(watchById[bestId])
      if bestWatch = invalid then bestWatch = 0
      bestPlays = _intFromAny(playsById[bestId])
      if bestPlays = invalid then bestPlays = 0

      i = 1
      while i < candidateIds.Count()
        cid = candidateIds[i]
        curWatch = _intFromAny(watchById[cid])
        if curWatch = invalid then curWatch = 0
        curPlays = _intFromAny(playsById[cid])
        if curPlays = invalid then curPlays = 0

        if (curWatch > bestWatch) or (curWatch = bestWatch and curPlays > bestPlays) then
          bestIdx = i
          bestId = cid
          bestWatch = curWatch
          bestPlays = curPlays
        end if
        i = i + 1
      end while

      rankedIds.Push(bestId)
      candidateIds.Delete(bestIdx)
    end while

    ids = []
    i = 0
    while i < rankedIds.Count() and ids.Count() < lim
      rid = rankedIds[i]
      if rid <> invalid then
        rs = rid.ToStr().Trim()
        if rs <> "" then ids.Push(rs)
      end if
      i = i + 1
    end while
    if ids.Count() <= 0 then continue for

    itemsResp = gatewayJellyfinItemsByIds(apiBase, appToken, jellyfinToken, userId, ids)
    if itemsResp.ok <> true then
      if itemsResp.error <> invalid then
        e3 = itemsResp.error.ToStr().Trim()
        if e3 <> "" then lastErr = e3
      end if
      continue for
    end if

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
    if out.Count() > 0 then
      return { ok: true, items: out }
    end if
  end for

  if hadStats then
    return { ok: true, items: [] }
  end if

  if lastErr = "" then lastErr = "stats_unavailable"
  return { ok: false, error: lastErr }
end function
