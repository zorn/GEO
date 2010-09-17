//
//  Enemy.m
//  RunQuest
//
//  Created by Joe Walsh on 9/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Enemy.h"


@implementation Enemy
@synthesize spriteURL;

- (id)initWithCoordinate:(CLLocationCoordinate2D)initialCoordinate {
	if (( self = [super init] )) {
		_coordinate = initialCoordinate;
	}return self;
}


- (CLLocationCoordinate2D)coordinate {
	return _coordinate;
}


@end
