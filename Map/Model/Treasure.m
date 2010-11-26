//
//  Treasure.m
//  RunQuest
//
//  Created by Joe Walsh on 11/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Treasure.h"


@implementation Treasure

@synthesize coordinate, lifetime, remaining;

- (id)initWithLifetime:(NSTimeInterval)lifetime_ coordinate:(CLLocationCoordinate2D)coordinate_ {
	if (( self = [super init] )) {
		self.coordinate = coordinate_;
		self.lifetime = lifetime_;
		self.remaining = lifetime_;
	} return self;
}

@end
