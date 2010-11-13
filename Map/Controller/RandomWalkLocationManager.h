//
//  RandomWalkLocationManager.h
//  RunQuest
//
//  Created by Joe Walsh on 11/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface RandomWalkLocationManager : CLLocationManager <CLLocationManagerDelegate> {
	CLLocationManager *_manager;
	CLLocationDirection _direction;
}
@property (nonatomic, retain) CLLocation *	destination;
@property (nonatomic, retain) CLLocation *	randomWalkLocation;
@property (nonatomic, retain) NSTimer *		timer;

@end
