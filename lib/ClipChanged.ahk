ClipChanged(Type) {

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

            ;; Get the full window's position as user could have resized
            ;; DPI scaling can mess up hardcoded coords, so multiply where
            ;; to move.
            WinGetPos, X, Y, W, H, DeepL
            cNewW := (W * .20)
            cNewH := (H * .23)

            ;; Remove foreign character from clipboard
            Clipboard := StrReplace(Clipboard, "「","")

            ;; Focus DeepL window
            SetControlDelay -1
            SetKeyDelay, 10, 10
            ControlFocus, Chrome_WidgetWin_01, DeepL
            ControlClick, x%cNewW% y%cNewH%, DeepL,,,, Pos
            ControlSend, Chrome_WidgetWin_01, ^a, DeepL
            ControlSend, Chrome_WidgetWin_01, {Backspace}, DeepL
            ControlSend, Chrome_WidgetWin_01, ^v, DeepL

            ;; Write clipboard contents to file if logging is enabled
            logToFile("dq_dialog_jp.txt")

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

              logToFile("dq_dialog_translated.txt")

              Keys := "Joy1,Joy2,Joy3,Joy4,Joy5,Joy6,Joy7,Joy8,Joy9,Joy10,Joy11,Joy12,Joy13,Joy14,Joy15,Joy16,Enter,Esc,Up,Down,Left,Right"

              if (LineByLineDialog = 1) {
                for index, sentence in StrSplit(Clipboard, "`n`n") {
                    GuiControl, 2:Text, Clip, %sentence%
                    Input := GetKeyPress(Keys)
                }
              }

              else {
                GuiControl, 2:Text, Clip, %Clipboard%
              }
            }
  
            ;; Re-focus DQX Window
            WinActivate, ahk_exe DQXGame.exe

            ;; Some users were experiencing infinite clipboard copy loops on slower machines,
            ;; so this sleep stops that from happening. 
            Sleep 300
            Return
          }
        }
      }
    }
  }
}
