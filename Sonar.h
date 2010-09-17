//
//  SonarObjects.h
//  RunQuest
//
//  Created by Joe Walsh on 9/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <pthread.h>

@interface Sonar : NSObject <MKOverlay> {
	NSMutableArray *objects;
	
	CLLocationCoordinate2D coordinate;
	MKMapRect _boundingMapRect;
	
	CLLocationDegrees radius;
	CLLocationDegrees range;
	
	NSTimer *_timer;
	pthread_rwlock_t rwLock;
}

@property (nonatomic) CLLocationDegrees radius;
@property (nonatomic) CLLocationDegrees range;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

- (void)lockForReading;
- (void)unlockForReading;

- (id)initWithCoordinate:(CLLocationCoordinate2D)initialCoordinate range:(CLLocationDegrees)range;

@end

@protocol SonarObject

@end