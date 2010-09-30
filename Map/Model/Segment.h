//
//  Trek.h
//  RunQuest
//
//  Created by Joe Walsh on 9/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>

@interface Segment : NSManagedObject {
}

@property (nonatomic, readonly) double			averageSpeed;
@property (nonatomic, readonly) double			distance;
@property (nonatomic, readonly) NSTimeInterval	duration;
@property (nonatomic, readonly) BOOL			isStopped;
@property (nonatomic, retain)	NSMutableArray*	locations;
@property (nonatomic, retain)	NSDate*			startDate;
@property (nonatomic, retain)	NSDate*			stopDate;

- (id)initWithLocation:(CLLocation *)location inManagedObjectContext:(NSManagedObjectContext *)moc;
- (void)addLocation:(CLLocation *)location;
- (void)stop;

@end
