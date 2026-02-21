sub init()
  m.liveTitle = m.top.findNode("liveTitle")
  m.liveDate = m.top.findNode("liveDate")
  m.calendarLabel = m.top.findNode("calendarLabel")
  onFieldsChanged()
end sub

sub onFieldsChanged()
  if m.liveTitle <> invalid then
    t = m.top.titleText
    if t = invalid then t = ""
    t = t.Trim()
    if t = "" then t = "Live TV"
    m.liveTitle.text = t
  end if

  if m.liveDate <> invalid then
    d = m.top.dateText
    if d = invalid then d = ""
    m.liveDate.text = d
  end if

  if m.calendarLabel <> invalid then
    r = m.top.rightText
    if r = invalid then r = ""
    r = r.Trim()
    if r = "" then r = "Agenda"
    m.calendarLabel.text = r
  end if
end sub
