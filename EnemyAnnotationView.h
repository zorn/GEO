//
//  EnemyAnnotationView.h
//  RunQuest
//
//  Created by Joe Walsh on 9/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface EnemyAnnotationView : MKAnnotationView {
	BOOL pulsing;
}

@property (nonatomic,getter=isPulsing) BOOL pulsing; 

@end
