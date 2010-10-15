#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface RQWeightLog : NSManagedObject 
{
	
}

@property (nonatomic, retain) NSDecimalNumber *weightTaken;
@property (nonatomic, retain) NSDate *dateTaken;

@end
