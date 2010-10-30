#import "WeightLogViewController.h"
#import "WeightLogListViewController.h"

// models
#import "RQModelController.h"

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
	[weightLostToDateLabel release]; weightLostToDateLabel = nil;
	[listViewButton release]; listViewButton = nil;
	[super dealloc];
}

@synthesize weightLostToDateLabel;
@synthesize listViewButton;

#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    // Update top label
	NSDecimalNumber *weightLostToDate = [[RQModelController defaultModelController] weightLostToDate];
	if (weightLostToDate) {
		// NSOrderedAscending if the value of decimalNumber is greater than the receiver; NSOrderedSame if they’re equal; and NSOrderedDescending if the value of decimalNumber is less than the receiver.
		if ([[NSDecimalNumber zero] compare:weightLostToDate] != NSOrderedDescending) {
			[self.weightLostToDateLabel setText:[NSString stringWithFormat:@"You have lost %@ pounds.", weightLostToDate]];
		} else {
			[self.weightLostToDateLabel setText:[NSString stringWithFormat:@"You have gained %@ pounds.", [weightLostToDate decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]]]];
		}
		
	} else {
		[self.weightLostToDateLabel setText:@"Enter your weight below."];
	}
	[super viewWillAppear:animated];
	
	// disable the list view button while zero items to list
	if ([[[RQModelController defaultModelController] weightLogEntries] count] > 0) {
		[self.listViewButton setEnabled:YES];
	} else {
		[self.listViewButton setEnabled:NO];
	}
}

#pragma mark -
#pragma mark Actions

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
