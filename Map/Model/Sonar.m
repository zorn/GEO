//
//  SonarObjects.m
//  RunQuest
//
//  Created by Joe Walsh on 9/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Sonar.h"

#define INITIAL_POINT_SPACE 1000

@interface Sonar (Private)
- (void)setRange:(CLLocationDegrees)range;

@end


@implementation Sonar
@synthesize radius, range;

- (id)initWithCoordinate:(CLLocationCoordinate2D)initialCoordinate range:(CLLocationDistance)sonarRange{
	if (( self = [super init] )) {
		coordinate = initialCoordinate;
		self.range = sonarRange;
		// bite off up to 1/4 of the world to draw into.
        MKMapPoint origin = MKMapPointForCoordinate(initialCoordinate);
        origin.x -= MKMapSizeWorld.width / 8.0;
        origin.y -= MKMapSizeWorld.height / 8.0;
        MKMapSize size = MKMapSizeWorld;
        size.width /= 4.0;
        size.height /= 4.0;
        _boundingMapRect = (MKMapRect) { origin, size };
        MKMapRect worldRect = MKMapRectMake(0, 0, MKMapSizeWorld.width, MKMapSizeWorld.height);
        _boundingMapRect = MKMapRectIntersection(_boundingMapRect, worldRect);
		
		// initialize read-write lock for drawing and updates
        pthread_rwlock_init(&rwLock, NULL);
		
	} return self;
}

- (MKMapRect)boundingMapRect {
	return _boundingMapRect;
}

- (CLLocationCoordinate2D)coordinate {
	return coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)sonarCoordinate {
	pthread_rwlock_wrlock(&rwLock);
	coordinate = sonarCoordinate;
	pthread_rwlock_unlock(&rwLock);
}	

- (void)setRadius:(CLLocationDegrees)sonarRadius {
	pthread_rwlock_wrlock(&rwLock);
	radius = sonarRadius;
	pthread_rwlock_unlock(&rwLock);
}	

- (void)dealloc {
	pthread_rwlock_destroy(&rwLock);
	[super dealloc];
}

- (void)setRange:(CLLocationDegrees)sonarRange {
	pthread_rwlock_wrlock(&rwLock);
	range = sonarRange;
	pthread_rwlock_unlock(&rwLock);
}


#pragma mark Read Lock

- (void)lockForReading
{
    pthread_rwlock_rdlock(&rwLock);
}

- (void)unlockForReading
{
    pthread_rwlock_unlock(&rwLock);
}


@end
