//
//  RQWeaponSprite.m
//  RunQuest
//
//  Created by Michael Zornek on 9/20/10.
//  Copyright 2010 Clickable Bliss. All rights reserved.
//

#import "RQWeaponSprite.h"

@implementation RQWeaponSprite

- (void)dealloc
{
	[touch release]; touch = nil;
	[weaponDetails release]; weaponDetails = nil;
	[super dealloc];
}

@synthesize weaponDetails;
@synthesize stamina;
@synthesize touch;

- (void)updateView
{
	
}

@end
