#import "WeightLogViewController.h"


@implementation WeightLogViewController

#pragma mark -
#pragma mark Initialization

- (id)init
{
	if (self = [super initWithNibName:@"WeightLogView" bundle:nil]) {
		self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Weight-ins" 
														 image:[UIImage imageNamed:@"wieght_log_tab_icon.png"] 
														   tag:0] autorelease];
		[[self navigationItem] setTitle:@"Log Book"];
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}


@end
