//
//  CLLocation+RQAdditions.m
//  RunQuest
//
//  Created by Joe Walsh on 11/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CLLocation+RQAdditions.h"

CLLocationDistance CLLocationDistanceBetweenCoordinates(CLLocationCoordinate2D startCoordinate, CLLocationCoordinate2D endCoordinate) {
	double deltaX = startCoordinate.longitude - endCoordinate.longitude;
	double deltaY = startCoordinate.latitude - endCoordinate.latitude;
	return sqrt(deltaX*deltaX + deltaY*deltaY);
}

double AngleBetweenCoordinates(CLLocationCoordinate2D startCoordinate, CLLocationCoordinate2D endCoordinate) {
	double deltaX = startCoordinate.longitude - endCoordinate.longitude;
	double deltaY = startCoordinate.latitude - endCoordinate.latitude;
	return atan(deltaX/deltaY);
}

@implementation CLLocation (RQAdditions)


- (double)angleToLocation:(CLLocation *)location {
	return AngleBetweenCoordinates(self.coordinate, location.coordinate);
}

@end
