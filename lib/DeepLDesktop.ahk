DeepLDesktop(Type) {

  ;; Don't run if clipboard does not contain text
  if DllCall("IsClipboardFormatAvailable", "uint", 1) {

    if (RequireFocus = 0) {
      keepGoing = 1
    }
    
    if (RequireFocus = 1) {
      if WinActive("ahk_exe DQXGame.exe") {
        keepGoing = 1
      }
    }

    if (keepGoing = 1) {
      Process, Exist, DeepL.exe

      if ErrorLevel {
        Process, Exist, DQXGame.exe

        if ErrorLevel {
          Process, Exist, DQ10Dialog.exe

          if ErrorLevel {

            ;; Get number of items we'll be iterating over. Using this at the end.
            numberOfClipboardItems := StrSplit(Clipboard, "`r`n`r`n")

            ;; Sanitize Clipboard
            Clipboard := StrReplace(Clipboard, "「","")

            ;; Open database connection
            dbFileName := A_ScriptDir . "\dqxtrl.db"
            db := New SQLiteDB

            for index, sentence in StrSplit(Clipboard, "`r`n`r`n") {

              ;; See if we have an entry available to grab from before sending the request to DeepL.
              result :=
              query := "SELECT " . Language . " FROM dialog WHERE jp = '" . sentence . "';"

              if !db.OpenDB(dbFileName)
                MsgBox, 16, SQLite Error, % "Msg:`t" . db.ErrorMsg . "`nCode:`t" . db.ErrorCode

              if !db.GetTable(query, result)
                MsgBox, 16, SQLite Error, % "Msg:`t" . db.ErrorMsg . "`nCode:`t" . db.ErrorCode

              result := result.Rows[1,1]

              ;; If no matching line was found in the database, query DeepL.
              if !result {

                ;; Get the full window's position as user could have resized
                ;; DPI scaling can mess up hardcoded coords, so multiply where
                ;; to move.
                WinGetPos, X, Y, W, H, DeepL
                cNewW := (W * .20)
                cNewH := (H * .23)

                Clipboard := sentence

                ;; Focus DeepL window
                SetControlDelay -1
                SetKeyDelay, 10, 10
                ControlFocus, Chrome_WidgetWin_01, DeepL
                ControlClick, x%cNewW% y%cNewH%, DeepL,,,, Pos
                ControlSend, Chrome_WidgetWin_01, ^a, DeepL
                ControlSend, Chrome_WidgetWin_01, {Backspace}, DeepL
                ControlSend, Chrome_WidgetWin_01, ^v, DeepL

                ;; If overlay or log is enabled
                if ((Overlay = 1) or (Log = 1)) {

                  ;; Clear clipboard so we know when it changes
                  Clipboard =

                  Loop {
                    
                    ;; If DeepL takes too long to return a translation, time the attempt out.
                    if (A_Index > DeepLAttempts) {
                      Gui, 2:Default
                      Gui, Font, cYellow Bold, %FontType%
                      GuiControl, Font, Clip
                      GuiControl, Text, Clip, DeepL did not return a translation in time.
                      Sleep 2000
                      Gui, Font, c%FontColor% Norm, %FontType%
                      GuiControl, Font, Clip
                      break
                    }

                    loading .= "."  ; Neat loading bar to let the user know translation is happening
                    GuiControl, 2:Text, Clip, %loading%
                    SetControlDelay -1
                    ControlClick, x%cNewW% y%cNewH%, DeepL,,,, Pos
                    ControlSend, Chrome_WidgetWin_01, {Tab}, DeepL
                    ControlSend, Chrome_WidgetWin_01, {Tab}, DeepL
                    ControlSend, Chrome_WidgetWin_01, {Enter}, DeepL
                    ClipWait .6
                  } Until Clipboard

                  ;; Reset loading bar
                  loading :=

                  ;; Write translated text to overlay
                  GuiControl, 2:Text, Clip, %Clipboard%

                  if (Log = 1)
                    FileAppend, %sentence%||%Clipboard%`n, textdb.out, UTF-16
                }
              }

              else {
                GuiControl, 2:Text, Clip, %result%
              }

              ;; Determine whether to listen for joystick or keyboard keys
              ;; to continue the dialog
              if numberOfClipboardItems.Count() > 1 {
                if (JoystickEnabled = 1) {
                  Input := GetKeyPress(JoystickKeys)
                }
                else {
                  Input := GetKeyPress(KeyboardKeys)
                }
              }
            }

            ;; Close database connection
            db.CloseDB()

            ; Re-focus DQX Window
            WinActivate, ahk_exe DQXGame.exe

            ; Some users were experiencing infinite clipboard copy loops on slower machines,
            ; so this sleep stops that from happening. 
            Sleep 300
            Return
          }
        }
      }
    }
  }
}
