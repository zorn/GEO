//
//  CLLocation+RQAdditions.h
//  RunQuest
//
//  Created by Joe Walsh on 11/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

double AngleBetweenCoordinates(CLLocationCoordinate2D startCoordinate, CLLocationCoordinate2D endCoordinate);

@interface CLLocation (RQAdditions)

- (double)angleToLocation:(CLLocation *)location;

@end
