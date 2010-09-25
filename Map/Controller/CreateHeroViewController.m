//
//  CreateHeroViewController.m
//  RunQuest
//
//  Created by Michael Zornek on 9/25/10.
//  Copyright 2010 Clickable Bliss. All rights reserved.
//

#import "CreateHeroViewController.h"
#import "RQModelController.h"
#import "M3CoreDataManager.h"
#import "RQMob.h"
#import "RQHero.h"
#import "RQEnemy.h"

@implementation CreateHeroViewController

#pragma mark -
#pragma mark Initialization

- (id)init
{
	if (self = [super initWithNibName:@"CreateHeroView" bundle:nil]) {
		
	}
	return self;
}

- (void)dealloc 
{
	// ..
	[super dealloc];
}

@synthesize heroNameTextField;
@synthesize delegate;

- (IBAction)createHeroButtonPressed:(id)sender
{
	//[self.heroNameTextField resignFirstResponder];
	NSString *newHeroName = [self.heroNameTextField text];
	if (!newHeroName || newHeroName.length <= 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Name Required" message:@"Please type in a name." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show]; [alert release];
		[self.heroNameTextField setText:@"Lazy Tester"];
		return;
	}
	RQHero *hero = [[RQModelController defaultModelController] hero];
	[hero setName:newHeroName];
	[hero setMaxHP:30];
	[hero setCurrentHP:30];
	[hero setLevel:5];
	[hero setStamina:0];
	[[[RQModelController defaultModelController] coreDataManager] save];
	[delegate createHeroViewControllerDidEnd:self];
}

@end
