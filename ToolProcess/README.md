AutoIt Hacks
============

This repository is mainly for me to put tiny bits of code I write in AutoIt.

At the moment, it consists of the following snippets:

	* ToolProcess
	* WordPredict

ToolProcess
-----------

This tool starts a process that stays minimized to the tray. It initializes various hotkeys; all of them can be toggled.

1. It initializes a hotkey `Ctrl+Alt+G` to perform a Google Search on the text entered in the input box.
2. It initializes a hotkey created by the user to perform any operation defined by the user.
3. It contains an option to set a timer (in seconds)
4. It contains a `Ping` operation to detect when the internet connection returns, if it's gone for a while
5. The `Ping Check` setting allows the user to check if the internet connection is up or down.
6. It contains a setting for my personal favourite: A tool that looks at the screen (or a user-defined section of the screen) to look for any changes with time. The hotkey for this is `Ctrl+Alt+PrintScreen` and if the `Shift` key is pressed within 2 seconds of the hotkey being pressed, it looks at the bounding-box created by the mouse while the `Shift` key was pressed. It looks at only that section of the screen for differences.

This tool mainly uses beeps, input boxes, and tray notifications to communicate with the user.

WordPredict
-----------

This is an attempt at writing something that predicts words while the user types them. It'll basically fill in the most likely word, based on the words typed by the user. It's basically like the auto-fill of Andriod/other phones. The prediction will be highlighted, so that the next key pressed by the user, if not the `Return` key, will clear the selection. The `Return` key accepts the selection, moving the cursor to the end of the predicted word.

TODO: This is a work in progress. I haven't finished much of this, since the word prediction is too slow to be useful at the moment. Additionally, I haven't implemented the logging of words typed by the user, so I can't make predictions based on the activity of the user yet.
