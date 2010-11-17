//
//  Trek.m
//  RunQuest
//
//  Created by Joe Walsh on 9/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Trek.h"
#import "Segment.h"

@interface Trek (Private)
- (void)addNewSegmentWithLocation:(CLLocation *)location;
@end

@implementation Trek
@dynamic segments, date;


- (id)initWithLocation:(CLLocation *)location inManagedObjectContext:(NSManagedObjectContext *)moc {
	NSEntityDescription *trekEntity = [NSEntityDescription entityForName:@"Trek" inManagedObjectContext:moc];
	if (( self = [super initWithEntity:trekEntity insertIntoManagedObjectContext:moc] )) {
		[self addNewSegmentWithLocation:location];
		self.date = [NSDate date];
	} return self;
}

- (NSArray *)orderedSegments {
	return [[self.segments allObjects] sortedArrayUsingSelector:@selector(compare:)];
}

- (Segment *)oldestSegment {
	return [self.orderedSegments objectAtIndex:0];
}

- (Segment *)newestSegment {
	return [self.orderedSegments lastObject];
}

- (void)addLocation:(CLLocation *)location {
	[self.newestSegment addLocation:location];
}

- (BOOL)isStopped {
	return self.newestSegment.isStopped;
}

- (NSTimeInterval)duration
{	
	NSTimeInterval total = 0;
	for (Segment *s in self.segments) {
		total = total + s.duration;
	}
	return total;
	//return (NSTimeInterval)[[self.segments valueForKeyPath:@"@sum.duration"] doubleValue];
}

- (void)addNewSegmentWithLocation:(CLLocation *)location {
	Segment *segment = [[Segment alloc] initWithLocation:location inManagedObjectContext:[self managedObjectContext]];
	[self addSegmentsObject:segment];
	[segment release];
}

- (void)startWithLocation:(CLLocation *)location {
	if ( self.isStopped )
		[self addNewSegmentWithLocation:location];
}

- (void)stop {
	if ( ![self isStopped] )
		[self.newestSegment stop];
}

@end
