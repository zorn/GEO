//
//  Trek.m
//  RunQuest
//
//  Created by Joe Walsh on 9/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Segment.h"

#define INITIAL_LOCATION_SPACE 1000
#define INITIAL_SEGMENT_SPACE  1000
@implementation Segment
@dynamic locations, startDate, stopDate, trek;

- (id)initWithLocation:(CLLocation *)location inManagedObjectContext:(NSManagedObjectContext *)moc {
	NSEntityDescription *segmentEntity = [NSEntityDescription entityForName:@"Segment" inManagedObjectContext:moc];
	if (( self = [super initWithEntity:segmentEntity insertIntoManagedObjectContext:moc] )) {
		NSMutableArray *initalLocationsArray = [[NSMutableArray alloc] initWithCapacity:INITIAL_LOCATION_SPACE];
		self.locations = initalLocationsArray;
		[initalLocationsArray release];
		
		self.startDate = [NSDate date];
		
	} return self;
}

- (void)awakeFromFetch {
	[super awakeFromFetch];
}

- (NSComparisonResult)compare:(Segment  *)segment{
	return [self.startDate compare:segment.startDate];
}

- (void)dealloc {
	[super dealloc];
}

- (NSTimeInterval)duration {
	NSDate *startTime = self.startDate;
	NSDate *endTime =  ( self.isStopped ? self.stopDate : [NSDate date]);
	return [endTime timeIntervalSinceDate:startTime];
}

- (void)stop {
	if ( !self.isStopped )
		self.stopDate = [NSDate date];
}

- (BOOL)isStopped {
	return ( self.stopDate != nil );
}

- (void)addLocation:(CLLocation *)location {
	NSMutableArray *locationsCopy = [[self locations] mutableCopy];
	[locationsCopy addObject:location];
	self.locations = locationsCopy;
}

- (double)averageSpeed {
	return [self distance]/[self duration];
}

- (double)distance {
	CLLocationDistance dist = 0;
	NSUInteger i = 1;
	for ( CLLocation *location in self.locations) {
		if ( i < [self.locations count] ) {
			dist+= [[self.locations objectAtIndex:i] distanceFromLocation:location];
		}
		i++;
	}
	return (double)dist;
}

@end
