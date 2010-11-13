#import <Foundation/Foundation.h>

@class M3CoreDataManager, M3SimpleCoreData;

@class RQHero;
@class RQEnemy;
@class RQWeightLogEntry;
@class RQMentorMessageTemplate;
@class RQBattle;

@interface RQModelController : NSObject {
	M3CoreDataManager *coreDataManager;
	M3SimpleCoreData *simpleCoreData;
	
	NSMutableArray *_monsterTemplates;
	NSMutableArray *_mentorMessageTemplates;
}

+ (RQModelController *)defaultModelController;

- (id)initWithInitialType:(NSString *)type appSupportName:(NSString *)supName modelName:(NSString *)mName dataStoreName:(NSString *)storeName;

@property (readonly) M3CoreDataManager *coreDataManager;
@property (readonly) M3SimpleCoreData *simpleCoreData;

- (void)save;
- (NSUndoManager *)undoManager;

- (NSArray *)weightLogEntries;
- (NSArray *)weightLogEntriesSortedByDate;
- (RQWeightLogEntry *)newWeightLogEntry;
- (void)deleteWeightLogEntry:(RQWeightLogEntry *)entry;
- (RQWeightLogEntry *)oldestWeightLogEntry;
- (RQWeightLogEntry *)newestWeightLogEntry;
- (RQWeightLogEntry *)weightLogEntryFromDate:(NSDate *)someDate;

- (NSDecimalNumber *)weightLostToDate;
- (NSDecimalNumber *)weightLostToDate:(NSDate *)someDate;

- (NSDecimalNumber *)maxWeightLogged;
- (NSDecimalNumber *)minWeightLogged;

- (NSArray *)monsterTemplates;
- (NSArray *)mentorMessageTemplates;

- (BOOL)shouldInsertInitialContents;
- (void)insertInitialContent;

- (RQHero *)hero;
- (RQMentorMessageTemplate *)randomMentorMessageBasedOnBattle:(RQBattle *)battle;
- (BOOL)heroExists;
- (RQEnemy *)randomEnemyBasedOnHero:(RQHero *)hero;

@end
