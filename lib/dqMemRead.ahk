dqMemRead()
{
  ;; Array of Bytes pattern that tells us if the dialog box is open or closed, as well as
  ;; the partial location of the address where the dialog text is.
  aAOBPattern := [255, 255, 255, 127, 255, 255, 255, 127, 0, 0, 0, 0, 0, 0, 0, 0, 253, "?", 168, 153]

  loop 
  { 
    Process, Exist, DQXGame.exe
    if ErrorLevel
    {
      ;; Create a new process attachment.
      if (_ClassMemory.__Class != "_ClassMemory")
      {
        msgbox classMemory not correctly installed or the (global class) variable "_ClassMemory" has been overwritten
        ExitApp  
      }

      if !dqx.isHandleValid()
        dqx := new _ClassMemory("ahk_exe DQXGame.exe", "", hProcessCopy)

      if !isObject(dqx) 
      {
        if (hProcessCopy = 0)
        {
          msgbox Dragon Quest X is not running on your computer. Please launch Dragon Quest X and then launch ahkmon.
          ExitApp 
        }
        else if (hProcessCopy = "")
        {
          msgbox Failed to open process. If Dragon Quest X is running with admin rights, then this script also needs to be run as admin.
          ExitApp
        }
      }

      ;; Start reading memory for dialog address.
      loop
      {
        dialogPatternResult := dqx.processPatternScan(,, aAOBPattern*)
        dialogBaseAddress := dialogPatternResult + 32 + 4
        dialogActualAddress := dqx.read(dialogBaseAddress, "UInt")

        if (dialogActualAddress != dialogLastAddress && dialogActualAddress != "")
        {
          ;; Read string at address and sanitize before sending for translation
          dialogText := dqx.readString(dialogActualAddress, sizeBytes := 0, encoding := "utf-8")
          dialogText := RegExReplace(dialogText, "\n", "")
          dialogText := RegExReplace(dialogText, "<br>", "`n`n")
          dialogText := RegExReplace(dialogText, "(<.+?>)", "")
          dialogText := StrReplace(dialogText, "「", "")

          ;; Determine which DeepL method to use.
          if (DeepLAPIEnable = 1)
            DeepLAPI(dialogText)
          else
            DeepLDesktop(dialogText)

          ;; Set LastAddress to ActualAddress so we aren't reading the same string over and over.
          dialogLastAddress := dialogActualAddress
        }

        ;; Exit loop if DQX closed.
        Process, Exist, DQXGame.exe
        if !ErrorLevel
          break
      }
    }

    ;; Keep looking for a DQXGame.exe process
    else
    sleep 2000
  }
}
