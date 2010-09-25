#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface M3CoreDataManager : NSObject {
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	NSString *initialType;
	NSString *appSupportName;
	NSString *modelName;
	NSString *dataStoreName;
	
	id delegate;
}

@property (assign) id delegate;

- (id)initWithInitialType:(NSString *)type appSupportName:(NSString *)supName modelName:(NSString *)mName dataStoreName:(NSString *)storeName;

- (NSString *)applicationSupportFolder;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;

#ifdef TARGET_OS_IPHONE
- (void)save;
#else
- (NSApplicationTerminateReply)save;
#endif


@end


@interface M3CoreDataManager (Delegates) 

- (void)coreDataManager:(M3CoreDataManager *)manager encounteredIncorrectModelWithVersionIdentifiers:(NSSet *)idents;

@end