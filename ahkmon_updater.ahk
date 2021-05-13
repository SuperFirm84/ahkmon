#Persistent
#NoEnv
#SingleInstance force
#Include <JSON>

/*
*************************************************
Used to auto update ahkmon to the latest version
*************************************************
*/

;; Display GUI to user showing the update is happening
Gui, 1:Default
Gui, Add, Progress, w200 h15 c0096FF Background0a2351 vProgress, 0
Gui, Show, Autosize

;; Make sure /tmp is clean by deleting + re-creating, then move updater into /tmp.
FileRemoveDir, %A_ScriptDir%\tmp
sleep 100
FileCreateDir, %A_ScriptDir%\tmp
sleep 100
FileMove, %A_ScriptDir%\ahkmon_updater.exe, %A_ScriptDir%\tmp\ahkmon_updater.exe

;; Download latest version
url := "https://github.com/jmctune/ahkmon/releases/latest/download/ahkmon.zip"
;downloadFile(url)
GuiControl,, Progress, 25

;; Unzip files that were downloaded into same directory, overwriting anything
unzipName := A_ScriptDir "\ahkmon.zip"
unzipLoc := A_ScriptDir
Unz(unzipName, unzipLoc)
GuiControl,, Progress, 50

;; Grab release notes + new version number
oWhr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
url := "https://api.github.com/repos/jmctune/ahkmon/releases/latest"
oWhr.Open("GET", url, 0)
oWhr.Send()
oWhr.WaitForResponse()
jsonResponse := JSON.Load(oWhr.ResponseText)
releaseVersion := (jsonResponse.tag_name)
releaseVersion := SubStr(releaseVersion, 2)
releaseNotes := (jsonResponse.body)
releaseNotes := RegExReplace(releaseNotes, "\r\n", "`n")
GuiControl,, Progress, 75

;; Get current version locally from version file
FileRead, currentVersion, version

;; If the versions differ, run updater
if (releaseVersion = currentVersion)
{
  GuiControl,, Progress, 100
  message := "UPDATE SUCCESSFUL!`n`nahkmon Version: " . releaseVersion . "`n`nRelease Notes:`n`n" . releaseNotes
  msgBox % message
  message := "ahkmon will now launch."
  msgBox % message
  FileDelete, %A_ScriptDir%\ahkmon.zip  ;; Delete the old file
  Run ahkmon.exe
  ExitApp
}
else
{
  GuiControl,, Progress, 100
  FileMove, %A_ScriptDir%\tmp\ahkmon_updater.exe, %A_ScriptDir%\ahkmon_updater.exe  ;; If failed, put updater back
  sleep 100
  FileRemoveDir, %A_ScriptDir%\tmp  ;; Remove /tmp folder
  message := "UPDATE FAILED! Version mismatch. Please update ahkmon manually."
  msgBox % message
  FileDelete, %A_ScriptDir%\ahkmon.zip  ;; Delete the old file if it exists
  Run, https://github.com/jmctune/ahkmon/releases/latest
  ExitApp
}

;=== Functions ==========================================================
downloadFile(url, dir := "", fileName := "ahkmon.zip") 
{
  whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
  whr.Open("GET", url, true)
  whr.Send()
  whr.WaitForResponse()

  body := whr.ResponseBody
  data := NumGet(ComObjValue(body) + 8 + A_PtrSize, "UInt")
  size := body.MaxIndex() + 1

  if !InStr(FileExist(dir), "D")
    FileCreateDir % dir

  SplitPath url, urlFileName
  f := FileOpen(dir (fileName ? fileName : urlFileName), "w")
  f.RawWrite(data + 0, size)
  f.Close()
}

Unz(sZip, sUnz)
{
  FileCreateDir, %sUnz%
    psh  := ComObjCreate("Shell.Application")
    psh.Namespace( sUnz ).CopyHere( psh.Namespace( sZip ).items, 4|16 )
}