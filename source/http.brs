' JSON helper using roUrlTransfer in async mode.
' Note: On Roku, roUrlTransfer must run on a MAIN or TASK thread (not render).

function httpJson(method as String, url as String, headers = invalid as Object, body = invalid as Object) as Object
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
    return { ok: false, error: "request_start_failed" }
  end if

  msg = wait(30000, port)
  if type(msg) <> "roUrlEvent" then
    return { ok: false, error: "timeout" }
  end if

  code = msg.GetResponseCode()
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
    return { ok: false, error: "empty_response", status: code }
  end if

  parsed = ParseJson(resp)
  if parsed = invalid then
    return { ok: false, error: "invalid_json", status: code, raw: resp }
  end if

  return { ok: true, status: code, data: parsed }
end function
