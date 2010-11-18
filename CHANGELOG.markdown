November 17 2010 - Joe
* Added basic treasure spawn. They don't do anything currently, but they are spawned in your path.
* Refactored some MapViewController methods to better communicate their intent.  start/stopGeneratingEnemies become start/pauseGameMechanics
* FIXED: Stopped enemy persuit on Pause

November 17, 2010

* Lightning animation - Matt
* Implemented Health and Glove Power bars in the battle view and updated their appearance to match Johnny's mockup - Matt

* Implemented a Calorie Burn formula. It is slightly variable to show increase burn if you are walking or running (>5mph) rate. It only shows calories being burned by walking/running that are relevant to the activity. It does include the normal calories you burn even while standing still. This now also updates on the map view as you walk around.
* FIXED: We no longer stop treks before starting a battle view.  // My bad, I thought that was what we wanted -Joe
* FIXED: The MapView has a bug(see below) which can cause it to not be dealloc-ed. I have not fixed this problem, but added some code so that we make sure to turn off the GPS when the user hits cancel or finish in the map view. Previously we only did this in dealloc so there was a situation where the user would be on the main menu with the GPS still on which is very bad for battery life.

https://indyhalllabs.basecamphq.com/projects/5521331/todo_lists/11518403


November 13-14th 2010
*Added fog of war to the map view - this is handled by the Sonar annotation and the SonarView which is a MKOverlayLayer.  The Other
*Enemies are generated in a range (you can tweak the x/y range in the #defines in MapViewController)
*Enemies only chase the hero when they are within the ENEMY_MAGNET_RADIUS.  They have a speed advantage of ENEMY_SPEED_ADVANTAGE.
*Added a Debug-Testing build which adds the TESTING preprocessor macro.


November 16, 2010

* Implemented the new shield orbs and look. 
* When a user starts a new workout we now ask for their weight if it has not been logged in the last 72 hours.
* Started implementing my vision for the workflow on mapview. Some labels are still static. Hope to get them working soon.
* Added a new preference in the dev toolbox that will override the location button in the mapview to launch a demo battle (useful for testing.)
* FIXED: You can now cancel a weight entry when starting a new workout.
* FIXED: Made the MapView a little taller to help hide the Google Watermark, which was slightly viewable under the transparent toolbar at the bottom.
* FIXED: I introduced a bug that would create new treks when resuming, this is now fixed.
* ADDED: Updated the distance label on the map view to update as you walk. Currently shows in miles, might need to add a preference toggle to show meters in the future.

November 15, 2010

* Adding some code from Joe via email to avoid a complier warning when using something less than iOS 4.2.
* Replaced and removed a pair of #warnings in the M3CoreDataManager They aren't really warnings as much as TODO items. 
>>>>>>> 474d9f580dffc17c23270217faad36b7c1eaf9db

November 11, 2010

* Started to implement the mentor messages in the victory screen. They are defined in a plist for easy editing. They currently aren't very suitable for the failure screen.
* Started to add some of the real design elements into the battle view screen.

November 10, 2010

* Monster will now spawn based on hero's available weapons. IE: You have the weapon to match the monster's weakness.
* Cleaned up some dangling outlet code that was left in place from a previous implementation of the victory screen.
* Changed the math behind the percent of level being gained. Was wrong before. It works now, though at low levels, the bar feels too bouncy.
* Added some math to calculate a experienceCountByAmount so we aren't always incrementing by 1. On the high levels it would animate for a looooong time.

November 9, 2010

* Added a new property for the hero called Glove Power. It is an int in the range of 0..100. Glove Power increases the damage done by the hero's weapons. When a hero is created it defaults to 50. As you fire weapons you lose it, as you walk on the map you gain it. Glove power is currently displayed in the battle view as text, this is temporary.

November 8, 2010

* Re-enabled the tap to skip xp animations in the victory view.
* Added new plist format to store monster names, types, file names, movement style.
* Added new monsters from phil. We now have 12 "designs" with 2 elemental styles each.

November 2, 2010

* Edited the Core Data format (made shields a float, used to be an int). Be sure to delete previous app installs to avoid save crashes.
* Shields is now implemented. You get them at level 10. Reminder use the hero editor in the dev toolbox to change your level.
* To put shields up drag from one blue orb to the other. Shields will deteriorate over time. It currently lasts 10 seconds. While shields are up incoming damage is halved (I could edit the dmg reduction to be in ratio to the shield power, thoughts?).
* The camera background of the battle view has been taken out (per last meeting discussions).

November 1, 2010

* Weight Logbook graph now has a nice labeled y axis and fills more of the screen. Long term I'd like to add a labeled x axis but since we aren't browsing Y from 0 to max I believe I'd have to do custom labels which is a little more work. For now I'm going to commit as-is.
* Added SIMULATOR ifdef to avoid slow battle launches due to missing iPod app.
* Added new developer tool to let you change the level of the hero (useful for testing weapon/story progression).
* Weapons are now given out over time. Fire then water (lv5) then earth (lv15) then air (lv25). In the future shields will be given out at lv10.
* Adjusted the spacing of weapons dependent on how many are on the field. They are a little closer to each other (really show with four up) but this will change as battle designs / graphics come in.

October 30, 2010

* Weight Logbook list view doesn't work well with no previous entries (WTF NSFetchedResultsController, you suck.). Going to disable the button to get to it while zero entries exist.
* We now show a proper message at the top of weight log home screen, showing a lose or gain of weight or, if needed, a message encouraging you to enter your weight.
* The weight list view now shows how much weight was lost as of the weight taken date of the row/cell being shown.

October 27, 2010

* Weight Logbook section is coming along. Can now enter today's weight as well as browse, edit and delete previous weight log entries.

October 25, 2010

* Re-enabled animations, though using a flip now. I am starting to work on fixes to the status bar problem. I believe it was a lack of `self.wantsFullScreenLayout = YES;` -- time will tell.
* The log book, settings, dev toolbox are now all modal off the main menu. They have a consistent "done" button in the upper right.

October 23, 2010

* Turned off the animation in the setCurrentViewController method and added a hard frame assignment to avoid the nasty status bar / frame issue documented on basecamp. I've tried to fix this but can not figure it out. This is the only workaround I could get going.

<http://indyhalllabs.basecamphq.com/projects/5521331/posts/37719465/comments>

* I bought a license for "Glyphish Pro". Some of the icons will come in handy. Raw icons in ThirdPartyStuff.
* Redid the look of the main menu. The layout is closer to what I hope the final screen will look like. The look is temporary, something I did in photoshop to hold in place.
* Watch Story was moves from the main menu to the dev tools. 

October 20, 2010

* Now save data set when they hit done on map view.

October 13, 2010

* Changed Product name to GEO -- have not taken the time to rename other folders/files yet.

October 1, 2010

* Redid the home screen. Added a new story button (probably just there for testing).
* Filled in the new story copy.

September 29, 2010

* Took out the naming of the hero screen. It's now hard coded with a name of "Hero".
* Replaced this with a new StoryViewController which will flip through a small collection of images with overlaying textviews before jumping into the map view.
* Resized and adjusted the story frames from Kotaro to fit this new controller.
* Added a new SettingsViewController. It lets you adjust volume levels for music and effects. There is also a toggle (defaults to on) that lets our app pause the iPod before a battle and un-pause it after. This works well except for a bug where sound effects won't play on the followup battle if we were pausing the iPod. I suspect changing the mode if causing this. Don't have a work around just yet.

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

