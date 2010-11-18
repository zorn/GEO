//
//  CLLocation+RQAdditions.h
//  RunQuest
//
//  Created by Joe Walsh on 11/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define DEGREES_PER_RADIAN 57.2957795f
#define RADIANS_PER_DEGREE 0.0174532925f

double AngleBetweenCoordinates(CLLocationCoordinate2D startCoordinate, CLLocationCoordinate2D endCoordinate);

@interface CLLocation (RQAdditions)

- (double)angleToLocation:(CLLocation *)location;

@end
