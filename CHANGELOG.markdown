September 28, 2010

* 

September 26, 2010

* MDZ: MaxHP is now a derived number.
* MDZ: Lots of new logic added to mod model, levels, experience, attack power, etc.

September 25, 2010

* MDZ: Added and converted the RQMob into the main core data database.
* MDZ: Added RQModelController which has a singleton defaultModelController. This is a nice class that lets you access objects from the core data soup in a clean way without excessive code.
* MDZ: The hero state now stays around from session to session. We don't have the code yet to regenerate the hero health as you walk so before each battle we give you a full heal.

September 24, 2010

* MDZ: Reworked some of the sound effects. Launch weapon sound, hit sound.
* MDZ: Enemy will now hit you.
* MDZ: Added some code for a death animation, needs work.
* MDZ: Victory screen now plays music, doesn't fade out as nice as I'd like if you double tap to return to the map before it's finished.
* MDZ: Adding a basic main menu screen based off Johnny render.

September 23, 2010

* MDZ: Added a `#define` flag called RQAudioPlayerPlayAudioDuringDevelopment. Lets me/us have the app stay quite during development.
* MDZ: Added a flick threshold that will force the user to define the trajectory and velocity of the weapon before they pass the yellow line.
* MDZ: Added some basic perspective as the weapon passes the flick threshold it will shrink. Not sure how well it works visually. Feedback welcome.

