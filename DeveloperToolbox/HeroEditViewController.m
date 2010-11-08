    //
//  HeroEditViewController.m
//  RunQuest
//
//  Created by Michael Zornek on 11/1/10.
//  Copyright 2010 Clickable Bliss. All rights reserved.
//

#import "HeroEditViewController.h"

// Models
#import "RQModelController.h"
#import "RQHero.h"

@implementation HeroEditViewController

#pragma mark -
#pragma mark Initialization

- (id)init
{
	if (self = [super initWithNibName:@"HeroEditView" bundle:nil]) {
		self.wantsFullScreenLayout = YES;
	}
	return self;
}

- (void)dealloc
{
	// outlets
	[heroCurrentLevelLabel release]; heroCurrentLevelLabel = nil;
	[heroLevelSlider release]; heroLevelSlider = nil;
	[super dealloc];
}

@synthesize heroCurrentLevelLabel;
@synthesize heroLevelSlider;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{ 
	[super viewDidLoad];
	
	RQHero *hero = [[RQModelController defaultModelController] hero];
	
	[self.heroLevelSlider setValue:hero.level];
	[self.heroCurrentLevelLabel setText:[NSString stringWithFormat:@"Current Hero Level: %i", hero.level]];
}

- (void)viewWillDisappear:(BOOL)animated
{ 
	[[RQModelController defaultModelController] save];
	[super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark Actions

- (IBAction)heroLevelSliderValueChanged:(id)sender
{
	RQHero *hero = [[RQModelController defaultModelController] hero];
	NSInteger newLevel = round(self.heroLevelSlider.value);
	NSInteger newXPTotal = [RQMob expectedExperiencePointTotalGivenLevel:newLevel];
	[hero setLevel:newLevel];
	[hero setExperiencePoints:newXPTotal];
	
	[self.heroCurrentLevelLabel setText:[NSString stringWithFormat:@"Current Hero Level: %i", hero.level]];
}


@end
