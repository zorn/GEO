#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "RQModelController.h"
#import "M3CoreDataManager.h"
#import "M3SimpleCoreData.h"

// models
#import "RQConstants.h"
#import "RQHero.h"
#import "RQEnemy.h"
#import "RQWeightLogEntry.h"
#import "RQMonsterTemplate.h"
#import "RQMentorMessageTemplate.h"
#import "Trek.h"
#import "Segment.h"

static RQModelController *defaultModelController = nil;

@implementation RQModelController

+ (RQModelController *)defaultModelController {
	if (!defaultModelController) {
		defaultModelController = [[RQModelController alloc] initWithInitialType:NSSQLiteStoreType 
																 appSupportName:@"RunQuest" 
																	  modelName:@"RunQuest.momd/RunQuest.mom"
																  dataStoreName:@"RunQuest.sqlite"];
	}
	return defaultModelController;
}

- (id)initWithInitialType:(NSString *)type appSupportName:(NSString *)supName modelName:(NSString *)mName dataStoreName:(NSString *)storeName
{
	if (self = [super init]) {
		
		NSString *initialType = nil;
		
		if (!type) {
			initialType = NSSQLiteStoreType;
		} else {
			initialType = type;
		}
		coreDataManager = [[M3CoreDataManager alloc] initWithInitialType:initialType 
														  appSupportName:supName 
															   modelName:mName 
														   dataStoreName:storeName];
		simpleCoreData = [[M3SimpleCoreData alloc] init];
		[simpleCoreData setManagedObjectModel:[coreDataManager managedObjectModel]];
		[simpleCoreData setManagedObjectContext:[coreDataManager managedObjectContext]];
		if ([self shouldInsertInitialContents]) {
			[self insertInitialContent];
		}
	}
	return self;
}

- (id)init {
	return [self initWithInitialType:NSInMemoryStoreType 
					  appSupportName:@"RunQuest" 
						   modelName:@"RunQuest.momd/RunQuest.mom" 
					   dataStoreName:@"RunQuest.sqlite"];
}

- (void)dealloc
{
	[_timerFormatter release];
	[_timerFormatterNoSeconds release];
	[_distanceFormatter release];
	[_calorieFormatter release];
	
	[coreDataManager release]; coreDataManager = nil;
	[simpleCoreData release]; simpleCoreData = nil;
	[_monsterTemplates release]; _monsterTemplates = nil;
	[super dealloc];
}

@synthesize coreDataManager;
@synthesize simpleCoreData;

- (void)save
{
	[self.coreDataManager save];
}

- (NSUndoManager *)undoManager
{
	return [[[self coreDataManager] managedObjectContext] undoManager];
}

- (RQHero *)hero
{
	NSArray *heros = [simpleCoreData objectsInEntityWithName:@"Hero" predicate:nil sortedWithDescriptors:nil];
	if (heros.count == 1) {
		RQHero *foundHero = [heros lastObject];
		return foundHero;
	} else if (heros.count == 0) {
		// make the hero
		RQHero *hero = (RQHero *)[simpleCoreData newObjectInEntityWithName:@"Hero" values:nil];
		return hero;
	} else {
		NSLog(@"There is more than 1 hero in the db. Uh oh.");
		// TODO: Something smart
	}
	return nil;
}

- (RQEnemy *)randomEnemyBasedOnHero:(RQHero *)hero
{	
	// Given the hero generate a random enemy for the hero 
	NSArray *allMonsterTemplates = [self monsterTemplates];
	
	// while progressing we will limit the enemies to match the weapons of the hero
	// Build a list of monster templates appriopiate for the hero
	NSMutableSet *monsterTemplates = [[NSMutableSet alloc] init];
	for (RQMonsterTemplate *template in allMonsterTemplates) {
		
		// if the hero has the weapon the template is weak to
		
		// earth is weak to fire
		if ([hero canUseFireWeapon] && [template type] == RQElementalTypeEarth) {
			[monsterTemplates addObject:template];
		}
		
		// fire is weak to water
		if ([hero canUseWaterWeapon] && [template type] == RQElementalTypeFire) {
			[monsterTemplates addObject:template];
		}
		
		// air is weak to earth
		if ([hero canUseEarthWeapon] && [template type] == RQElementalTypeAir) {
			[monsterTemplates addObject:template];
		}
		
		// water is weak to air
		if ([hero canUseAirWeapon] && [template type] == RQElementalTypeWater) {
			[monsterTemplates addObject:template];
		}
	}
	
	NSUInteger randomIndex = arc4random() % [monsterTemplates count];
	RQMonsterTemplate *monsterTemplate = [[monsterTemplates allObjects] objectAtIndex:randomIndex];
	[monsterTemplates autorelease];
	
	RQEnemy *newEnemy = (RQEnemy *)[simpleCoreData newObjectInEntityWithName:@"Enemy" values:nil];
	[newEnemy setName:[monsterTemplate name]];
	[newEnemy setType:[monsterTemplate type]];
	newEnemy.movementType = monsterTemplate.movementType;
	[newEnemy setSpriteImageName:[monsterTemplate imageFileName]];
	[newEnemy setLevel:hero.level];
	[newEnemy setCurrentHP:[newEnemy maxHP]];
	[newEnemy setStamina:0];
	[newEnemy setStaminaRegenRate:4.0];
	return newEnemy;
}

- (RQMentorMessageTemplate *)randomMentorMessageBasedOnBattle:(RQBattle *)battle
{
	// TODO: Current implimentation does not use battle, but should .. all messages are currently victory based.
	NSArray *allMentorTemplates = [self mentorMessageTemplates];
	
	// Build a list of mentor message templates appriopiate for the battle
	NSMutableSet *mentorTemplates = [[NSMutableSet alloc] init];
	for (RQMentorMessageTemplate *template in allMentorTemplates) {
		
		// Only add the shield related messages when the hero has shields
		if ([[battle hero] canUseShields] && [template relatedToMechanic] == RQMechanicShields) {
			[mentorTemplates addObject:template];
		}
		
		if ([template relatedToMechanic] == RQMechanicNone) {
			[mentorTemplates addObject:template];
		}
	}
	
	NSUInteger randomIndex = arc4random() % [mentorTemplates count];
	RQMentorMessageTemplate *mentorTemplate = [[mentorTemplates allObjects] objectAtIndex:randomIndex];
	[mentorTemplates autorelease];
	return mentorTemplate;
}

- (BOOL)heroExists
{
	NSArray *heros = [simpleCoreData objectsInEntityWithName:@"Hero" predicate:nil sortedWithDescriptors:nil];
	if (heros.count > 0) {
		return YES;
	} else {
		return NO;
	}
}

- (NSArray *)weightLogEntries
{
	return [simpleCoreData objectsInEntityWithName:@"WeightLogEntry" predicate:nil sortedWithDescriptors:nil];
}

- (NSArray *)weightLogEntriesSortedByDate
{
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateTaken" ascending:YES selector:@selector(compare:)];
	[sortDescriptor autorelease];
	return [simpleCoreData objectsInEntityWithName:@"WeightLogEntry" predicate:nil sortedWithDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

- (RQWeightLogEntry *)newWeightLogEntry
{
	[self willChangeValueForKey:@"weightLogEntries"];
	RQWeightLogEntry *entry = (RQWeightLogEntry *)[simpleCoreData newObjectInEntityWithName:@"WeightLogEntry" values:nil];
	[self didChangeValueForKey:@"weightLogEntries"];
	return entry;
}

- (void)deleteWeightLogEntry:(RQWeightLogEntry *)entry
{
	[self willChangeValueForKey:@"weightLogEntries"];
	[[simpleCoreData managedObjectContext] deleteObject:entry];
	[self didChangeValueForKey:@"weightLogEntries"];
}

- (RQWeightLogEntry *)oldestWeightLogEntry
{
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateTaken" ascending:YES selector:@selector(compare:)];
	NSArray *entries = [simpleCoreData objectsInEntityWithName:@"WeightLogEntry" predicate:nil sortedWithDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	if ([entries count] >= 1) {
		return [entries objectAtIndex:0];
	} else {
		return nil;
	}
}

- (RQWeightLogEntry *)newestWeightLogEntry
{
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateTaken" ascending:NO selector:@selector(compare:)];
	NSArray *entries = [simpleCoreData objectsInEntityWithName:@"WeightLogEntry" predicate:nil sortedWithDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	if ([entries count] >= 1) {
		return [entries objectAtIndex:0];
	} else {
		return nil;
	}
}

- (RQWeightLogEntry *)weightLogEntryFromDate:(NSDate *)someDate
{
	// Will return the closest match. IE: if we have a weight log entry on the 23rd and 25th and you ask for the 24th we will give you 23rd.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateTaken" ascending:NO selector:@selector(compare:)];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dateTaken <= %@", someDate];
	NSArray *entries = [simpleCoreData objectsInEntityWithName:@"WeightLogEntry" predicate:predicate sortedWithDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	if ([entries count] >= 1) {
		return [entries objectAtIndex:0];
	} else {
		return nil;
	}
}

- (NSDecimalNumber *)weightLostToDate
{
	return [self weightLostToDate:[NSDate distantFuture]];
}

- (NSDecimalNumber *)weightLostToDate:(NSDate *)someDate
{
	RQWeightLogEntry *oldest = [self oldestWeightLogEntry];
	RQWeightLogEntry *newest = [self weightLogEntryFromDate:someDate];
	if (oldest && newest) {
		CCLOG(@"oldest: %@, newest: %@", oldest.weightTaken, newest.weightTaken);
		return [oldest.weightTaken decimalNumberBySubtracting:newest.weightTaken];
	} else {
		return nil;
	}
}

- (NSDecimalNumber *)maxWeightLogged
{
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"weightTaken" ascending:NO selector:@selector(compare:)];
	NSArray *entries = [simpleCoreData objectsInEntityWithName:@"WeightLogEntry" predicate:nil sortedWithDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	if ([entries count] >= 1) {
		return [[entries objectAtIndex:0] weightTaken];
	} else {
		return nil;
	}
}

- (NSDecimalNumber *)minWeightLogged
{
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"weightTaken" ascending:YES selector:@selector(compare:)];
	NSArray *entries = [simpleCoreData objectsInEntityWithName:@"WeightLogEntry" predicate:nil sortedWithDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	if ([entries count] >= 1) {
		return [[entries objectAtIndex:0] weightTaken];
	} else {
		return nil;
	}
}



- (NSArray *)monsterTemplates
{
	if (!_monsterTemplates) {
		
		// Read the monster templates from the plist
		NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"monsters" ofType:@"plist"];
		NSArray *plistArray = [NSArray arrayWithContentsOfFile:plistPath];
		
		_monsterTemplates = [[NSMutableArray alloc] init];
		RQMonsterTemplate *newTemplate;
		for (NSDictionary *d in plistArray) {
			newTemplate = [[RQMonsterTemplate alloc] init];
			[newTemplate setName:[d objectForKey:@"name"]];
			[newTemplate setImageFileName:[d objectForKey:@"image_file"]];
			if ([[d objectForKey:@"type"] isEqualToString:@"fire"]) {
				[newTemplate setType:RQElementalTypeFire];
			} else if ([[d objectForKey:@"type"] isEqualToString:@"water"]) {
				[newTemplate setType:RQElementalTypeWater];
			} else if ([[d objectForKey:@"type"] isEqualToString:@"earth"]) {
				[newTemplate setType:RQElementalTypeEarth];
			} else if ([[d objectForKey:@"type"] isEqualToString:@"air"]) {
				[newTemplate setType:RQElementalTypeAir];
			}
			
			if ([[d objectForKey:@"movement_type"] isEqualToString:@"flying"]) {
				[newTemplate setMovementType:RQMonsterMovementTypeFlying];
			} else if ([[d objectForKey:@"movement_type"] isEqualToString:@"warp"]) {
				[newTemplate setMovementType:RQMonsterMovementTypeWarp];
			}
			[_monsterTemplates addObject:newTemplate];
			[newTemplate release]; newTemplate = nil;
		}
	} 
	return [NSArray arrayWithArray:_monsterTemplates];
}

- (NSArray *)mentorMessageTemplates
{
	if (!_mentorMessageTemplates) {
		
		// Read the mentor message templates from the plist
		NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"mentorMessageTemplates" ofType:@"plist"];
		NSArray *plistArray = [NSArray arrayWithContentsOfFile:plistPath];
		
		_mentorMessageTemplates = [[NSMutableArray alloc] init];
		RQMentorMessageTemplate *newTemplate;
		for (NSDictionary *d in plistArray) {
			newTemplate = [[RQMentorMessageTemplate alloc] init];
			
			if ([[d objectForKey:@"event"] isEqualToString:@"random"]) {
				[newTemplate setEventType:RQMessageEventTypeRandom];
			}
			if ([[d objectForKey:@"relatedToMechanic"] isEqualToString:@"shields"]) {
				[newTemplate setRelatedToMechanic:RQMechanicShields];
			} else {
				[newTemplate setRelatedToMechanic:RQMechanicNone];
			}
			[newTemplate setMessage:[d objectForKey:@"message"]];

			[_mentorMessageTemplates addObject:newTemplate];
			[newTemplate release]; newTemplate = nil;
		}
	} 
	return [NSArray arrayWithArray:_mentorMessageTemplates];
}

- (Trek *)oldestTrek
{
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES selector:@selector(compare:)];
	NSArray *entries = [simpleCoreData objectsInEntityWithName:@"Trek" predicate:nil sortedWithDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	if ([entries count] >= 1) {
		return [entries objectAtIndex:0];
	} else {
		return nil;
	}
}

- (Trek *)newestTrek
{
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO selector:@selector(compare:)];
	NSArray *entries = [simpleCoreData objectsInEntityWithName:@"Trek" predicate:nil sortedWithDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	if ([entries count] >= 1) {
		return [entries objectAtIndex:0];
	} else {
		return nil;
	}
}

- (NSArray *)allTreksFromWeekStartingOnSundayDate:(NSDate *)date
{
	// given some sunday, return an array of all the treks that took place that week
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES selector:@selector(compare:)];
	NSDate *lastDayOfTheWeek = [date dateByAddingTimeInterval:60*60*24*7];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date >= %@ && date <= %@", date, lastDayOfTheWeek];
	NSArray *entries = [simpleCoreData objectsInEntityWithName:@"Trek" predicate:predicate sortedWithDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	if ([entries count] >= 1) {
		return entries;
	} else {
		return nil;
	}
}

- (NSDateFormatter *)timeLengthFormatter
{
	if (!_timerFormatter) {
		_timerFormatter = [[NSDateFormatter alloc] init];
		[_timerFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		[_timerFormatter setDateFormat:@"H:mm:ss"];
	}
	return _timerFormatter;
}

- (NSDateFormatter *)timeLengthFormatterNoSeconds
{
	if (!_timerFormatterNoSeconds) {
		_timerFormatterNoSeconds = [[NSDateFormatter alloc] init];
		[_timerFormatterNoSeconds setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		[_timerFormatterNoSeconds setDateFormat:@"H:mm"];
	}
	return _timerFormatterNoSeconds;
}

- (NSNumberFormatter *)distanceFormatter
{
	if (!_distanceFormatter) {
		_distanceFormatter = [[NSNumberFormatter alloc] init];
		[_distanceFormatter setMinimumFractionDigits:1];
		[_distanceFormatter setMinimumIntegerDigits:1];
	}
	return _distanceFormatter;
}

- (NSNumberFormatter *)calorieFormatter
{
	if (!_calorieFormatter) {
		_calorieFormatter = [[NSNumberFormatter alloc] init];
		[_calorieFormatter setMinimumFractionDigits:0];
		[_calorieFormatter setMinimumIntegerDigits:1];
	}
	return _calorieFormatter;
}

- (BOOL)shouldInsertInitialContents
{
	//return ![self heroExists] && [[self weightLogEntries] count] <= 0;
	// yes, if we have no treks
	return [self oldestTrek] == nil;
}

- (void)insertInitialContent
{
	// SAMPLE DATE FOR WEIGHT LOG VIEWS 
	// create two months worth of random weight-in data, assuming they enter in a weight ~3 days and the delta +0.5 -2.5 pounds.
	/*
	int totalDays = 0;
	int daysToGenerate = 70;
	float currentWeight = 375.0;
	while (totalDays <= daysToGenerate) {
		
		int numberOfDays = (random() % 3) + 1; // 1, 2 or 3
		int entryDate = daysToGenerate - totalDays - numberOfDays;
		
		NSDate *weightinDate = [NSDate dateWithTimeIntervalSinceNow:60*60*24* -1 * entryDate];
		currentWeight = currentWeight + ((random() % 4) - 3); // -2 .. +1 
		
		RQWeightLogEntry *newEntry = [self newWeightLogEntry];
		[newEntry setDateTaken:weightinDate];
		[newEntry setWeightTaken:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", currentWeight]]];
		//CCLOG(@"newEntry: %@", newEntry);
		
		totalDays = totalDays + numberOfDays;
	}
	[self createSampleDataForTrekLogBookTesting];
	[self save];
	*/
}

- (void)createSampleDataForTrekLogBookTesting
{
	
	int totalDays = 0;
	int daysToGenerate = 60;
	CLLocation *startLocation = [[[CLLocation alloc] initWithLatitude:39.950756827139195 longitude:-75.14529347419739] autorelease];
	CLLocation *endLocation;
	NSManagedObjectContext *moc = [[self coreDataManager] managedObjectContext]; 
	while (totalDays <= daysToGenerate) {
		
		int numberOfDays = (random() % 3) + 1; // 1, 2 or 3
		int entryDate = daysToGenerate - totalDays - numberOfDays;
		
		
		NSDate *trekDate = [NSDate dateWithTimeIntervalSinceNow:60*60*24* -1 * entryDate];
		Trek *newTrek = [[Trek alloc] initWithLocation:startLocation inManagedObjectContext:moc];
		[newTrek setDate:trekDate];
		// add a random number of checkins
		int numberOfRandomLocation = (arc4random() % 25) + 1;
		for (int i = 0; i < numberOfRandomLocation; i++) {
			endLocation = [self randomLocationFromLocation:startLocation];
			[newTrek addLocation:endLocation];
			startLocation = endLocation;
		}
		
		// fake out the seqment dates
		int minutes = (arc4random() % 30) + 40;
		NSDate *endTrekDate = [trekDate dateByAddingTimeInterval:60*minutes];
		Segment *newestSegment = [newTrek newestSegment];
		newestSegment.startDate = trekDate;
		newestSegment.stopDate = endTrekDate;
		
		[newTrek release];
		
		totalDays = totalDays + numberOfDays;
	}
}

- (CLLocation *)randomLocationFromLocation:(CLLocation *)location
{
	// Take the given location and move randomly from it
	double latDelta = (arc4random() % 50)/10000.0;
	double lonDelta = (arc4random() % 50)/10000.0;
	
	CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:(location.coordinate.latitude + latDelta) longitude:(location.coordinate.longitude + lonDelta)];
	CCLOG(@"newLocation %@", newLocation);
	[newLocation autorelease];
	return newLocation;
}

@end
