# ahkmon
Pastes your clipboard into DeepL Translate for the popular game "Dragon Quest X" (DQX).

Few requirements:
- DQX, DQXDialog and DeepL all need to be open for the auto copy/paste to work. If either of these aren't open, nothing will happen.

Things to note:
- I've packaged DQ10Dialog with ahkmon as it relies on it to function. Credit goes to [Aeana](https://twitter.com/Aeana) for this lovely tool and is the reason us primary English speakers can play this game

Features:
-  Allows logging both the Japanese and translated text to a text file in the same directory (Enable logging to file in the UI). Text file is created where the executable was run from.
- Enables an overlay that is always on top that you can leave on top of the DQX window. All this overlay does is take DeepL's translated text and copy to clipboard, which the overlay will pick up. (Enable overlay in the UI)
- Resize the overlay. If enabled, you can drag the overlay by a corner and resize. If disabled, you can only drag the entire window around
- Set the overlay width/height
- Set the overlay's font color. You can type other colors, but I don't guarantee they will work.
- Set the font size of the overlay
- Set the font type of the overlay. If you want to use a different font than is available on the drop down, you can manually type a font that's on your system and the overlay should pick it up.
- Able to hide the overlay by hitting F12. On first launch, you need to tap F12 twice, then it'll behave like normal.
