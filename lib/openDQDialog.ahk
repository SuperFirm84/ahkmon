openDQDialog() {
  Process, Exist, DQ10Dialog.exe
  if ! errorLevel {
    ifExist, apps/DQ10Dialog.exe
        Run, apps/DQ10Dialog.exe,,Min
  }
  else {
    return
  }
}
