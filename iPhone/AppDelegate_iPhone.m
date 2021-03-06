//
//  AppDelegate_iPhone.m
//  RunQuest
//
//  Created by Joe Walsh on 9/11/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "AppDelegate_iPhone.h"
#import "MainMenuViewController.h"
#import "TrekListViewController.h"
#import "CDAudioManager.h"
#import "SimpleAudioEngine.h"
#import "DeveloperToolboxViewController.h"
#import "RQModelController.h"
#import "M3CoreDataManager.h"
#import "WeightLogViewController.h"

@implementation AppDelegate_iPhone
@synthesize currentViewController, mainMenuViewController, developerToolboxNavigationController, mapViewController, storyViewController, settingsViewController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    // Override point for customization after application launch.
	
	// First lauch thing
	// if they are in the US, use US measurement settings
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"RQSetupUnitSettings"] boolValue] == NO) {
		NSString *locale = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
		if ([locale isEqualToString:@"US"]) {
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"RQDisplayDistanceAsMeters"];
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"RQDisplayWeightAsGrams"];
		}
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"RQSetupUnitSettings"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
	}
	
	// TODO: This fade doesn't happen
	splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0,20, 320, 460)];
	splashView.image = [UIImage imageNamed:@"Default.png"];
	[self.window addSubview:splashView];
	[self.window bringSubviewToFront:splashView];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.window cache:YES];
	[UIView setAnimationDelegate:self]; 
	[UIView setAnimationDidStopSelector:@selector(startupAnimationDone:finished:context:)];
	splashView.alpha = 0.0;
	//splashView.frame = CGRectMake(-60, -60, 440, 600);
	[UIView commitAnimations];
	
	[self updateAudioSystemVolumeSettings];
	[self setCurrentViewController:[self mainMenuViewController] animated:NO];
	
	//[self.window addSubview:self.currentViewController.view];	
    [self.window makeKeyAndVisible];
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"RQSoundShouldPrioritizeIPod"] boolValue]) {
		[[CDAudioManager sharedManager] setMode:kAMM_FxPlusMusicIfNoOtherAudio];
	}
	else {
		[[CDAudioManager sharedManager] setMode:kAMM_FxPlusMusic];
	}
	
	//[[CDAudioManager sharedManager] setMode:kAMM_FxPlusMusicIfNoOtherAudio];
	
	// Handle launching from a notification
    UILocalNotification *localNotif =
    [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif) {
        NSLog(@"Recieved Notification %@",localNotif);
    }	
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	if ( !self.mapViewController.trek )
		[self.mapViewController stopUpdatingLocation];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	
	if ( !self.mapViewController.trek )
		[self.mapViewController startUpdatingLocation];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


/**
 Superclass implementation saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	[super applicationWillTerminate:application];
}


- (MainMenuViewController *)mainMenuViewController {
	if ( !mainMenuViewController ) {
		mainMenuViewController = [[MainMenuViewController alloc] init]; 
		[mainMenuViewController setDelegate:self];
	}	
	return mainMenuViewController;	
}

#pragma mark -
#pragma mark Memory management

+ (void)initialize
{
    NSMutableDictionary *regDictionary = [NSMutableDictionary dictionary];
    [regDictionary setObject:[NSNumber numberWithFloat:1.0] forKey:@"RQSoundVolumeMusic"];
	[regDictionary setObject:[NSNumber numberWithFloat:1.0] forKey:@"RQSoundVolumeEffects"];
	[regDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"RQSoundShouldPrioritizeIPod"];
	[regDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"RQDisplayDistanceAsMeters"];
	[regDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"RQDisplayWeightAsGrams"];
	[regDictionary setObject:[NSNumber numberWithBool:NO] forKey:@"RQMapBattleDemoOverride"];
	[regDictionary setObject:[NSNumber numberWithBool:NO] forKey:@"RQSimulateGPS"];
	[regDictionary setObject:[NSNumber numberWithBool:NO] forKey:@"RQSetupUnitSettings"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:regDictionary];
}


- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
   
    [super applicationDidReceiveMemoryWarning:application];
}

- (void)dealloc {
	[developerToolboxNavigationController release];
	[mapViewController release];
	[settingsViewController release];
	[mainMenuViewController release];
	[currentViewController release];
	[super dealloc];
}

- (void)setCurrentViewController:(UIViewController *)to animated:(BOOL)animate {
   to.view.frame = self.window.frame;
	void (^switchBlock)(BOOL) = ^(BOOL finished){
		if (finished) {
			[self.window addSubview:to.view];
			[currentViewController.view removeFromSuperview];
			[currentViewController release];
			currentViewController = [to retain];
		}};
	
	if ( animate ) {
		UIViewAnimationOptions options = ( [to isKindOfClass:[MainMenuViewController class]] ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight );
		[UIView transitionFromView:currentViewController.view toView:to.view duration:1.0f options:options completion:switchBlock];
	}
	else {
		switchBlock(YES);
	}
	
}

- (void)setCurrentViewController:(UIViewController *)to {
	[self setCurrentViewController:to animated:YES];
}

- (void)updateAudioSystemVolumeSettings
{
	float backgroundMusic = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RQSoundVolumeMusic"] floatValue];
	float soundEffects = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RQSoundVolumeEffects"] floatValue];
	
	[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:backgroundMusic];
	[[SimpleAudioEngine sharedEngine] setEffectsVolume:soundEffects];
}

- (void)startupAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	[splashView removeFromSuperview];
	[splashView release];
}

#pragma mark -
#pragma mark StoryViewControllerDelegate methods

- (void)storyViewControllerDidEnd:(StoryViewController *)controller
{
	[self mainMenuViewControllerPlayButtonPressed:nil];
	self.storyViewController = nil;
}
#pragma mark -
#pragma mark SettingsViewControllerDelegate methods

- (void)settingsViewControllerDidEnd:(SettingsViewController *)controller;
{
	self.currentViewController = self.mainMenuViewController;
	self.settingsViewController = nil;
}

#pragma mark -
#pragma mark MapViewControllerDelegate Methods

- (void)mapViewControllerDidEnd:(MapViewController *)controller {
	[[[RQModelController defaultModelController] coreDataManager] save];
	self.currentViewController = self.mainMenuViewController;
	self.mapViewController = nil;
}

#pragma mark -
#pragma mark MainMenuViewControllerDelegate methods

- (void)presentStory:(MainMenuViewController *)controller
{
	StoryViewController *storyVC = [[StoryViewController alloc] init];
	[storyVC setStoryToShow:@"intro"];
	[storyVC loadFirstStoryFrame];
	[storyVC setDelegate:self];
	self.storyViewController = storyVC;
	[storyVC release];
	self.currentViewController = self.storyViewController;
}

- (void)mainMenuViewControllerPlayButtonPressed:(MainMenuViewController *)controller {
	
	// before we go into the map view pause any background music
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	
	MapViewController *mapVC = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
	self.mapViewController = mapVC;
	self.mapViewController.delegate = self;
	[mapVC release];
	self.currentViewController = self.mapViewController;
}

- (void)mainMenuViewControllerStoryButtonPressed:(MainMenuViewController *)controller
{
	[self presentStory:nil];
}


- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif {
	if (app.applicationState == UIApplicationStateActive) {
		//if app is active, we never saw the notification
		[self.mapViewController encounterEnemyShouldConfirm:YES];
	}
	else {
		//else we already said we wanted to fight
		[self.mapViewController encounterEnemyShouldConfirm:NO];
	}

   
}

@end

