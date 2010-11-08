//
//  RQMonsterTemplate.m
//  RunQuest
//
//  Created by Michael Zornek on 11/8/10.
//  Copyright 2010 Clickable Bliss. All rights reserved.
//

#import "RQMonsterTemplate.h"


@implementation RQMonsterTemplate

#pragma mark -
#pragma mark Initialization

- (id)init
{
	if (self = [super init]) {
		type = RQElementalTypeNone;
		movementType = RQMonsterMovementTypeFlying;
	}
	return self;
}

- (void)dealloc
{
	[name release]; name = nil;
	[imageFileName release]; imageFileName = nil;
	[super dealloc];
}

@synthesize name;
@synthesize type;
@synthesize imageFileName;
@synthesize movementType;

@end
