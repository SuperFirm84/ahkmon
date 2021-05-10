DeepLAPI(dqDialogText)
{
  ;; Open database connection.
  dbFileName := A_ScriptDir . "\dqxtrl.db"
  db := New SQLiteDB

  ;; Show overlay if AutoHideOverlay enabled.
  if (AutoHideOverlay = 1)
  {
    Gui, 2:Default
    Gui, Show, NA
  }

  ;; Iterate through each line returned.
  for index, sentence in StrSplit(dqDialogText, "`n`n", "`r") {

    ;; See if we have an entry available to grab from the database before sending the request to DeepL.
    result :=
    query := "SELECT " . Language . " FROM dialog WHERE jp = '" . sentence . "';"

    if !db.OpenDB(dbFileName)
      MsgBox, 16, SQLite Error, % "Msg:`t" . db.ErrorMsg . "`nCode:`t" . db.ErrorCode

    if !db.GetTable(query, result)
      MsgBox, 16, SQLite Error, % "Msg:`t" . db.ErrorMsg . "`nCode:`t" . db.ErrorCode

    result := result.Rows[1,1]

    ;; If no matching line was found in the database, query DeepL.
    if !result
    {

      ;; If not found locally, make a call to DeepL API to get
      ;; translated text.
      StringUpper, languageUpper, Language
      Body := "auth_key="
            . DeepLAPIKey
            . "&source_lang=JA"
            . "&target_lang="
            . languageUpper
            . "&text="
            . sentence

      if DeepLApiPro = 1
        url := "https://api.deepl.com/v2/translate"
      else
        url := "https://api-free.deepl.com/v2/translate"

      oWhr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
      oWhr.Open("POST", url, 0)

      oWhr.SetRequestHeader("User-Agent", "DQXTranslator")
      oWhr.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
      oWhr.Send(Body)
      oWhr.WaitForResponse()
          
      ;; Translated dialog text
      jsonResponse := JSON.Load(oWhr.ResponseText)
      translatedText := jsonResponse.translations[1].text

      ;; Sanitize text that comes back from DeepL
      if (Language = "en")
        translatedText := StrReplace(translatedText, "ã"," ")

      translatedText := StrReplace(translatedText, "'","''")  ;; Escape single quotes found in contractions before sending to database

      ;; Write new entry to the database if it doesn't exist.
      ;; If we're in this block, jp was found, but translation for another language
      ;; doesn't, so we update it here.
      selectQuery := "SELECT jp FROM dialog WHERE jp = '" . sentence . "'"
      insertQuery := "INSERT INTO dialog (jp, " . Language . ") VALUES ('" . sentence . "', '" . translatedText . "');"
      updateQuery := "UPDATE dialog SET " . Language . " = '" . translatedText . "' WHERE jp = '" . sentence . "'"

      db.Exec("BEGIN TRANSACTION;")

      if !db.GetTable(selectQuery, result)
        MsgBox, 16, SQLite Error, % "Msg:`t" . db.ErrorMsg . "`nCode:`t" . db.ErrorCode

      result := result.Rows[1,1]

      if !result 
      {
        if !db.Exec(insertQuery)
          MsgBox, 16, SQLite Error, % "Msg:`t" . db.ErrorMsg . "`nCode:`t" . db.ErrorCode
      }
      else
      {
        if !db.Exec(updatequery)
          MsgBox, 16, SQLite Error, % "Msg:`t" . db.ErrorMsg . "`nCode:`t" . db.ErrorCode
      }

      db.Exec("COMMIT TRANSACTION;")

      ;; Remove escaped single quotes before sending to overlay.
      translatedText := StrReplace(translatedText, "''","'")
      GuiControl, MoveDraw, Clip,
      GuiControl, 2:Text, Clip, %translatedText%
    }

    else 
    {
      GuiControl, MoveDraw, Clip,
      GuiControl, 2:Text, Clip, %result%
    }

    ;; Determine whether to listen for joystick or keyboard keys
    ;; to continue the dialog.
    if (JoystickEnabled = 1)
    {
      WinActivate, ahk_class AutoHotkeyGUI
      Input := GetKeyPress(JoystickKeys)
    }
    else
    {
      Input := GetKeyPress(KeyboardKeys)
    }
  }

  ;; Close database connection.
  db.CloseDB()

  ;; Clear + Hide overlay if AutoHideOverlay enabled.
  if (AutoHideOverlay = 1)
  {
    Gui, 2:Default
    Gui, Hide
    GuiControl, Text, Clip,
  }

  return
}