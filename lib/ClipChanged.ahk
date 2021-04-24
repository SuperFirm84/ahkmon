ClipChanged(Type) {
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
          cNewW := (W * .10)
          cNewH := (H * .20)

          ;; Remove foreign character from clipboard
          Clipboard := StrReplace(Clipboard, "「","")

          ;; Focus DeepL window
          SetControlDelay -1
          SetKeyDelay, 10, 10
          ControlFocus, Chrome_WidgetWin_01, DeepL
          ControlClick, Chrome_WidgetWin_01, DeepL,,,, NA x%cNewW% y%cNewH%
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
              if (A_Index > 25) {
                Gui, 2:Default
                Gui, Font, cYellow Bold, %FontType%
                GuiControl, Font, Clip
                GuiControl, Text, Clip, DeepL did not return a translation in time.
                Sleep 2000
                Gui, Font, c%FontColor%, %FontType%
                GuiControl, Font, Clip
                break
              }

              loading .= "."  ; Neat loading bar to let the user know translation is happening
              GuiControl, 2:Text, Clip, %loading%
              SetControlDelay -1
              ControlClick, Chrome_WidgetWin_01, DeepL,,,, NA x%cNewW% y%cNewH%
              ControlSend, Chrome_WidgetWin_01, {Tab}{Tab}{Enter}, DeepL
              ClipWait .4
            } Until Clipboard

            GuiControl, 2:Text, Clip, %Clipboard%
            logToFile("dq_dialog_translated.txt")
          }
          
          ; Re-focus DQX Window
          WinActivate, ahk_exe DQXGame.exe
        }
      }
    }
  }
}
