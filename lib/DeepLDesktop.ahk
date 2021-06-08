DeepLDesktop(dqDialogText)
{
  Process, Exist, DeepL.exe
  if ErrorLevel
  {
    ;; Check if user has DeepL minimized. If so, open it and send it to the back of the z-axis.
    ;; If it's in the system tray and not open, alert the user and exit the app. Re-activating
    ;; the window doesn't work with DeepL - you just get a permanent black box until you relaunch.
    Gui, 2:Default
    WinActivate, ahk_exe DeepL.exe
    if !WinActive("ahk_exe DeepL.exe")
    {
      MsgBox DeepL is in your system tray, but not your taskbar, which makes it impossible for us to talk to it.`n`nOpen DeepL from the system tray and ensure it isn't minimized and try again.`n`nExiting app.
      ExitApp
    }
    else
      WinActivate, ahk_exe DQXGame.exe

    WinGet, DeepLWindowState, MinMax, DeepL
    if (DeepLWindowState == -1)
    {
      WinRestore, DeepL
      WinActivate, ahk_exe DeepL.exe
      sleep 50
      WinSet, Bottom,,A
    }

    ;; If HideDeepL enabled, moves the window completely off the screen so that it doesn't pop up
    ;; for the user during translations.
    if (HideDeepL = 1)
      WinMove, DeepL,, -2000, -2000

    ;; Open database connection
    dbFileName := A_ScriptDir . "\dqxtrl.db"
    db := New SQLiteDB

    ;; Show overlay if AutoHideOverlay enabled
    if (AutoHideOverlay = 1)
      Gui, Show, NA

    fullDialog := 
    for index, sentence in StrSplit(dqDialogText, "`n`n", "`r")
    {
      ;; See if we have an entry available to grab from before sending the request to DeepL.
      result :=
      query := "SELECT " . Language . " FROM dialog WHERE jp = '" . sentence . "';"

      if db.OpenDB(dbFileName)
      if db.GetTable(query, result)

      result := result.Rows[1,1]

      ;; If no matching line was found in the database, query DeepL.
      if !result
      {
        ;; Get the full window's position as user could have resized
        ;; DPI scaling can mess up hardcoded coords, so multiply where
        ;; to move.
        WinGetPos, X, Y, W, H, DeepL
        cNewW := (W * .20)
        cNewH := (H * .23)

        Clipboard := sentence

        ;; Interact with DeepL window to send Japanese text
        SetControlDelay -1
        SetKeyDelay, 10, 10
        WinGetClass, class, DeepL
        ControlClick, x%cNewW% y%cNewH%, ahk_class %class%,,,, Pos
        ControlSend, Chrome_WidgetWin_01, ^a, ahk_class %class%
        ControlSend, Chrome_WidgetWin_01, {Backspace}, ahk_class %class%
        Sleep 100
        ControlSend, Chrome_WidgetWin_01, ^v, ahk_class %class%

        ;; Clear clipboard so we know when it changes
        Clipboard =
        sleep 100

        Loop
        {
          ;; If DeepL takes too long to return a translation, time the attempt out.
          if (A_Index > 15)
          {
            Gui, Font, cYellow Bold, %FontType%
            GuiControl, Font, Clip
            GuiControl, Text, Clip, DeepL did not return a translation in time.
            Sleep 2000
            Gui, Font, c%FontColor% Norm, %FontType%
            GuiControl, Font, Clip
            break
          }

          ;; If the clipboard is in use, force whatever has it to let go
          if (DllCall("OpenClipboard", Ptr,A_ScriptHwnd))
            DllCall("CloseClipboard")

          ;; Click in the top left corner of DeepL to reset our tab position
          ControlClick, x%cNewW% y%cNewH%, ahk_class %class%,,,, NA 
          ControlSend, Chrome_WidgetWin_01, {Tab}, ahk_class %class%
          ControlSend, Chrome_WidgetWin_01, {Tab}, ahk_class %class%
          ControlSend, Chrome_WidgetWin_01, {Enter}, ahk_class %class%
          Sleep 300
          clipboardContents := Clipboard
        } Until clipboardContents

        if (ShowFullDialog = 1)
        {
          fullDialog .= clipboardContents "`n`n"
          GuiControl, Text, Clip, %fullDialog%
        }
        else
        {
          GuiControl, Text, Clip, %clipboardContents%
        }
      }

      ;; If we found a result in the database, use that instead
      else
      {
        if (ShowFullDialog = 1)
        {
          fullDialog .= result "`n`n"
          GuiControl, Text, Clip, %fullDialog%
        }
        else
        {
          GuiControl, Text, Clip, %result%
        }
      }

      if (ShowFullDialog != 1)
      {
        ;; Determine whether to listen for joystick or keyboard keys to continue the dialog.
        if (JoystickEnabled = 1)
        {
          WinActivate, ahk_class AutoHotkeyGUI
          Input := GetKeyPress(JoystickKeys)
        }
        else
        {
          Input := GetKeyPress(KeyboardKeys)
        }
      }

      if (Log = 1)
        FileAppend, JP: %sentence%`nEN: %clipboardContents%`n`n, txtout.txt, UTF-8
    }

    ;; Close database connection
    db.CloseDB()

    ;; Re-focus DQX Window
    WinActivate, ahk_exe DQXGame.exe
    return
  }

  else
    msgBox Unable to locate DeepL Translate. Make sure it's installed and running, then try again.`n`nExiting app.
    ExitApp
}
