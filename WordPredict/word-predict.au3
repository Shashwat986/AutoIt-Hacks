; This tool aims to predict words/sentences based on what has been typed so far.
;
; Currently (21/12/2013), it predicts single words based on the characters typed so far, and the frequency of that word.
; TODO: We need to fix the problem with using Enter and add capital letter support.
; Additionally, we need to make the backspace key delete characters from $sofar.
; We need to fix bugs in the Enter key and also problems with fast typing and how it screws up what is being written sometimes.
; The delete key needs to delete the text predicted.
;
; Further Steps: Predict sentences based on what has been typed so far using a bigram frequency table.

#include <Misc.au3>

AutoItSetOption("SendKeyDelay",0)
Global $sofar=""	; This is the substring written by the user so far
Global $pred=False	; This is True if a prediction is visible to the user
Global $l=0			; This contains the length of the last prediction made
Global $str=""		; This containst the last prediction made
Global $hDLL = DllOpen("user32.dll")

HotKeySet("^!q","Stop")		; Pressing CTRL+ALT+Q will stop the program
Func Stop()
   Exit
EndFunc

Func Test()
   HotKeySet("a")
   Send("a")
   Local $str = "pple"
   Local $l = StringLen($str)
   Send($str & "+{LEFT " & String($l) & "}")
   HotKeySet("a","Test")
EndFunc

Func iPA()
   ; Returns the key pressed on the keyboard if it is a letter and if it isn't used in a control sequence.
   ; Also, returns -1 when the Spacebar, a number, or one of the cursor moving keys is pressed
   ; Also, returns -2 when the Tab key or the Enter key is pressed.
   ;
   ; >0: ASCII value of key pressed
   ; 0: To be ignored
   ; -1: To reset $sofar
   ; -2: To reset $sofar if $pred is false, and to complete word if $pred is true.
   
   ; For the -2s
   if _IsPressed(09, $hDLL) Then
	  While _IsPressed(09, $hDLL)
		 Sleep(10)
	  WEnd
	  Return -2
   EndIf
   if _IsPressed("0D", $hDLL) Then
	  While _IsPressed("0D", $hDLL)
		 Sleep(10)
	  WEnd
	  Return -2
   EndIf
   
   ; 10 SHIFT key
   If _IsPressed(10, $hDLL) Then
	  Return 0
   EndIf
   ; 11 CTRL key
   If _IsPressed(11, $hDLL) Then
	  Return 0
   EndIf
   ; 12 ALT key
   If _IsPressed(12, $hDLL) Then
	  Return 0
   EndIf
   ; Windows keys
   If _IsPressed("5B", $hDLL) Then
	  Return 0
   EndIf
   If _IsPressed("5C", $hDLL) Then
	  Return 0
   EndIf
   
   ; For the -1s
   ; SpaceBar
   if _IsPressed(20, $hDLL) Then
	  While _IsPressed(20, $hDLL)
		 Sleep(10)
	  WEnd
	  Return -1
   EndIf
   ; Escape
   if _IsPressed("1B", $hDLL) Then
	  While _IsPressed("1B", $hDLL)
		 Sleep(10)
	  WEnd
	  Return -1
   EndIf
   ; Space, PageUp, PageDown, Home, End, Left, Right, Up, Down
   For $i = 32 to 40
	  If _IsPressed(Hex($i), $hDLL) Then
		 While _IsPressed(Hex($i), $hDLL)
			Sleep(10)
		 WEnd
		 Return -1
	  EndIf
   Next
   ; Numbers
   For $i = 48 to 57
	  If _IsPressed(Hex($i), $hDLL) Then
		 While _IsPressed(Hex($i), $hDLL)
			Sleep(10)
		 WEnd
		 Return -1
	  EndIf
   Next
   
   ; For all text keystrokes
   For $i = 65 to 90
	  If _IsPressed(Hex($i), $hDLL) Then	; If the key is pressed, return the ASCII value of that key.
		 While _IsPressed(Hex($i), $hDLL)
			Sleep(10)
		 WEnd
		 Return $i
	  EndIf
   Next
   
   ; For all other characters.
   Return 0
EndFunc

Func UnigramPrediction($lstr)
   $lstr = StringLower($lstr)
   $fp = FileOpen("en.txt")
   While True
	  $line = FileReadLine($fp)
	  If @error = -1 Then ExitLoop
	  If StringLeft($line,StringLen($lstr)) == $lstr Then
		 $array = StringSplit($line," ")	; Since the entries in en.txt are of the form "<word> <frequency>\n"
		 FileClose($fp)
		 Return StringMid($array[1],StringLen($lstr)+1)
		 ExitLoop
	  EndIf
   WEnd
   FileClose($fp)
   Return ""
EndFunc


While 1
   Sleep(1)						; Loops in the background till it detects the HotKey
   $k = iPA()
   If $k <> 0 Then
	  If $k <> -1 and $k <> -2 Then
		 $sofar = $sofar & Chr($k)
		 $str = UnigramPrediction($sofar)
		 $l = StringLen($str)
		 ;MsgBox(0,$sofar,$str)
		 If $l > 0 Then
			Send($str & "+{LEFT " & String($l) & "}")
			$pred = True
		 EndIf
	  ElseIf $k == -2 and $pred = True Then
		 Send("{BACKSPACE}" & $str)
		 $sofar=""
		 $l=0
		 $str=""
		 $pred = False
	  Else
		 $sofar=""
		 $l=0
		 $str=""
		 $pred = False
	  EndIf
   EndIf
WEnd