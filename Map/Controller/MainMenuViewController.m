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
		
		CreateHeroViewController *vc = [[CreateHeroViewController alloc] init];
		[vc setDelegate:self];
		[self presentModalViewController:vc animated:YES];
		[vc release];
	} else {
		[delegate mainMenuViewControllerPlayButtonPressed:self];
	}	
}

- (IBAction)optionsButtonPressed:(id)sender
{
	[delegate mainMenuViewControllerTreksButtonPressed:self];
}

#pragma mark -
#pragma mark CreateHeroViewControllerDelegate methods

- (void)createHeroViewControllerDidEnd:(CreateHeroViewController *)controller;
{
	[self dismissModalViewControllerAnimated:YES];
	[delegate mainMenuViewControllerPlayButtonPressed:self];
}


@end
