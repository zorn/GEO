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

@implementation MainMenuViewController

@synthesize delegate;

#pragma mark -
#pragma mark Initialization

- (id)init
{
	if (self = [super initWithNibName:@"MainMenuView" bundle:nil]) {
		
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
	[delegate mainMenuViewControllerOptionsButtonPressed:self];
}

- (IBAction)logButtonPressed:(id)sender
{
	[delegate mainMenuViewControllerTreksButtonPressed:self];
}

- (IBAction)developerToolboxButtonPressed:(id)sender
{
	[delegate mainMenuViewControllerDeveloperToolboxButtonPressed:self];
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

@end
