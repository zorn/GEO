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
#import "EnemyMapSpawn.h"
#import "EnemyAnnotationView.h"
#import "RQBattleViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "SimpleAudioEngine.h"
#import "RQModelController.h"
#import "M3CoreDataManager.h"
#import "RQHero.h"
#import "RQBattle.h"

#define ENEMY_GENERATION_BOUNDS_X .001f
#define ENEMY_GENERATION_BOUNDS_Y .0015f
#define ENEMY_SPEED_VARIANCE 0.5f
#define SLOWEST_ENEMY_SPEED 1.25f
#define ENEMIES_TO_GENERATE 5
#define ENEMY_GENERATION_RADIUS 10
#define LOCATION_ACCURACY_THRESHOLD 50
#define PRINT_TREKS 0
#define ENEMY_SPAWN_EVERY 20 //seconds
#define ENEMY_PULSE_EVERY 1 //second

#define CORE_LOCATION_DISTANCE_FILTER 3.0f

@interface MapViewController ()
@property (nonatomic, retain) RQBattleViewController *battleViewController;
//- (void)updatePath;
- (void)showHUD;
- (void)hideHUD;
- (void)removeEnemyView:(EnemyAnnotationView *)enemyView;
- (void)encounterEnemy:(EnemyMapSpawn *)enemy;
- (void)startGeneratingEnemies;
- (void)stopGeneratingEnemies;
@end

@implementation MapViewController
@synthesize hudView, overlayLabel, mapView, displayLink, timerLabel, trek, launchBattleButton, locationManager, battleViewController;

#pragma mark Object Life Cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		srand([[NSDate date] timeIntervalSince1970]);
		appDelegate = [[UIApplication sharedApplication] delegate];
		CLLocationManager *manager = [[CLLocationManager alloc] init];
		self.locationManager = manager;
		[manager release];
		self.locationManager.purpose = NSLocalizedString(@"To track your progress around the RunQuest world.", @"Explain what we're using core location for");
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		self.locationManager.distanceFilter = CORE_LOCATION_DISTANCE_FILTER; //Distance in meters
		self.locationManager.delegate = self;
		
		_enemyViews = [[NSMutableSet alloc] initWithCapacity:ENEMIES_TO_GENERATE];
		_enemies = [[NSMutableSet alloc] initWithCapacity:ENEMIES_TO_GENERATE];
		_timerFormatter = [[NSDateFormatter alloc] init];
		[_timerFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		[_timerFormatter setDateFormat:@"HH:mm:ss"];
		_timers = [[NSMutableDictionary alloc] initWithCapacity:2];
        [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"RQ_Battle_Song.m4a"];
		[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"victory_song_002.m4a"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"Hit_001.caf"];
    }
    return self;
}

- (void)dealloc {
	[locationManager release];
	[trek release];
	[displayLink release];
	[mapView release];
	[hudView release];
	[overlayLabel release];
	[timerLabel release];
	[launchBattleButton release];
	[_lastEnemyUpdate release];
	[_sonarView release];
	[_sonar release];
	[_enemies release];
    [launchBattleButton release];
	[_enemyViews release];
	[_timerFormatter release];
	[_timers release];
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark View Life Cycle
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[self startUpdatingLocation];
	
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)viewDidDisappear:(BOOL)animated {
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
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

#pragma mark Timer Fire Methods

- (void)displayLinkDidFire:(CADisplayLink *)sender {
	
}

- (void)encounterEnemy:(EnemyMapSpawn *)enemy {
	[self stopGeneratingEnemies];
	[self launchBattlePressed:self];
}

- (void)pulseEnemies {
	NSTimeInterval timeSinceLastUpdate = 0;
	if ( _lastEnemyUpdate )
		timeSinceLastUpdate = [[NSDate date] timeIntervalSinceDate:_lastEnemyUpdate];
	
	
	@synchronized (_enemyViews ) {
		NSSet *safeIterableCopy = [_enemyViews copy];
		for ( EnemyAnnotationView* enemyView in safeIterableCopy ) {
			EnemyMapSpawn *enemy = enemyView.annotation;
			if ( enemy.speed ) {
				MKMapPoint enemyPoint = MKMapPointForCoordinate(enemy.coordinate);
				MKMapPoint heroPoint = MKMapPointForCoordinate(locationManager.location.coordinate);
				double mapPointsPerMeter = MKMapPointsPerMeterAtLatitude(enemy.coordinate.latitude);
				double enemyStepSize =  enemy.speed*timeSinceLastUpdate;
				if ( MKMetersBetweenMapPoints(enemyPoint, heroPoint) > enemyStepSize ) {
					double deltaX = enemyPoint.x - heroPoint.x;
					double deltaY = enemyPoint.y - heroPoint.y;
					
					double theta = atan(deltaY/deltaX);
					
					double moveX = enemyStepSize*cos(theta)*mapPointsPerMeter;
					double moveY = enemyStepSize*sin(theta)*mapPointsPerMeter;
					
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
					[self encounterEnemy:enemyView.annotation];
				}
			}
			[enemyView pulse];
		}
		[safeIterableCopy release];
	}
	[_lastEnemyUpdate release];
		_lastEnemyUpdate = [[NSDate date] retain];
}

- (void)startUpdatingLocation {
	//if ( !self.displayLink ) {
//		self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkDidFire:)];
//		[self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
//	}
	
	[self.locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation {
	//[self.displayLink invalidate];
//	self.displayLink = nil;
	[self.locationManager stopUpdatingLocation];
}

- (void)removeEnemyView:(EnemyAnnotationView *)enemyView {
	@synchronized (_enemyViews ) {
		EnemyMapSpawn *enemy = enemyView.annotation;
		[self.mapView removeAnnotation:enemy];
		[_enemies removeObject:enemy];
		[_enemyViews removeObject:enemyView];
	}
}

- (void)addEnemyView:(EnemyAnnotationView *)enemyView {
	@synchronized (_enemyViews ) {
		[_enemyViews addObject:enemyView];
	}
}


- (void)addEnemy:(EnemyMapSpawn *)enemy {
	@synchronized (_enemyViews ) {
		[self.mapView addAnnotation:enemy];
		[_enemies addObject:enemy];
	}
}	
- (void)generateEnemyForHeroAtLocation:(CLLocation *)location {
	CLLocationCoordinate2D coordinate = location.coordinate;
	CLLocationDirection course = location.course;

	MKMapPoint heroMapPoint = MKMapPointForCoordinate(coordinate);
	CLLocationDistance mapPointsPerMeter = MKMapPointsPerMeterAtLatitude(coordinate.latitude);
	CLLocationDistance deltaX = ENEMY_GENERATION_RADIUS*cos(course)*mapPointsPerMeter;
	CLLocationDistance deltaY = ENEMY_GENERATION_RADIUS*sin(course)*mapPointsPerMeter;
	MKMapPoint enemyMapPoint = MKMapPointMake(heroMapPoint.x + deltaX, heroMapPoint.y + deltaY);
	CLLocationCoordinate2D enemyCoordinate = MKCoordinateForMapPoint(enemyMapPoint);
	
	EnemyMapSpawn *enemy = [[EnemyMapSpawn alloc] initWithCoordinate:enemyCoordinate inManagedObjectContext:[appDelegate managedObjectContext]];
	enemy.speed = ( location.speed > 0 ? location.speed : SLOWEST_ENEMY_SPEED ) + ENEMY_SPEED_VARIANCE*rand()/RAND_MAX;
	enemy.heading = 0;
	
	[self addEnemy:enemy];
	[enemy release];
}

- (void)spawnEnemy {
	[self generateEnemyForHeroAtLocation:locationManager.location];
}


- (void)loadEnemiesAroundLocation:(CLLocation *)location {
	CLLocationCoordinate2D coordinate = location.coordinate;
	for ( NSUInteger i = 1; i <= ENEMIES_TO_GENERATE; i++ ) {
		double randX = ENEMY_GENERATION_BOUNDS_X*rand()/RAND_MAX;
		double randY = ENEMY_GENERATION_BOUNDS_Y*rand()/RAND_MAX;
		EnemyMapSpawn *enemy = [[EnemyMapSpawn alloc] initWithCoordinate:CLLocationCoordinate2DMake(coordinate.latitude + randY - ENEMY_GENERATION_BOUNDS_Y/2.0f, coordinate.longitude + randX - ENEMY_GENERATION_BOUNDS_X/2.0f) inManagedObjectContext:[appDelegate managedObjectContext]];
		enemy.speed = SLOWEST_ENEMY_SPEED + ENEMY_SPEED_VARIANCE*rand()/RAND_MAX;
		enemy.heading = 0;
		[self addEnemy:enemy];
		[enemy release];
	}
}

- (void)updateTimerLabel {
	self.timerLabel.text = [_timerFormatter stringForObjectValue:[NSDate dateWithTimeIntervalSinceReferenceDate:self.trek.duration]];//[NSString stringWithFormat:@"%lu:%lu", floor(trek.duration/60.0f), floor(remainder(trek.duration, 60.0f))];
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	if ( !newLocation )
		[self showHUD];
	
	if ( !oldLocation ) {
		[self hideHUD];
		MKCoordinateSpan span = MKCoordinateSpanMake(ENEMY_GENERATION_BOUNDS_Y, ENEMY_GENERATION_BOUNDS_X);
		[self.mapView setRegion:MKCoordinateRegionMake(newLocation.coordinate, span) animated:YES];
	}
	
	if ( newLocation && newLocation.horizontalAccuracy > 0) {
		if ( newLocation.horizontalAccuracy < LOCATION_ACCURACY_THRESHOLD && self.trek )
				[self.trek addLocation:newLocation];
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
	if ( [annotation isKindOfClass:[EnemyMapSpawn class]] ) {
		EnemyAnnotationView *view = [[EnemyAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"blah"];
		[self addEnemyView:view];
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
	[safeToIterateCopy release];
}

- (void)battleViewControllerDidEnd:(RQBattleViewController *)controller {
	[self dismissModalViewControllerAnimated:YES];
	[self setBattleViewController:nil];
	if ( self.trek )
		[self startGeneratingEnemies];
	[[[RQModelController defaultModelController] coreDataManager] save];
}


#pragma mark -
#pragma mark Action

- (IBAction)launchBattlePressed:(id)sender {
    self.battleViewController = [[[RQBattleViewController alloc] init] autorelease];
	self.battleViewController.delegate = self;
	RQHero *hero = [[RQModelController defaultModelController] hero];
	self.battleViewController.battle.hero = hero;
	
	// TODO: Typically the hero will regen health as they walk but for the purposes of this demo version we will give him full hp before each fight
	[hero setCurrentHP:hero.maxHP];
	
	// TODO: EnemyMapSpawn in the future should dictate the enemy the hero is fighting, but for now let's make a random enemy:
	self.battleViewController.battle.enemy = [[RQModelController defaultModelController] randomEnemyBasedOnHero:hero];
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	[self presentModalViewController:self.battleViewController animated:YES];
//	self.battleViewController.view.frame = CGRectMake(0, -1.0f*self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
//	[self.view.superview addSubview:self.battleViewController.view];
//	self.modalViewController = self.battleViewController;
//	[self.battleViewController.view animateWithDuration:1.0f animations:^{self.battleViewController.view.frame = self.view.frame; } completion:^(BOOL finished){ [self.view removeFromSuperview]; self.modalViewController = self.battleViewController;}];
}

- (void)removeTimerNamed:(NSString *)name {
	NSTimer *timer = [_timers objectForKey:name];
	[timer invalidate];
	[_timers removeObjectForKey:name];
}

- (void)addTimerNamed:(NSString *)name withInterval:(NSTimeInterval)interval selector:(SEL)selector fireDate:(NSDate *)fireDate {
	NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:selector	userInfo:nil repeats:YES];
	[_timers setObject:timer forKey:name];
	if ( fireDate )
		[timer setFireDate:fireDate];
	else
		[timer fire];
}

- (void)startGeneratingEnemies {
	[self addTimerNamed:@"EnemySpawn" withInterval:ENEMY_SPAWN_EVERY selector:@selector(spawnEnemy) fireDate:[NSDate dateWithTimeIntervalSinceNow:ENEMY_SPAWN_EVERY]];
	[self addTimerNamed:@"EnemyPulse" withInterval:ENEMY_PULSE_EVERY selector:@selector(pulseEnemies) fireDate:nil];
}

- (void)stopGeneratingEnemies {
	[self removeTimerNamed:@"EnemySpawn"];
	[self removeTimerNamed:@"EnemyPulse"];
}

	
- (IBAction)startStopPressed:(id)sender { 
	UIButton *button = nil;
	if ( [sender isKindOfClass:[UIButton class]] )
		button = sender;
	
	if ( !self.trek ) {
		[button setTitle:@"Stop" forState:UIControlStateNormal];
		Trek *newTrek = [[Trek alloc] initWithLocation:locationManager.location inManagedObjectContext:[appDelegate managedObjectContext]];
		newTrek.date = [NSDate date];
		self.trek = newTrek;
		[newTrek release];
		[self addTimerNamed:@"Tick" withInterval:1 selector:@selector(updateTimerLabel) fireDate:nil];
		[self generateEnemyForHeroAtLocation:locationManager.location];
		[self startGeneratingEnemies];
	}
	else {
		[self removeTimerNamed:@"Tick"];
		[button setTitle:@"Start" forState:UIControlStateNormal];
		[self removeAllEnemies];
		NSError *error = nil;
		[[appDelegate managedObjectContext] save:&error];
		if ( error )
			NSLog(@"%@", error);
		self.trek = nil;
		[self stopGeneratingEnemies];
	}
}

@end
