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

@protocol MapViewControllerDelegate;

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, RQBattleViewControllerDelegate> {
	
	id <MKOverlay> _pathOverlay;
	
	Sonar *_sonar;
	SonarView *_sonarView;
	
	AppDelegate_Shared *appDelegate;
	
	NSMutableSet *_enemies;
	NSMutableSet *_enemyViews;
	
	NSMutableSet *_treasures;
	NSMutableSet *_treasureViews;
	
	NSDate *_lastEnemyUpdate;
	
	NSDateFormatter *_timerFormatter;
	
	NSMutableDictionary *_timers;
	
	BOOL firstZoomDidOccur;
}

@property (nonatomic, assign) id <MapViewControllerDelegate> delegate;

@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIView *hudView;
@property (nonatomic, retain) IBOutlet UILabel *overlayLabel;
@property (nonatomic, retain) IBOutlet UILabel *timerLabel;
@property (nonatomic, retain) Trek *trek;
@property (nonatomic, retain) CADisplayLink *displayLink;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *startButton;

- (IBAction)launchBattlePressed:(id)sender;
- (IBAction)startStopPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)centerMapOnLocation:(id)sender;
- (void)stopUpdatingLocation;
- (void)startUpdatingLocation;

@end


@protocol MapViewControllerDelegate
- (void)mapViewControllerDidEnd:(MapViewController *)mapViewController;
@end