#import "RQWeightLogEntry.h"

@implementation RQWeightLogEntry

- (void)awakeFromInsert
{
	[super awakeFromInsert];
	[self setDateTaken:[NSDate date]];
}

@dynamic weightTaken;
@dynamic dateTaken;

@end
