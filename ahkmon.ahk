#Persistent
#NoEnv
#SingleInstance force
SendMode Input

; Create GUI to toggle features on/off
Gui, New, AlwaysOnTop, ahkmon
Gui Font, s10, Segoe UI
Gui, Add, CheckBox, vLog, Enable logging to file?
Gui, Add, Button, gSend, Run ahkmon
Gui, Show, w200 h75
Return

GuiEscape:
GuiClose:
    ExitApp

Send:
Gui, Submit, Hide

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
                    WinWaitActive, ahk_exe DeepL.exe

                    ; Get the full window's position as user could have resized
                    WinGetPos, X, Y, W, H, DeepL

                    ; Take WxH and get new coords by % for the translated window.
                    tNewW := (W * .50)
                    tNewH := (H * .75)

                    ; Take WxH and get new coords by % for the copied window.
                    cNewW := (W * .20)
                    cNewH := (H * .20)

                    ; Virtually click the mouse in the DeepL translation window 
                    ; (don't physically move it)
                    SetControlDelay -1
                    ControlClick x%cNewW% y%cNewH%, ahk_exe DeepL.exe

                    ; Remove foreign character from clipboard
                    Clipboard := StrReplace(Clipboard, "「","")

                    ; Remove any existing text in the translation box before
                    ; pressing Ctrl+V to paste
                    Send, {Ctrl Down}a{Ctrl Up}
                    Send, {BackSpace}
                    Send, {Ctrl Down}v{Ctrl Up}
                    Sleep 250

                    ; Write clipboard contents to file if logging is enabled
                    LogToFile("dq_dialog_jp.txt")

                    ; DeepL sometimes pauses for a bit when you paste, so give it
                    ; time to realize what we just did so the paste gets into the
                    ; box. Have also seen incomplete pastes when tuning this lower
                    Sleep 750

                    ; If logging is enabled, also log the translated text to file
                    Global Log
                    if (Log = 1) {

	                    ; Get the full window's position as user could have resized
	                    WinGetPos, X, Y, W, H, DeepL

	                    ; Take WxH and get new coords by % for the translated window.
	                    tNewW := (W * .50)
	                    tNewH := (H * .70)

	                    ; Click in the translated box and copy to clipboard + log
	                    SetControlDelay -1
	                    ControlClick x%tNewW% y%tNewH%, ahk_exe DeepL.exe
                        Send, {Ctrl Down}a{Ctrl Up}
                        Sleep 50
                        Send, {Ctrl Down}c{Ctrl Up}
                        Sleep 50
                        Send, {Tab}{Tab}
                        LogToFile("dq_dialog_translated.txt")
                    }
                    
                    ; Re-focus DQX Window
                    WinActivate, ahk_exe DQXGame.exe
                }
            }
        }
    }
}

LogToFile(logFile) {
    Global Log
    if (Log = 1) {
        FormatTime, TimeString,, [dd-MM-yyyy] [HH:mm]
        FileAppend, %TimeString% %clipboard%`n`n, %logfile%, UTF-16
    }
}
