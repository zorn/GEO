    //
//  DeveloperToolboxViewController.m
//  RunQuest
//
//  Created by Michael Zornek on 10/15/10.
//  Copyright 2010 Clickable Bliss. All rights reserved.
//

#import "DeveloperToolboxViewController.h"
#import "CorePlotTestViewController.h"
#import "AppDelegate_iPhone.h"

@implementation DeveloperToolboxViewController

#pragma mark -
#pragma mark Initialization

- (id)init
{
	if (self = [super initWithNibName:@"DeveloperToolboxView" bundle:nil]) {
		[[self navigationItem] setTitle:@"Developer Toolbox"];
		UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(returnToMainMenu)];
		[[self navigationItem] setLeftBarButtonItem:newBackButton];
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
	[(AppDelegate_iPhone *)[[UIApplication sharedApplication] delegate] presentStory:nil];
}

- (void)returnToMainMenu
{
	[self.delegate developerToolboxViewControllerDidEnd:self];
}

@end
