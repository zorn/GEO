//CCLOG
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
#import "Segment.h"
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
#import "Treasure.h"
#import "TreasureAnnotationView.h"
#import "CLLocation+RQAdditions.h"
#import "RandomWalkLocationManager.h"
#import "RQBarView.h"
#import "RQConstants.h"
#import "HelpViewController.h"

#define METERS_PER_DEGREE 111000

#define ENEMY_GENERATION_BOUNDS .05f

#define ENEMY_SPAWN_RADIUS 500.0f

#define DEFAULT_ZOOM_BOUNDS_X .01f
#define DEFAULT_ZOOM_BOUNDS_Y .01f

#define ENEMY_MAGNET_RADIUS 500.0f //meters
#define ENEMY_MIN_DISTANCE ENEMY_MAGNET_RADIUS/(1.5f*METERS_PER_DEGREE)

#define ENEMY_GENERATION_MIN_DISTANCE .001f
#define ENEMY_SPEED_VARIANCE 2.0f

#define SLOWEST_ENEMY_SPEED 4.0f
#define ENEMIES_TO_GENERATE 200

#define MAX_TREASURES 2
#define TREASURE_SPAWN_EVERY 30 //seconds


#define LOCATION_ACCURACY_THRESHOLD 100
#define PRINT_TREKS 0
#define ENEMY_SPAWN_EVERY 20 //seconds

#define ENEMY_PULSE_EVERY 1 //second

#define CORE_LOCATION_DISTANCE_FILTER 3.0f
#define ENEMY_SPEED_ADVANTAGE 10.0f
#define DISTANCE_CONVERSION_FACTOR 1.8f

@interface MapViewController ()
@property (nonatomic, retain) RQBattleViewController *battleViewController;
//- (void)updatePath;
- (void)showHUD;
- (void)hideHUD;
- (void)removeEnemyView:(EnemyAnnotationView *)enemyView;
- (void)removeTreasure:(Treasure *)treasure;
- (void)removeTreasureView:(TreasureAnnotationView *)treasureView;
- (void)startGameMechanics;
- (void)pauseGameMechanicsAndRemoveTreasures:(BOOL)removeTreasures;
- (void)updateHPAndGP;
- (void)encounterEnemy;
@end

@implementation MapViewController
@synthesize delegate, hero, distanceTraveledSinceLastHPGain, startButton, locationButton, hudView, overlayLabel, mapView, displayLink, timerLabel, distanceLabel, calorieBurnLabel, trek, locationManager, battleViewController;

@synthesize newWorkoutNavigationBar;
@synthesize workoutStatCollectionView;
@synthesize startToolbar;
@synthesize pauseToolbar;
@synthesize hpBarView;
@synthesize gpBarView;

#pragma mark Object Life Cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		self.wantsFullScreenLayout = YES;
		srand([[NSDate date] timeIntervalSince1970]);
		appDelegate = [[UIApplication sharedApplication] delegate];
		CLLocationManager *manager = nil;
#if (TARGET_IPHONE_SIMULATOR)
		manager = [[RandomWalkLocationManager alloc] init];
#else
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"RQSimulateGPS"] boolValue] == YES) {
			manager = [[RandomWalkLocationManager alloc] init];
		} else {
			manager = [[CLLocationManager alloc] init];
		}
#endif
		CCLOG(@"Using Location manager class: %@", [manager class]);
			  
		self.locationManager = manager;
		[manager release];
		self.locationManager.purpose = NSLocalizedString(@"To track your progress around the RunQuest world.", @"Explain what we're using core location for");
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		self.locationManager.distanceFilter = CORE_LOCATION_DISTANCE_FILTER; //Distance in meters
		self.locationManager.delegate = self;
		_treasureViews = [[NSMutableSet alloc] initWithCapacity:MAX_TREASURES];
		_enemyViews = [[NSMutableSet alloc] initWithCapacity:ENEMIES_TO_GENERATE];
		_treasures = [[NSMutableSet alloc] initWithCapacity:MAX_TREASURES];
		_enemies = [[NSMutableSet alloc] initWithCapacity:ENEMIES_TO_GENERATE];
		
		_timerFormatter = [[[RQModelController defaultModelController] timeLengthFormatter] retain];
		_distanceFormatter = [[[RQModelController defaultModelController] distanceFormatter] retain];
		_calorieFormatter = [[[RQModelController defaultModelController] calorieFormatter] retain];
		
		_timers = [[NSMutableDictionary alloc] initWithCapacity:2];
        [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"RQ_Battle_Song.m4a"];
		[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"victory_song_002.m4a"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"Hit_001.caf"];
    }
    return self;
}

- (void)dealloc {
	[_treasures release];
	[_treasureViews release];
	CCLOG(@"MapViewController -dealloc called...");
	[self stopUpdatingLocation];
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
	[distanceLabel release];
	[calorieBurnLabel release];
	
	[hpBarView release];
	[gpBarView release];
	
	[_lastEnemyUpdate release];
	[_sonarView release];
	[_sonar release];
	[_enemies release];
	[_enemyViews release];
	[_timerFormatter release];
	[_distanceFormatter release];
	[_calorieFormatter release];
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
	
	[self updateHPAndGP];
	self.hpBarView.barColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.7];
	self.gpBarView.barColor = [UIColor colorWithRed:0.080 green:0.583 blue:1.0 alpha:0.7];
	
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
	if (![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying]) {
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"mapview_run_theme.m4a" loop:YES];
	}
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
	
	self.mapView = nil;
	self.hudView = nil;
	self.overlayLabel = nil;
	self.timerLabel = nil;
	self.distanceLabel = nil;
	self.calorieBurnLabel = nil;
	self.startButton = nil;
	self.locationButton = nil;
	self.newWorkoutNavigationBar = nil;
	self.workoutStatCollectionView = nil;
	self.startToolbar = nil;
	self.pauseToolbar = nil;
	self.hpBarView = nil;
	self.gpBarView = nil;
	
	[self.displayLink invalidate];
	self.displayLink = nil;
}
#pragma mark -
#pragma mark View Updating
- (void)updateHPAndGP {
	[self.hpBarView setPercent:(1.0f * self.hero.currentHP / self.hero.maxHP) duration:0.0];
	[self.gpBarView setPercent:(self.hero.glovePower / 100.0) duration:0.0];
}


#pragma mark -
#pragma mark Properties

- (RQHero *)hero {
	RQHero *hero_ = [[RQModelController defaultModelController] hero];
	if ( hero !=  hero_) {
		hero = hero_;
	}
	return hero;
}

#pragma mark Timer Fire Methods

- (void)displayLinkDidFire:(CADisplayLink *)sender {
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
			[self startGameMechanics];
			break;
		case 1:
			[self launchBattlePressed:self];
			break;
		default:
			break;
	}
}

- (void)encounterTreasure:(Treasure *)treasure {
	[hero setGlovePower:hero.glovePower + 15];
	[self updateHPAndGP];
}

- (void)encounterEnemy {
	NSString *alertBody = NSLocalizedString(@"You have encountered an enemy.  Do you want to fight?", @"ask the user if they want to fight the enemy");
	UILocalNotification *localNote = [[UILocalNotification alloc] init];
	localNote.fireDate = [NSDate date];
	localNote.repeatInterval = 0;
	localNote.alertBody = alertBody;
	localNote.alertAction = NSLocalizedString(@"Fight", @"Fight");
	localNote.soundName = @"Computer_Data_001.caf";
	localNote.userInfo = [NSDictionary dictionaryWithObject:@"fight" forKey:@"type"];
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	[[UIApplication sharedApplication] presentLocalNotificationNow:localNote];
    [localNote release];
}

- (void)encounterEnemyShouldConfirm:(BOOL)shouldConfirm {
	if ( shouldConfirm ) {
		[self pauseGameMechanicsAndRemoveTreasures:NO];
		[[SimpleAudioEngine sharedEngine] playEffect:@"Computer_Data_001.caf"];
		NSString *alertBody = NSLocalizedString(@"You have encountered an enemy.  Do you want to fight?", @"ask the user if they want to fight the enemy");
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ENEMY ENCOUNTERED", @"enemy encountered") 
														message:alertBody 
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"Keep Walking", @"Keep Walking") 
											  otherButtonTitles:NSLocalizedString(@"Fight", @"Fight"), nil];
		
		[alertView show];
		[alertView release];
	}
	else {
		[self launchBattlePressed:self];
	}

}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	if ( _encounteredTreasure ) {
		[self removeTreasure:_encounteredTreasure];
		_encounteredTreasure = nil;
	}
}

- (void)pulseEnemies {
	[self updateHPAndGP];
	NSTimeInterval timeSinceLastUpdate = 0;
	if ( _lastEnemyUpdate )
		timeSinceLastUpdate = [[NSDate date] timeIntervalSinceDate:_lastEnemyUpdate];
	
	MKMapPoint heroPoint = MKMapPointForCoordinate(_sonar.coordinate);
	CLLocationDistance sonarRange = _sonar.range;
	
	@synchronized (_enemyViews ) {
		NSSet *safeIterableCopy = [_enemyViews copy];
		BOOL didEncounterEnemy = NO;
		for ( EnemyAnnotationView* enemyView in safeIterableCopy ) {
			EnemyMapSpawn *enemy = enemyView.annotation;
			MKMapPoint enemyPoint = MKMapPointForCoordinate(enemy.coordinate);
			[_sonar lockForReading];
			
			
			//CLLocation *heroLocation = [[CLLocation alloc] initWithLatitude:_sonar.coordinate.latitude longitude:_sonar.coordinate.longitude];
			[_sonar unlockForReading];
			//CLLocation *enemyLocation = [[CLLocation alloc] initWithLatitude:enemy.coordinate.latitude longitude:enemy.coordinate.longitude];
			
			CLLocationDistance metersToHero = MKMetersBetweenMapPoints(enemyPoint, heroPoint)*DISTANCE_CONVERSION_FACTOR;
			
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
					[self encounterEnemy];
				}
				[enemyView pulse];
			}
			else {
				[enemyView stopPulsing];
			}
			
			
		}
		[safeIterableCopy release];
	}
	
	@synchronized ( _treasureViews ) {
		NSSet *safeIterableCopy = [_treasureViews copy];
		for ( TreasureAnnotationView *treasureView in safeIterableCopy ) {
			Treasure *treasure = [treasureView annotation];
			MKMapPoint treasurePoint = MKMapPointForCoordinate(treasure.coordinate);
			CLLocationDistance distance = MKMetersBetweenMapPoints(treasurePoint, heroPoint)*DISTANCE_CONVERSION_FACTOR;
			if ( distance > sonarRange ) {
				if ( treasure.remaining > timeSinceLastUpdate ) {
					treasure.remaining = treasure.remaining - timeSinceLastUpdate;
					[treasureView setNeedsDisplay];
				} else {
					[self removeTreasureView:treasureView];
					[self removeTreasure:treasure];
				}
			} else {
				[treasureView animateEncounterWithDelegate:self];
				[[SimpleAudioEngine sharedEngine] playEffect:@"levelUp.m4a"];
				[self removeTreasureView:treasureView];
				[self encounterTreasure:treasure];
				_encounteredTreasure = treasure;
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

- (void)removeTreasureView:(TreasureAnnotationView *)treasureView {
	@synchronized (_treasureViews ) {
		if ( treasureView )
			[_treasureViews	removeObject:treasureView];
	}
}

- (void)addTreasureView:(TreasureAnnotationView *)treasureView {
	@synchronized (_treasureViews ) {
		if ( treasureView )
			[_treasureViews	addObject:treasureView];
	}
}

- (void)removeTreasure:(Treasure *)treasure {
	@synchronized (_treasures) {
		[self.mapView removeAnnotation:treasure];
		[_treasures removeObject:treasure];
	}
}

- (void)addTreasure:(Treasure *)treasure {
	@synchronized (_treasures ) {
		[self.mapView addAnnotation:treasure];
		[_treasures addObject:treasure];
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
	course = course*RADIANS_PER_DEGREE;
	MKMapPoint heroMapPoint = MKMapPointForCoordinate(coordinate);
	CLLocationDistance mapPointsPerMeter = MKMapPointsPerMeterAtLatitude(coordinate.latitude);
	CLLocationDistance deltaY = -1.0f*ENEMY_SPAWN_RADIUS*cos((double)course)*mapPointsPerMeter;
	CLLocationDistance deltaX = ENEMY_SPAWN_RADIUS*sin((double)course)*mapPointsPerMeter;
	MKMapPoint enemyMapPoint = MKMapPointMake(heroMapPoint.x + deltaX, heroMapPoint.y + deltaY);
	CLLocationCoordinate2D enemyCoordinate = MKCoordinateForMapPoint(enemyMapPoint);
	
	CLLocationSpeed speed = location.speed;
	if ( speed < 0 ) {
		speed = (CLLocationSpeed)[[trek newestSegment] averageSpeed];
	}
	
	EnemyMapSpawn *enemy = [[EnemyMapSpawn alloc] initWithCoordinate:enemyCoordinate inManagedObjectContext:[appDelegate managedObjectContext]];
	enemy.speed = ( speed > 0 ? speed : SLOWEST_ENEMY_SPEED ) + ENEMY_SPEED_VARIANCE*rand()/RAND_MAX;
	enemy.heading = 0;
	
	[self addEnemy:enemy];
	[enemy release];
}

- (void)spawnEnemy {
	[self generateEnemyForHeroAtLocation:locationManager.location];
}

- (void)spawnTreasure {
	if ( [_treasures count] < MAX_TREASURES ) {
		CLLocation *location = locationManager.location;
		CLLocationCoordinate2D coordinate = location.coordinate;
		CLLocationDirection course = location.course;
		CLLocationSpeed speed = location.speed;
		if ( speed < 0 ) {
			speed = (CLLocationSpeed)[[trek newestSegment] averageSpeed];
		}
		course = course*RADIANS_PER_DEGREE;
		MKMapPoint heroMapPoint = MKMapPointForCoordinate(coordinate);
		CLLocationDistance mapPointsPerMeter = MKMapPointsPerMeterAtLatitude(coordinate.latitude);
		CLLocationDistance deltaY = -1.0f*ENEMY_SPAWN_RADIUS*cos((double)course)*mapPointsPerMeter;
		CLLocationDistance deltaX = ENEMY_SPAWN_RADIUS*sin((double)course)*mapPointsPerMeter;
		MKMapPoint enemyMapPoint = MKMapPointMake(heroMapPoint.x + deltaX, heroMapPoint.y + deltaY);
		CLLocationCoordinate2D enemyCoordinate = MKCoordinateForMapPoint(enemyMapPoint);
		MKMapPoint heroPoint = MKMapPointForCoordinate(_sonar.coordinate);
		CLLocationDistance metersToHero = MKMetersBetweenMapPoints(enemyMapPoint, heroPoint)*DISTANCE_CONVERSION_FACTOR;
		
		BOOL add = YES;
		
		for ( Treasure *treasure_ in _treasures ) {
			MKMapPoint point = MKMapPointForCoordinate(treasure_.coordinate);
			if ( MKMetersBetweenMapPoints(point, enemyMapPoint)*DISTANCE_CONVERSION_FACTOR < _sonar.range ) {
				add = NO;
				break;
			}
		}
		
		if ( add ) {
			Treasure *treasure = [[Treasure alloc] initWithLifetime:(metersToHero - _sonar.range)/(speed + 1.0f) coordinate:enemyCoordinate];
			[self addTreasure:treasure];
			[treasure release];
		}
	}
}

- (void)loadEnemiesAroundLocation:(CLLocation *)location {
	CLLocationCoordinate2D coordinate = location.coordinate;
	CLLocationDistance minDistanceBetweenEnemies = 10.0f/ENEMIES_TO_GENERATE*ENEMY_GENERATION_BOUNDS;
	CLLocationCoordinate2D lastCoordinate = coordinate;
	for ( NSUInteger i = 1; i <= ENEMIES_TO_GENERATE; i++ ) {
		double distance = 1.0f*i/ENEMIES_TO_GENERATE*ENEMY_GENERATION_BOUNDS + ENEMY_MIN_DISTANCE;
		
		CLLocationDistance distanceFromLast = 0;
		CLLocationCoordinate2D enemySpawnCoordinate = lastCoordinate;
		uint8_t tries = 0;
		while ( distanceFromLast < minDistanceBetweenEnemies && tries < 5) {
			double radians = 2*M_PI*rand()/RAND_MAX;
			double randX = -1.0f*distance*cos(radians);
			double randY = distance*sin(radians);
			enemySpawnCoordinate = CLLocationCoordinate2DMake(coordinate.latitude + randY, coordinate.longitude + randX);
			distanceFromLast = CLLocationDistanceBetweenCoordinates(enemySpawnCoordinate, lastCoordinate);
			tries++;
		}
		
		EnemyMapSpawn *enemy = [[EnemyMapSpawn alloc] initWithCoordinate:enemySpawnCoordinate inManagedObjectContext:[appDelegate managedObjectContext]];
		enemy.speed = 0; //SLOWEST_ENEMY_SPEED + ENEMY_SPEED_VARIANCE*rand()/RAND_MAX;
		enemy.heading = 0;
		
		[self addEnemy:enemy];
		[enemy release];
		lastCoordinate = enemySpawnCoordinate;
	}
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"RQSimulateGPS"] boolValue] == YES) {
		//EnemyMapSpawn *lastEnemy = [_enemies anyObject];
		//	CLLocation *destination = [[CLLocation alloc] initWithCoordinate:lastEnemy.coordinate altitude:0 horizontalAccuracy:0 verticalAccuracy:0 timestamp:[NSDate date]];
		//	[(RandomWalkLocationManager *)locationManager setDestination:destination];
	}
}

- (void)updateTimerLabel {
	self.timerLabel.text = [_timerFormatter stringForObjectValue:[NSDate dateWithTimeIntervalSinceReferenceDate:self.trek.duration]];
	//[NSString stringWithFormat:@"%lu:%lu", floor(trek.duration/60.0f), floor(remainder(trek.duration, 60.0f))];
	
	// update distance label, convert to miles
	NSString *newDistance = @"";
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"RQDisplayDistanceAsMeters"] boolValue]) {
		newDistance = [NSString stringWithFormat:@"%@ km", [_distanceFormatter stringForObjectValue:[NSNumber numberWithDouble:[self.trek distance]/1000]]];
	} else {
		newDistance = [NSString stringWithFormat:@"%@ mi", [_distanceFormatter stringForObjectValue:[NSNumber numberWithDouble:[self.trek distanceInMiles]]]];
	}
	
	//CCLOG(@"newDistance %@", newDistance);
	self.distanceLabel.text = newDistance;
	
	NSString *newCalBurn = [NSString stringWithFormat:@"%@ cal", [_calorieFormatter stringForObjectValue:[NSNumber numberWithDouble:[self.trek caloriesBurned]]]];
	self.calorieBurnLabel.text = newCalBurn;
	
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
		
		self.distanceTraveledSinceLastHPGain = self.distanceTraveledSinceLastHPGain + [[self trek] distance];
		if (self.distanceTraveledSinceLastHPGain > 2.0) {
			self.hero.currentHP = self.hero.currentHP + lroundf(self.hero.maxHP * 0.01);
			// adjustment to make low level easier
			if (self.hero.level < 10) {
				self.hero.currentHP = self.hero.currentHP + 1;
			} 
			self.distanceTraveledSinceLastHPGain = 0;
		} 
	}
}

#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	if ( [annotation isKindOfClass:[EnemyMapSpawn class]] ) {
		EnemyAnnotationView *view = [[EnemyAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"enemy"];
		[self addEnemyView:view];
		return [view autorelease];
	} else if ( [annotation isKindOfClass:[Treasure class]] ) {
		TreasureAnnotationView *view = [[TreasureAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"tresure"];
		[self addTreasureView:view];
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
	[self updateHPAndGP];
	[self dismissModalViewControllerAnimated:YES];
	[self setBattleViewController:nil];
	if ( self.trek )
		[self startGameMechanics];
	[[[RQModelController defaultModelController] coreDataManager] save];
}

- (void)viewControllerDidEnd:(UIViewController *)vc {
	if ( [vc isKindOfClass:[HelpViewController class]] ) {
		[self dismissModalViewControllerAnimated:YES];
		[self startGameMechanics];
	}
}

#pragma mark -
#pragma mark Action
- (IBAction)infoButtonPressed:(id)sender {
	NSString *mapViewHelp = [[NSBundle mainBundle] pathForResource:@"MapViewHelp" ofType:nil inDirectory:@"HTML"];
	HelpViewController *hvc = [[HelpViewController alloc] initWithHTMLFolder:mapViewHelp];
	hvc.delegate = self;
	[self pauseGameMechanicsAndRemoveTreasures:NO];
	[self presentModalViewController:hvc animated:YES];
	[hvc release];
}

- (IBAction)launchBattlePressed:(id)sender {
	
	// Commenting this out. I don't belive we should stop tracking the user while they fight.
	// [self.trek stop];
    
	self.battleViewController = [[[RQBattleViewController alloc] init] autorelease];
	self.battleViewController.delegate = self;
	self.battleViewController.battle.hero = self.hero;
	
	RQEnemy *enemy = [[RQModelController defaultModelController] randomEnemyBasedOnHero:hero];
	self.battleViewController.battle.enemy = enemy;
	
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	[self presentModalViewController:self.battleViewController animated:YES];
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
	[self removeTimerNamed:name];
	
	NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:selector	userInfo:nil repeats:YES];
	[_timers setObject:timer forKey:name];
	
	if ( fireDate )
		[timer setFireDate:fireDate];
	else
		[timer fire];
}



- (void)startGameMechanics {
	[self addTimerNamed:@"TreasureSpawn" withInterval:TREASURE_SPAWN_EVERY selector:@selector(spawnTreasure) fireDate:[NSDate dateWithTimeIntervalSinceNow:TREASURE_SPAWN_EVERY]];
	[self addTimerNamed:@"EnemyPulse" withInterval:ENEMY_PULSE_EVERY selector:@selector(pulseEnemies) fireDate:nil];
}

- (void)pauseGameMechanicsAndRemoveTreasures:(BOOL)removeTreasures {
	_lastEnemyUpdate = nil;
	if ( removeTreasures ) {
		NSSet *treasureCopy = [_treasureViews copy];
		for ( TreasureAnnotationView *tv in treasureCopy ) {
			[self removeTreasureView:tv];
			[self removeTreasure:tv.annotation];
		}
		[treasureCopy release];
	}
	[self removeTimerNamed:@"EnemyPulse"];
	[self removeTimerNamed:@"TreasureSpawn"];
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
		
		if (!self.trek) {
			Trek *newTrek = [[Trek alloc] initWithLocation:locationManager.location inManagedObjectContext:[appDelegate managedObjectContext]];
			self.trek = newTrek;
			[newTrek release];
		}
		
		distanceTraveledSinceLastHPGain = 0;
		
		[self.trek startWithLocation:locationManager.location];
		startButton.title = @"Pause Workout";
		[self addTimerNamed:@"Tick" withInterval:1 selector:@selector(updateTimerLabel) fireDate:nil];
		[self startGameMechanics];
	}
}

- (void)stopTrek {
	[self.trek stop];
	//startButton.title = @"Start Workout";
	[self removeTimerNamed:@"Tick"];
	NSError *error = nil;
	[[appDelegate managedObjectContext] save:&error];
	if ( error )
		CCLOG(@"%@", error);
	[self pauseGameMechanicsAndRemoveTreasures:YES];
	
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
	CCLOG(@"self.trek %@", self.trek);
}

- (IBAction)resumeButtonPressed:(id)sender
{
	[self startTrek];
}

- (IBAction)finishButtonPressed:(id)sender
{
	[self stopUpdatingLocation];
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	[delegate mapViewControllerDidEnd:self];
}

- (IBAction)doneButtonPressed:(id)sender {
	[self stopUpdatingLocation];
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
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

- (void)switchBottomToolbarToPauseShouldAnimate:(BOOL)animate {
	CGRect startToolbarEndFrame = self.startToolbar.frame;
	startToolbarEndFrame.origin.x = startToolbarEndFrame.origin.x - startToolbarEndFrame.size.width;
	CGRect pauseToolbarEndFrame = self.startToolbar.frame;
	
	if ( animate ) {
		[UIView beginAnimations:@"SwapToolbarsToPause" context:NULL];
	}
	
	self.pauseToolbar.frame = pauseToolbarEndFrame;
	self.startToolbar.frame = startToolbarEndFrame;
	
	if ( animate ) {
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView commitAnimations];
	}
}

- (void)switchBottomToolbarToStartShouldAnimate:(BOOL)animate {
	CGRect startToolbarEndFrame = self.pauseToolbar.frame;
	
	CGRect pauseToolbarEndFrame = self.pauseToolbar.frame;
	pauseToolbarEndFrame.origin.x = pauseToolbarEndFrame.origin.x + pauseToolbarEndFrame.size.width;
	
	if ( animate ) {
		[UIView beginAnimations:@"SwapToolbarsToStart" context:NULL];
	}
	
	self.pauseToolbar.frame = pauseToolbarEndFrame;
	self.startToolbar.frame = startToolbarEndFrame;
	
	if ( animate ) {
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView commitAnimations];
	}
}

- (void)moveStartWorkoutToolbarOffScreenShouldAnimate:(BOOL)animate
{
	CGRect newFrame = self.startToolbar.frame;
	newFrame.origin.x = 0 - self.startToolbar.frame.size.width;
	
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
	newFrame.origin.x = 0;
	
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
	newFrame.origin.x = self.view.frame.size.width + self.pauseToolbar.frame.size.width;
	
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
	newFrame.origin.x = self.view.frame.size.width - self.pauseToolbar.frame.size.width;
	
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
