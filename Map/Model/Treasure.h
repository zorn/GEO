//
//  Treasure.h
//  RunQuest
//
//  Created by Joe Walsh on 11/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Treasure : NSObject <MKAnnotation> {

}

@property (readwrite) NSTimeInterval lifetime;
@property (readwrite) NSTimeInterval remaining;

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;


- (id)initWithLifetime:(NSTimeInterval)lifetime_ coordinate:(CLLocationCoordinate2D)coordinate_;

@end
