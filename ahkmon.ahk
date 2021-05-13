#Persistent
#NoEnv
#SingleInstance force
#Include <DeepLDesktop>
#Include <DeepLAPI>
#Include <ocrFunctions>
#Include <JSON>
#Include <SQLiteDB>
#Include <createFormData>
#Include <classMemory>
#Include <dqMemRead>
SendMode Input
DetectHiddenWindows, On

;=== Auto update ============================================================
;; Get latest version number from Github
oWhr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
url := "https://api.github.com/repos/jmctune/ahkmon/releases/latest"
oWhr.Open("GET", url, 0)
oWhr.Send()
oWhr.WaitForResponse()
jsonResponse := JSON.Load(oWhr.ResponseText)
latestVersion := (jsonResponse.tag_name)
latestVersion := SubStr(latestVersion, 2)

;; Get current version locally from version file
FileRead, currentVersion, version

;; If the versions differ, run updater
if (latestVersion != currentVersion)
{
  if (latestVersion = "" || currentVersion = "")
  {
    MsgBox Unable to determine latest version. Continuing without updating.
  }
  else
  {
    Run ahkmon_updater.exe
    ExitApp
  }
}
else
{
tmpLoc := A_ScriptDir "\tmp"
if FileExist(tmpLoc)
  FileRemoveDir, %A_ScriptDir%\tmp, 1
  sleep 50
}

;=== Load Start GUI settings from file ======================================
IniRead, Language, settings.ini, general, Language, en
IniRead, Log, settings.ini, general, Log, 0
IniRead, Overlay, settings.ini, overlay, Overlay, 1
IniRead, OCR, settings.ini, general, OCR, 0
IniRead, JoystickEnabled, settings.ini, general, JoystickEnabled, 0
IniRead, ResizeOverlay, settings.ini, overlay, ResizeOverlay, 0
IniRead, AutoHideOverlay, settings.ini, overlay, AutoHideOverlay, 0
IniRead, ShowOnTaskbar, settings.ini, overlay, ShowOnTaskbar, 0
IniRead, OverlayWidth, settings.ini, overlay, OverlayWidth, 930
IniRead, OverlayHeight, settings.ini, overlay, OverlayHeight, 150
IniRead, OverlayColor, settings.ini, overlay, OverlayColor, 000000
IniRead, FontColor, settings.ini, overlay, FontColor, White
IniRead, FontSize, settings.ini, overlay, FontSize, 16
IniRead, FontType, settings.ini, overlay, FontType, Arial
IniRead, OverlayPosX, settings.ini, overlay, OverlayPosX, 0
IniRead, OverlayPosY, settings.ini, overlay, OverlayPosY, 0
IniRead, OverlayTransparency, settings.ini, overlay, OverlayTransparency, 255
IniRead, HideDeepL, settings.ini, advanced, HideDeepL, 0
IniRead, DeepLAttempts, settings.ini, advanced, DeepLAttempts, 25
IniRead, DeepLAPIEnable, settings.ini, deepl, DeepLAPIEnable, 0
IniRead, DeepLApiPro, settings.ini, deepl, DeepLApiPro, 0
IniRead, DeepLAPIKey, settings.ini, deepl, DeepLAPIKey, EMPTY

;=== Create Start GUI =======================================================
Gui, 1:Default
Gui, Font, s10, Segoe UI
Gui, Add, Tab3,, General|Overlay Settings|Advanced|DeepL API|About
Gui, Add, Text,, ahkmon: Automate your DQX text translation.
Gui, Add, Picture, w375 h206, imgs/dqx_logo.png
Gui, Add, Link,, Language you want to translate text to:`n<a href="https://www.andiamo.co.uk/resources/iso-language-codes/">Regional Codes</a>
Gui, Add, DDL, vLanguage, %Language%||bg|cs|da|de|el|en|es|et|fi|fr|hu|it|lt|lv|nl|pl|pt|ro|ru|sk|sl|sv|zh
Gui, Add, CheckBox, vLog Checked%Log%, Enable logging to file?
Gui, Add, CheckBox, vJoystickEnabled Checked%JoystickEnabled%, Do you play with a controller?
Gui, Add, CheckBox, vOverlay Checked%Overlay%, Enable overlay? (Toggle with F12)
Gui, Add, CheckBox, vOCR Checked%OCR%, Enable Optical Character Recognition (OCR)? (Ctrl+Q)
Gui, Add, Button, gSave, Run ahkmon

;; Overlay settings tab
Gui, Tab, Overlay Settings
Gui, Add, Text,, F12 will turn the overlay on/off.`n - Alt+F12 will save the location of the overlay on next start.`n - Make sure you click on the overlay before you press Alt+F12!
Gui, Add, CheckBox, vResizeOverlay Checked%ResizeOverlay%, Allow resize of overlay?
Gui, Add, CheckBox, vAutoHideOverlay Checked%AutoHideOverlay%, Automatically hide overlay?
Gui, Add, CheckBox, vShowOnTaskbar Checked%ShowOnTaskbar%, Show overlay on taskbar when active?
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
Gui, Add, CheckBox, vHideDeepL Checked%HideDeepL%, Hide DeepL?
Gui, Add, Button, gResetDeepLPosition, Reset DeepL Position
Gui, Add, Text, vDeepLAttemptsInfo, DeepL Desktop client translate attempts before giving up:
Gui, Add, Slider, vDeepLAttempts Range10-50 TickInterval1 Page1 Line1 Tooltip, %DeepLAttempts%
Gui, Add, Text,, Uploads your translation log and copies a link`nto your clipboard.
Gui, Add, Button, gUploadLogs, Upload Log
Gui, Add, Text, w+300 vLogLink, 
Gui, Add, Text,, Download latest database`n(this will overwrite your current database!)
Gui, Add, Button, gDownloadDb, Download Database
Gui, Add, Text, w+300 vDatabaseStatusMessage,

;; DeepL API tab
Gui, Tab, DeepL API
Gui, Add, Text,, This section is for those who created a DeepL Pro account.`n`nThis allows you to use ahkmon without the DeepL desktop`nclient, while instead, interacting directly with DeepL's API.`n`nNote that signing up for a DeepL API account`nrequires a valid credit card.`n`nDo not enable this option if you do not have DeepL API Free or Pro.`n
Gui, Add, CheckBox, vDeepLAPIEnable Checked%DeepLAPIEnable%, Enable DeepL API Requests?
Gui, Add, CheckBox, vDeepLApiPro Checked%DeepLApiPro%, Do you have DeepL API Pro?
Gui, Add, Text,, DeepL API Key (Found in your account page):
Gui, Add, Text, y+2 cRed, DO NOT SHARE THIS KEY WITH ANYONE
Gui, Add, Edit, r1 vDeepLAPIKey w135, %DeepLAPIKey%
Gui, Add, Button, gDeepLWordsLeft, Check remaining character count
Gui, Add, Text, w+300 vDeepLWords, 

;; About tab
Gui, Tab, About
Gui, Add, Link,, Join the unofficial Dragon Quest X <a href="https://discord.gg/UFaUHBxKMY">Discord</a>!
Gui, Add, Link,, <a href="https://github.com/jmctune/ahkmon">Get the Source</a>
Gui, Add, Link,, <a href="https://github.com/jmctune/ahkmon/wiki">Documentation</a>
Gui, Add, Link,, Like what I'm doing? <a href="https://www.paypal.com/paypalme/supportjmct">Donate :P</a>
Gui, Add, Text,, Catch me on Discord: mebo#1337
Gui, Add, Text,, Made by Serany <3

;;=== Misc Start GUI ========================================================
Gui, Show, Autosize
Return

DeepLWordsLeft:
  GuiControlGet, DeepLApiPro
  GuiControlGet, DeepLAPIKey

  if DeepLApiPro = 1
    url := "https://api.deepl.com/v2"
  else
    url := "https://api-free.deepl.com/v2"

  oWhr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
  url := url . "/usage?auth_key=" . DeepLAPIKey
  oWhr.Open("POST", url, 0)
  oWhr.SetRequestHeader("User-Agent", "DQXTranslator")
  oWhr.Send()
  oWhr.WaitForResponse()
  jsonResponse := JSON.Load(oWhr.ResponseText)
  charRemaining := (jsonResponse.character_limit - jsonResponse.character_count)
  GuiControl, Text, DeepLWords, %charRemaining% characters remaining
  return

UploadLogs:
  file := "textdb.out"
  oWhr := ComObjCreate("WinHttp.WinHttpRequest.5.1")

  ;; Uses createFormData lib to generate multi-part stream
  objParam := { file : ["textdb.csv"] }
  CreateFormData(PostData, hdr_ContentType, objParam)

  oWhr.Open("POST", "https://file.io", 1)
  oWhr.SetRequestHeader("Content-Type", hdr_ContentType)
  oWhr.SetRequestHeader("File", file)
  oWhr.Send(PostData)
  oWhr.WaitForResponse()

  jsonResponse := JSON.Load(oWhr.ResponseText)
  jsonResponse := jsonResponse.link

  if (jsonResponse = "")
  {
    GuiControl, Text, LogLink, Failed to upload. Does textdb.csv exist?
  }
  else 
  {
    Clipboard := jsonResponse
    GuiControl, Text, LogLink, Success. Link copied to clipboard!
  }
  return

DownloadDb:
  UrlDownloadToFile, https://github.com/jmctune/ahkmon/raw/main/dqxtrl.db, dqxtrl.db
  if ErrorLevel
  {
    GuiControl, Text, DatabaseStatusMessage, Database failed to update.
  }
  else
  {
    GuiControl, Text, DatabaseStatusMessage, Database updated!
  }
  return

ResetDeepLPosition:
  WinMove, DeepL,, 0, 0
  return

;; What to do when the app is gracefully closed
GuiEscape:
GuiClose:
  ExitApp

;=== Save Start GUI settings to ini ==========================================
Save:
  Gui, Submit, Hide
  IniWrite, %Language%, settings.ini, general, Language
  IniWrite, %Log%, settings.ini, general, Log
  IniWrite, %Overlay%, settings.ini, overlay, Overlay
  IniWrite, %ShowOnTaskbar%, settings.ini, overlay, ShowOnTaskbar
  IniWrite, %OCR%, settings.ini, general, OCR
  IniWrite, %JoystickEnabled%, settings.ini, general, JoystickEnabled
  IniWrite, %OverlayWidth%, settings.ini, overlay, OverlayWidth
  IniWrite, %OverlayHeight%, settings.ini, overlay, OverlayHeight
  IniWrite, %OverlayColor%, settings.ini, overlay, OverlayColor
  IniWrite, %ResizeOverlay%, settings.ini, overlay, ResizeOverlay
  IniWrite, %AutoHideOverlay%, settings.ini, overlay, AutoHideOverlay
  IniWrite, %FontColor%, settings.ini, overlay, FontColor
  IniWrite, %FontSize%, settings.ini, overlay, FontSize
  IniWrite, %FontType%, settings.ini, overlay, FontType
  IniWrite, %OverlayTransparency%, settings.ini, overlay, OverlayTransparency
  IniWrite, %HideDeepL%, settings.ini, advanced, HideDeepL
  IniWrite, %DeepLAttempts%, settings.ini, advanced, DeepLAttempts
  IniWrite, %DeepLAPIEnable%, settings.ini, deepl, DeepLAPIEnable
  IniWrite, %DeepLApiPro%, settings.ini, deepl, DeepLApiPro
  IniWrite, %DeepLAPIKey%, settings.ini, deepl, DeepLAPIKey

;=== Keys to press to trigger dialog to continue =============================
;; Detect joystick
if (JoystickEnabled = 1)
{
  Loop 16  ; Query each joystick number to find out which ones exist.
    {
      GetKeyState, JoyName, %A_Index%JoyName
      if JoyName <>
      {
        JoystickNumber = %A_Index%
        break
      }
    }
    if JoystickNumber <= 0
    {
      MsgBox Could not find a valid joystick. Exiting.
      ExitApp
    }
}

KeyboardKeys := "Enter,Esc,Up,Down,Left,Right"

;; Maps 1Joy1, 1Joy2, etc for the correct controller number that was found.
loop 32
  JoystickKeys .= JoystickNumber . "Joy" . A_Index . ","

;=== Global vars we'll be using elsewhere ====================================
Global Overlay
Global Log
Global TranslateType
Global FontType
Global FontColor
Global DeepLAttempts
Global HideDeepL
Global ClipboardWaitTime
Global DeepLAPIEnable
Global DeepLAPIKey
Global JoystickEnabled
Global JoystickKeys
Global KeyboardKeys
Global Language
Global newOverlayWidth
Global newOverlayHeight
Global AutoHideOverlay
Global OverlayHeight
Global alteredOverlayWidth
Global DeepLApiPro

;=== Open overlay if enabled =================================================
if (Overlay = 1)
{
  overlayShow = 1
  alteredOverlayWidth := OverlayWidth - 50
  Gui, 2:Default
  Gui, Color, %OverlayColor%  ; Sets GUI background to black
  Gui, Font, s%FontSize% c%FontColor%, %FontType%
  Gui, Add, Text, +0x0 vClip h%OverlayHeight% w%alteredOverlayWidth% 
  Gui, Show, w%OverlayWidth% h%OverlayHeight% x%OverlayPosX% y%OverlayPosY%
  Winset, Transparent, %OverlayTransparency%, A
  Gui, +LastFound

  OnMessage(0x201,"WM_LBUTTONDOWN")  ; Allows dragging the window

  flags := "-caption +alwaysontop -Theme -DpiScale -Border "

  if (ResizeOverlay = 1)
    customFlags := "+Resize -MaximizeBox "

  if (ShowOnTaskbar = 0) 
    customFlags .= "+ToolWindow "
  else
    customFlags .= "-ToolWindow "

  Gui, % flags . customFlags

}

;=== Miscellaneous functions =================================================
WM_LBUTTONDOWN(wParam,lParam,msg,hwnd) {
  PostMessage, 0xA1, 2
  Gui, 2:Default
  WinGetPos, newOverlayX, newOverlayY, newOverlayWidth, newOverlayHeight, A
  GuiControl, MoveDraw, Clip, % "w" newOverlayWidth-31 "h" newOverlayHeight-38  ; Prefer redrawing on move rather than at the end as text gets distorted otherwise
  WinGetPos, newOverlayX, newOverlayY, newOverlayWidth, newOverlayHeight, A
  IniWrite, %newOverlayX%, settings.ini, overlay, OverlayPosX
  IniWrite, %newOverlayY%, settings.ini, overlay, OverlayPosY
}

;; Controller/Keyboard function to progress text
GetKeyPress(keyStr) {
  keys := StrSplit(keyStr, ",")
  loop
    for each, key in keys
      if GetKeyState(key)
      {
        KeyWait, %key%
        return key
      }
}

;=== Start DQ memread ========================================================
dqMemRead()

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
  return
}

;=== Activates OCR capture ===================================================
^Q::
{
  if (OCR = 1) {
    screenOCR()
  }
  return
}
