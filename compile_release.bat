@echo off
"C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in "ahkmon.ahk" /icon "imgs/dqx.ico"
"C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in "ahkmon_updater.ahk" /icon "imgs/updater.ico"
"C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in "dialogFinder.ahk" /icon "imgs/dialog.ico"
"C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in "questFinder.ahk" /icon "imgs/quest.ico"
"C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in "walkthroughFinder.ahk" /icon "imgs/walkthrough.ico"
"C:\Program Files\7-Zip\7z.exe" a -tzip ahkmon.zip ./imgs ahkmon.exe dqxtrl.db sqlite3.dll version ahkmon_updater.exe dialogFinder.exe questFinder.exe walkthroughFinder.exe