' JSON helper using roUrlTransfer in async mode.
' Note: On Roku, roUrlTransfer must run on a MAIN or TASK thread (not render).

function httpJson(method as String, url as String, headers = invalid as Object, body = invalid as Object) as Object
  ' Log only the path (no query) to avoid leaking secrets like api_key/sig.
  safePath = url
  if safePath = invalid then safePath = ""
  safePath = safePath.ToStr()
  scheme = Instr(1, safePath, "://") ' 1-based; returns 0 when not found
  if scheme > 0 then
    slash = Instr(scheme + 3, safePath, "/")
    if slash > 0 then
      safePath = Mid(safePath, slash)
    else
      safePath = "/"
    end if
  end if
  qpos = Instr(1, safePath, "?")
  if qpos > 0 then safePath = Left(safePath, qpos - 1)

  port = CreateObject("roMessagePort")
  xfer = CreateObject("roUrlTransfer")
  xfer.SetMessagePort(port)
  xfer.SetUrl(url)

  ' HTTPS needs Roku's CA bundle.
  if Left(url, 8) = "https://" then
    xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    xfer.InitClientCertificates()
  end if

  if headers <> invalid then
    for each k in headers
      xfer.AddHeader(k, headers[k])
    end for
  end if

  started = false
  if method = "GET" then
    started = xfer.AsyncGetToString()
  else if method = "POST" then
    if body = invalid then body = ""
    started = xfer.AsyncPostFromString(body)
  else
    return { ok: false, error: "unsupported_method" }
  end if

  if started <> true then
    print "[http] " + method + " " + safePath + " -> start_failed"
    return { ok: false, error: "request_start_failed" }
  end if

  msg = wait(30000, port)
  if type(msg) <> "roUrlEvent" then
    print "[http] " + method + " " + safePath + " -> timeout"
    return { ok: false, error: "timeout" }
  end if

  code = msg.GetResponseCode()
  print "[http] " + method + " " + safePath + " -> " + code.ToStr()
  resp = msg.GetString()
  if resp = invalid then resp = ""

  if code < 200 or code >= 300 then
    if resp <> "" then
      parsedErr = ParseJson(resp)
      if parsedErr <> invalid then
        return { ok: false, error: "http_" + code.ToStr(), status: code, data: parsedErr }
      end if
      return { ok: false, error: "http_" + code.ToStr(), status: code, raw: resp }
    end if
    return { ok: false, error: "http_" + code.ToStr(), status: code }
  end if

  if resp = "" then
    ' Some gateway endpoints intentionally return 204 No Content.
    return { ok: true, status: code, data: invalid, raw: "" }
  end if

  parsed = ParseJson(resp)
  if parsed = invalid then
    return { ok: false, error: "invalid_json", status: code, raw: resp }
  end if

  return { ok: true, status: code, data: parsed }
end function
