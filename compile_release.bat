@echo off
set /p release="New release version (last octet) (ex: 3 for v1.2.3): "
"C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in "ahkmon.ahk" /icon "imgs/dqx.ico"
"C:\Program Files\7-Zip\7z.exe" a -tzip ahkmon_v1.2.%release%.zip ./imgs ahkmon.exe dqxtrl.db sqlite3.dll