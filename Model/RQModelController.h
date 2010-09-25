#import <Foundation/Foundation.h>

@class M3CoreDataManager, M3SimpleCoreData;

@class RQHero;
@class RQEnemy;

@interface RQModelController : NSObject {
	M3CoreDataManager *coreDataManager;
	M3SimpleCoreData *simpleCoreData;
}

+ (RQModelController *)defaultModelController;

- (id)initWithInitialType:(NSString *)type appSupportName:(NSString *)supName modelName:(NSString *)mName dataStoreName:(NSString *)storeName;

@property (readonly) M3CoreDataManager *coreDataManager;
@property (readonly) M3SimpleCoreData *simpleCoreData;

- (NSUndoManager *)undoManager;

- (BOOL)shouldInsertInitialContents;
- (void)insertInitialContent;

- (RQHero *)hero;
- (BOOL)heroExists;
- (RQEnemy *)randomEnemy;

@end
