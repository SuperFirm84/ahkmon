logToFile(logFile) {
    Global Log
    if (Log = 1) {
        FormatTime, TimeString,, [dd-MM-yyyy] [HH:mm]
        FileAppend, %TimeString% %clipboard%`n`n, %logfile%, UTF-16
    }
}