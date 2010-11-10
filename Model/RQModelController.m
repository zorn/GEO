#import <CoreData/CoreData.h>
#import "RQModelController.h"
#import "M3CoreDataManager.h"
#import "M3SimpleCoreData.h"

// models
#import "RQHero.h"
#import "RQEnemy.h"
#import "RQWeightLogEntry.h"
#import "RQMonsterTemplate.h"

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
	
	RQEnemy *newEnemy = (RQEnemy *)[simpleCoreData newObjectInEntityWithName:@"Enemy" values:nil];
	[newEnemy setName:[monsterTemplate name]];
	[newEnemy setType:[monsterTemplate type]];
	[newEnemy setSpriteImageName:[monsterTemplate imageFileName]];
	[newEnemy setLevel:hero.level];
	[newEnemy setCurrentHP:[newEnemy maxHP]];
	[newEnemy setStamina:0];
	[newEnemy setStaminaRegenRate:4.0];
	return newEnemy;
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
		NSLog(@"oldest: %@, newest: %@", oldest.weightTaken, newest.weightTaken);
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

- (BOOL)shouldInsertInitialContents
{
	return ![self heroExists] && [[self weightLogEntries] count] <= 0;
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

- (void)insertInitialContent
{
	// SAMPLE DATE FOR WEIGHT LOG VIEWS 
	// create two months worth of random weight-in data, assuming they enter in a weight ~3 days and the delta +0.5 -2.5 pounds.
	/*
	int totalDays = 0;
	int daysToGenerate = 2;
	float currentWeight = 200.0;
	while (totalDays <= daysToGenerate) {
		
		int numberOfDays = (random() % 3) + 1; // 1, 2 or 3
		int entryDate = daysToGenerate - totalDays - numberOfDays;
		
		NSDate *weightinDate = [NSDate dateWithTimeIntervalSinceNow:60*60*24* -1 * entryDate];
		currentWeight = currentWeight + ((random() % 4) - 3); // -2 .. +1 
		
		RQWeightLogEntry *newEntry = [self newWeightLogEntry];
		[newEntry setDateTaken:weightinDate];
		[newEntry setWeightTaken:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", currentWeight]]];
		//NSLog(@"newEntry: %@", newEntry);
		
		totalDays = totalDays + numberOfDays;
	}
	*/
}



@end
