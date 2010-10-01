//
//  Trek.h
//  RunQuest
//
//  Created by Joe Walsh on 9/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Segment;
@class CLLocation;
@interface Trek : NSManagedObject {

}

@property (nonatomic, retain) NSSet* segments;
@property (readonly) NSTimeInterval	duration;
@property (nonatomic, retain) NSDate *date;
@property (readonly) NSArray *orderedSegments;
@property (readonly) Segment *oldestSegment;
@property (readonly) Segment *newestSegment;
@property (readonly) BOOL isStopped;

- (id)initWithLocation:(CLLocation *)location inManagedObjectContext:(NSManagedObjectContext *)moc;
- (void)addLocation:(CLLocation *)location;
- (void)startWithLocation:(CLLocation *)location;
- (void)stop;

@end

@interface Trek (CoreDataGeneratedAccessors)
- (void)addSegmentsObject:(Segment *)value;
- (void)removeSegmentsObject:(Segment *)value;
- (void)addSegments:(NSSet *)value;
- (void)removeSegments:(NSSet *)value;
@end