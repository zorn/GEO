    //
//  MainMenuViewController.m
//  RunQuest
//
//  Created by Michael Zornek on 9/24/10.
//  Copyright 2010 Clickable Bliss. All rights reserved.
//

#import "MainMenuViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation MainMenuViewController

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

- (IBAction)playButtonPressed:(id)sender
{
	NSLog(@"playButtonPressed");
}

- (IBAction)optionsButtonPressed:(id)sender
{
	NSLog(@"optionsButtonPressed");
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

@end
