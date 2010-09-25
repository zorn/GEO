//
//  Enemy.h
//  RunQuest
//
//  Created by Joe Walsh on 9/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>
#import <pthread.h>

@interface EnemyMapSpawn : NSManagedObject <MKAnnotation> {
	CLLocationCoordinate2D _coordinate;
}

@property (nonatomic) double speed;
@property (nonatomic) double heading;

- (id)initWithCoordinate:(CLLocationCoordinate2D)initialCoordinate inManagedObjectContext:(NSManagedObjectContext *)moc;

@end
