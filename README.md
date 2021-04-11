# ahkmon
Pastes your clipboard into DeepL Translate for the popular game "Dragon Quest X" (DQX).

Will also create a `dq_dialog_jp.txt` file that the japanese text is written to and a `dq_dialog_translated.txt` file that the translated text is written to within the working directory of where the executable/ahk file was launched.

Few requirements:
- DQX, DQXDialog and DeepL all need to be open for the auto copy/paste to work. If either of these aren't open, nothing will happen.
- DQX needs to be the focused window for the auto copy/paste to work. If the DQX window is not focused, nothing will happen.