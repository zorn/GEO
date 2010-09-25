#import <CoreData/CoreData.h>
#import "RQModelTests.h"
#import "RQModelController.h"

@implementation RQModelTests

- (void)setUp
{
	modelController = [[RQModelController alloc] initWithInitialType:NSInMemoryStoreType appSupportName:nil modelName:@"RunQuest.momd/RunQuest.mom" dataStoreName:nil];
}

- (void)tearDown
{
	[modelController release]; modelController = nil;
}

- (RQModelController *)modelController
{
	return modelController;
}

@end
