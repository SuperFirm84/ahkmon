# ahkmon
Pastes your clipboard into DeepL Translate for the popular game "Dragon Quest X" (DQX).

## Credit:
- ahkmon wouldn't be possible without [Aeana's DQ10Dialog app](https://www.woodus.com/forums/topic/34653-dq10-dialog-monitor/?tab=comments#comment-538328), which is packaged with this project for convenience

## Features + Walkthrough

✔ : Option is checked <br>
✖ : Option is not checked

### General tab
- Language you want to translate text to:
  - Provides a list of regional codes to use for translating. This has no effect on the DeepL client translations, but controls what text is pulled from the SQLite database and (if enabled) what is sent to the DeepL API for translating.
- Enable logging to file
  - ✔: This sends the Japanese and translated text to a file called `textdb.out` in the local `ahkmon` directory. This pipe-delimited file is used to feed the dialog database back into the SQLite database.
  - ✖: Don't log to file.
- Require DQX window to be focused for auto translate?
  - ✔: If the Dragon Quest X window is focused, perform auto translate operations. If Dragon Quest X isn't targeted, auto translation will not occur. This is useful if you multi-task outside of Dragon Quest X and tend to copy other things to your browser while the game is open.
  - ✖: Auto translation will happen regardless if Dragon Quest X is the focused window or not.
- Do you play with a controller?
  - ✔: Controller keypresses will progress the text in the overlay.
  - ✖: Keyboard keypresses will progress the text in the overlay. Valid keys are ENTER, ESCAPE and the arrow keys.
- Enable overlay? (Toggle with F12)
  - ✔: A configurable overlay will display on your screen. You can customize the look of the overlay in the "Overlay Settings" tab.
  - ✖: An overlay will not be displayed.
- Enable Optical Character Recognition (OCR)? (Ctrl+Q)
  - ✔: Using Ctrl+Q, you can click and drag a section of the screen to have translated. Keep the selection small and as tight to the text as possible. The Japanese language pack will need to be installed on your system and can be found [here](https://www.microsoft.com/store/productId/9N1W692FV4S1)
  - ✖: OCR will not be enabled.

### Overlay Settings tab

- Allow resize of overlay?
  - ✔: Allows you to stretch the overlay to your preferred size. This leaves a slim border at the top of the overlay.
  - ✖: Locks the overlay's size and removed the slim border at the top of the overlay.
- Automatically hide overlay?
  - ✔: When all clipboard text has been exhausted, hide the overlay from sight.
  - ✖: Always leave the overlay open.
- Show overlay on taskbar when active?
  - ✔: When the overlay is open, it will remain visible on the taskbar. This is necessary for streamers who want to capture the overlay using OBS or similar tools.
  - ✖: Never show the overlay on the taskbar.
- Overlay transparency
  - A slider that allows you to make the overlay transparent. Left is more opaque and Right is more transparent.
- Overlay background color
  - Accepts [hex color codes](https://www.color-hex.com/) to change the background of the overlay.
- Initial overlay width
  - Sets the initial width of the overlay on launch
- Initial overlay height
  - Sets the initial height of the overlay on launch
- Overlay font color
  - Sets the color of the overlay font
- Overlay font size:
  - Sets the size of the overlay font
- Select a font or enter a custom font available on your system to use with the overlay
  - Select from a pre-selected list of fonts or manually type a font you may have already installed to be used in the overlay

### Advanced tab

This tab is for users who might be struggling with the default options. Allows for further tweaking.

- Hide DeepL?
  - ✔: Moves DeepL to a ridiculous x,y coordinate on your screen to artifically hide the window from sight. This was introduced for users who were experiencing issues with DeepL getting focus on top of Dragon Quest X.
  - ✖: Don't artificially hide DeepL and behave as normal.
 - Reset DeepL Position
   - Resets DeepL to the default x0,y0 position on the main monitor.
 - DeepL Desktop client translate attempts before giving up
   - Slider to specify how many attempts to wait for DeepL to translate. Users with slower computers or are translating in other languages may experience longer delays, so this allows you to customize that. The default number of attempts is 25.

### DeepL API

- Enable DeepL API Requests?
  - No longer requires the DeepL desktop client for translations and instead, utilizes the DeepL API for translations. This requires a free DeepL Pro account, which requires a valid credit card to register. You are limited to 500,000 characters translated per month. This method is overall much more stable than interacting with the external DeepL desktop client. You can sign up for a free DeepL Pro API account [here](https://www.deepl.com/pro#developer).
  - The box below this is where you enter your API key after creating an account. You can find the key to enter on the account page you signed up for on DeepL's website. Note that this key is equivalent to someone having your password, so do not share it with anyone.
- Check remaining character count
  - Calls out to DeepL's API to tell you how many characters you have left for the month

### Logging

- If logging is enabled, this button will upload your `textdb.out` log file to https://file.io and generate a link in your clipboard for a one-time use download. This is best to send to @Serany on the Dragon Quest X Discord for merging your translated logs to the main SQLite database that is distributed amongst everyone.

## Troubleshooting

### Problem: I launched `ahkmon` and am talking to NPCs, but text isn't translating.

Potential solutions:
- If you have "Require DQX window to be focused for auto translate?" checked, you will need to make sure Dragon Quest X is the focused window before attempting to translate. If you don't like this feature, don't enable it (uncheck).

### Problem: I see text in the overlay, but pressing <enter key here> isn't progressing the text!
  
Potential solutions:
- If you have "Do you play with a controller?" enabled, you will need to use the buttons on your joystick. If this is unchecked, you will need to press ENTER, ESCAPE or use the arrow keys to progress the text.

### Problem: I keep seeing "DeepL did not return a translation in time." in the overlay.

Potential solutions:
- If this is sporadic, you might want to try adjusting the number of attempts in the "Advanced" tab.
- Make sure DeepL isn't minimized. It doesn't have to be visible on your screen, but it needs to be open. You can drag DeepL on top of Dragon Quest X, then click Dragon Quest X and have it open, but not showing.

### Problem: DeepL is randomly opening during translation and I have to click on Dragon Quest X again to play.

Potential solutions:
- In the "Advanced" tab, select "Hide DeepL?". This will move DeepL far off your screen so it no longer is in your way. 

### Problem: I checked "Hide DeepL?", but I can't get access to the DeepL client window anymore.

Potential solutions:
If you want to get access to DeepL again, you can relaunch `ahkmon`, click on the "Advanced" tab and click on "Reset DeepL Position". Alternatively, you can Shift+Right-Click the icon on the taskbar, click "Move", press an arrow key and then left-click your mouse to get the window back. 
