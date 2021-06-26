#Persistent
#NoEnv
#SingleInstance force
#Include <DeepLDesktop>
#Include <DeepLAPI>
#Include <JSON>
#Include <SQLiteDB>
SendMode Input

;=== Close any existing finder windows ======================================
Process, Close, questFinder.exe
Process, Close, dialogFinder.exe

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
IniRead, JoystickEnabled, settings.ini, general, JoystickEnabled, 0
IniRead, dialogResizeOverlay, settings.ini, dialogoverlay, dialogResizeOverlay, 0
IniRead, dialogRoundedOverlay, settings.ini, dialogoverlay, dialogRoundedOverlay, 1
IniRead, dialogAutoHideOverlay, settings.ini, dialogoverlay, dialogAutoHideOverlay, 0
IniRead, dialogShowOnTaskbar, settings.ini, dialogoverlay, dialogShowOnTaskbar, 0
IniRead, dialogOverlayWidth, settings.ini, dialogoverlay, dialogOverlayWidth, 930
IniRead, dialogOverlayHeight, settings.ini, dialogoverlay, dialogOverlayHeight, 150
IniRead, dialogOverlayColor, settings.ini, dialogoverlay, dialogOverlayColor, 000000
IniRead, dialogFontColor, settings.ini, dialogoverlay, dialogFontColor, White
IniRead, dialogFontSize, settings.ini, dialogoverlay, dialogFontSize, 16
IniRead, dialogFontType, settings.ini, dialogoverlay, dialogFontType, Arial
IniRead, dialogOverlayPosX, settings.ini, dialogoverlay, dialogOverlayPosX, 0
IniRead, dialogOverlayPosY, settings.ini, dialogoverlay, dialogOverlayPosY, 0
IniRead, dialogOverlayTransparency, settings.ini, dialogoverlay, dialogOverlayTransparency, 255
IniRead, questResizeOverlay, settings.ini, questoverlay, questResizeOverlay, 0
IniRead, questRoundedOverlay, settings.ini, questoverlay, questRoundedOverlay, 1
IniRead, questAutoHideOverlay, settings.ini, questoverlay, questAutoHideOverlay, 0
IniRead, questShowOnTaskbar, settings.ini, questoverlay, questShowOnTaskbar, 0
IniRead, questOverlayWidth, settings.ini, questoverlay, questOverlayWidth, 930
IniRead, questOverlayHeight, settings.ini, questoverlay, questOverlayHeight, 150
IniRead, questOverlayColor, settings.ini, questoverlay, questOverlayColor, 000000
IniRead, questFontColor, settings.ini, questoverlay, questFontColor, White
IniRead, questFontSize, settings.ini, questoverlay, questFontSize, 16
IniRead, questFontType, settings.ini, questoverlay, questFontType, Arial
IniRead, questOverlayPosX, settings.ini, questoverlay, questOverlayPosX, 0
IniRead, questOverlayPosY, settings.ini, questoverlay, questOverlayPosY, 0
IniRead, questOverlayTransparency, settings.ini, questoverlay, questOverlayTransparency, 255
IniRead, ShowFullDialog, settings.ini, advanced, ShowFullDialog, 0
IniRead, HideDeepL, settings.ini, advanced, HideDeepL, 0
IniRead, DeepLAPIEnable, settings.ini, deepl, DeepLAPIEnable, 0
IniRead, DeepLApiPro, settings.ini, deepl, DeepLApiPro, 0
IniRead, DeepLAPIKey, settings.ini, deepl, DeepLAPIKey, EMPTY

;=== Create Start GUI =====================================================
Gui, 1:Default
Gui, Font, s10, Segoe UI
Gui, Add, Tab3,, General|Dialog Overlay|Quest Overlay|Advanced|DeepL API|Help|About
Gui, Add, Link,, <a href="https://github.com/jmctune/ahkmon/wiki/General-tab">General Settings Documentation</a>
Gui, Add, Text,, ahkmon: Automate your DQX text translation.
Gui, Add, Picture, w375 h206, imgs/dqx_logo.png
Gui, Add, Link,, Language you want to translate text to:`n<a href="https://www.andiamo.co.uk/resources/iso-language-codes/">Regional Codes</a>
Gui, Add, DDL, vLanguage, %Language%||bg|cs|da|de|el|en|es|et|fi|fr|hu|it|lt|lv|nl|pl|pt|ro|ru|sk|sl|sv|zh
Gui, Add, CheckBox, vLog Checked%Log%, Enable logging to file?
Gui, Add, CheckBox, vJoystickEnabled Checked%JoystickEnabled%, Do you play with a controller?
Gui, Add, Button, gSave, Run ahkmon

;; Dialog Overlay settings tab
Gui, Tab, Dialog Overlay
Gui, Add, Link,, <a href="https://github.com/jmctune/ahkmon/wiki/Overlay-Settings-tab">Dialog Overlay Documentation</a>
Gui, Add, CheckBox, vdialogResizeOverlay Checked%dialogResizeOverlay%, Allow resize of Dialog overlay?
Gui, Add, CheckBox, vdialogRoundedOverlay Checked%dialogRoundedOverlay%, Rounded Dialog overlay?
Gui, Add, CheckBox, vdialogAutoHideOverlay Checked%dialogAutoHideOverlay%, Automatically hide Dialog overlay?
Gui, Add, CheckBox, vdialogShowOnTaskbar Checked%dialogShowOnTaskbar%, Show Dialog overlay on taskbar when active?
Gui, Add, Text,, Dialog overlay transparency (lower = more transparent):
Gui, Add, Slider, vdialogOverlayTransparency Range10-255 TickInterval3 Page3 Line3 Tooltip, %dialogOverlayTransparency%
Gui, Add, Text, vdialogOverlayColorInfo, Dialog overlay background color (use hex color codes):
Gui, Add, ComboBox, vdialogOverlayColor, %dialogOverlayColor%||
Gui, Add, Text, vdialogOverlayWidthInfo, Initial Dialog overlay width:
Gui, Add, Edit
Gui, Add, UpDown, vdialogOverlayWidth Range100-2000, %dialogOverlayWidth%
Gui, Add, Text, vdialogOverlayHeightInfo, Initial Dialog overlay height:
Gui, Add, Edit
Gui, Add, UpDown, vdialogOverlayHeight Range100-2000, %dialogOverlayHeight%
Gui, Add, Text, vdialogFontColorInfo, Dialog overlay font color:
Gui, Add, ComboBox, vdialogFontColor, %dialogFontColor%||Yellow|Red|Green|Blue|Black|Gray|Maroon|Purple|Fuchsia|Lime|Olive|Navy|Teal|Aqua
Gui, Add, Text,, Dialog overlay font size:
Gui, Add, Edit
Gui, Add, UpDown, vdialogFontSize Range8-30, %dialogFontSize%
Gui, Add, Text, vdialogFontInfo, Select a font or enter a custom font available`non your system to use with the Dialog overlay:
Gui, Add, ComboBox, vdialogFontType, %dialogFontType%||Calibri|Consolas|Courier New|Inconsolata|Segoe UI|Tahoma|Times New Roman|Trebuchet MS|Verdana

;; Quest Overlay settings tab
Gui, Tab, Quest Overlay
Gui, Add, Link,, <a href="https://github.com/jmctune/ahkmon/wiki/Overlay-Settings-tab">Quest Overlay Documentation</a>
Gui, Add, CheckBox, vquestResizeOverlay Checked%questResizeOverlay%, Allow resize of Quest overlay?
Gui, Add, CheckBox, vquestRoundedOverlay Checked%questRoundedOverlay%, Rounded Quest overlay?
Gui, Add, CheckBox, vquestAutoHideOverlay Checked%questAutoHideOverlay%, Automatically hide Quest overlay?
Gui, Add, CheckBox, vquestShowOnTaskbar Checked%questShowOnTaskbar%, Show Quest overlay on taskbar when active?
Gui, Add, Text,, Quest overlay transparency (lower = more transparent):
Gui, Add, Slider, vquestOverlayTransparency Range10-255 TickInterval3 Page3 Line3 Tooltip, %questOverlayTransparency%
Gui, Add, Text, vquestOverlayColorInfo, Quest overlay background color (use hex color codes):
Gui, Add, ComboBox, vquestOverlayColor, %questOverlayColor%||
Gui, Add, Text, vquestOverlayWidthInfo, Initial Quest overlay width:
Gui, Add, Edit
Gui, Add, UpDown, vquestOverlayWidth Range100-2000, %questOverlayWidth%
Gui, Add, Text, vquestOverlayHeightInfo, Initial Quest overlay height:
Gui, Add, Edit
Gui, Add, UpDown, vquestOverlayHeight Range100-2000, %questOverlayHeight%
Gui, Add, Text, vquestFontColorInfo, Quest overlay font color:
Gui, Add, ComboBox, vquestFontColor, %questFontColor%||Yellow|Red|Green|Blue|Black|Gray|Maroon|Purple|Fuchsia|Lime|Olive|Navy|Teal|Aqua
Gui, Add, Text,, Quest overlay font size:
Gui, Add, Edit
Gui, Add, UpDown, vquestFontSize Range8-30, %questFontSize%
Gui, Add, Text, vquestFontInfo, Select a font or enter a custom font available`non your system to use with the Quest overlay:
Gui, Add, ComboBox, vquestFontType, %questFontType%||Calibri|Consolas|Courier New|Inconsolata|Segoe UI|Tahoma|Times New Roman|Trebuchet MS|Verdana

;; Advanced tab
Gui, Tab, Advanced
Gui, Add, Link,, <a href="https://github.com/jmctune/ahkmon/wiki/Advanced-tab">Advanced Settings Documentation</a>
Gui, Add, Text,, This tab is for users that struggle with the default settings.
Gui, Add, CheckBox, vShowFullDialog Checked%ShowFullDialog%, Show all text at once instead of line by line?
Gui, Add, CheckBox, vHideDeepL Checked%HideDeepL%, Hide DeepL?
Gui, Add, Button, gResetDeepLPosition, Reset DeepL Position
Gui, Add, Text, w+300 vLogLink, 
Gui, Add, Text,, Download latest database`n(this will overwrite your current database!)
Gui, Add, Button, gDownloadDb, Download Database
Gui, Add, Text, w+300 vDatabaseStatusMessage,

;; DeepL API tab
Gui, Tab, DeepL API
Gui, Add, Link,, <a href="https://github.com/jmctune/ahkmon/wiki/DeepL-API-tab">DeepL API Documentation</a>
Gui, Add, Text,, This section is for those who created a DeepL API account.`n`nThis allows you to use ahkmon without the DeepL desktop`nclient, while instead, interacting directly with DeepL's API.`n`nNote that signing up for a DeepL API account`nrequires a valid credit card.
Gui, Add, Link,, <a href="https://www.deepl.com/pro#developer">Sign up for a FREE DeepL Developer API account here</a>
Gui, Add, CheckBox, vDeepLAPIEnable Checked%DeepLAPIEnable%, Enable DeepL API Requests?`n(You signed up for a`nfree DeepL Developer API account)
Gui, Add, CheckBox, vDeepLApiPro Checked%DeepLApiPro%, Use DeepL API Pro APIs?`n(You paid for DeepL)
Gui, Add, Text,, DeepL API Key (Found in your account page):
Gui, Add, Text, y+2 cRed, DO NOT SHARE THIS KEY WITH ANYONE
Gui, Add, Edit, r1 vDeepLAPIKey w135, %DeepLAPIKey%
Gui, Add, Button, gDeepLWordsLeft, Check remaining character count
Gui, Add, Text, w+300 vDeepLWords, 

;; Help tab
Gui, Tab, Help
Gui, Add, Link,, <a href="https://github.com/jmctune/ahkmon/wiki/Troubleshooting">Troubleshooting ahkmon</a>

;; About tab
Gui, Tab, About
Gui, Add, Link,, Join the unofficial Dragon Quest X <a href="https://discord.gg/UFaUHBxKMY">Discord</a>!
Gui, Add, Link,, <a href="https://github.com/jmctune/ahkmon">Get the Source</a>
Gui, Add, Link,, <a href="https://github.com/jmctune/ahkmon/wiki">Documentation</a>
Gui, Add, Link,, Like what I'm doing? <a href="https://www.paypal.com/paypalme/supportjmct">Donate :P</a>
Gui, Add, Text,, Catch me on Discord: mebo#1337
Gui, Add, Text,, Made by Serany <3

;=== Misc Start GUI =======================================================
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

DownloadDb:
  UrlDownloadToFile, https://github.com/jmctune/ahkmon/raw/main/dqxtrl.db, dqxtrl.db
  if ErrorLevel
    GuiControl, Text, DatabaseStatusMessage, Database failed to update.
  else
    GuiControl, Text, DatabaseStatusMessage, Database updated!
  return

ResetDeepLPosition:
  WinMove, DeepL,, 0, 0
  return

;; What to do when the app is gracefully closed
GuiEscape:
GuiClose:
{
  Process, Close, dialogFinder.exe
  Process, Close, questFinder.exe
  ExitApp
}

;=== Save Start GUI settings to ini ==========================================
Save:
  Gui, Submit, Hide
  IniWrite, %Language%, settings.ini, general, Language
  IniWrite, %Log%, settings.ini, general, Log
  IniWrite, %ShowOnTaskbar%, settings.ini, overlay, ShowOnTaskbar
  IniWrite, %JoystickEnabled%, settings.ini, general, JoystickEnabled
  IniWrite, %dialogOverlayWidth%, settings.ini, dialogoverlay, dialogOverlayWidth
  IniWrite, %dialogRoundedOverlay%, settings.ini, dialogoverlay, dialogRoundedOverlay
  IniWrite, %dialogOverlayHeight%, settings.ini, dialogoverlay, dialogOverlayHeight
  IniWrite, %dialogOverlayColor%, settings.ini, dialogoverlay, dialogOverlayColor
  IniWrite, %dialogResizeOverlay%, settings.ini, dialogoverlay, dialogResizeOverlay
  IniWrite, %dialogAutoHideOverlay%, settings.ini, dialogoverlay, dialogAutoHideOverlay
  IniWrite, %dialogFontColor%, settings.ini, dialogoverlay, dialogFontColor
  IniWrite, %dialogFontSize%, settings.ini, dialogoverlay, dialogFontSize
  IniWrite, %dialogFontType%, settings.ini, dialogoverlay, dialogFontType
  IniWrite, %dialogOverlayTransparency%, settings.ini, dialogoverlay, dialogOverlayTransparency
  IniWrite, %questOverlayWidth%, settings.ini, questoverlay, questOverlayWidth
  IniWrite, %questRoundedOverlay%, settings.ini, questoverlay, questRoundedOverlay
  IniWrite, %questOverlayHeight%, settings.ini, questoverlay, questOverlayHeight
  IniWrite, %questOverlayColor%, settings.ini, questoverlay, questOverlayColor
  IniWrite, %questResizeOverlay%, settings.ini, questoverlay, questResizeOverlay
  IniWrite, %questAutoHideOverlay%, settings.ini, questoverlay, questAutoHideOverlay
  IniWrite, %questFontColor%, settings.ini, questoverlay, questFontColor
  IniWrite, %questFontSize%, settings.ini, questoverlay, questFontSize
  IniWrite, %questFontType%, settings.ini, questoverlay, questFontType
  IniWrite, %questOverlayTransparency%, settings.ini, questoverlay, questOverlayTransparency
  IniWrite, %ShowFullDialog%, settings.ini, advanced, ShowFullDialog
  IniWrite, %HideDeepL%, settings.ini, advanced, HideDeepL
  IniWrite, %DeepLAPIEnable%, settings.ini, deepl, DeepLAPIEnable
  IniWrite, %DeepLApiPro%, settings.ini, deepl, DeepLApiPro
  IniWrite, %DeepLAPIKey%, settings.ini, deepl, DeepLAPIKey

;=== Globals =================================================================
Global DeepLAPIEnable
Global Log

;=== Start DQ memreads =======================================================
;; Pass arbitrary arg. Don't want user to run these directly.
Run, questFinder.exe "nothing"
Sleep 500  ;; Give questfinder a chance to start up its overlay stuff before adding dialogFinder
Run, dialogFinder.exe "nothing"
