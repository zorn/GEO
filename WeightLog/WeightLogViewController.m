#import "WeightLogViewController.h"
#import "WeightLogListViewController.h"

@implementation WeightLogViewController

#pragma mark -
#pragma mark Initialization

- (id)init
{
	if (self = [super initWithNibName:@"WeightLogView" bundle:nil]) {
		self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Weight-ins" 
														 image:[UIImage imageNamed:@"wieght_log_tab_icon.png"] 
														   tag:0] autorelease];
		[[self navigationItem] setTitle:@"Weight Summary"];
		UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Summary" style:UIBarButtonItemStyleBordered target:nil action:nil];
		[[self navigationItem] setBackBarButtonItem:newBackButton];
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (IBAction)enterTodaysWeight:(id)sender
{
	WeightLogEventEditViewController *controller = [[WeightLogEventEditViewController alloc] init];
	[controller setEditMode:NO]; // make a new object when they save
	[controller setDelegate:self];
	[self presentModalViewController:controller animated:YES];
	[controller release];
}

- (IBAction)editPreviousWeightins:(id)sender
{
	WeightLogListViewController *controller = [[WeightLogListViewController alloc] init];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}

#pragma mark -
#pragma mark WeightLogEventEditViewControllerDelegate methods

- (void)weightLogEventEditViewControllerDidEnd:(WeightLogEventEditViewController *)controller
{
	[self dismissModalViewControllerAnimated:YES];
}

@end
