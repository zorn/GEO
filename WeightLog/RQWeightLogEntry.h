#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface RQWeightLogEntry : NSManagedObject 
{
	
}

@property (nonatomic, copy) NSDecimalNumber *weightTaken;
@property (nonatomic, copy) NSDate *dateTaken;

- (NSDecimalNumber *)weightLostAsOfSelf;


@end
