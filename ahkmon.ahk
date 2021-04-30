#Persistent
#NoEnv
#SingleInstance force
#Include <clipChanged>
#Include <logToFile>
#Include <openDQDialog>
#Include <ocrFunctions>
SendMode Input
DetectHiddenWindows, On

;=== Load Start GUI settings from file ======================================
IniRead, Log, settings.ini, settings, Log, 0
IniRead, Overlay, settings.ini, settings, Overlay, 1
IniRead, RequireFocus, settings.ini, settings, RequireFocus, 0
IniRead, OCR, settings.ini, settings, OCR, 0
IniRead, ResizeOverlay, settings.ini, settings, ResizeOverlay, 0
IniRead, OverlayWidth, settings.ini, settings, OverlayWidth, 930
IniRead, OverlayHeight, settings.ini, settings, OverlayHeight, 150
IniRead, OverlayColor, settings.ini, settings, OverlayColor, 000000
IniRead, FontColor, settings.ini, settings, FontColor, White
IniRead, FontSize, settings.ini, settings, FontSize, 16
IniRead, FontType, settings.ini, settings, FontType, Arial
IniRead, OverlayPosX, settings.ini, settings, OverlayPosX, 0
IniRead, OverlayPosY, settings.ini, settings, OverlayPosY, 0
IniRead, OverlayTransparency, settings.ini, settings, OverlayTransparency, 255
IniRead, DeepLAttempts, settings.ini, settings, DeepLAttempts, 25
IniRead, LineByLineDialog, settings.ini, settings, LineByLineDialog, 0

;=== Create Start GUI =======================================================
Gui, 1:Default
Gui, Font, s10, Segoe UI
Gui, Add, Tab3,, General|Overlay Settings|Advanced
Gui, Add, Text,, ahkmon: Automate your DQX text translation.
Gui, Add, Link, y+2 vDiscord, Join the unofficial Dragon Quest X <a href="https://discord.gg/UFaUHBxKMY">Discord</a>!
Gui, Add, CheckBox, vLog Checked%Log%, Enable logging to file?
Gui, Add, CheckBox, vRequireFocus Checked%RequireFocus%, Require DQX window to be focused for auto translate?
Gui, Add, CheckBox, vOverlay Checked%Overlay%, Enable overlay? (Toggle with F12)
Gui, Add, CheckBox, vOCR Checked%OCR%, Enable Optical Character Recognition (OCR)? (Ctrl+Q)
Gui, Add, Picture, w375 h206, imgs/dqx_logo.png
Gui, Add, Button, gSave, Run ahkmon

;; Overlay settings tab
Gui, Tab, Overlay Settings
Gui, Add, Text,, F12 will turn the overlay on/off.`n - Alt+F12 will save the location of the overlay on next start.`n - Make sure you click on the overlay before you press Alt+F12!
Gui, Add, CheckBox, vResizeOverlay Checked%ResizeOverlay%, Allow resize of overlay?
Gui, Add, CheckBox, vLineByLineDialog Checked%LineByLineDialog%, Enable line by line dialog?
Gui, Add, Text,, Overlay transparency (lower = more transparent):
Gui, Add, Slider, vOverlayTransparency Range10-255 TickInterval3 Page3 Line3 Tooltip, %OverlayTransparency%
Gui, Add, Text, vOverlayColorInfo, Overlay background color (use hex color codes):
Gui, Add, ComboBox, vOverlayColor, %OverlayColor%||
Gui, Add, Text, vOverlayWidthInfo, Initial overlay width:
Gui, Add, Edit
Gui, Add, UpDown, vOverlayWidth Range100-2000, %OverlayWidth%
Gui, Add, Text, vOverlayHeightInfo, Initial overlay height:
Gui, Add, Edit
Gui, Add, UpDown, vOverlayHeight Range100-2000, %OverlayHeight%
Gui, Add, Text, vFontColorInfo, Overlay font color:
Gui, Add, ComboBox, vFontColor, %FontColor%||Yellow|Red|Green|Blue|Black|Gray|Maroon|Purple|Fuchsia|Lime|Olive|Navy|Teal|Aqua
Gui, Add, Text,, Overlay font size:
Gui, Add, Edit
Gui, Add, UpDown, vFontSize Range8-30, %FontSize%
Gui, Add, Text, vFontInfo, Select a font or enter a custom font available`n on your system to use with the overlay:
Gui, Add, ComboBox, vFontType, %FontType%||Calibri|Consolas|Courier New|Inconsolata|Segoe UI|Tahoma|Times New Roman|Trebuchet MS|Verdana

;; Advanced tab
Gui, Tab, Advanced
Gui, Add, Text,, This tab is for users that struggle with the default settings.
Gui, Add, Text, vDeepLAttemptsInfo, DeepL translate attempts before giving up:
Gui, Add, Slider, vDeepLAttempts Range10-50 TickInterval1 Page1 Line1 Tooltip, %DeepLAttempts%

;; Tooltips
Log_TT := "Logs both pre and post translations to separate`nlog files for viewing."
RequireFocus_TT := "Checked: Auto translation will only work`nwhen DQX is the focused window.`nUnchecked: Auto translation will function regardless`n of DQX being the focused window or not."
Overlay_TT := "Enables a draggable box to display the translated text.`nConfigure behavior in the 'Overlay Settings' tab."
OCR_TT := "Optical Character Recognition (OCR) allows you to`ncapture an image with a hotkey and translate the`ntext from the image. This method is reportedly`nmore accurate than tesseract, but is far from perfect.`n`nThe method used with this program can be triggered with`nCtrl+R. Click and drag over the text you want to translate and`n it'll show up in both DeepL and the overlay."
ResizeOverlay_TT := "Checked: Allows you to stretch the overlay`nto your preferred size.`nUnchecked:A fixed overlay with the size configured with`n'Initial overlay width' and 'Initial overlay height'."
LineByLineDialog_TT := "DQDialog will sometimes show all exhausted NPC text in one go.`nChecked: Allows you to go through the dialog just like you were reading it`n(sentence by sentence).`nUnchecked: See all text like normal."

;;=== Misc Start GUI ========================================================
;; Used for tooltip popups in the Start GUI
Gui, Show, Autosize
OnMessage(0x0200, "WM_MOUSEMOVE")
Return

WM_MOUSEMOVE() {
  static CurrControl, PrevControl, _TT  ; _TT is kept blank for use by the ToolTip command below
  CurrControl := A_GuiControl
  if (CurrControl != PrevControl and not InStr(CurrControl, " ")) {
    ToolTip  ; Turn off any previous tooltip
    SetTimer, DisplayToolTip, 10
    PrevControl := CurrControl
  }
  return

  DisplayToolTip:
    SetTimer, DisplayToolTip, Off
    ToolTip % %CurrControl%_TT
    SetTimer, RemoveToolTip, 60000
    return

  RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
    return
}

;;
JoyCpl:
  Run joy.cpl
  Return

;; What to do when the app is gracefully closed
GuiEscape:
GuiClose:
  ExitApp

;=== Save Start GUI settings to ini ==========================================
Save:
  Gui, Submit, Hide
  IniWrite, %Log%, settings.ini, settings, Log
  IniWrite, %RequireFocus%, settings.ini, settings, RequireFocus
  IniWrite, %Overlay%, settings.ini, settings, Overlay
  IniWrite, %OCR%, settings.ini, settings, OCR
  IniWrite, %OverlayWidth%, settings.ini, settings, OverlayWidth
  IniWrite, %OverlayHeight%, settings.ini, settings, OverlayHeight
  IniWrite, %OverlayColor%, settings.ini, settings, OverlayColor
  IniWrite, %ResizeOverlay%, settings.ini, settings, ResizeOverlay
  IniWrite, %FontColor%, settings.ini, settings, FontColor
  IniWrite, %FontSize%, settings.ini, settings, FontSize
  IniWrite, %FontType%, settings.ini, settings, FontType
  IniWrite, %OverlayTransparency%, settings.ini, settings, OverlayTransparency
  IniWrite, %DeepLAttempts%, settings.ini, settings, DeepLAttempts
  IniWrite, %LineByLineDialog%, settings.ini, settings, LineByLineDialog

;=== Global vars we'll be using elsewhere ====================================
Global RequireFocus
Global Overlay
Global Log
Global TranslateType
Global FontType
Global FontColor
Global DeepLAttempts
Global ClipboardWaitTime
Global LineByLineDialog

;=== Open DQDialog ===========================================================
openDQDialog()

;=== Open overlay if enabled =================================================
if (Overlay = 1) {
  overlayShow = 1
  alteredOverlayWidth := OverlayWidth - 2
  Gui, 2:Default
  Gui, Color, %OverlayColor%  ; Sets GUI background to black
  Gui, Font, s%FontSize% c%FontColor%, %FontType%

  if (LineByLineDialog = 1)
  	Gui, Add, Text, -E0x200 vClip w%alteredOverlayWidth% h%OverlayHeight%
  else
  	Gui, Add, Edit, +wrap readonly -E0x200 vClip w%alteredOverlayWidth% h%OverlayHeight%, %Clipboard%

  Gui, Show, % "w" OverlayWidth "h" OverlayHeight "x" OverlayPosX "y" OverlayPosY
  Winset, Transparent, %OverlayTransparency%, A

  OnMessage(0x201,"WM_LBUTTONDOWN")  ; Allows dragging the window
  OnMessage(0x47, "WM_WINDOWPOSCHANGED")  ; When left mouse click down is detected

  if (ResizeOverlay = 1) {
    Gui, -caption +alwaysontop -Theme -DPIScale +ToolWindow -Border +Resize -MaximizeBox
  }
  else {
    Gui -caption +alwaysontop -Theme -DPIScale +ToolWindow -Border
  }
}

;=== Miscellaneous functions =================================================
WM_LBUTTONDOWN(wParam,lParam,msg,hwnd) {
  PostMessage, 0xA1, 2
}

WM_WINDOWPOSCHANGED() {
    Gui, 2:Default
    WinGetPos,newOverlayX,newOverlayY,newOverlayWidth,newOverlayHeight, A
    ; Prefer redrawing on move rather than at the end as text gets distorted otherwise
    GuiControl, MoveDraw, Clip, % "w" newOverlayWidth-31 "h" newOverlayHeight-38
}

GetKeyPress(keyStr) {
	keys := StrSplit(keyStr, ",")
	loop
		for each, key in keys
			if GetKeyState(key) {
				KeyWait, %key%
				return key
			}
}

;=== Start Clipboard listen ==================================================
OnClipboardChange("clipChanged")

;=== Allows toggling the overlay on and off ==================================
f12::
{
  if (overlayShow = 1) {
    Gui, 2:Default
    Gui, Hide
    WinActivate, ahk_exe DQXGame.exe
    overlayShow = 0
  }
  else {
    Gui, 2:Default
    Gui, Show
    Sleep 100
    WinGetPos,,,newOverlayWidth,newOverlayHeight, A
    GuiControl, MoveDraw, Clip, % "w" newOverlayWidth-31 "h" newOverlayHeight-38
    WinActivate, ahk_exe DQXGame.exe
    overlayShow = 1
  }
}

;=== Saves location of dialog box ============================================
!f12::
{
  if (Overlay = 1) {
    WinGetPos,newOverlayX,newOverlayY,newOverlayWidth,newOverlayHeight, A
    IniWrite, %newOverlayX%, settings.ini, settings, OverlayPosX
    IniWrite, %newOverlayY%, settings.ini, settings, OverlayPosY
    Return
  }
}

;=== Activates OCR capture ===================================================
^Q::
{
  if (OCR = 1) {
    screenOCR()
  }
}
