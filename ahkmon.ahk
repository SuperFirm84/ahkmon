#Persistent
#NoEnv
#SingleInstance force
SendMode Input

OnClipboardChange("ClipChanged")
return

ClipChanged(Type) {
    if WinActive("ahk_exe DQXGame.exe"){
        Process, Exist, DeepL.exe

        if ErrorLevel {
            Process, Exist, DQXGame.exe

            if ErrorLevel {
                Process, Exist, DQ10Dialog.exe

                if ErrorLevel {
                    WinActivate, ahk_exe DeepL.exe
                    SetControlDelay -1
                    ControlClick x150 y275, DeepL
                    Send, ^a{BackSpace}
                    Send, ^v
                    Sleep 750
                    WinActivate, ahk_exe DQXGame.exe
                }
            }
        }
    }
}