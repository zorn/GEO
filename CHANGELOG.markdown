September 29, 2010

* Took out the naming of the hero screen. It's now hard coded with a name of "Hero".
* Replaced this with a new StoryViewController which will flip through a small collection of images with overlaying textviews. before jumping into the map view.

September 28, 2010

* We now load 3 monsters with the 4 color variations each. Whom you battle is currently random.
* I took out the red flash when we get hit due to the documented bug. A new effect is in the works from Matt.
* Added elemental types to all weapons and monsters. When an attack hits it will now be a strong (1.5) normal (1.0) or weak (0.5) attack value.
* If you hit an enemy with the strong attack the hit sound will be different, though under the current music it's kinda hard to tell.

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

