//
//  Enemy.m
//  RunQuest
//
//  Created by Joe Walsh on 9/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EnemyMapSpawn.h"


@interface EnemyMapSpawn (CoreData) 
@property (nonatomic, retain) NSNumber * headingNumber;
@property (nonatomic, retain) NSNumber * latitudeNumber;
@property (nonatomic, retain) NSNumber * longitudeNumber;
@property (nonatomic, retain) NSNumber * speedNumber;
@end

@implementation EnemyMapSpawn (CoreData)
@dynamic headingNumber;
@dynamic latitudeNumber;
@dynamic longitudeNumber;
@dynamic speedNumber;
@end

@implementation EnemyMapSpawn

- (id)initWithCoordinate:(CLLocationCoordinate2D)initialCoordinate inManagedObjectContext:(NSManagedObjectContext *)moc {
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"EnemyMapSpawn" inManagedObjectContext:moc];
	if (( self = [super initWithEntity:entity insertIntoManagedObjectContext:moc] )) {
		self.coordinate = initialCoordinate;
		self.speed = 0;
		self.heading = 0;
	}return self;
}

- (void)awakeFromFetch {
	_coordinate = CLLocationCoordinate2DMake([self.latitudeNumber doubleValue], [self.longitudeNumber doubleValue]);
}

- (double)speed {
	return [self.speedNumber doubleValue];
}

- (double)heading {
	return [self.headingNumber doubleValue];
}

- (void)setSpeed:(double)theSpeed {
	self.speedNumber = [NSNumber numberWithDouble:theSpeed];
}

- (void)setHeading:(double)theHeading {
	self.headingNumber = [NSNumber numberWithDouble:theHeading];
}

- (CLLocationCoordinate2D)coordinate {
	return _coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
	_coordinate = newCoordinate;
	self.longitudeNumber = [NSNumber numberWithDouble:_coordinate.longitude];
	self.latitudeNumber = [NSNumber numberWithDouble:_coordinate.latitude];
}


@end
