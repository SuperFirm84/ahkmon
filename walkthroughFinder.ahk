#NoEnv
#NoTrayIcon
#SingleInstance force
#Include <translate>
#Include <GetKeyPress>
#Include <classMemory>
#Include <SQLiteDB>
#Include <JSON>

SetBatchLines, -1

;; Don't let user run this script directly.
if A_Args.Length() < 1
{
    MsgBox Don't run this directly. Run ahkmon.exe instead.
    ExitApp
}

;=== Load Start GUI settings from file ======================================
IniRead, Language, settings.ini, general, Language, en
IniRead, Log, settings.ini, general, Log, 0
IniRead, ResizeOverlay, settings.ini, walkthroughoverlay, walkthroughResizeOverlay, 0
IniRead, RoundedOverlay, settings.ini, walkthroughoverlay, walkthroughRoundedOverlay, 0
IniRead, AutoHideOverlay, settings.ini, walkthroughoverlay, walkthroughAutoHideOverlay, 0
IniRead, ShowOnTaskbar, settings.ini, walkthroughoverlay, walkthroughShowOnTaskbar, 0
IniRead, OverlayWidth, settings.ini, walkthroughoverlay, walkthroughOverlayWidth, 930
IniRead, OverlayHeight, settings.ini, walkthroughoverlay, walkthroughOverlayHeight, 150
IniRead, OverlayColor, settings.ini, walkthroughoverlay, walkthroughOverlayColor, 000000
IniRead, FontColor, settings.ini, walkthroughoverlay, walkthroughFontColor, White
IniRead, FontSize, settings.ini, walkthroughoverlay, walkthroughFontSize, 16
IniRead, FontType, settings.ini, walkthroughoverlay, walkthroughFontType, Arial
IniRead, OverlayPosX, settings.ini, walkthroughoverlay, walkthroughOverlayPosX, 0
IniRead, OverlayPosY, settings.ini, walkthroughoverlay, walkthroughOverlayPosY, 0
IniRead, OverlayTransparency, settings.ini, walkthroughoverlay, walkthroughOverlayTransparency, 255
IniRead, DeepLApiPro, settings.ini, deepl, DeepLApiPro, 0
IniRead, DeepLAPIKey, settings.ini, deepl, DeepLAPIKey, EMPTY

;; === Global vars we'll be using elsewhere ==================================
Global Log
Global DeepLAPIKey
Global Language
Global DeepLApiPro

;; === Walkthrough text =====================================================
walkthroughAddress := 0x01EB9B04
walkthroughOffsets := [0x4, 0x2C, 0xC, 0x84, 0x16C, 0xCFC]

;== Save overlay POS when moved =============================================
WM_LBUTTONDOWN(wParam,lParam,msg,hwnd) {
  PostMessage, 0xA1, 2
  Gui, Default
  WinGetPos, newOverlayX, newOverlayY, newOverlayWidth, newOverlayHeight, A
  GuiControl, MoveDraw, Overlay, % "w" newOverlayWidth-31 "h" newOverlayHeight-38  ;; Prefer redrawing on move rather than at the end as text gets distorted otherwise
  WinGetPos, newOverlayX, newOverlayY, newOverlayWidth, newOverlayHeight, A
  IniWrite, %newOverlayX%, settings.ini, walkthroughoverlay, walkthroughOverlayPosX
  IniWrite, %newOverlayY%, settings.ini, walkthroughoverlay, walkthroughOverlayPosY
}

;=== Open overlay ============================================================
overlayShow = 1
alteredOverlayWidth := OverlayWidth - 37
Gui, Default
Gui, Color, %OverlayColor%  ; Sets GUI background to user's color
Gui, Font, s%FontSize% c%FontColor%, %FontType%
Gui, Add, Link, +0x0 vOverlay h%OverlayHeight% w%alteredOverlayWidth%
Gui, Show, w%OverlayWidth% h%OverlayHeight% x%OverlayPosX% y%OverlayPosY%
Winset, Transparent, %OverlayTransparency%, A

if (RoundedOverlay = 1)
{
  WinGetPos, X, Y, W, H, A
  WinSet, Region, R30-30 w%W% h%H% 0-0, A
}

Gui, +LastFound
Gui, Hide

OnMessage(0x201,"WM_LBUTTONDOWN")  ;; Allows dragging the window

flags := "-caption +alwaysontop -Theme -DpiScale -Border "

if (ResizeOverlay = 1)
  customFlags := "+Resize -MaximizeBox "

if (ShowOnTaskbar = 0) 
  customFlags .= "+ToolWindow "
else
  customFlags .= "-ToolWindow "

Gui, % flags . customFlags
;=== End overlay =============================================================
loop
{
  Process, Exist, DQXGame.exe
  if ErrorLevel
  {
    if !dqx.isHandleValid()
    {
      dqx := new _ClassMemory("ahk_exe DQXGame.exe", "", hProcessCopy)
      baseAddress := dqx.getProcessBaseAddress("ahk_exe DQXGame.exe")
    }

    ;; Start searching for text.
    loop
    {
      newWalkthrough := dqx.readString(baseAddress + walkthroughAddress, sizeBytes := 0, encoding := "utf-8", walkthroughOffsets*)

      if (newWalkthrough != "")
        if (lastWalkthrough != newWalkthrough)
        {
          GuiControl, Text, Overlay, ...
          Gui, Show
          walkthroughText := translate(newWalkthrough, "false")
          GuiControl, Text, Overlay, %walkthroughText%

          Loop {
            lastWalkthrough := dqx.readString(baseAddress + walkthroughAddress, sizeBytes := 0, encoding := "utf-8", walkthroughOffsets*)
            Sleep 250
          }
          Until (lastWalkthrough != newWalkthrough)
        }
      else
      {
        if (AutoHideOverlay = 1)
          Gui, Hide

        GuiControl, Text, Overlay,
      }

      if (AutoHideOverlay = 1)
        Gui, Hide

      GuiControl, Text, Overlay,

      lastWalkthrough := newWalkthrough
      Sleep 250

      ;; Exit app if DQX closed
      Process, Exist, DQXGame.exe
      if !ErrorLevel
        ExitApp

      ;; Exit app if ahkmon is closed
      Process, Exist, ahkmon.exe
      If !ErrorLevel
        ExitApp
    }
  }

  ;; Keep looking for a DQXGame.exe process
  else
  sleep 2000
}
