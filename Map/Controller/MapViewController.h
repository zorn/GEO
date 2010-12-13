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
#import "WeightLogEventEditViewController.h"
#import "RQViewController.h"
@class Trek;
@class RQHero;
@class AppDelegate_Shared;
@class Treasure;
@class RQBarView;

@protocol MapViewControllerDelegate;


@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, RQBattleViewControllerDelegate, RQViewControllerDelegate, WeightLogEventEditViewControllerDelegate> {
	
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
	NSNumberFormatter *_distanceFormatter;
	NSNumberFormatter *_calorieFormatter;

	NSMutableDictionary *_timers;
	
	RQHero *hero;
	double distanceTraveledSinceLastHPGain;
	
	BOOL firstZoomDidOccur;
	
	
	Treasure *_encounteredTreasure;
}

@property (nonatomic, assign) id <MapViewControllerDelegate> delegate;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, readonly) RQHero *hero;
@property (nonatomic, assign) double distanceTraveledSinceLastHPGain;

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIView *hudView;
@property (nonatomic, retain) IBOutlet UILabel *overlayLabel;
@property (nonatomic, retain) IBOutlet UILabel *timerLabel;
@property (nonatomic, retain) IBOutlet UILabel *distanceLabel;
@property (nonatomic, retain) IBOutlet UILabel *calorieBurnLabel;
@property (nonatomic, retain) Trek *trek;
@property (nonatomic, retain) CADisplayLink *displayLink;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *startButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *locationButton;
@property (nonatomic, retain) IBOutlet UINavigationBar *newWorkoutNavigationBar;
@property (nonatomic, retain) IBOutlet UIView *workoutStatCollectionView;
@property (nonatomic, retain) IBOutlet UIToolbar *startToolbar;
@property (nonatomic, retain) IBOutlet UIToolbar *pauseToolbar;
@property (nonatomic, retain) IBOutlet RQBarView *hpBarView;
@property (nonatomic, retain) IBOutlet RQBarView *gpBarView;

- (IBAction)infoButtonPressed:(id)sender;
- (IBAction)launchBattlePressed:(id)sender;
- (IBAction)startStopPressed:(id)sender;
- (IBAction)resumeButtonPressed:(id)sender;
- (IBAction)finishButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)centerMapOnLocation:(id)sender;
- (void)stopUpdatingLocation;
- (void)startUpdatingLocation;

- (void)encounterEnemyShouldConfirm:(BOOL)shouldConfirm;

#pragma mark -
#pragma mark Methods to adjust the UI for the current state of the workout
- (void)moveNewWorkoutNavigationBarOffScreenShouldAnimate:(BOOL)animate;
- (void)moveNewWorkoutNavigationBarOnScreenShouldAnimate:(BOOL)animate;
- (void)moveWorkoutStatCollectionViewOffScreenShouldAnimate:(BOOL)animate;
- (void)moveWorkoutStatCollectionViewOnScreenShouldAnimate:(BOOL)animate;
- (void)moveStartWorkoutToolbarOffScreenShouldAnimate:(BOOL)animate;
- (void)moveStartWorkoutToolbarOnScreenShouldAnimate:(BOOL)animate;
- (void)movePauseWorkoutToolbarOffScreenShouldAnimate:(BOOL)animate;
- (void)movePauseWorkoutToolbarOnScreenShouldAnimate:(BOOL)animate;

@end


@protocol MapViewControllerDelegate
- (void)mapViewControllerDidEnd:(MapViewController *)mapViewController;
@end