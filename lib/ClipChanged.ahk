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
          
          ;; Focus DeepL window
          WinActivate, ahk_exe DeepL.exe
          WinWaitActive, ahk_exe DeepL.exe

          ;; Get the full window's position as user could have resized
          WinGetPos, X, Y, W, H, DeepL

          ;; Take WxH and get new coords by % for the translated window.
          tNewW := (W * .50)
          tNewH := (H * .75)

          ;; Take WxH and get new coords by % for the copied window.
          cNewW := (W * .20)
          cNewH := (H * .20)

          ;; Virtually click the mouse in the DeepL translation window 
          ;; (don't physically move it)
          SetControlDelay -1
          ControlClick x%cNewW% y%cNewH%, ahk_exe DeepL.exe

          ;; Remove foreign character from clipboard
          Clipboard := StrReplace(Clipboard, "「","")

          ;; Remove any existing text in the translation box before
          ;; pressing Ctrl+V to paste
          Send, {Ctrl Down}a{Ctrl Up}
          Send, {Ctrl Down}v{Ctrl Up}

          ;; Write clipboard contents to file if logging is enabled
          logToFile("dq_dialog_jp.txt")

          ;; DeepL sometimes pauses for a bit when you paste, so give it
          ;; time to realize what we just did so the paste gets into the
          ;; box. Have also seen incomplete pastes when tuning this lower
          Sleep 1000

          if ((Overlay = 1) or (Log = 1)) {
            ;; Get the full window's position as user could have resized
            WinGetPos, X, Y, W, H, DeepL

            ;; Take WxH and get new coords by % for the translated window.
            tNewW := (W * .50)
            tNewH := (H * .70)

            ;; Click in the translated box and copy to clipboard + log
            SetControlDelay -1
            ControlClick x%cNewW% y%cNewH%, ahk_exe DeepL.exe
            Send, {Tab}

            ;; Clear the clipboard. We do this because logToFile sometimes
            ;; pastes the Japanese text into the translated log file. We
            ;; wait up to 1 second for the system to realize the clipboard
            ;; contents have changed.
            Clipboard := ""
            Send, {Ctrl Down}a{Ctrl Up}
            Sleep 50
            Send, {Ctrl Down}c{Ctrl Up}
            Send, {Tab}{Tab}
            ClipWait, 1
            GuiControl,2:Text, Clip, %Clipboard%
            logToFile("dq_dialog_translated.txt")
          }
          
          ; Re-focus DQX Window
          WinActivate, ahk_exe DQXGame.exe
        }
      }
    }
  }
}