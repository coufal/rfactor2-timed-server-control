#Persistent
menu, tray, NoIcon
FormatTime,LastDeamonExecTime,,yyyyMMddHHmmss
RestartCount:=0
SecondsUntilRestart:=30 ;needed since program takes a few secs to init 
ActRepeatHour := 01
ActRepeatMinute := 00
ActWindowId := 0
ActWindowName := 0
ActStartDate := 0
ActStartDateTime := 0
ProgramStartTimestamp := 0

Gui, Add, DropDownList, x162 y29 w40 vStartHour, 00||01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20|21|22|23
Gui, Add, DropDownList, x212 y29 w40 vStartMinute, 00||05|10|15|20|25|30|35|40|45|50|55
Gui, Add, DropDownList, x292 y29 w40 vRepeatHour, 00|01|02|03|04|05||06|07|08|09|10|11|12|13|14|15|16|17|18|19|20|21|22|23
Gui, Add, DropDownList, x342 y29 w40 vRepeatMinute, 00||05|10|15|20|25|30|35|40|45|50|55
Gui, Add, GroupBox, x152 y9 w110 h50 , Start time (HH:mm)
Gui, Add, GroupBox, x282 y9 w110 h50 , Restart (HH:mm)
Gui, Add, Text, x162 y99 w180 h20 vSelectedWindowStatus, 
Gui, Add, Button, x12 y219 w70 h30 vStart, Start
Gui, Add, Button, x92 y219 w70 h30 vStop, Stop
;Gui, Add, Text, x182 y219 w210 h20 , Note: Finish race about 15min before restart
Gui, Add, Text, x212 y219 w190 h40 , Written by:`n<dennis.coufal@gmail.com>
Gui, Add, Text, x22 y179 w350 h20 vStatusText, idle
Gui, Add, GroupBox, x12 y159 w380 h50 , Status 
Gui, Add, Text, x162 y119 w240 h20 vWindowName, 
Gui, Add, Button, x32 y99 w110 h30 vSelectWindow, Select Window
Gui, Add, GroupBox, x12 y69 w380 h80 , Select server (click on the server window you want to control)
Gui, Add, DateTime, x22 y29 w100 h20 vStartDate
Gui, Add, GroupBox, x12 y9 w120 h50 , Start Date
; Generated using SmartGUI Creator 4.0
Gui, Show, x572 y277 h274 w406, rFactor2 Timed Server Control v1.3

GuiControl, disable, Stop

return

ServerHandler:
	If isReadyToRestart() 
	{
		RestartCount++
		If WinExist(ActWindowName) 
		{
			LastDeamonExecTime=%A_Now%
			sleep, 200	
			WinActivate
			ControlClick, << Restart Weekend, ahk_id %ActWindowID%
		} 
		else 
		{
			WindowNotFoundError()			
		}		
	}
Return

CalcSecondsUntilRestart:	
	if(RestartCount>0) ;restart
	{
		restartTimestamp := (ActRepeatHour*100+ActRepeatMinute)*100 + LastDeamonExecTime
	} 
	else ;first start
	{
		restartTimestamp := ActStartDateTime
	}

	SecondsUntilRestart:=secondsUntilTimestamp(restartTimestamp)
return

RefreshStatusMsg:	
	countdown:=seconds2Timestamp(SecondsUntilRestart)
	uptime:=seconds2Timestamp(A_Now-ProgramStartTimestamp)
	GuiControl,,StatusText, Countdown: %countdown%  |  Uptime: %uptime%  |  #: %RestartCount%
return

ButtonStart:	
	Gui, Submit, NoHide	
	
	if(ActWindowId = 0) {
		MsgBox, Select a server window first
		return
	}
	;assign vars
	RestartCount:=0
	StringTrimRight, ActStartDate, StartDate, 6
	ActStartDateTime := (ActStartDate*10000+StartHour*100+StartMinute)*100
	ActRepeatHour := RepeatHour
	ActRepeatMinute := RepeatMinute
	ProgramStartTimestamp := A_Now
	
	;set timers
	SetTimer, ServerHandler, 1000
	SetTimer, CalcSecondsUntilRestart, 1000
	SetTimer, RefreshStatusMsg, 1000
	
	;handle buttons and update messages
	GuiControl, disable, Start
	GuiControl, enable, Stop
	GuiControl, disable, SelectWindow
	GuiControl,,StatusText, Starting...		
Return

ButtonSelectWindow:
	Gui, Submit, NoHide
	GuiControl,,SelectedWindowStatus, Please click on the server window now!	
	
	KeyWait, LButton, D
	MouseGetPos, , , id, control
	ActWindowId=%id%
	WinGetTitle, title, ahk_id %ActWindowId%
	ActWindowName=%title%	
	
	GuiControl,,SelectedWindowStatus, Selected window:
	GuiControl,,WindowName, "%ActWindowName%" (ID: %ActWindowId%)
Return

ButtonStop:	
	stopDeamon()
Return

GuiClose:
	ExitApp
Return

; ***********
;  FUNCTIONS
; ***********

isReadyToRestart()
{
	global SecondsUntilRestart
	return SecondsUntilRestart=0
}

secondsUntilTimestamp(pTimestamp)
{
	if pTimestamp-A_Now<=0 
	{
		return 0
	} 
	else 
	{	
		RetVal := pTimestamp
		RetVal -= A_Now , seconds ;subtracts timestamps and converts to seconds
		return RetVal
	}
}

HourMin2Sec(h,min)
{
	return (h*60+min)*60
}

seconds2Timestamp(s)
{	
	m:=s//60 ;integer division
	s:=Mod(s,60)
	
	h:=m//60
	m:=Mod(m,60)
	
	d:=h//24
	h:=Mod(h,60)
	
	d:=leadingZero(d)
	h:=leadingZero(h)
	m:=leadingZero(m)
	s:=leadingZero(s)
	
	str=%d%:%h%:%m%:%s%

	return str
}

leadingZero(i) 
{
	return (StrLen(i)=1) ? "0" i : i
}

stopDeamon()
{
	;set timers to off
	SetTimer, ServerHandler, Off
	SetTimer, CalcSecondsUntilRestart, Off
	SetTimer, RefreshStatusMsg, Off

	;handle buttons and update messages
	GuiControl, enable, Start
	GuiControl, disable, Stop
	GuiControl, enable, SelectWindow	 
	SetTimer, RefreshStatusMsg, Off
	GuiControl,,StatusText, idle	
}

WindowNotFoundError()
{
	MsgBox, Server window not found: %ActWindowName%		
	stopDeamon()
}
