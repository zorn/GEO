#import "RQModelController.h"
#import "M3CoreDataManager.h"
#import "M3SimpleCoreData.h"

static RQModelController *defaultModelController = nil;

@implementation RQModelController

+ (RQModelController *)defaultModelController {
	if (!defaultModelController) {
		defaultModelController = [[RQModelController alloc] initWithInitialType:NSSQLiteStoreType 
																 appSupportName:@"RunQuest" 
																	  modelName:@"RunQuest.xcdatamodeld/RunQuest.xcdatamodel"
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
					  appSupportName:@"ProfitTrain" 
						   modelName:@"PTDataModel.momd/schemaVersion1.mom" 
					   dataStoreName:@"ProfitTrainCoreDataStore.sqlite"];
}



@synthesize coreDataManager;
@synthesize simpleCoreData;

- (NSUndoManager *)undoManager
{
	return [[[self coreDataManager] managedObjectContext] undoManager];
}

- (BOOL)shouldInsertInitialContents
{
	return NO;
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
