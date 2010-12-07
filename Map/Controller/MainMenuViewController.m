    //
//  MainMenuViewController.m
//  RunQuest
//
//  Created by Michael Zornek on 9/24/10.
//  Copyright 2010 Clickable Bliss. All rights reserved.
//

#import "MainMenuViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "RQModelController.h"
#import "M3CoreDataManager.h"
#import "RQHero.h"
#import "CreateHeroViewController.h"
#import "SimpleAudioEngine.h"

// controllers
#import "TrekListViewController.h"
#import "WeightLogViewController.h"
#import "SettingsViewController.h"
#import "DeveloperToolboxViewController.h"

@implementation MainMenuViewController

@synthesize delegate;
@synthesize visitDrGordonButton;

#pragma mark -
#pragma mark Initialization

- (id)init
{
	if (self = [super initWithNibName:@"MainMenuView" bundle:nil]) {
		self.wantsFullScreenLayout = YES;
	}
	return self;
}

- (void)dealloc 
{
	// ..
	[visitDrGordonButton release];
	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if (![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying]) {
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"menu_music.m4a" loop:YES];
	}
	
	RQHero *hero = [[RQModelController defaultModelController] hero];
	if ([hero isLevelCapped]) {
		self.visitDrGordonButton.hidden = NO;
	} else {
		self.visitDrGordonButton.hidden = YES;
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	//[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	[super viewWillAppear:animated];
}

- (IBAction)playButtonPressed:(id)sender
{
	NSLog(@"playButtonPressed");
	
	RQModelController *modelController = [RQModelController defaultModelController];
	if ([modelController newestTrek] == nil) {
		
		// Used to have a window to ask for hero name .. taking it out for now
		RQHero *hero = [modelController hero];
		[hero setName:@"Hero"];
		[hero setCurrentHP:[hero maxHP]];
		[hero setLevel:1];
		[hero setStamina:0];
		[[modelController coreDataManager] save];
		
		[delegate presentStory:self];
		
	} else {
		[delegate mainMenuViewControllerPlayButtonPressed:self];
	}	
}

- (IBAction)optionsButtonPressed:(id)sender
{
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
	SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
	[settingsVC setDelegate:self];
	[self presentModalViewController:settingsVC animated:YES];
	[settingsVC release];
}

- (IBAction)visitDrGordon:(id)sender
{
	// start up story and last battle
	NSLog(@"visitDrGordon: called ...");
}

- (IBAction)logButtonPressed:(id)sender
{
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
	
	//[delegate mainMenuViewControllerTreksButtonPressed:self];
	// BUILD Trek Log
	TrekListViewController *trekListVC = [[TrekListViewController alloc] init];
	UINavigationController *trekNavController = [[UINavigationController alloc] initWithRootViewController:trekListVC];
	[trekListVC release];
	trekNavController.navigationBar.barStyle = UIBarStyleBlack;
	
	UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBrowsingLogBook:)];
	trekNavController.navigationBar.topItem.rightBarButtonItem = doneItem;
	
	// BUILD Weight Log
	WeightLogViewController *weightVC = [[WeightLogViewController alloc] init];
	UINavigationController *weightNavController = [[UINavigationController alloc] initWithRootViewController:weightVC];
	weightNavController.navigationBar.topItem.rightBarButtonItem = doneItem;
	weightNavController.navigationBar.barStyle = UIBarStyleBlack;

	[weightVC release];
	
	[doneItem release];
	
	// BUILD tab controller
	UITabBarController *tabBarController = [[UITabBarController alloc] init];
	tabBarController.viewControllers = [NSArray arrayWithObjects:trekNavController, weightNavController, nil];
	[trekNavController release];
	[weightNavController release];
	
	[self presentModalViewController:tabBarController animated:YES];
	[tabBarController release];
}

- (IBAction)developerToolboxButtonPressed:(id)sender
{
	//[delegate mainMenuViewControllerDeveloperToolboxButtonPressed:self];
	DeveloperToolboxViewController *devVC = [[DeveloperToolboxViewController alloc] init];
	[devVC setDelegate:self];
	UINavigationController *developerToolboxNavigationController = [[UINavigationController alloc] initWithRootViewController:devVC];
	[devVC release];
	[self presentModalViewController:developerToolboxNavigationController animated:YES];
	[developerToolboxNavigationController release];
}


- (IBAction)storyButtonPressed:(id)sender
{
	// because the story currently pushed them into the mapview we should make sure they have a hero first
	RQModelController *modelController = [RQModelController defaultModelController];
	if (![modelController heroExists]) {
		[self playButtonPressed:self];
	}
	
	[delegate mainMenuViewControllerStoryButtonPressed:self];
}

- (IBAction)doneBrowsingLogBook:(id)sender
{	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)doneBrowsingDevToolbox:(id)sender
{	
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark SettingsViewControllerDelegate methods

- (void)settingsViewControllerDidEnd:(SettingsViewController *)controller;
{
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark DeveloperToolboxViewControllerDelegate Methods

- (void)developerToolboxViewControllerDidEnd:(DeveloperToolboxViewController *)controller
{
	[self dismissModalViewControllerAnimated:YES];
}

@end
