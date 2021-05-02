@echo off
set /p release="New release version (last octet) (ex: 3 for v1.1.3): "
"C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in "ahkmon.ahk" /icon "imgs/dqx.ico"
"C:\Program Files\7-Zip\7z.exe" a -tzip ahkmon_v1.1.%release%.zip ./apps ./imgs ./lib ahkmon.ahk ahkmon.exe dqxtrl.db sqlite3.dll