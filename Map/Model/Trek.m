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
@dynamic locations, date;

- (id)initWithLocation:(CLLocation *)location inManagedObjectContext:(NSManagedObjectContext *)moc {
	NSEntityDescription *trekEntity = [NSEntityDescription entityForName:@"Trek" inManagedObjectContext:moc];
	if (( self = [super initWithEntity:trekEntity insertIntoManagedObjectContext:moc] )) {
		NSMutableArray *initalLocationsArray = [[NSMutableArray alloc] initWithCapacity:INITIAL_LOCATION_SPACE];
		self.locations = initalLocationsArray;
		[initalLocationsArray release];
		
		self.date = [NSDate date];
		
		stopped = NO;
		
	} return self;
}

- (void)awakeFromFetch {
	stopped = YES;
	[super awakeFromFetch];
}

- (void)dealloc {
	[super dealloc];
}

- (NSTimeInterval)duration {
	NSDate *startTime = self.date;
	NSDate *endTime =  [NSDate date];
	if ( [self.locations count] ) {
		startTime = [(CLLocation *)[self.locations objectAtIndex:0] timestamp];
		if ( self.isStopped ) {
			endTime = [(CLLocation *)[self.locations lastObject] timestamp];
		}
	}
	return [endTime timeIntervalSinceDate:startTime];
}

- (void)stop {
	stopped = YES;
}

- (BOOL)isStopped {
	return stopped;
}

- (void)addLocation:(CLLocation *)location {
	[self.locations addObject:location];
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
