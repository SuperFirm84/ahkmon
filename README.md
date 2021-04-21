# ahkmon
Pastes your clipboard into DeepL Translate for the popular game "Dragon Quest X" (DQX).

Requirements:
- DQX, DQXDialog and DeepL all need to be open for the auto copy/paste to work. If either of these aren't open, nothing will happen.
- If you plan on using the OCR capture, the Japanese Language Pack for Windows needs to be installed (https://www.microsoft.com/store/productId/9N1W692FV4S1). Make sure both the Language Pack and Handwriting pack is installed. Voice and speech recognition are optional and not required for this to work. You do NOT need to set Japanese as your system default language.

Things to note:
- I've packaged DQ10Dialog with ahkmon as it relies on it to function. Credit goes to [Aeana](https://twitter.com/Aeana) for this lovely tool and is the reason us primary English speakers can easily understand what's going on in this game

Features:
-  Allows logging both the Japanese and translated text to a text file in the same directory (Enable logging to file in the UI). Text file is created where the executable was run from.
- Toggle requiring the DQX window to be focused for auto translate to work. Useful if you alt+tab out of the game and use your clipboard elsewhere.
- Enables an overlay that is always on top that you can leave on top of the DQX window. All this overlay does is take DeepL's translated text and copy to clipboard, which the overlay will pick up. (Enable overlay in the UI)
- EXPERIMENTAL: Enable Optical Character Recognition (OCR) with Ctrl+R. Allows you to click and drag a selection on your screen (in this case, Japanese text) that will be copied to your clipboard and translated via DeepL, then returned to you either in DeepL or in the overlay (if enabled)
- Resize the overlay. If enabled, you can drag the overlay by a corner and resize. If disabled, you can only drag the entire window around.
- Set the overlay width/height.
- Set the overlay's font color. You can type other colors, but I don't guarantee they will work.
- Set the font size of the overlay.
- Set the font type of the overlay. If you want to use a different font than is available on the drop down, you can manually type a font that's on your system and the overlay should pick it up.
- Able to hide the overlay by hitting F12.
- Save the position of the overlay by putting it where you want it, making sure the overlay is your focus window and pressing Alt+F12
