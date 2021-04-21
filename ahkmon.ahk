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
IniRead, Log, settings.ini, settings, Log
IniRead, Overlay, settings.ini, settings, Overlay
IniRead, RequireFocus, settings.ini, settings, RequireFocus
IniRead, OCR, settings.ini, settings, OCR
IniRead, ResizeOverlay, settings.ini, settings, ResizeOverlay
IniRead, OverlayWidth, settings.ini, settings, OverlayWidth
IniRead, OverlayHeight, settings.ini, settings, OverlayHeight
IniRead, FontColor, settings.ini, settings, FontColor
IniRead, FontSize, settings.ini, settings, FontSize
IniRead, FontType, settings.ini, settings, FontType
IniRead, OverlayPosX, settings.ini, settings, OverlayPosX
IniRead, OverlayPosY, settings.ini, settings, OverlayPosY

;=== Create Start GUI =======================================================
Gui, 1:Default
Gui, Font, s10, Segoe UI
Gui, Add, Tab3,, General|Overlay Settings|OCR Notice
Gui, Add, Text,, ahkmon: Automate your DQX text translation.
Gui, Add, Text, y+2 cBlue gLink1, (Ctrl+Click) Join the unofficial Dragon Quest X Discord!
Gui, Add, CheckBox, vLog, Enable logging to file?
Gui, Add, CheckBox, vRequireFocus, Require DQX window to be focused for auto translate?
Gui, Add, CheckBox, vOverlay, Enable overlay? (Toggle with F12)
Gui, Add, CheckBox, vOCR, Enable Optical Character Recognition (OCR)? (Ctrl+R)
Gui, Add, Picture, w151 h138, imgs/slime.png
Gui, Add, Button, gSave, Run ahkmon

;; Overlay settings tab
Gui, Tab, Overlay Settings
Gui, Add, Text,, F12 will turn the overlay on/off.`n - Alt+F12 will save the location of the overlay on next start.`n - Make sure you click on the overlay before you press Alt+F12!
Gui, Add, CheckBox, vResizeOverlay, Allow resize of overlay?
Gui, Add, Text, vOverlayWidthInfo, Initial overlay width:
Gui, Add, Edit
Gui, Add, UpDown, vOverlayWidth Range100-2000, 930
Gui, Add, Text, vOverlayHeightInfo, Initial overlay height:
Gui, Add, Edit
Gui, Add, UpDown, vOverlayHeight Range100-2000, 150
Gui, Add, Text, vFontColorInfo, Overlay font color:
Gui, Add, ComboBox, vFontColor, White|Yellow|Red|Green|Blue
Gui, Add, Text,, Overlay font size:
Gui, Add, Edit
Gui, Add, UpDown, vFontSize Range8-30, 14
Gui, Add, Text, vFontInfo, Select a font or enter a custom font available`n on your system to use with the overlay:
Gui, Add, ComboBox, vFontType, Arial|Calibri|Consolas|Courier New|Inconsolata|Segoe UI|Tahoma|Times New Roman|Trebuchet MS|Verdana

;; OCR Notice
Gui, Tab, OCR Notice
Gui, Add, Text,, Optical Character Recognition (OCR) allows you to`ncapture an image with a hotkey and translate the`ntext from the image. This method is reportedly`nmore accurate than tesseract, but is far from perfect.`n`nThe method used with this program can be triggered with`nCtrl+R. Click and drag over the text you want to translate and`n it'll show up in both DeepL and the overlay.

;=== Set defaults and apply Start GUI settings ==============================
If (Log = "ERROR") {
  GuiControl,, Log, 1
} else {
  GuiControl,, Log, %Log%
}

If (RequireFocus = "ERROR") {
  GuiControl,, RequireFocus, 1
} else {
  GuiControl,, RequireFocus, %RequireFocus%
}

If (OCR = "ERROR") {
  GuiControl,, OCR, 0
} else {
  GuiControl,, OCR, %OCR%
}

If (Overlay = "ERROR") {
  GuiControl,, Overlay, 1
} else {
  GuiControl,, Overlay, %Overlay%
}

If (ResizeOverlay = "ERROR") {
  GuiControl,, ResizeOverlay, 1
} else {
  GuiControl,, ResizeOverlay, %ResizeOverlay%
}

If (OverlayWidth = "ERROR") {
  GuiControl,, OverlayWidth, 950
} else {
  GuiControl,, OverlayWidth, %OverlayWidth%
}

If (OverlayHeight = "ERROR") {
  GuiControl,, OverlayHeight, 300
} else {
  GuiControl,, OverlayHeight, %OverlayHeight%
}

If (FontColor = "ERROR") {
  GuiControl, Text, FontColor, White
} else {
  GuiControl, Text, FontColor, %FontColor%
}

If (FontSize = "ERROR") {
  GuiControl,, FontSize, 12
} else {
  GuiControl,, FontSize, %FontSize%
}

If (FontType = "ERROR") {
  GuiControl, Text, FontType, Arial
} else {
  GuiControl, Text, FontType, %FontType%
}

If (OverlayPosX = "ERROR")
  OverlayPosX = 0

If (OverlayPosY = "ERROR")
  OverlayPosY = 0

Gui, Show, Autosize
Return

Link1:
  Run https://discord.gg/UFaUHBxKMY
  Return

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
  IniWrite, %ResizeOverlay%, settings.ini, settings, ResizeOverlay
  IniWrite, %FontColor%, settings.ini, settings, FontColor
  IniWrite, %FontSize%, settings.ini, settings, FontSize
  IniWrite, %FontType%, settings.ini, settings, FontType

;=== Global vars we'll be using elsewhere ====================================
Global RequireFocus
Global Overlay
Global Log
Global TranslateType

;=== Open DQDialog ===========================================================
openDQDialog()

;=== Open overlay if enabled =================================================
if (Overlay = 1) {
  overlayShow=1
  alteredOverlayWidth := OverlayWidth - 30
  Gui, 2:Default
  Gui, color, 000000  ; Sets GUI background to black
  Gui, Font, s%FontSize% c%FontColor%, %FontType%
  Gui, Add, Edit, +wrap readonly -E0x200 vClip w%alteredOverlayWidth% h%OverlayHeight%, %Clipboard%
  Gui, Show, % "w" OverlayWidth "h" OverlayHeight "x" OverlayPosX "y" OverlayPosY

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
    GuiControl, MoveDraw, Clip, % "w" newOverlayWidth-51 "h" newOverlayHeight-20
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
    GuiControl, MoveDraw, Clip, % "w" newOverlayWidth-51 "h" newOverlayHeight-20
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
^r::
{
  if (OCR = 1) {
    screenOCR()
    Return
  }
}
