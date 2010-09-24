    //
//  RQBattleVictoryViewController.m
//  RunQuest
//
//  Created by Michael Zornek on 9/22/10.
//  Copyright 2010 Clickable Bliss. All rights reserved.
//

#import "RQBattleVictoryViewController.h"
#import "RQBattleViewController.h"

@implementation RQBattleVictoryViewController

- (id)init
{
	if (self = [super initWithNibName:@"BattleVictoryView" bundle:nil]) {
		
	}
	return self;
}

- (void)dealloc 
{
	NSLog(@"RQBattleVictoryViewController -dealloc called...");
	[super dealloc];
}

@synthesize delegate;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSLog(@"RQBattleVictoryViewController -viewDidLoad");

	UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
	[recognizer setNumberOfTapsRequired:2];
	[self.view addGestureRecognizer:recognizer];
	[recognizer release]; recognizer = nil;
}

- (void)tapRecognized:(UIGestureRecognizer *)recognizer
{
	[delegate battleVictoryControllerDidEnd:self];
}

@end
