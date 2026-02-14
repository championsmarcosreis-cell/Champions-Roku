' Registry-backed config storage.

function _cfgSection() as Object
  return CreateObject("roRegistrySection", "champions")
end function

function _readOrEmpty(sec as Object, key as String) as String
  v = sec.Read(key)
  if v = invalid then return ""
  return v
end function

sub saveConfig(apiBase as String, appToken as String, jellyfinToken as String, userId as String)
  sec = _cfgSection()
  sec.Write("apiBase", apiBase)
  sec.Write("appToken", appToken)
  sec.Write("jellyfinToken", jellyfinToken)
  sec.Write("userId", userId)
  sec.Flush()
end sub

function loadConfig() as Object
  sec = _cfgSection()

  ' We always default to the public gateway (no LAN-only base).
  ' Optional override can be bundled at build-time via bundledApiBase().
  apiBase = bundledApiBase()
  if apiBase = "" then apiBase = "https://api.champions.place"

  appToken = _readOrEmpty(sec, "appToken")
  if appToken = "" then appToken = bundledAppToken()

  jellyfinToken = _readOrEmpty(sec, "jellyfinToken")
  userId = _readOrEmpty(sec, "userId")

  cfg = {
    apiBase: apiBase
    appToken: appToken
    jellyfinToken: jellyfinToken
    userId: userId
  }
  return cfg
end function

sub clearConfig()
  sec = _cfgSection()
  sec.Delete("apiBase")
  sec.Delete("appToken")
  sec.Delete("jellyfinToken")
  sec.Delete("userId")
  sec.Flush()
end sub
