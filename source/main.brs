sub Main()
  screen = CreateObject("roSGScreen")
  port = CreateObject("roMessagePort")
  screen.SetMessagePort(port)

  scene = screen.CreateScene("MainScene")
  lastExitSeq = 0
  if scene <> invalid then
    scene.ObserveField("requestExit", port)
    scene.ObserveField("requestExitSeq", port)
  end if
  screen.Show()
  while true
    msg = wait(200, port)

    ' Polling fallback: interface field updates are visible from main thread.
    if scene <> invalid then
      if scene.requestExit = true then
        print "Main: requestExit=true (poll), closing screen"
        screen.Close()
        return
      end if
      seq = Int(scene.requestExitSeq)
      if seq > lastExitSeq then
        print "Main: requestExitSeq=" + seq.ToStr() + " (poll), closing screen"
        screen.Close()
        return
      end if
      if seq > 0 then lastExitSeq = seq
    end if

    if type(msg) = "roSGNodeEvent" then
      f = msg.GetField()
      if f = "requestExit" and msg.GetData() = true then
        print "Main: requestExit=true, closing screen"
        screen.Close()
        return
      else if f = "requestExitSeq" and Int(msg.GetData()) > 0 then
        print "Main: requestExitSeq=" + Int(msg.GetData()).ToStr() + ", closing screen"
        screen.Close()
        return
      end if
    else if type(msg) = "roSGScreenEvent"
      if msg.IsScreenClosed() then return
    end if
  end while
end sub
