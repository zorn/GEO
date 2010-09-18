//
//  Enemy.h
//  RunQuest
//
//  Created by Joe Walsh on 9/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Enemy : NSObject <MKAnnotation> {
	CLLocationCoordinate2D _coordinate;
}

@property (nonatomic, retain) NSURL *spriteURL;

@end
