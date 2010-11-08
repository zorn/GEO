    //
//  DeveloperToolboxViewController.m
//  RunQuest
//
//  Created by Michael Zornek on 10/15/10.
//  Copyright 2010 Clickable Bliss. All rights reserved.
//

#import "DeveloperToolboxViewController.h"
#import "AppDelegate_iPhone.h"

// Controllers
#import "HeroEditViewController.h"
#import "CorePlotTestViewController.h"

@implementation DeveloperToolboxViewController

#pragma mark -
#pragma mark Initialization

- (id)init
{
	if (self = [super initWithNibName:@"DeveloperToolboxView" bundle:nil]) {
		[[self navigationItem] setTitle:@"Developer Toolbox"];
		UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(returnToMainMenu)];
		[[self navigationItem] setRightBarButtonItem:newBackButton];
		self.wantsFullScreenLayout = YES;
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

@synthesize delegate;

- (IBAction)loadCorePlotDemoOne:(id)sender
{
	CorePlotTestViewController *controller = [[CorePlotTestViewController alloc] init];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}

- (IBAction)watchStory:(id)sender
{
	//[(AppDelegate_iPhone *)[[UIApplication sharedApplication] delegate] presentStory:nil];
	StoryViewController *storyVC = [[StoryViewController alloc] init];
	[storyVC setDelegate:self];
	[self presentModalViewController:storyVC animated:YES];
	[storyVC release];
	
}

- (IBAction)editHero:(id)sender
{
	HeroEditViewController *controller = [[HeroEditViewController alloc] init];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}

- (void)returnToMainMenu
{
	[self.delegate developerToolboxViewControllerDidEnd:self];
}

#pragma mark -
#pragma mark StoryViewControllerDelegate methods

- (void)storyViewControllerDidEnd:(StoryViewController *)controller
{
	[self dismissModalViewControllerAnimated:YES];
}

@end
