#import "RQWeightLog.h"

@implementation RQWeightLog

- (void)awakeFromInsert
{
	[super awakeFromInsert];
	[self setDateTaken:[NSDate date]];
}

@dynamic weightTaken;
@dynamic dateTaken;

@end
