//
//  RQMapViewController.m
//  RunQuest
//
//  Created by Joe Walsh on 9/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "HeroPath.h"
#import "SonarView.h"
#import "Trek.h"
#import "AppDelegate_Shared.h"
#import "NSManagedObjectContext+FetchAdditions.h"
#import "Enemy.h"
#import "EnemyAnnotationView.h"
#import "RQBattleTestViewController.h"
#import <AudioToolbox/AudioToolbox.h>

#define ENEMY_GENERATION_BOUNDS_X .01f
#define ENEMY_GENERATION_BOUNDS_Y .015f
#define ENEMY_SPEED_VARIANCE 1.5f
#define SLOWEST_ENEMY_SPEED 1.5f
#define ENEMIES_TO_GENERATE 5

#define LOCATION_ACCURACY_THRESHOLD 50
#define PRINT_TREKS 0

@interface MapViewController ()
@property (nonatomic, retain) RQBattleTestViewController *battleViewController;
- (void)updatePath;
- (void)showHUD;
- (void)hideHUD;
@end

@implementation MapViewController
@synthesize hudView, overlayLabel, mapView, displayLink, speedLabel, durationLabel, trek;
@synthesize launchBattleButton;
@synthesize battleViewController;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		srand([[NSDate date] timeIntervalSince1970]);
		appDelegate = [[UIApplication sharedApplication] delegate];
		_locationManager = [[CLLocationManager alloc] init];
		_locationManager.purpose = NSLocalizedString(@"To track your progress around the RunQuest world.", @"Explain what we're using core location for");
		_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		_locationManager.distanceFilter = kCLDistanceFilterNone;
		_locationManager.delegate = self;
		[_locationManager startUpdatingLocation];
		
		_enemyViews = [[NSMutableSet alloc] initWithCapacity:ENEMIES_TO_GENERATE];
		_enemies = [[NSMutableSet alloc] initWithCapacity:ENEMIES_TO_GENERATE];
		
		_speedFormatter = [[NSNumberFormatter alloc] init];
		[_speedFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[_speedFormatter setMaximumSignificantDigits:2];
		CLLocation *lastLocation = nil;
#if PRINT_TREKS
		NSArray	*treks = [[appDelegate managedObjectContext] fetchObjectsForEntityName:@"Trek"];
		for ( Trek *trek in treks ) {
			for (CLLocation *location in trek.locations )
			{
				if ( lastLocation ) {
					NSLog(@"dt:\t%f", location.timestamp - lastLocation.timestamp);
					NSLog(@"dd:\t%f", [location distanceFromLocation:lastLocation]);
					NSLog(@"da:\t%f", location.altitude - lastLocation.altitude);
				}
				lastLocation = location;
			}
			NSLog(@"Distance:\t%f", trek.distance);
			NSLog(@"Time:\t%f",trek.duration);
			NSLog(@"Speed:\t%f",trek.averageSpeed);
		}
#endif
    }
    return self;
}

- (void)dealloc {
	[_speedFormatter release];
	[_lastEnemyUpdate release];
	[_locationManager release];
	[_sonarView release];
	[_sonar release];
	[_enemies release];
    [launchBattleButton release];
	[_enemyViews release];
	[super dealloc];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(cycleRadius:)];
	[self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [super viewDidLoad];
}

- (void)removeEnemyView:(EnemyAnnotationView *)enemyView {
	Enemy *enemy = enemyView.annotation;
	[self.mapView removeAnnotation:enemy];
	[_enemies removeObject:enemy];
	[_enemyViews removeObject:enemyView];
}

- (void)cycleRadius:(CADisplayLink *)sender{
	NSTimeInterval timeSinceLastUpdate = 0;
	if ( _lastEnemyUpdate )
		timeSinceLastUpdate = [[NSDate date] timeIntervalSinceDate:_lastEnemyUpdate];
	
	if ( !_lastEnemyUpdate || timeSinceLastUpdate > 2.0f ) {
		
	for ( EnemyAnnotationView* enemyView in _enemyViews ) {
		Enemy *enemy = enemyView.annotation;
		if ( enemy.speed ) {
			MKMapPoint enemyPoint = MKMapPointForCoordinate(enemy.coordinate);
			MKMapPoint heroPoint = MKMapPointForCoordinate(_locationManager.location.coordinate);
			double mapPointsPerMeter = MKMapPointsPerMeterAtLatitude(enemy.coordinate.latitude);
			double enemyStepSize =  enemy.speed*timeSinceLastUpdate*mapPointsPerMeter;
			if ( MKMetersBetweenMapPoints(enemyPoint, heroPoint) > enemyStepSize ) {
				double deltaX = enemyPoint.x - heroPoint.x;
				double deltaY = enemyPoint.y - heroPoint.y;
				
				double theta = atan(deltaY/deltaX);
				
				
				
				double moveX = enemyStepSize*cos(theta);
				double moveY = enemyStepSize*sin(theta);
				
				
				if ( deltaX > 0) {
					moveX = -1.0f*moveX;
					moveY = -1.0f*moveY;
				}
				
				MKMapPoint newPoint = MKMapPointMake(enemyPoint.x + moveX, enemyPoint.y + moveY);
				
				CLLocationCoordinate2D newCoordinate = MKCoordinateForMapPoint(newPoint);
				enemy.coordinate = newCoordinate;
			}
			else {
				enemy.coordinate = _sonar.coordinate;
				AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
				[self removeEnemyView:enemyView];
			}
		}
		[enemyView pulse];
	}
		[_lastEnemyUpdate release];
		_lastEnemyUpdate = [[NSDate date] retain];
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[self.displayLink invalidate];
	self.displayLink = nil;
	self.mapView = nil;
	self.hudView = nil;
	self.overlayLabel = nil;
    self.launchBattleButton = nil;
}

- (void)loadEnemiesAroundLocation:(CLLocation *)location {
	CLLocationCoordinate2D coordinate = location.coordinate;
	for ( NSUInteger i = 1; i <= ENEMIES_TO_GENERATE; i++ ) {
		double randX = ENEMY_GENERATION_BOUNDS_X*rand()/RAND_MAX;
		double randY = ENEMY_GENERATION_BOUNDS_Y*rand()/RAND_MAX;
		Enemy *enemy = [[Enemy alloc] initWithCoordinate:CLLocationCoordinate2DMake(coordinate.latitude + randY - ENEMY_GENERATION_BOUNDS_Y/2.0f, coordinate.longitude + randX - ENEMY_GENERATION_BOUNDS_X/2.0f) inManagedObjectContext:[appDelegate managedObjectContext]];
		enemy.speed = SLOWEST_ENEMY_SPEED + ENEMY_SPEED_VARIANCE*rand()/RAND_MAX;
		enemy.heading = 0;
		[self.mapView addAnnotation:enemy];
		[_enemies addObject:enemy];
		[enemy release];
	}
}

- (void)updateSpeedLabel {
	self.speedLabel.text = [NSString stringWithFormat:@"%@ m/s", [_speedFormatter stringFromNumber:[NSNumber numberWithDouble:self.trek.averageSpeed]]];
}

- (void)updateDurationLabel {
	self.durationLabel.text = [_speedFormatter stringFromNumber:[NSNumber numberWithDouble:self.trek.duration]];//[NSString stringWithFormat:@"%lu:%lu", floor(trek.duration/60.0f), floor(remainder(trek.duration, 60.0f))];
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	if ( !newLocation )
		[self showHUD];
	
	if ( !oldLocation )
		[self hideHUD];
	
	if ( newLocation && newLocation.horizontalAccuracy > 0) {
		
		MKCoordinateSpan span = MKCoordinateSpanMake(ENEMY_GENERATION_BOUNDS_Y, ENEMY_GENERATION_BOUNDS_X);
		[self.mapView setRegion:MKCoordinateRegionMake(newLocation.coordinate, span) animated:YES];
		
		if ( newLocation.horizontalAccuracy < LOCATION_ACCURACY_THRESHOLD && self.trek )
				[self.trek addLocation:newLocation];
		
		[self updateSpeedLabel];
		[self updateDurationLabel];
	}
}

#pragma mark Loading Overlay

- (void)showHUD { 
	if ( self.hudView.isHidden )
		hudView.hidden = NO;
}

- (void)hideHUD {
	if ( !self.hudView.isHidden )
		hudView.hidden = YES;
}

#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	if ( [annotation isKindOfClass:[Enemy class]] ) {
		EnemyAnnotationView *view = [[EnemyAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"blah"];
		[_enemyViews addObject:view];
		return [view autorelease];
	}
	else
		return nil;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
	MKOverlayView *overlayView = nil;
	if ( [overlay isKindOfClass:[MKPolyline class]] ) {
//		MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
//		polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.6f];
//		overlayView = [polylineView autorelease];
		
	} else if ( [overlay isKindOfClass:[Sonar class]] ) {
		if ( !_sonarView )
			_sonarView = [[SonarView alloc] initWithOverlay:_sonar];
		overlayView = _sonarView;
	}
	
	return overlayView;
}

- (void)removeAllEnemies {
	NSSet *safeToIterateCopy = [_enemyViews	copy];
	for ( EnemyAnnotationView *enemyView in safeToIterateCopy ) {
		[self removeEnemyView:enemyView];
	}
}

#pragma mark -
#pragma mark Action

- (IBAction)launchBattlePressed:(id)sender {
    self.battleViewController = [[[RQBattleTestViewController alloc] init] autorelease];
    [self.battleViewController setMapViewController:self];
	[self.view.window addSubview:self.battleViewController.view];
    self.mapView.hidden = YES;
}

- (void)removeBattleView
{
	[self.battleViewController.view removeFromSuperview];
	self.mapView.hidden = NO;
}

- (IBAction)startStopPressed:(id)sender { 
	UIButton *button = nil;
	if ( [sender isKindOfClass:[UIButton class]] )
		button = sender;
	
	if ( !self.trek ) {
		[button setTitle:@"Stop" forState:UIControlStateNormal];
		Trek *newTrek = [[Trek alloc] initWithLocation:_locationManager.location inManagedObjectContext:[appDelegate managedObjectContext]];
		newTrek.date = [NSDate date];
		self.trek = newTrek;
		[newTrek release];
		[self loadEnemiesAroundLocation:_locationManager.location];
	}
	else {
		[button setTitle:@"Start" forState:UIControlStateNormal];
		[self removeAllEnemies];
		NSError *error = nil;
		[[appDelegate managedObjectContext] save:&error];
		if ( error )
			NSLog(@"%@", error);
		self.trek = nil;
	}
}

@end
