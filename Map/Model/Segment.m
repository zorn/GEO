//
//  Trek.m
//  RunQuest
//
//  Created by Joe Walsh on 9/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Segment.h"
#import "RQWeightLogEntry.h"
#import "RQModelController.h"

#define INITIAL_LOCATION_SPACE 1000
#define INITIAL_SEGMENT_SPACE  1000
@implementation Segment
@dynamic locations, startDate, stopDate, trek;

- (id)initWithLocation:(CLLocation *)location inManagedObjectContext:(NSManagedObjectContext *)moc {
	NSEntityDescription *segmentEntity = [NSEntityDescription entityForName:@"Segment" inManagedObjectContext:moc];
	if (( self = [super initWithEntity:segmentEntity insertIntoManagedObjectContext:moc] )) {
		NSMutableArray *initalLocationsArray = [[NSMutableArray alloc] initWithCapacity:INITIAL_LOCATION_SPACE];
		self.locations = initalLocationsArray;
		[initalLocationsArray release];
		
		self.startDate = [NSDate date];
		
	} return self;
}

- (void)awakeFromFetch {
	[super awakeFromFetch];
}

- (NSComparisonResult)compare:(Segment  *)segment{
	return [self.startDate compare:segment.startDate];
}

- (void)dealloc {
	[super dealloc];
}

- (NSTimeInterval)duration {
	NSDate *startTime = self.startDate;
	NSDate *endTime =  ( self.isStopped ? self.stopDate : [NSDate date]);
	return [endTime timeIntervalSinceDate:startTime];
}

- (void)stop {
	if ( !self.isStopped )
		self.stopDate = [NSDate date];
}

- (BOOL)isStopped {
	return ( self.stopDate != nil );
}

- (void)addLocation:(CLLocation *)location {
	NSMutableArray *locationsCopy = [[self locations] mutableCopy];
	[locationsCopy addObject:location];
	self.locations = locationsCopy;
}

- (double)averageSpeed {
	return [self distance]/[self duration];
}

- (double)averageSpeedInMiles {
	return [self distanceInMiles]/[self duration];
}

- (double)distance {
	CLLocationDistance dist = 0;
	NSUInteger i = 1;
	for ( CLLocation *location in self.locations) {
		if ( i < [self.locations count] ) {
			dist+= [[self.locations objectAtIndex:i] distanceFromLocation:location];
		}
		i++;
	}
	return (double)dist;
}

- (double)distanceInMiles
{
	// 1 meter = 0.000621371192 miles
	return [self distance] * 0.000621371192;
}

- (double)caloriesBurned
{
	// Via: http://www.indiacurry.com/weightloss/walkingrunningcalories.htm
	//	How many calories burned by walking or running? Formula
	//	During walking or running, you are carrying your own weight, thus the calories spent are a function of your weight
	//	
	//	While walking, the center of gravity is just over your legs. When running, the center of gravity suddenly shifts upwards as you push off one foot, suddenly shifts downward as you lower the the foot bending knee to absorb the shock. The sudden shifts in center of gravity cause burning extra calories to maintain balance and momentum. When you are running, you are consuming more oxygen, thus spending more calories. It takes 5 calories to consume one liter of oxygen.
	//	Speed of running does not influence the number of calories being spent. However faster you walk, more calories you burn, finally arriving at a cross over point where walking burns more calories than running. The cross-over point is at 5 mph.
	//	
	//	The following formulas are adopted from 'Energy Expenditure of Walking and Running,' Medicine & Science in Sport & Exercise, Cameron et al, Dec. 2004
	//	
	//	Without any activity, we are still burning energy (Basal metabolism). The 'Net Calories Spent' excludes Basal Metabolism. The walking formula applies to speeds of 3 to 4 miles per hour. You burn approximately twice as many calories by running than by walking at these speeds.
	//	
	//	Net Running calories Spent = (Body weight in pounds) x (0.63) x (Distance in miles)
	//	A person weighing 160 pounds will burn 100.8 extra calories by running for one mile than sitting ideally by.
	//		Total Running calories Spent = (Body weight in pounds) x (0.75) x (Distance in miles)
	//		
	//	Net Walking calories Spent = (Body weight in pounds) x (0.30) x (Distance in miles)
	//		A person weighing 160 pounds will burn 48 extra calories walking for one mile than sitting ideally by.
	//			Total Walking calories Spent = (Body weight in pounds) x (0.53) x (Distance in miles)
	//			
	//			After walking or running, the metabolism remains high burning calories for at least 30 minutes, before it slowly reaches down to Basal Metabolic rate.
	//	
	// Other refs:
	// http://answers.google.com/answers/threadview/id/758572.html
	// http://ask.metafilter.com/48652/Walking-formula	
	
	// We will only show the calories they are gaining by running, not the total burned
	RQWeightLogEntry *entry = [[RQModelController defaultModelController] weightLogEntryFromDate:self.startDate];
	if (entry) {
		float burnRate = 0.30;
		if ([self averageSpeedInMiles] > 5.0) {
			burnRate = 0.63;
		}
		double calBurn = [[entry weightTaken] doubleValue] * burnRate * [self distanceInMiles];
		return calBurn;
	} else {
		NSLog(@"Could not calculate cal burn due to missing weight entry for date %@", self.startDate);
		return 0.0;
	}
}


@end
