#Persistent
#NoEnv
#SingleInstance force
#Include <clipChanged>
#Include <logToFile>
#Include <openDQDialog>
SendMode Input

;=== Load Start GUI settings from file ======================================
IniRead, Log, settings.ini, settings, Log
IniRead, Overlay, settings.ini, settings, Overlay
IniRead, ResizeOverlay, settings.ini, settings, ResizeOverlay
IniRead, OverlayWidth, settings.ini, settings, OverlayWidth
IniRead, OverlayHeight, settings.ini, settings, OverlayHeight
IniRead, FontColor, settings.ini, settings, FontColor
IniRead, FontSize, settings.ini, settings, FontSize
IniRead, FontType, settings.ini, settings, FontType

;=== Create Start GUI =======================================================
Gui, 1:Default
Gui, Font, s10, Segoe UI
Gui, Add, CheckBox, vLog, Enable logging to file?
Gui, Add, CheckBox, vOverlay, Enable overlay?
Gui, Add, CheckBox, vResizeOverlay, Allow resize of overlay?
Gui, Add, Text, vOverlayWidthInfo, Initial overlay width:
Gui, Add, Edit
Gui, Add, UpDown, vOverlayWidth Range100-2000, 975
Gui, Add, Text, vOverlayHeightInfo, Initial overlay height:
Gui, Add, Edit
Gui, Add, UpDown, vOverlayHeight Range100-2000, 200
Gui, Add, Text, vFontColorInfo, Overlay font color:
Gui, Add, ComboBox, vFontColor, White|Yellow|Red|Green|Blue
Gui, Add, Text,, Overlay font size:
Gui, Add, Edit
Gui, Add, UpDown, vFontSize Range8-30, 14
Gui, Add, Text, vFontInfo, Select a font or enter a custom font available`n on your system to use with the overlay:
Gui, Add, ComboBox, vFontType, Arial|Calibri|Consolas|Courier New|Inconsolata|Segoe UI|Tahoma|Times New Roman|Trebuchet MS|Verdana
Gui, Add, Button, gSave, Run ahkmon

;=== Apply Start GUI settings ===============================================
If (Log != "")
  GuiControl,, Log, %Log%
If (Overlay != "")
  GuiControl,, Overlay, %Overlay%
If (OverlayWidth != "")
  GuiControl,, OverlayWidth, %OverlayWidth%
If (OverlayHeight != "")
  GuiControl,, OverlayHeight, %OverlayHeight%
If (ResizeOverlay != "")
  GuiControl,, ResizeOverlay, %ResizeOverlay%
If (FontColor != "")
  GuiControl, Text, FontColor, %FontColor%
If (FontSize != "")
  GuiControl,, FontSize, %FontSize%
If (FontType != "")
  GuiControl, Text, FontType, %FontType%
Gui, Show, Autosize
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
  IniWrite, %OverlayWidth%, settings.ini, settings, OverlayWidth
  IniWrite, %OverlayHeight%, settings.ini, settings, OverlayHeight
  IniWrite, %ResizeOverlay%, settings.ini, settings, ResizeOverlay
  IniWrite, %FontColor%, settings.ini, settings, FontColor
  IniWrite, %FontSize%, settings.ini, settings, FontSize
  IniWrite, %FontType%, settings.ini, settings, FontType

;=== Open DQDialog ===========================================================
openDQDialog()

;=== Open overlay if enabled =================================================
if (Overlay = 1) {
  overlayShow=1
  Gui, 2:Default
  Gui, color, 000000  ; Sets GUI background to black
  Gui, Font, s%FontSize% c%FontColor%, %FontType%
  Gui, Add, Text, vClip w800 h200, %Clipboard%
  Gui, Show, w%OverlayWidth% h%OverlayHeight%
  if (ResizeOverlay = 1) {
      Gui -caption +alwaysontop -Theme +Resize
  }
  else {
    Gui -caption +alwaysontop -Theme
  }
  OnMessage(0x201,"WM_LBUTTONDOWN")  ; Allows dragging the window
}

;=== Miscellaneous functions =================================================
WM_LBUTTONDOWN(wParam,lParam,msg,hwnd){
  PostMessage, 0xA1, 2
}

;=== Start Clipboard listen ==================================================
OnClipboardChange("clipChanged")

;=== Allows toggling the overlay on and off ==================================
f12::
{
  if (overlayShow = 1) {
    Gui, 2:Show
    overlayShow = 0
  }
  else if (overlayShow = 0) {
    Gui, 2:Hide
    overlayShow = 1
  }
}
