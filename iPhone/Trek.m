//
//  Trek.m
//  RunQuest
//
//  Created by Joe Walsh on 9/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Trek.h"

#define INITIAL_LOCATION_SPACE 1000
#define INITIAL_SEGMENT_SPACE  1000
@implementation Trek
@dynamic segments, date;

- (id)initWithLocation:(CLLocation *)location inManagedObjectContext:(NSManagedObjectContext *)moc {
	NSEntityDescription *trekEntity = [NSEntityDescription entityForName:@"Trek" inManagedObjectContext:moc];
	if (( self = [super initWithEntity:trekEntity insertIntoManagedObjectContext:moc] )) {
		_locations = [[NSMutableArray alloc] initWithCapacity:INITIAL_LOCATION_SPACE];
		[_locations addObject:location];
		
		_segments = [[NSMutableArray alloc] initWithCapacity:INITIAL_SEGMENT_SPACE];
		[_segments addObject:_locations];
		
		self.segments = _segments;
		stopped = NO;
		
	} return self;
}

- (void)dealloc {
	[_locations release];
	[_segments release];
	[super dealloc];
}

- (void)awakeFromFetch {
	_segments = [self.segments mutableCopy];
	stopped = YES;
}

- (void)willSave {
	self.segments = _segments;
}


- (NSTimeInterval)duration {
	if ( self.isStopped ) {
		return 0;
	}
	else {
		NSDate *startTime = [(CLLocation *)[[_segments objectAtIndex:0] objectAtIndex:0] timestamp]; 
		return [[NSDate date] timeIntervalSinceDate:startTime];
	}

}

- (void)stop {
	stopped = YES;
}

- (BOOL)isStopped {
	return stopped;
}

- (void)addLocation:(CLLocation *)location {
	if ( !stopped )
		[_segments addObject:location];
}

- (double)averageSpeed {
	return 0;
}

- (double)distance {
	return 0;
}

@end
