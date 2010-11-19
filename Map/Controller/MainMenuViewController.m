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

// controllers
#import "TrekListViewController.h"
#import "WeightLogViewController.h"
#import "SettingsViewController.h"
#import "DeveloperToolboxViewController.h"

@implementation MainMenuViewController

@synthesize delegate;

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
	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	[super viewWillAppear:animated];
}

- (IBAction)playButtonPressed:(id)sender
{
	NSLog(@"playButtonPressed");
	
	RQModelController *modelController = [RQModelController defaultModelController];
	if (![modelController heroExists]) {
		
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
	SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
	[settingsVC setDelegate:self];
	[self presentModalViewController:settingsVC animated:YES];
	[settingsVC release];
}

- (IBAction)logButtonPressed:(id)sender
{
	//[delegate mainMenuViewControllerTreksButtonPressed:self];
	// BUILD Trek Log
	TrekListViewController *trekListVC = [[TrekListViewController alloc] init];
	UINavigationController *trekNavController = [[UINavigationController alloc] initWithRootViewController:trekListVC];
	[trekListVC release];
	UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBrowsingLogBook:)];
	trekNavController.navigationBar.topItem.rightBarButtonItem = doneItem;
	
	// BUILD Weight Log
	WeightLogViewController *weightVC = [[WeightLogViewController alloc] init];
	UINavigationController *weightNavController = [[UINavigationController alloc] initWithRootViewController:weightVC];
	weightNavController.navigationBar.topItem.rightBarButtonItem = doneItem;
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
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark DeveloperToolboxViewControllerDelegate Methods

- (void)developerToolboxViewControllerDidEnd:(DeveloperToolboxViewController *)controller
{
	[self dismissModalViewControllerAnimated:YES];
}

@end
