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
#import "RQWeightLogEntry.h"
#import "M3CoreDataManager.h"
#import "RQHero.h"
#import "RQBattle.h"
#ifdef TESTING
#import "RandomWalkLocationManager.h"
#endif

#define METERS_PER_DEGREE 111000

#define MIN_ENEMY_DISTANCE .005f

#define ENEMY_GENERATION_BOUNDS_X .05f
#define ENEMY_GENERATION_BOUNDS_Y .05f

#define DEFAULT_ZOOM_BOUNDS_X .01f
#define DEFAULT_ZOOM_BOUNDS_Y .01f

#define ENEMY_GENERATION_BOUNDS_X_METERS ENEMY_GENERATION_BOUNDS_X * METERS_PER_DEGREE
#define ENEMY_GENERATION_BOUNDS_Y_METERS ENEMY_GENERATION_BOUNDS_Y * METERS_PER_DEGREE

#define ENEMY_GENERATION_MIN_DISTANCE .001f
#define ENEMY_SPEED_VARIANCE 2.0f

#define SLOWEST_ENEMY_SPEED 10.0f
#define ENEMIES_TO_GENERATE 75

#define ENEMY_GENERATION_RADIUS 10
#define LOCATION_ACCURACY_THRESHOLD 100
#define PRINT_TREKS 0
#define ENEMY_SPAWN_EVERY 20 //seconds
#define ENEMY_PULSE_EVERY 1 //second
#define ENEMY_MAGNET_RADIUS 500.0f //meters
#define CORE_LOCATION_DISTANCE_FILTER 3.0f
#define ENEMY_SPEED_ADVANTAGE .5f

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
@synthesize delegate, startButton, locationButton, hudView, overlayLabel, mapView, displayLink, timerLabel, trek, locationManager, battleViewController;

@synthesize newWorkoutNavigationBar;
@synthesize workoutStatCollectionView;
@synthesize startToolbar;
@synthesize pauseToolbar;

#pragma mark Object Life Cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		self.wantsFullScreenLayout = YES;
		srand([[NSDate date] timeIntervalSince1970]);
		appDelegate = [[UIApplication sharedApplication] delegate];
		CLLocationManager *manager = nil;
		
#ifdef TESTING 
		manager = [[RandomWalkLocationManager alloc] init];
#else	
		manager = [[CLLocationManager alloc] init];
#endif
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
		[_timerFormatter setDateFormat:@"H:mm:ss"];
		_timers = [[NSMutableDictionary alloc] initWithCapacity:2];
        [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"RQ_Battle_Song.m4a"];
		[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"victory_song_002.m4a"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"Hit_001.caf"];
    }
    return self;
}

- (void)dealloc {
	locationManager.delegate = nil;
	[locationManager release];
	locationManager = nil;
	
	[startToolbar release];
	[pauseToolbar release];
	
	[locationButton release];
	[workoutStatCollectionView release];
	[newWorkoutNavigationBar release];
	[trek release];
	[displayLink release];
	[mapView release];
	[hudView release];
	[overlayLabel release];
	[timerLabel release];
	[_lastEnemyUpdate release];
	[_sonarView release];
	[_sonar release];
	[_enemies release];
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
	self.mapView.showsUserLocation = NO;
	
	[self moveWorkoutStatCollectionViewOffScreenShouldAnimate:NO];
	[self moveNewWorkoutNavigationBarOnScreenShouldAnimate:NO];
	[self moveStartWorkoutToolbarOffScreenShouldAnimate:NO];
	[self movePauseWorkoutToolbarOffScreenShouldAnimate:NO];
	
	[self showHUD];
	[self startUpdatingLocation];
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	[super viewWillAppear:animated];
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
	self.startButton = nil;
}

#pragma mark Timer Fire Methods

- (void)displayLinkDidFire:(CADisplayLink *)sender {
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
			[self startGeneratingEnemies];
			break;
		case 1:
			[self launchBattlePressed:self];
			break;
		default:
			break;
	}
}

- (void)encounterEnemy:(EnemyMapSpawn *)enemy {
	[self stopGeneratingEnemies];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ENEMY ENCOUNTERED", @"enemy encountered") 
														message:NSLocalizedString(@"You have encountered an enemy.  Do you want to fight?", @"ask the user if they want to fight the enemy") 
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"No", @"No") 
											  otherButtonTitles:NSLocalizedString(@"Yes", @"Yes"), nil];
	
	[alertView show];
	[alertView release];
}

- (void)pulseEnemies {
	NSTimeInterval timeSinceLastUpdate = 0;
	if ( _lastEnemyUpdate )
		timeSinceLastUpdate = [[NSDate date] timeIntervalSinceDate:_lastEnemyUpdate];
	
	
	@synchronized (_enemyViews ) {
		NSSet *safeIterableCopy = [_enemyViews copy];
		BOOL didEncounterEnemy = NO;
		for ( EnemyAnnotationView* enemyView in safeIterableCopy ) {
			EnemyMapSpawn *enemy = enemyView.annotation;
			MKMapPoint enemyPoint = MKMapPointForCoordinate(enemy.coordinate);
			[_sonar lockForReading];
			MKMapPoint heroPoint = MKMapPointForCoordinate(_sonar.coordinate);
			CLLocationDistance sonarRange = _sonar.range;
			//CLLocation *heroLocation = [[CLLocation alloc] initWithLatitude:_sonar.coordinate.latitude longitude:_sonar.coordinate.longitude];
			[_sonar unlockForReading];
			//CLLocation *enemyLocation = [[CLLocation alloc] initWithLatitude:enemy.coordinate.latitude longitude:enemy.coordinate.longitude];
			
			CLLocationDistance metersToHero = MKMetersBetweenMapPoints(enemyPoint, heroPoint)*2.0f;
			
			//[heroLocation distanceFromLocation:enemyLocation];//
			if ( metersToHero < sonarRange )
				enemy.speed = locationManager.location.speed + ENEMY_SPEED_ADVANTAGE;
			else 
				enemy.speed = 0;
			
			
			if ( enemy.speed ) {
				double mapPointsPerMeter = MKMapPointsPerMeterAtLatitude(enemy.coordinate.latitude);
				double enemyStepSize =  enemy.speed*timeSinceLastUpdate;
				if ( metersToHero > enemyStepSize ) {
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
				else if (!didEncounterEnemy) {
					didEncounterEnemy = YES;
					enemy.coordinate = _sonar.coordinate;
					AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
					[self removeEnemyView:enemyView];
					[self encounterEnemy:enemyView.annotation];
				}
				[enemyView pulse];
			}
			else {
				[enemyView stopPulsing];
			}
			
			
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
	//	
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
		if ( enemy )
			[_enemies removeObject:enemy];
		if ( enemyView )
			[_enemyViews removeObject:enemyView];
	}
}

- (void)addEnemyView:(EnemyAnnotationView *)enemyView {
	@synchronized (_enemyViews ) {
		if ( enemyView )
			[_enemyViews addObject:enemyView];
	}
}


- (void)addEnemy:(EnemyMapSpawn *)enemy {
	@synchronized (_enemyViews ) {
		[self.mapView addAnnotation:enemy];
		[_enemies addObject:enemy];
	}
}

- (void)generateMapForHeroAtLocation:(CLLocation *)location {
	
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
		enemy.speed = 0; //SLOWEST_ENEMY_SPEED + ENEMY_SPEED_VARIANCE*rand()/RAND_MAX;
		enemy.heading = 0;
		[self addEnemy:enemy];
		[enemy release];
	}
#ifdef TESTING
	//EnemyMapSpawn *lastEnemy = [_enemies anyObject];
	//	CLLocation *destination = [[CLLocation alloc] initWithCoordinate:lastEnemy.coordinate altitude:0 horizontalAccuracy:0 verticalAccuracy:0 timestamp:[NSDate date]];
	//	[(RandomWalkLocationManager *)locationManager setDestination:destination];
#endif
}

- (void)updateTimerLabel {
	self.timerLabel.text = [_timerFormatter stringForObjectValue:[NSDate dateWithTimeIntervalSinceReferenceDate:self.trek.duration]];//[NSString stringWithFormat:@"%lu:%lu", floor(trek.duration/60.0f), floor(remainder(trek.duration, 60.0f))];
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	
	if ( newLocation && newLocation.horizontalAccuracy < LOCATION_ACCURACY_THRESHOLD) {
		if ( !firstZoomDidOccur ) {
			MKCoordinateSpan span = MKCoordinateSpanMake(DEFAULT_ZOOM_BOUNDS_X, DEFAULT_ZOOM_BOUNDS_X);
			[self.mapView setRegion:MKCoordinateRegionMake(newLocation.coordinate, span) animated:YES];
			firstZoomDidOccur = YES;
			[self loadEnemiesAroundLocation:locationManager.location];
			_sonar = [[Sonar alloc] initWithCoordinate:locationManager.location.coordinate range:ENEMY_MAGNET_RADIUS];
			[self.mapView addOverlay:_sonar];
			[self hideHUD];
		}
		if ( self.trek )
			[self.trek addLocation:newLocation];
		_sonar.coordinate = newLocation.coordinate;
		CLLocationCoordinate2D sonarCoordinate = _sonar.coordinate;
		MKMapPoint sonarMapPoint = MKMapPointForCoordinate(sonarCoordinate);
		double mapPointsPerMeter = MKMapPointsPerMeterAtLatitude(sonarCoordinate.latitude);
		double dimension = _sonar.range*mapPointsPerMeter + 100.0f;
		[_sonarView setNeedsDisplayInMapRect:[self.mapView visibleMapRect]];
		[_sonarView setNeedsDisplayInMapRect:MKMapRectMake(sonarMapPoint.x, sonarMapPoint.y, dimension, dimension)];
	}
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
	if ( [overlay isKindOfClass:[Sonar class]] ) {
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
	[self.trek stop];
    self.battleViewController = [[[RQBattleViewController alloc] init] autorelease];
	self.battleViewController.delegate = self;
	RQHero *hero = [[RQModelController defaultModelController] hero];
	self.battleViewController.battle.hero = hero;
	
	// TODO: Typically the hero will regen health as they walk but for the purposes of this demo version we will give him full hp before each fight
	[hero setCurrentHP:hero.maxHP];
	
	// TODO: Typically the hero will regen glove power as they walk, for now lets add 15 before each fight
	[hero setGlovePower:hero.glovePower+15];
	
	// TODO: EnemyMapSpawn in the future should dictate the enemy the hero is fighting, but for now let's make a random enemy:
	self.battleViewController.battle.enemy = [[RQModelController defaultModelController] randomEnemyBasedOnHero:hero];
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	[self presentModalViewController:self.battleViewController animated:YES];
	//	self.battleViewController.view.frame = CGRectMake(0, -1.0f*self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
	//	[self.view.superview addSubview:self.battleViewController.view];
	//	self.modalViewController = self.battleViewController;
	//	[self.battleViewController.view animateWithDuration:1.0f animations:^{self.battleViewController.view.frame = self.view.frame; } completion:^(BOOL finished){ [self.view removeFromSuperview]; self.modalViewController = self.battleViewController;}];
}

- (IBAction)centerMapOnLocation:(id)sender {
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"RQMapBattleDemoOverride"] boolValue] == YES) {
		[self launchBattlePressed:self];
	} else {
		if ( self.locationManager.location ) {
			MKCoordinateSpan span = MKCoordinateSpanMake(DEFAULT_ZOOM_BOUNDS_X, DEFAULT_ZOOM_BOUNDS_Y);
			MKCoordinateRegion region = MKCoordinateRegionMake(self.locationManager.location.coordinate, span);
			[self.mapView setRegion:region animated:YES];
		}
	}	
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
	//[self addTimerNamed:@"EnemySpawn" withInterval:ENEMY_SPAWN_EVERY selector:@selector(spawnEnemy) fireDate:[NSDate dateWithTimeIntervalSinceNow:ENEMY_SPAWN_EVERY]];
	[self addTimerNamed:@"EnemyPulse" withInterval:ENEMY_PULSE_EVERY selector:@selector(pulseEnemies) fireDate:nil];
}

- (void)stopGeneratingEnemies {
	//[self removeTimerNamed:@"EnemySpawn"];
	[self removeTimerNamed:@"EnemyPulse"];
	for ( EnemyAnnotationView *enemyView in _enemyViews ) {
		EnemyMapSpawn *spawn = enemyView.annotation;
		spawn.speed = 0;
		[enemyView stopPulsing];
	}
}

- (void)startTrek {
	
	// if the newest weight log entry is less than 72 hours old, ask for a new one.
	RQWeightLogEntry *entry = [[RQModelController defaultModelController] newestWeightLogEntry];
	if (entry == nil || [entry.dateTaken compare:[NSDate dateWithTimeIntervalSinceNow:-60*60*72]] == NSOrderedAscending) {
		WeightLogEventEditViewController *controller = [[WeightLogEventEditViewController alloc] init];
		[controller setEditMode:NO]; // make a new object when they save
		[controller setDelegate:self];
		[self presentModalViewController:controller animated:YES];
		[controller release];
	} else {
		
		[self moveWorkoutStatCollectionViewOnScreenShouldAnimate:YES];
		[self moveNewWorkoutNavigationBarOffScreenShouldAnimate:YES];
		
		[self moveStartWorkoutToolbarOnScreenShouldAnimate:YES];
		[self movePauseWorkoutToolbarOffScreenShouldAnimate:YES];
		
		Trek *newTrek = [[Trek alloc] initWithLocation:locationManager.location inManagedObjectContext:[appDelegate managedObjectContext]];
		self.trek = newTrek;
		[newTrek release];
		
		[self.trek startWithLocation:locationManager.location];
		startButton.title = @"Pause Workout";
		[self addTimerNamed:@"Tick" withInterval:1 selector:@selector(updateTimerLabel) fireDate:nil];
		[self startGeneratingEnemies];
	}
}

- (void)stopTrek {
	[self.trek stop];
	//startButton.title = @"Start Workout";
	[self removeTimerNamed:@"Tick"];
	NSError *error = nil;
	[[appDelegate managedObjectContext] save:&error];
	if ( error )
		NSLog(@"%@", error);
	[self stopGeneratingEnemies];
	
	[self moveStartWorkoutToolbarOffScreenShouldAnimate:YES];
	[self movePauseWorkoutToolbarOnScreenShouldAnimate:YES];
}

- (IBAction)startStopPressed:(id)sender
{
	if ( !self.trek ) {
		[self startTrek];
	} else if ( self.trek.isStopped ) {
		[self startTrek];
	} else {
		[self stopTrek];
	}
}

- (IBAction)resumeButtonPressed:(id)sender
{
	[self startTrek];
}

- (IBAction)finishButtonPressed:(id)sender
{
	[delegate mapViewControllerDidEnd:self];
}

- (IBAction)doneButtonPressed:(id)sender {
	[delegate mapViewControllerDidEnd:self];
}

#pragma mark -
#pragma mark Methods to adjust the UI for the current state of the workout

- (void)moveNewWorkoutNavigationBarOffScreenShouldAnimate:(BOOL)animate
{
	CGRect newFrame = self.newWorkoutNavigationBar.frame;
	newFrame.origin.y = 0 - self.newWorkoutNavigationBar.frame.size.height;
	
	if (animate) {
		[UIView beginAnimations:@"NewWorkoutNavigationBarViewOuttro" context:NULL];
		self.newWorkoutNavigationBar.frame = newFrame;
		[UIView commitAnimations];
	} else {
		self.newWorkoutNavigationBar.frame = newFrame;
	}
}

- (void)moveNewWorkoutNavigationBarOnScreenShouldAnimate:(BOOL)animate
{
	CGRect newFrame = self.newWorkoutNavigationBar.frame;
	newFrame.origin.y = 0 + 20;
	
	if (animate) {
		[UIView beginAnimations:@"NewWorkoutNavigationBarViewIntro" context:NULL];
		self.newWorkoutNavigationBar.frame = newFrame;
		[UIView commitAnimations];
	} else {
		self.newWorkoutNavigationBar.frame = newFrame;
	}
}

- (void)moveWorkoutStatCollectionViewOffScreenShouldAnimate:(BOOL)animate
{
	CGRect newFrame = self.workoutStatCollectionView.frame;
	newFrame.origin.y = 0 - self.workoutStatCollectionView.frame.size.height;
	
	if (animate) {
		[UIView beginAnimations:@"WorkoutStatCollectionViewOuttro" context:NULL];
		self.workoutStatCollectionView.frame = newFrame;
		[UIView commitAnimations];
	} else {
		self.workoutStatCollectionView.frame = newFrame;
	}
	
}

- (void)moveWorkoutStatCollectionViewOnScreenShouldAnimate:(BOOL)animate
{
	CGRect newFrame = self.workoutStatCollectionView.frame;
	newFrame.origin.y = 0 + 20;
	
	if (animate) {
		[UIView beginAnimations:@"WorkoutStatCollectionViewIntro" context:NULL];
		self.workoutStatCollectionView.frame = newFrame;
		[UIView commitAnimations];
	} else {
		self.workoutStatCollectionView.frame = newFrame;
	}
}

- (void)moveStartWorkoutToolbarOffScreenShouldAnimate:(BOOL)animate
{
	CGRect newFrame = self.startToolbar.frame;
	newFrame.origin.y = self.view.frame.size.height + self.startToolbar.frame.size.height;
	
	if (animate) {
		[UIView beginAnimations:@"StartWorkoutToolbarOuttro" context:NULL];
		self.startToolbar.frame = newFrame;
		[UIView commitAnimations];
	} else {
		self.startToolbar.frame = newFrame;
	}
	
}

- (void)moveStartWorkoutToolbarOnScreenShouldAnimate:(BOOL)animate
{
	CGRect newFrame = self.startToolbar.frame;
	newFrame.origin.y = self.view.frame.size.height - self.startToolbar.frame.size.height;
	
	if (animate) {
		[UIView beginAnimations:@"StartWorkoutToolbarIntro" context:NULL];
		self.startToolbar.frame = newFrame;
		[UIView commitAnimations];
	} else {
		self.startToolbar.frame = newFrame;
	}
}

- (void)movePauseWorkoutToolbarOffScreenShouldAnimate:(BOOL)animate
{
	CGRect newFrame = self.pauseToolbar.frame;
	newFrame.origin.y = self.view.frame.size.height + self.pauseToolbar.frame.size.height;
	
	if (animate) {
		[UIView beginAnimations:@"PauseWorkoutToolbarOuttro" context:NULL];
		self.pauseToolbar.frame = newFrame;
		[UIView commitAnimations];
	} else {
		self.pauseToolbar.frame = newFrame;
	}
	
}

- (void)movePauseWorkoutToolbarOnScreenShouldAnimate:(BOOL)animate
{
	CGRect newFrame = self.pauseToolbar.frame;
	newFrame.origin.y = self.view.frame.size.height - self.pauseToolbar.frame.size.height;
	
	if (animate) {
		[UIView beginAnimations:@"PauseWorkoutToolbarIntro" context:NULL];
		self.pauseToolbar.frame = newFrame;
		[UIView commitAnimations];
	} else {
		self.pauseToolbar.frame = newFrame;
	}
}

- (void)showHUD { 
	hudView.hidden = NO;
	[self moveStartWorkoutToolbarOffScreenShouldAnimate:YES];
}

- (void)hideHUD {
	hudView.hidden = YES;
	[self moveStartWorkoutToolbarOnScreenShouldAnimate:YES];
}

#pragma mark -
#pragma mark WeightLogEventEditViewControllerDelegate methods
						 
- (void)weightLogEventEditViewControllerDidEnd:(WeightLogEventEditViewController *)controller
{
	[self dismissModalViewControllerAnimated:YES];
	if ([controller wasCanceled] == NO) {
		// resume starting the workout
		[self startTrek];
	}
}



@end
