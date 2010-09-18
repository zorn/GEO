//
//  RQMapViewController.h
//  RunQuest
//
//  Created by Joe Walsh on 9/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Sonar.h"
#import "SonarView.h"

@class Trek;
@class AppDelegate_Shared;

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate> {
	CLLocationManager *_locationManager;
	
	Trek *trek;
	
	id <MKOverlay> _pathOverlay;
	
	Sonar *_sonar;
	SonarView *_sonarView;
	
	AppDelegate_Shared *appDelegate;
	
	NSMutableSet *_enemies;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIView *hudView;
@property (nonatomic, retain) IBOutlet UILabel *overlayLabel;

@property (nonatomic, retain) CADisplayLink *displayLink;
@end
