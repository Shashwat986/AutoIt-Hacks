#include <ScreenCapture.au3>
#include <Array.au3>
#include <Constants.au3>
#include <WindowsConstants.au3>
#include <GDIPlus.au3>
#include <Misc.au3>

Func Capture_Window($hWnd, $w, $h, $location)
    _GDIPlus_Startup()
   
    Local $hDC_Capture = _WinAPI_GetWindowDC($hWnd)
    Local $hMemDC = _WinAPI_CreateCompatibleDC($hDC_Capture)
    Local $hHBitmap = _WinAPI_CreateCompatibleBitmap($hDC_Capture, $w, $h)
    Local $hObject = _WinAPI_SelectObject($hMemDC, $hHBitmap)
    DllCall("user32.dll", "int", "PrintWindow", "hwnd", $hWnd, "handle", $hMemDC, "int", 0)
    _WinAPI_DeleteDC($hMemDC)
    Local $hObject = _WinAPI_SelectObject($hMemDC, $hObject)
    _WinAPI_ReleaseDC($hWnd, $hDC_Capture)
    Local $hBmp = _GDIPlus_BitmapCreateFromHBITMAP($hHBitmap)
    _WinAPI_DeleteObject($hHBitmap)
    ;Return $hBmp
	
	_GDIPlus_ImageSaveToFile($hBmp, $location)
    _GDIPlus_BitmapDispose($hBmp)
    _GDIPlus_Shutdown()
EndFunc   ;==>Capture_Window
;http://www.autoitscript.com/forum/topic/140948-screenshot-to-a-incative-window/
;coded by UEZ 2012


;-------------------


#NoTrayIcon

Opt("TrayMenuMode", 1)
Local $item[7]

$item[1] = TrayCreateItem("Google")
TrayItemSetState(-1, $TRAY_CHECKED) ; Starts out checked

$item[2] = TrayCreateItem("Ping")

$item[3] = TrayCreateItem("SendKeys")
Global $sendifset=""
Global $hotkeyifset=""

$item[4] = TrayCreateItem("Diff?")
Global $checksum=0, $winsize, $title, $hnd, $c2, $noshiftflag=0
Global $arr1, $arr2

Global $img
Global $ret
; Initialize error handler
$oMyError = ObjEvent("AutoIt.Error","MyErrFunc")
$img = ObjCreate("ImageMagickObject.MagickImage.1")

$item[5] = TrayCreateItem("Timer")
Global $timerv
Global $timerhnd

$item[6] = TrayCreateItem("Ping Check")
Global $downflag=0

TrayCreateItem("")
$item[0] = TrayCreateItem("Exit")
TrayItemSetOnEvent(-1,"exit")


TraySetState(1)
;TraySetIcon("")

Global $flagping=0
While 1
   Sleep(50)
   $msg = TrayGetMsg()
   
   If $msg = $item[0] Then
	  ExitLoop
   EndIf
   
   If $msg <> 0 Then
	  If TrayItemGetState($item[1]) = 65 AND $msg = $item[1] Then
		 HotKeySet("^!g","google_fn")
	  Elseif $msg = $item[1] Then
		 HotKeySet("^!g")
	  EndIf
	  
	  If TrayItemGetState($item[2]) = 65 AND $msg = $item[2] Then
		 $flagping = BitOR($flagping,2) 	; Use BitAND and BitNOT instead
	  Elseif $msg = $item[2] Then
		 $flagping = BitAND($flagping,BitNOT(2))
	  EndIf

	  If TrayItemGetState($item[3]) = 65 AND $msg = $item[3] Then
		 $hotkeyifset = InputBox("HotKey","Enter The Hotkey. ! = ALT; ^ = CTRL; + = SHIFT; # = WIN; {} enclose keys",$hotkeyifset)
		 If $hotkeyifset = "" Then ContinueLoop
		 $sendifset = InputBox("Combination","Enter The Combination. Same Key codes.",$sendifset)
		 If $sendifset = "" Then ContinueLoop
		 HotKeySet($hotkeyifset,"sendkeys")
	  Elseif $msg = $item[3] Then
		 HotKeySet($hotkeyifset)
	  EndIf
	  
	  If TrayItemGetState($item[4]) = 65 AND $msg = $item[4] Then		 
		 HotKeySet("^!{PRINTSCREEN}","scrdiff_fn")
	  Elseif $msg = $item[4] Then
		 HotKeySet("^!{PRINTSCREEN}")
	  EndIf
	  
	  If TrayItemGetState($item[5]) = 65 AND $msg = $item[5] Then
		 Local $temp = InputBox("Timer", "Enter time in seconds (60 seconds in a minute, 3600 seconds in an hour)")
		 $timerv = Number($temp)
		 $timerv = Int($n * 1000)
		 $timerhnd = TimerInit()
		 $flagping = BitOR($flagping,16)
	  EndIf
	  
	  If TrayItemGetState($item[6]) = 65 AND $msg = $item[6] Then
		 $flagping = BitOR($flagping,32)
	  Elseif $msg = $item[6] Then
		 $flagping = BitAND($flagping,BitNOT(32))
		 $downflag = 0
	  EndIf
	  
   EndIf
   
   If $flagping > 0 Then
	  Select
		 Case BitAND($flagping,1) <> 0
			;--
		 Case BitAND($flagping,2) <> 0
			Local $var = Ping("www.google.com", 500)
			If $var Then
			   Beep(1318,800)					;E6
			   If $var > 100 Then Beep(1568,400);G6
			   If $var > 200 Then Beep(2093,400);C6
			   ;MsgBox(0, "Status", "Online")
			   $flagping = BitAND($flagping,BitNOT(2))
			   TrayItemSetState($item[2],68)
			EndIf
		 Case BitAND($flagping,4) <> 0
			;--
		 Case BitAND($flagping,8) <> 0
			Sleep(200)
			Local $state = WinGetState($title)
			If BitAND($state, 16) Then
			   $actitle = WinGetTitle("[active]")
			   WinSetState($title,"",@SW_MAXIMIZE)
			   WinActivate($actitle)
			EndIf
			
			Capture_Window($hnd,$winsize[2],$winsize[3],@ScriptDir & "\GDIPlus_Image2.jpg")
			If NOT $noshiftflag Then
			$ret = $img.Convert(@ScriptDir & "\GDIPlus_Image2.jpg", _
			   "-crop", String($arr2[0]-$arr1[0])&"x"&String($arr2[1]-$arr1[1])&"+"&String($arr1[0])&"+"&String($arr1[1]), _
			   @ScriptDir & "\GDIPlus_Image2.jpg")
			EndIf
			
			Local $c1 = FileRead(@ScriptDir & "\GDIPlus_Image2.jpg")
			
			If $c1 <> $c2 Then
			   ;MsgBox(0, "", "Something in the region has changed!")
			   Beep(1318,800)					;E6
			   $flagping  = BitAND($flagping,BitNOT(8))
			EndIf
		 Case BitAND($flagping,16) <> 0
			If TimerDiff($timerhnd)>$timerv Then
			   Beep(1318,800)					;E6
			   $flagping  = BitAND($flagping,BitNOT(16))
			EndIf
		 Case BitAND($flagping,32) <> 0
			Local $var = Ping("www.google.com", 1000)
			If $var Then
			   If $downflag Then
				  Beep(1318,800)
				  Beep(1568,800)
				  $downflag = 0
			   EndIf
			Else
			   If NOT $downflag Then
				  Beep(1568,800)
				  Beep(1318,800)
				  $downflag = 1
			   EndIf
			EndIf
			
	  EndSelect
   EndIf
   
WEnd

Exit

Func google_fn()
   $st = InputBox("Google Search","Enter Seach Term")
   If @error <> 0 Then
	  Return
   EndIf
   ShellExecute("chrome.exe", """www.google.com/#q=" & $st & """")
EndFunc

Func sendkeys()
   HotKeySet($hotkeyifset)
   Send($sendifset)
   HotKeySet($hotkeyifset,"sendkeys")
EndFunc

; Screenshot differences
Func scrdiff_fn()
   Local $hDLL = DllOpen("user32.dll")
   
   Local $i=0
   $noshiftflag = 0
   While $i < 20	; 2 seconds to use the shift modifier
	  If _IsPressed("10",$hDLL) Then
		 $arr1 = MouseGetPos()
		 While _IsPressed("10",$hDLL)
			Sleep(100)
		 WEnd
		 $arr2 = MouseGetPos()
		 ExitLoop
	  EndIf
	  Sleep(100)
	  $i = $i + 1
   WEnd
   
   If $i >= 20 Then	; If shift modifier wasn't used
	  $noshiftflag = 1
   EndIf
   
   If NOT $noshiftflag Then	; If shift modifier was used
	  If $arr1[0]>$arr2[0] Then
		 $t = $arr1[0]
		 $arr1[0]=$arr2[0]
		 $arr2[0]=$t
	  EndIf
	  If $arr1[1]>$arr2[1] Then
		 $t = $arr1[1]
		 $arr1[1]=$arr2[1]
		 $arr2[1]=$t
	  EndIf
   EndIf
   
   $title = WinGetTitle("[active]")
   
   If NOT $noshiftflag Then	; If shift modifier was used, display gui of size
	  $h = GUICreate("",($arr2[0]-$arr1[0]),($arr2[1]-$arr1[1]),$arr1[0],$arr1[1])
	  GUISetState(@SW_SHOW,$h)
	  Sleep(250)
	  GUIDelete($h)
   EndIf
   
   $hnd = WinGetHandle($title)
   $winsize = WinGetPos($title)
   
   Local $state = WinGetState($title)
   If BitAND($state, 16) Then
	  $actitle = WinGetTitle("[active]")
	  WinSetState($title,"",@SW_MAXIMIZE)
	  WinActivate($actitle)
   EndIf
   
   Capture_Window($hnd,$winsize[2],$winsize[3],@ScriptDir & "\GDIPlus_Image1.jpg")
   
   If NOT $noshiftflag Then
   $ret = $img.Convert(@ScriptDir & "\GDIPlus_Image1.jpg", _
        "-crop", String($arr2[0]-$arr1[0])&"x"&String($arr2[1]-$arr1[1])&"+"&String($arr1[0])&"+"&String($arr1[1]), _
        @ScriptDir & "\GDIPlus_Image1.jpg")
   EndIf
	 
   $c2 = FileRead(@ScriptDir & "\GDIPlus_Image1.jpg")
   
   $flagping = BitOR($flagping, 8)
EndFunc


; COM Object error function.
Func MyErrFunc()
   $HexNumber=hex($oMyError.number,8)
   Msgbox(0,"COM Error Test","We intercepted a COM Error !"     & @CRLF & @CRLF & _
				"err.description is: " & @TAB & $oMyError.description  & @CRLF & _
				"err.windescription:"   & @TAB & $oMyError.windescription & @CRLF & _
				"err.number is: "       & @TAB & $HexNumber             & @CRLF & _
				"err.lastdllerror is: " & @TAB & $oMyError.lastdllerror & @CRLF & _
				"err.scriptline is: "   & @TAB & $oMyError.scriptline   & @CRLF & _
				"err.source is: "       & @TAB & $oMyError.source       & @CRLF & _
				"err.helpfile is: "     & @TAB & $oMyError.helpfile     & @CRLF & _
				"err.helpcontext is: " & @TAB & $oMyError.helpcontext _
			   )
   SetError(1) ; to check for after this function returns
Endfunc