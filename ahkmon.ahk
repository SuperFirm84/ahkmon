#Persistent
#NoEnv
#SingleInstance force
#Include <DeepLDesktop>
#Include <DeepLAPI>
#Include <openDQDialog>
#Include <ocrFunctions>
#Include <JSON>
#Include <SQLiteDB>
SendMode Input
DetectHiddenWindows, On

;=== Load Start GUI settings from file ======================================
IniRead, Log, settings.ini, general, Log, 0
IniRead, Overlay, settings.ini, overlay, Overlay, 1
IniRead, RequireFocus, settings.ini, general, RequireFocus, 0
IniRead, OCR, settings.ini, general, OCR, 0
IniRead, JoystickEnabled, settings.ini, general, JoystickEnabled, 0
IniRead, ResizeOverlay, settings.ini, overlay, ResizeOverlay, 0
IniRead, OverlayWidth, settings.ini, overlay, OverlayWidth, 930
IniRead, OverlayHeight, settings.ini, overlay, OverlayHeight, 150
IniRead, OverlayColor, settings.ini, overlay, OverlayColor, 000000
IniRead, FontColor, settings.ini, overlay, FontColor, White
IniRead, FontSize, settings.ini, overlay, FontSize, 16
IniRead, FontType, settings.ini, overlay, FontType, Arial
IniRead, OverlayPosX, settings.ini, overlay, OverlayPosX, 0
IniRead, OverlayPosY, settings.ini, overlay, OverlayPosY, 0
IniRead, OverlayTransparency, settings.ini, overlay, OverlayTransparency, 255
IniRead, DeepLAttempts, settings.ini, advanced, DeepLAttempts, 25
IniRead, DeepLAPIEnable, settings.ini, deepl, DeepLAPIEnable, 0
IniRead, DeepLAPIKey, settings.ini, deepl, DeepLAPIKey, EMPTY

;=== Create Start GUI =======================================================
Gui, 1:Default
Gui, Font, s10, Segoe UI
Gui, Add, Tab3,, General|Overlay Settings|Advanced|DeepL API
Gui, Add, Text,, ahkmon: Automate your DQX text translation.
Gui, Add, Link, y+2 vDiscord, Join the unofficial Dragon Quest X <a href="https://discord.gg/UFaUHBxKMY">Discord</a>!
Gui, Add, CheckBox, vLog Checked%Log%, Enable logging to file?
Gui, Add, CheckBox, vRequireFocus Checked%RequireFocus%, Require DQX window to be focused for auto translate?
Gui, Add, CheckBox, vJoystickEnabled Checked%JoystickEnabled%, Do you play with a controller?
Gui, Add, CheckBox, vOverlay Checked%Overlay%, Enable overlay? (Toggle with F12)
Gui, Add, CheckBox, vOCR Checked%OCR%, Enable Optical Character Recognition (OCR)? (Ctrl+Q)
Gui, Add, Picture, w375 h206, imgs/dqx_logo.png
Gui, Add, Button, gSave, Run ahkmon

;; Overlay settings tab
Gui, Tab, Overlay Settings
Gui, Add, Text,, F12 will turn the overlay on/off.`n - Alt+F12 will save the location of the overlay on next start.`n - Make sure you click on the overlay before you press Alt+F12!
Gui, Add, CheckBox, vResizeOverlay Checked%ResizeOverlay%, Allow resize of overlay?
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
Gui, Add, Text, vDeepLAttemptsInfo, DeepL Desktop client translate attempts before giving up:
Gui, Add, Slider, vDeepLAttempts Range10-50 TickInterval1 Page1 Line1 Tooltip, %DeepLAttempts%

;; DeepL API tab
Gui, Tab, DeepL API
Gui, Add, Text,, This section is for those who created a DeepL Pro free account.`n`nThis allows you to use ahkmon without the DeepL desktop`nclient, while instead, interacting directly with DeepL's API.`n`nNote that signing up for a free DeepL Pro account`nrequires a valid credit card.`n`nDo not enable this option if you do not have DeepL Pro.`n
Gui, Add, CheckBox, vDeepLAPIEnable Checked%DeepLAPIEnable%, Enable DeepL API Requests?
Gui, Add, Text,, DeepL API Key (Found in your account page):
Gui, Add, Text, y+2 cRed, DO NOT SHARE THIS KEY WITH ANYONE
Gui, Add, Edit, r1 vDeepLAPIKey w135, %DeepLAPIKey%
Gui, Add, Button, gDeepLWordsLeft, Check remaining character count for month
Gui, Add, Text, w+300 vDeepLWords,

;; Tooltips
Log_TT := "Logs both pre and post translations to separate`nlog files for viewing."
RequireFocus_TT := "Checked: Auto translation will only work`nwhen DQX is the focused window.`nUnchecked: Auto translation will function regardless`n of DQX being the focused window or not."
Overlay_TT := "Enables a draggable box to display the translated text.`nConfigure behavior in the 'Overlay Settings' tab."
OCR_TT := "Optical Character Recognition (OCR) allows you to`ncapture an image with a hotkey and translate the`ntext from the image. This method is reportedly`nmore accurate than tesseract, but is far from perfect.`n`nThe method used with this program can be triggered with`nCtrl+R. Click and drag over the text you want to translate and`n it'll show up in both DeepL and the overlay."
ResizeOverlay_TT := "Checked: Allows you to stretch the overlay`nto your preferred size.`nUnchecked:A fixed overlay with the size configured with`n'Initial overlay width' and 'Initial overlay height'."
JoystickEnabled_TT := "Checked: Progressing dialog is done with controller inputs.`nUnchecked: Progressing dialog is done with keyboard inputs.`n(ENTER, ESCAPE and arrow keys)"

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
DeepLWordsLeft:
  oWhr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
  url := "https://api-free.deepl.com/v2/usage?auth_key=" . DeepLAPIKey
  oWhr.Open("GET", url, 0)
  oWhr.SetRequestHeader("User-Agent", "DQXTranslator")
  oWhr.Send()
  oWhr.WaitForResponse()
  jsonResponse := JSON.Load(oWhr.ResponseText)
  charRemaining := (jsonResponse.character_limit - jsonResponse.character_count)
  GuiControl, Text, DeepLWords, %charRemaining% characters remaining
  return


;; What to do when the app is gracefully closed
GuiEscape:
GuiClose:
  ExitApp

;=== Save Start GUI settings to ini ==========================================
Save:
  Gui, Submit, Hide
  IniWrite, %Log%, settings.ini, general, Log
  IniWrite, %RequireFocus%, settings.ini, general, RequireFocus
  IniWrite, %Overlay%, settings.ini, overlay, Overlay
  IniWrite, %OCR%, settings.ini, general, OCR
  IniWrite, %JoystickEnabled%, settings.ini, general, JoystickEnabled
  IniWrite, %OverlayWidth%, settings.ini, overlay, OverlayWidth
  IniWrite, %OverlayHeight%, settings.ini, overlay, OverlayHeight
  IniWrite, %OverlayColor%, settings.ini, overlay, OverlayColor
  IniWrite, %ResizeOverlay%, settings.ini, overlay, ResizeOverlay
  IniWrite, %FontColor%, settings.ini, overlay, FontColor
  IniWrite, %FontSize%, settings.ini, overlay, FontSize
  IniWrite, %FontType%, settings.ini, overlay, FontType
  IniWrite, %OverlayTransparency%, settings.ini, overlay, OverlayTransparency
  IniWrite, %DeepLAttempts%, settings.ini, advanced, DeepLAttempts
  IniWrite, %DeepLAPIEnable%, settings.ini, deepl, DeepLAPIEnable
  IniWrite, %DeepLAPIKey%, settings.ini, deepl, DeepLAPIKey

;=== SQLLite DB Details ======================================================
dbFileName := A_ScriptDir . "\dqxtrl.db"

;=== Keys to press to trigger dialog to continue =============================
KeyboardKeys := "Enter,Esc,Up,Down,Left,Right"
JoystickKeys := "Joy1,Joy2,Joy3,Joy4,Joy5,Joy6,Joy7,Joy8,Joy9,Joy10,Joy11,Joy12,Joy13,Joy14,Joy15,Joy16" 

;=== Global vars we'll be using elsewhere ====================================
Global RequireFocus
Global Overlay
Global Log
Global TranslateType
Global FontType
Global FontColor
Global DeepLAttempts
Global ClipboardWaitTime
Global DeepLAPIEnable
Global DeepLAPIKey
Global dbFileName
Global JoystickEnabled
Global JoystickKeys
Global KeyboardKeys

;=== Open DQDialog ===========================================================
openDQDialog()

;=== Open overlay if enabled =================================================
if (Overlay = 1) {
  overlayShow = 1
  alteredOverlayWidth := OverlayWidth - 2
  Gui, 2:Default
  Gui, Color, %OverlayColor%  ; Sets GUI background to black
  Gui, Font, s%FontSize% c%FontColor%, %FontType%
  Gui, Add, Text, -E0x200 vClip w%alteredOverlayWidth% h%OverlayHeight%
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
    GuiControl, MoveDraw, Clip, % "w" newOverlayWidth-31 "h" newOverlayHeight-38  ; Prefer redrawing on move rather than at the end as text gets distorted otherwise

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
if (DeepLAPIEnable = 1) {
  OnClipboardChange("DeepLAPI")
}
else {
  OnClipboardChange("DeepLDesktop")
}

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
