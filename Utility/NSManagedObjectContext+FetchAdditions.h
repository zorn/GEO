//
//  NSManagedObjectContext+FetchAdditions.h
//

#ifdef TARGET_OS_EMBEDDED
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif
#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (FetchAdditions)

- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName withPredicate:(NSPredicate *)predicate;
- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName;
- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName withPredicateFormat:(NSString *)predicateFormat, ...;
- (NSUInteger)countOfObjectsForEntityName:(NSString *)newEntityName withPredicate:(NSPredicate *)predicate;

- (id)fetchObjectForEntityName:(NSString *)newEntityName;
- (id)fetchObjectForEntityName:(NSString *)entityName withPredicate:(NSPredicate *)predicate;
- (id)fetchObjectForEntityName:(NSString *)entityName withPredicateFormat:(NSString *)predicateFormat, ...;

- (NSManagedObject *)objectWithURI:(NSURL *)uri;

@end
