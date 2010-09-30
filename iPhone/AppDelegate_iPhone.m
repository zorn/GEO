//
//  AppDelegate_iPhone.m
//  RunQuest
//
//  Created by Joe Walsh on 9/11/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "AppDelegate_iPhone.h"
#import "MapViewController.h"
#import "MainMenuViewController.h"
#import "TrekListViewController.h"
#import "CDAudioManager.h"
#import "SimpleAudioEngine.h"

@implementation AppDelegate_iPhone
@synthesize currentViewController, mainMenuViewController, mapViewController, storyViewController, settingsViewController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    // Override point for customization after application launch.
	[self updateAudioSystemVolumeSettings];
	
	[self setCurrentViewController:[self mainMenuViewController] animated:NO];
	[self.window addSubview:self.currentViewController.view];	
    [self.window makeKeyAndVisible];
	[[CDAudioManager sharedManager] setMode:kAMM_FxPlusMusicIfNoOtherAudio];
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
	[regDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"RQSoundMuteIPod"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:regDictionary];
}


- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
   
    [super applicationDidReceiveMemoryWarning:application];
}

- (void)dealloc {
	[mapViewController release];
	[settingsViewController release];
	[mainMenuViewController release];
	[currentViewController release];
	[super dealloc];
}

- (void)setCurrentViewController:(UIViewController *)to animated:(BOOL)animate {
	void (^switchBlock)(BOOL) = ^(BOOL finished){
		if (finished) {
			[self.window addSubview:to.view];
			[currentViewController.view removeFromSuperview];
			[currentViewController release];
			currentViewController = [to retain];
		}};
	
	if ( animate ) {
		UIViewAnimationOptions options = ( [to isKindOfClass:[MainMenuViewController class]] ? UIViewAnimationOptionTransitionCurlDown : UIViewAnimationOptionTransitionCurlUp );
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
#pragma mark MainMenuViewControllerDelegate methods

- (void)presentStory:(MainMenuViewController *)controller
{
	StoryViewController *storyVC = [[StoryViewController alloc] init];
	[storyVC setDelegate:self];
	self.storyViewController = storyVC;
	[storyVC release];
	self.currentViewController = self.storyViewController;
}

- (void)mainMenuViewControllerPlayButtonPressed:(MainMenuViewController *)controller {
	MapViewController *mapVC = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
	self.mapViewController = mapVC;
	[mapVC release];
	self.currentViewController = self.mapViewController;
}

- (void)mainMenuViewControllerOptionsButtonPressed:(MainMenuViewController *)controller
{
	SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
	[settingsVC setDelegate:self];
	self.settingsViewController = settingsVC;
	[settingsVC release];
	self.currentViewController = self.settingsViewController;
}

- (void)mainMenuViewControllerTreksButtonPressed:(MainMenuViewController *)controller {
	TrekListViewController *trekListVC = [[TrekListViewController alloc] initWithNibName:@"TrekListView" bundle:nil];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"Trek" inManagedObjectContext:self.managedObjectContext]];
	[request setSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO], nil]];
	
	NSFetchedResultsController *resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Treks"];
	[request release];
	
	trekListVC.fetchedResultsController= resultsController;
	[resultsController release];
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:trekListVC];
	UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBrowsingTreks:)];
	navController.navigationBar.topItem.rightBarButtonItem = doneItem;
	[doneItem release];

	self.currentViewController = navController;
	
	[navController release];
	
	
}

- (IBAction)doneBrowsingTreks:(id)sender {
	
	self.currentViewController = [self mainMenuViewController];
}

@end

