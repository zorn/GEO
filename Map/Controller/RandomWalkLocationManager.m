//
//  RandomWalkLocationManager.m
//  RunQuest
//
//  Created by Joe Walsh on 11/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RandomWalkLocationManager.h"
#import "CLLocation+RQAdditions.h"

#define RANDOM_WALK_UPDATE_INTERVAL 0.15f
#define RANDOM_WALK_UPDATE_SPEED 20.0f
#define STEP_SIZE RANDOM_WALK_UPDATE_INTERVAL * RANDOM_WALK_UPDATE_SPEED
#define DIRECTION_VARIANCE .5f

#define METERS_PER_DEGREE 111000

@implementation RandomWalkLocationManager
@synthesize timer, randomWalkLocation, destination;

- (id)init {
	if (( self = [super init] )) {
		_manager = [[CLLocationManager alloc] init];
		_manager.delegate = self;
		srand([[NSDate date] timeIntervalSince1970]);
		_direction = 359.9f*rand()/RAND_MAX;
	} return self;
}

- (void)dealloc {
	[_manager release];
	[timer release];
	[destination release];
	[randomWalkLocation release];
	[super dealloc];
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {
	if ( !self.randomWalkLocation && newLocation ) {
		self.randomWalkLocation = newLocation;
		NSTimer *randomWalkTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:RANDOM_WALK_UPDATE_INTERVAL] interval:RANDOM_WALK_UPDATE_INTERVAL target:self selector:@selector(generateRandomLocation:) userInfo:nil repeats:YES];
		[[NSRunLoop mainRunLoop] addTimer:randomWalkTimer forMode:NSRunLoopCommonModes];
		self.timer = randomWalkTimer;
		[randomWalkTimer release];
		[self.delegate locationManager:self didUpdateToLocation:self.randomWalkLocation fromLocation:nil];
		[_manager stopUpdatingLocation];
	}
}

- (void)generateRandomLocation:(id)timer_ {
	if ( self.randomWalkLocation ) {
		
		if ( self.destination ) {
			_direction = [self.randomWalkLocation angleToLocation:self.destination]; 
		}
		else {
			double deltaDirection = DIRECTION_VARIANCE*rand()/RAND_MAX - DIRECTION_VARIANCE/2.0f;
			if ( deltaDirection + _direction < 359.9 && deltaDirection + _direction > 0.0f ) {
				_direction = _direction + deltaDirection;
			}
			else {
				_direction = 0.0f;
			}
		}
		
		CLLocationDistance deltaY = STEP_SIZE*sin(_direction)/METERS_PER_DEGREE;
		CLLocationDistance deltaX = STEP_SIZE*cos(_direction)/METERS_PER_DEGREE;
		
		CLLocationCoordinate2D newCoordinate = CLLocationCoordinate2DMake(self.randomWalkLocation.coordinate.latitude + deltaX, self.randomWalkLocation.coordinate.longitude + deltaY);
		CLLocation *newLocation = [[CLLocation alloc] initWithCoordinate:newCoordinate 
																altitude:0
													  horizontalAccuracy:1 
														verticalAccuracy:1  
																  course:0
																   speed:RANDOM_WALK_UPDATE_SPEED
															   timestamp:[NSDate date]];
		CLLocation *oldLocation = [self.randomWalkLocation copy];

		self.randomWalkLocation = newLocation;
		[self.delegate locationManager:self didUpdateToLocation:newLocation fromLocation:oldLocation];
		[oldLocation release];
		[newLocation release];
	}
}

- (CLLocation *)location {
	return self.randomWalkLocation;
}

- (void)startUpdatingLocation {
	[_manager startUpdatingLocation];
}

- (void)stopUpdatingLocation {
	[self.timer invalidate];
	self.timer = nil;
}

@end
