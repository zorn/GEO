#import <Foundation/Foundation.h>

@class M3CoreDataManager, M3SimpleCoreData;

@class RQHero;
@class RQEnemy;
@class RQWeightLogEntry;

@interface RQModelController : NSObject {
	M3CoreDataManager *coreDataManager;
	M3SimpleCoreData *simpleCoreData;
}

+ (RQModelController *)defaultModelController;

- (id)initWithInitialType:(NSString *)type appSupportName:(NSString *)supName modelName:(NSString *)mName dataStoreName:(NSString *)storeName;

@property (readonly) M3CoreDataManager *coreDataManager;
@property (readonly) M3SimpleCoreData *simpleCoreData;

- (NSUndoManager *)undoManager;

- (NSArray *)weightLogEntries;
- (RQWeightLogEntry *)newWeightLogEntry;
- (void)deleteWeightLogEntry:(RQWeightLogEntry *)entry;

- (NSArray *)monsterTemplates;


- (BOOL)shouldInsertInitialContents;
- (void)insertInitialContent;

- (RQHero *)hero;
- (BOOL)heroExists;
- (RQEnemy *)randomEnemyBasedOnHero:(RQHero *)hero;

@end
