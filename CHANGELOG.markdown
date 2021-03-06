January 4, 2011

* CHANGED: main Info.plist to use 1.0 instead of 1.0b3 (in prep for submission).
* ADDED: new array for UIRequiredDeviceCapabilities to Info.plist to force gps requirement.

December 13, 2010

* CHANGED: New images for health and glove power on the battle screen
* CHANGED: Using text instead of images for health and glove power on the map view
* CHANGED: We now only show the dev toolbox button on the main menu when the CFBundleVersion contains a "b" as-in beta release.
* CHANGED: A few small adjustments to the HTML contents of the help and about windows.

December 12, 2010

* CHANGED: Swapped in new Dr Gordon sprites for final battle.
* CHANGED: The PlusHP bonus during the final battle now give a little glover power as well.
* ADDED: New pref in setting to toggle distance as miles or meters.
* CHANGED: Updated MapView and TrekListView to honor new pref and show distance as kilometers if needed.
* ADDED: New pref in setting to toggle weight as pounds or grams.
* CHANGED: Updated WeightLog views to honor new pref.
* ADDED: New prefs default to meters/grams. Check on first run to see if unit is running as "US". If so, switches to miles/pounds.
* FIXED: Removed some garbage pointer initialization and a few memory leaks via Build and Analyze.
* FIXED: StatusBar now shows back up after final battle sequence.
* ADDED: Icon-72.png to avoid release warning about iPad icon size missing.
* CHANGED: Updated app icon to latest version from KUT.
* ADDED: New run text-based icon for run button in battle view.
* CHANGED: Redid the about page HTML. Feedback welcome.
* CHANGED: Battle Music now doesn't play when iPod is playing music
* ADDED: New movement animations for Blob, Oni, and Mage

December 11, 2010

* ADDED: New story frames for final fight.
* ADDED: Second phase of the Dr. Gordon Fight.
* ADDED: Elemental shift to Dr. Gordon second phase.
* ADDED: Set up monster weapon effect color to match the base element of the monster throwing it.
* FIXED: Small typo in story line.
* FIXED: Bad Earth type in getter method.

December 10, 2010

* ADDED: New plus HP mechanic to final boss fight. Tap to gain 200 hp. They spawn every 10 seconds.
* CHANGED: Increased the HP of Dr Gordon.
* CHANGED: Replace our NSLogs with a CCLOG macro.
* CHANGED: The list of previous weights in the log book is now themed.
* ADDED: Now check of weights larger than 999 and prevent their entry.

December 9, 2010

* CHANGED: Swapped in some new frames for final story battle before boss fight.
* ADDED: Added failure state, graphics and sounds to the boss result.
* CHANGED: Increased Dr Gordon HP.
* CHANGED: Reduced the impact of glove power. Full glove power would double an attack, now increases it by 1.5 max.
* CHANGED: We no longer randomly adjust attack power.

December 8, 2010

* Moved repo to GitHub.
* Boss sequence fixed.

December 7, 2010

* CHANGED: Refactored StoryController to be more generic. Will use for final boss story soon.
* ADDED: We now show story for Dr. Gordon button on main menu.
* FIXED: some status bar disappearing issues. Still cause an issue for viewing a story in the dev tools.

December 6, 2010

* FIXED: monsters.plist was missing from project file. re-added.
* CHANGED: made the map view fit the bounds of the frame so that the "Google" watermark shows through. Not showing this is a reject-able offense.
* CHANGE: the speed of the fake GPS walker is a little slower.
* CHANGED: swapped in new xp tick sound 'spaceBeat.m4a' and it works well i think.
* CHANGED: added in new version of victory/failure title images
* ADDED: new button in victory view to continue workout.
* ADDED: victory view now uses a new background and title when you are at max level.
* ADDED: when you reach level 50 we now display a short messages of congratulations telling you to visit the doctor after you are done your workout.

December 2, 2010

* CHANGED: Swapped in new battle view background from Kut.
* CHANGED: We no longer award +15 to glove power before each battle. This reward will be moved to treasures.
* CHANGED: We no longer make the hero's HP 100% before each battle.
* ADDED: The hero now regains 1% of max HP per 2 meters traveled. Feedback welcome.
* ADDED: The hero now regains 30% of max HP after losing a fight.
* REMOVED: Face and Hole (aka Dick and Asshole) have been removed from the monster list.
* CHANGED: Added new monster names to monsters.plist. (not used in game yet)
* FIXED: Previous sprite fix for meanie/wizard was to old sprite files. Reapplied resize fix to "newmeanie" sprite family.
* CHANGED: Removed unused sprites from project so they are no longer included in bundle.

November 30, 2010

* FIXED: Meanie enemy sprite so he is not as tall in the battle view.
* CHANGED: Right aligned HP/GLOVE labels on map view.
* ADDED: Battle view will no longer add XP to hero when hero has reached level cap.
* FIXED: We now use a high res icon for location on the map view.
* ADDED: New XP tick sounds to victory view. (Not sure it fits in though.)
* CHANGED: Made battle background an animated cloud view. Not final just testing some stuff.
* CHANGED: Using new victory and failure background
* ADDED: Strong Hit Animation

November 28, 2010

* Swapped HP and Glove Power colors
* Added labels for HP and Glove Power
* Changed map view to use the same bars as Battle View

November 27, 2010

* Added new main menu background.
* Added Default.png to help load visual. (It's suppose to fade but I think the Core Animation I added is interfering with the "currentViewController" stuff.)
* Background mesh for log view is now a little darker.
* Settings section is now themed.
* You can no longer select a trek row in the log book.
* More of the log book has been styled. The previous weigh-ins section has been left "white" since I had trouble getting it styled w/o other issues. Will look into in the future.

November 27, 2010

* HP & GP meters are updated in the MapView
* Boost of MaxHP/5 when you encounter a treasure
* White outline around enemies so they stand out a bit more against the fog
* Local notifications for encountering enemies while in the background w/ custom sound
* Added sound, animation on treasure encounter
* Added sound on Enemy encounter while in-app
* New enemy generation code for more even distribution of enemies

November 26, 2010

* Added new developer pref to optionally use simulated GPS on the device. This works, though does seem to cause more drawing artifacts. On the simulator it will now always use simulated GPS.
* The Main Menu now plays music. It will stop as you jump into the map view.
* The Settings view now live update the volume settings as you drag the slider, so you instantly hear the music volume change. Additionally you will also hear a sound effect sample as you move it's slider.
* The storyboard view now plays music.
* The Map view now plays music.
* Unused songs have been de-referenced from the main project and should help make the bundle smaller.
* Added first rev of app icon to the project. Feedback welcome.

November 25, 2010

* Added new monsters to temporarily replace ones of questionable obscenity.  
* Added treasure countdown animation.  They still do nothing when encountered.

November 22, 2010

* Started to implemented style cues from Johnny's table view mock up. Some things easier to implement than others. Feedback very welcome. 
* FIXED: A previous push has the load sample code and TESTING define uncommented.

November 19, 2010

* Fixed a time format issue for the logbook view.

November 19, 2010 

* SHIPPED: 1.0b1 to a few testers!

November 18, 2010

* Added a new trek log view. This view groups treks by week and shows them some summary stats. It is my intention to eventually add totals in the section footers and also graphs that will let people browse their calorie burn, distance traveled and time played. For now, this is a good start and better than what we had before. 
* FIXED: LogView will now load when there are zero treks in the system.
* CHANGE: Made the bundle id com.indyhall.labs.geo
* CHANGE: Made the bundle version 1.0b1 in prep for first beta release.


November 17 2010 - Joe

* Added basic treasure spawn. They don't do anything currently, but they are spawned in your path.
* Refactored some MapViewController methods to better communicate their intent.  start/stopGeneratingEnemies become start/pauseGameMechanics
* FIXED: Stopped enemy pursuit on Pause

November 17, 2010

* Lightning animation - Matt
* Implemented Health and Glove Power bars in the battle view and updated their appearance to match Johnny's mockup - Matt

* Implemented a Calorie Burn formula. It is slightly variable to show increase burn if you are walking or running (>5mph) rate. It only shows calories being burned by walking/running that are relevant to the activity. It does include the normal calories you burn even while standing still. This now also updates on the map view as you walk around.
* FIXED: We no longer stop treks before starting a battle view.  // My bad, I thought that was what we wanted -Joe
* FIXED: The MapView has a bug(see below) which can cause it to not be dealloc-ed. I have not fixed this problem, but added some code so that we make sure to turn off the GPS when the user hits cancel or finish in the map view. Previously we only did this in dealloc so there was a situation where the user would be on the main menu with the GPS still on which is very bad for battery life.

https://indyhalllabs.basecamphq.com/projects/5521331/todo_lists/11518403

November 13-14th 2010

* Added fog of war to the map view - this is handled by the Sonar annotation and the SonarView which is a MKOverlayLayer.  The Other
* Enemies are generated in a range (you can tweak the x/y range in the #defines in MapViewController)
* Enemies only chase the hero when they are within the ENEMY_MAGNET_RADIUS.  They have a speed advantage of ENEMY_SPEED_ADVANTAGE.
* Added a Debug-Testing build which adds the TESTING preprocessor macro.

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

