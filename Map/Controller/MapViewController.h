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
#import "RQBattleViewController.h"

@class Trek;
@class AppDelegate_Shared;

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, RQBattleViewControllerDelegate> {
	id <MKOverlay> _pathOverlay;
	
	Sonar *_sonar;
	SonarView *_sonarView;
	
	AppDelegate_Shared *appDelegate;
	
	NSMutableSet *_enemies;
	NSMutableSet *_enemyViews;
	
	NSDate *_lastEnemyUpdate;
	
	NSNumberFormatter *_speedFormatter;
	
	NSMutableSet *_timers;
}

@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIView *hudView;
@property (nonatomic, retain) IBOutlet UILabel *overlayLabel;
@property (nonatomic, retain) IBOutlet UILabel *speedLabel;
@property (nonatomic, retain) IBOutlet UILabel *durationLabel;
@property (nonatomic, retain) Trek *trek;
@property (nonatomic, retain) CADisplayLink *displayLink;
@property (nonatomic, retain) IBOutlet UIButton *launchBattleButton;

- (IBAction)launchBattlePressed:(id)sender;
- (IBAction)startStopPressed:(id)sender;

- (void)stopUpdatingLocation;
- (void)startUpdatingLocation;

@end
