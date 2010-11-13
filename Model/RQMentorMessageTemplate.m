//
//  RQMentorMessageTemplate.m
//  RunQuest
//
//  Created by Michael Zornek on 11/11/10.
//  Copyright 2010 Clickable Bliss. All rights reserved.
//

#import "RQMentorMessageTemplate.h"


@implementation RQMentorMessageTemplate

#pragma mark -
#pragma mark Initialization

- (id)init
{
	if (self = [super init]) {
		eventType = RQMessageEventTypeRandom;
		relatedToMechanic = RQMechanicNone;
	}
	return self;
}

- (void)dealloc
{
	[message release]; message = nil;
	[super dealloc];
}

@synthesize eventType;
@synthesize relatedToMechanic;
@synthesize message;

@end
