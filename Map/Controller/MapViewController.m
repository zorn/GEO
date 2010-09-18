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


#define ENEMY_GENERATION_BOUNDS_X .01f
#define ENEMY_GENERATION_BOUNDS_Y .015f

#define ENEMY_STEP_SIZE .0001
#define ENEMIES_TO_GENERATE 10

@interface MapViewController ()
@property (nonatomic, retain) RQBattleTestViewController *battleViewController;
- (void)updatePath;
- (void)showHUD;
- (void)hideHUD;
@end

@implementation MapViewController
@synthesize hudView, overlayLabel, mapView, displayLink;
@synthesize launchBattleButton;
@synthesize battleViewController;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		srand([[NSDate date] timeIntervalSince1970]);
		appDelegate = [[UIApplication sharedApplication] delegate];
		_locationManager = [[CLLocationManager alloc] init];
		_locationManager.purpose = NSLocalizedString(@"To track your progress around the RunQuest world.", @"Explain what we're using core location for");
		_locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
		_locationManager.distanceFilter = kCLDistanceFilterNone;
		_locationManager.delegate = self;
		[_locationManager startUpdatingLocation];
		
		_enemies = [[NSMutableSet alloc] initWithCapacity:ENEMIES_TO_GENERATE];
		
		[[appDelegate managedObjectContext] fetchObjectsForEntityName:@"Trek"];
    }
    return self;
}

- (void)dealloc {
	[_locationManager release];
	[_sonarView release];
	[_sonar release];
	[_enemies release];
    [launchBattleButton release];
	[super dealloc];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(cycleRadius:)];
	[self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [super viewDidLoad];
}

- (void)cycleRadius:(CADisplayLink *)sender{ 
	[_sonar lockForReading];
	CGFloat oldRadius = _sonar.radius;
	CGFloat range = _sonar.range;
	CLLocationCoordinate2D coordinate = _sonar.coordinate;
	[_sonar unlockForReading];
	
	
	double newRadius = 10;
	if ( oldRadius < range )
		newRadius = oldRadius + 10;

	[_sonar setRadius:newRadius];
	MKMapPoint needsDisplayCorner = MKMapPointForCoordinate(coordinate);
	MKMapRect needsDisplay = (MKMapRect) {MKMapPointMake(needsDisplayCorner.x - newRadius/2.0f, needsDisplayCorner.y - newRadius/2.0f), MKMapSizeMake(newRadius, newRadius) };
	
	needsDisplay = MKMapRectInset(needsDisplay, -5, -5);
	[_sonarView setNeedsDisplayInMapRect:needsDisplay];
	
//	for ( Enemy* enemy in _enemies ) {
//		CLLocationCoordinate2D currentCoordinate = enemy.coordinate;
//		double heading = 2.0f*M_PI*rand()/RAND_MAX;
//		double deltaX = cos(heading)*ENEMY_STEP_SIZE;
//		double deltaY = sin(heading)*ENEMY_STEP_SIZE;
//		CLLocationCoordinate2D newCoordinate = CLLocationCoordinate2DMake(currentCoordinate.latitude + deltaY, currentCoordinate.longitude + deltaX);
//		enemy.coordinate = newCoordinate;
//	}
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.launchBattleButton = nil;
}

- (void)loadEnemiesAroundLocation:(CLLocation *)location {
	CLLocationCoordinate2D coordinate = location.coordinate;
	for ( NSUInteger i = 1; i <= 10; i++ ) {
		double randX = ENEMY_GENERATION_BOUNDS_X*rand()/RAND_MAX;
		double randY = ENEMY_GENERATION_BOUNDS_Y*rand()/RAND_MAX;
		Enemy *enemy = [[Enemy alloc] initWithCoordinate:CLLocationCoordinate2DMake(coordinate.latitude + randY - ENEMY_GENERATION_BOUNDS_Y/2.0f, coordinate.longitude + randX - ENEMY_GENERATION_BOUNDS_X/2.0f)];
		enemy.spriteURL = [NSURL URLWithString:@"http://www.fanboyreview.net/wp-content/uploads/2009/11/mm9-mega-man-sprite1.gif"];
		[self.mapView addAnnotation:enemy];
		[_enemies addObject:enemy];
		[enemy release];
	}
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	if ( !newLocation )
		[self showHUD];
	
	if ( !oldLocation )
		[self hideHUD];
	
	if ( newLocation && newLocation.horizontalAccuracy > 0) {
		
		if ( !_sonar ) { 
			_sonar = [[Sonar alloc] initWithCoordinate:newLocation.coordinate range:1000];
			[self.mapView addOverlay:_sonar];
		}
		else
			_sonar.coordinate = newLocation.coordinate;
		
		//[_sonarView setNeedsDisplayInMapRect:[_sonar boundingMapRect]];
		
		if ( newLocation.horizontalAccuracy < 100 ) {
			if ( !trek ) {
				MKCoordinateSpan span = MKCoordinateSpanMake(ENEMY_GENERATION_BOUNDS_Y, ENEMY_GENERATION_BOUNDS_X);
				[self.mapView setRegion:MKCoordinateRegionMake(newLocation.coordinate, span) animated:YES];
				[self loadEnemiesAroundLocation:newLocation];
				trek = [[Trek alloc] initWithLocation:newLocation inManagedObjectContext:[appDelegate managedObjectContext]];
			}
			else
				[trek addLocation:newLocation];
		}
	
		NSLog(@"%f", [trek duration]);
		
		
		//MKCoordinateSpan span = MKCoordinateSpanMake(.25, .25);
		//MKCoordinateRegion region = MKCoordinateRegionMake(newLocation.coordinate, span);
		//[self.mapView setRegion:region animated:YES];
		[self updatePath];
	}
}

#pragma mark Path Drawing

- (void)updatePath {
	//NSUInteger count = [_track count];
//	CLLocationCoordinate2D coordinates[count];
//	
//	for ( NSUInteger i = 0; i < count; i++ ) {
//		CLLocation *location = [_track objectAtIndex:i];
//		CLLocationCoordinate2D coordinate = location.coordinate;
//		coordinates[i] = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
//	}
//	
//	MKPolyline *newPolyline = [MKPolyline polylineWithCoordinates:coordinates count:count];
//	
//	[self.mapView addOverlay:newPolyline];
//	
//	if ( _pathOverlay ) {
//		[self.mapView removeOverlay:_pathOverlay];
//		[_pathOverlay release];
//		_pathOverlay = nil;
//	}
//	
//	
//	_pathOverlay = [newPolyline retain];
}

#pragma mark Overlay View

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
	if ( [annotation isKindOfClass:[Enemy class]] )
		return [[[EnemyAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"blah"] autorelease];
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


#pragma mark -
#pragma mark Action
- (IBAction)launchBattlePressed:(id)sender {
    self.battleViewController = [[[RQBattleTestViewController alloc] init] autorelease];
    [self.view.window addSubview:self.battleViewController.view];
    self.mapView.hidden = YES;
}

@end
