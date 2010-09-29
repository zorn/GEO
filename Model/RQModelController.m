#import <CoreData/CoreData.h>
#import "RQModelController.h"
#import "M3CoreDataManager.h"
#import "M3SimpleCoreData.h"

#import "RQHero.h"
#import "RQEnemy.h"

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



@synthesize coreDataManager;
@synthesize simpleCoreData;

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
	NSArray *monsterTemplates = [self monsterTemplates];
	NSDictionary *monsterTemplate = [monsterTemplates objectAtIndex:(random() % [monsterTemplates count])];
	
	RQEnemy *newEnemy = (RQEnemy *)[simpleCoreData newObjectInEntityWithName:@"Enemy" values:nil];
	[newEnemy setName:[monsterTemplate objectForKey:@"name"]];
	[newEnemy setTypeAsNumber:[monsterTemplate objectForKey:@"type"]];
	[newEnemy setSpriteImageName:[monsterTemplate objectForKey:@"image"]];
	[newEnemy setLevel:hero.level];
	[newEnemy setCurrentHP:[newEnemy maxHP]];
	[newEnemy setStamina:0];
	[newEnemy setStaminaRegenRate:8.0];
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

- (BOOL)shouldInsertInitialContents
{
	return NO;
}

- (NSArray *)monsterTemplates
{
	return [NSArray arrayWithObjects:
			[NSDictionary dictionaryWithObjectsAndKeys:@"Globby", @"name", @"boob1.png", @"image", [NSNumber numberWithInteger: RQElementalTypeFire], @"type", [UIColor redColor], @"color", nil],
			[NSDictionary dictionaryWithObjectsAndKeys:@"Super Globby", @"name", @"boob2.png", @"image", [NSNumber numberWithInteger: RQElementalTypeWater], @"type", [UIColor blueColor], @"color", nil],
			[NSDictionary dictionaryWithObjectsAndKeys:@"Ultra Globby", @"name", @"boob3.png", @"image", [NSNumber numberWithInteger: RQElementalTypeEarth], @"type", [UIColor brownColor], @"color", nil],
			[NSDictionary dictionaryWithObjectsAndKeys:@"Master Globby", @"name", @"boob4.png", @"image", [NSNumber numberWithInteger: RQElementalTypeAir], @"type", [UIColor lightGrayColor], @"color", nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:@"ManTuss", @"name", @"man-tuss.png", @"image", [NSNumber numberWithInteger: RQElementalTypeFire], @"type", [UIColor redColor], @"color", nil],
			[NSDictionary dictionaryWithObjectsAndKeys:@"Super ManTuss", @"name", @"man-tuss_blue.png", @"image", [NSNumber numberWithInteger: RQElementalTypeWater], @"type", [UIColor blueColor], @"color", nil],
			[NSDictionary dictionaryWithObjectsAndKeys:@"Ultra ManTuss", @"name", @"man-tuss_purple.png", @"image", [NSNumber numberWithInteger: RQElementalTypeEarth], @"type", [UIColor brownColor], @"color", nil],
			[NSDictionary dictionaryWithObjectsAndKeys:@"Master ManTuss", @"name", @"man-tuss_red.png", @"image", [NSNumber numberWithInteger: RQElementalTypeAir], @"type", [UIColor lightGrayColor], @"color", nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:@"Meanie", @"name", @"meanie_1.png", @"image", [NSNumber numberWithInteger: RQElementalTypeFire], @"type",  [UIColor redColor], @"color", nil],
			[NSDictionary dictionaryWithObjectsAndKeys:@"Super Meanie", @"name", @"meanie_2.png", @"image", [NSNumber numberWithInteger: RQElementalTypeWater], @"type", [UIColor blueColor], @"color", nil],
			[NSDictionary dictionaryWithObjectsAndKeys:@"Ultra Meanie", @"name", @"meanie_3.png", @"image", [NSNumber numberWithInteger: RQElementalTypeEarth], @"type", [UIColor brownColor], @"color", nil],
			[NSDictionary dictionaryWithObjectsAndKeys:@"Master Meanie", @"name", @"meanie_4.png", @"image", [NSNumber numberWithInteger: RQElementalTypeAir], @"type", [UIColor lightGrayColor], @"color", nil],
			
			nil];
}

/**
 Inserts the initial content for the database from the info dict
 */
- (void)insertInitialContent {
	//	NSArray *authors = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"Authors"];
	//	for (NSDictionary *authorDict in authors) { 
	//		M3Author *author = [self newAuthor];
	//		[author setName:[authorDict valueForKey:@"name"]];
	//		[author setEmail:[authorDict valueForKey:@"email"]];
	//	}
	//	
	//	
	//	NSArray *categories = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"Categories"];
	//	for (NSString *categoryTitle in categories) { 
	//		M3Category *category = [self newCategory];
	//		[category setTitle:categoryTitle];
	//	}	
}

@end
