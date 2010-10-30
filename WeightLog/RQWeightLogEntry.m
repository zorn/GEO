#import "RQWeightLogEntry.h"
#import "RQModelController.h"

@implementation RQWeightLogEntry

- (void)awakeFromInsert
{
	[super awakeFromInsert];
	[self setDateTaken:[NSDate date]];
}

@dynamic weightTaken;
@dynamic dateTaken;

- (NSDecimalNumber *)weightLostAsOfSelf
{
	if (self.dateTaken) {
		return [[RQModelController defaultModelController] weightLostToDate:self.dateTaken];
	} else {
		return nil;
	}
}

@end
