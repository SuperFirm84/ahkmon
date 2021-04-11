#Persistent
#NoEnv
#SingleInstance force
SendMode Input

OnClipboardChange("ClipChanged")
return

ClipChanged(Type) {
    if WinActive("ahk_exe DQXGame.exe") {
        Process, Exist, DeepL.exe

        if ErrorLevel {
            Process, Exist, DQXGame.exe

            if ErrorLevel {
                Process, Exist, DQ10Dialog.exe

                if ErrorLevel {
                    ; Focus DeepL window
                    WinActivate, ahk_exe DeepL.exe

                    ; Get the full window's position as user could have resized
                    WinGetPos, X, Y, W, H, DeepL

                    ; Take WxH and get new coords for the translated window.
                    ; Gets coords 25% into the window
                    tNewW := (W * .75)
                    tNewH := (H * .75)

                    ; DeepL tries to give suggestions when you click into the
                    ; translated window, so we click out of it to remove
                    ; the suggestion box.
                    cNewW := (W * .98)
                    cNewH := (H * .98)

                    ; Virtually click the mouse in the DeepL translation window 
                    ; (don't physically move it)
                    SetControlDelay -1
                    ControlClick x150 y275, DeepL

                    ; Remove any existing text in the translation box before
                    ; pressing Ctrl+V to paste
                    Send, ^a{BackSpace}
                    Send, {Ctrl Down}v{Ctrl Up}

                    ; Write clipboard contents to file
                    FormatTime, TimeString,, [dd-MM-yyyy] [HH:mm]
                    FileAppend, %TimeString% %clipboard%`n`n, dq_dialog_jp.txt, UTF-16

                    ; DeepL sometimes pauses for a bit when you paste, so give it
                    ; time to realize what we just did so the paste gets into the
                    ; box. Have also seen incomplete pastes when tuning this lower
                    Sleep 750

                    ; Copy translated text to clipboard and send to file
                    SetControlDelay -1
                    ControlClick x%tNewW% y%tNewH%, DeepL
                    Send, {Ctrl Down}a{Ctrl Up}
                    Send, {Ctrl Down}c{Ctrl Up}
                    Sleep 250
                    FileAppend, %TimeString% %clipboard%`n`n, dq_dialog_translated.txt, UTF-16

                    ; Execute the click to remove the suggestion box
                    SetControlDelay -1
                    ControlClick x%cNewW% y%cNewH%, DeepL

                    ; Re-focus DQX Window
                    WinActivate, ahk_exe DQXGame.exe
                }
            }
        }
    }
}