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
@dynamic segments;


- (id)initWithLocation:(CLLocation *)location inManagedObjectContext:(NSManagedObjectContext *)moc {
	NSEntityDescription *trekEntity = [NSEntityDescription entityForName:@"Trek" inManagedObjectContext:moc];
	if (( self = [super initWithEntity:trekEntity insertIntoManagedObjectContext:moc] )) {
		[self addNewSegmentWithLocation:location];
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

- (NSDate *)date {
	if ( [self.segments count] == 1 )
		return [[self.segments anyObject] date];
	else if ( [self.segments count] > 1 )
		return [[[self orderedSegments] objectAtIndex:0] date];
	else
		return nil;
}

- (BOOL)isStopped {
	return self.newestSegment.isStopped;
}

- (NSTimeInterval)duration {
	return (NSTimeInterval)[[self.segments valueForKeyPath:@"@sum.duration"] doubleValue];
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
