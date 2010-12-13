#import "WeightLogEventEditViewController.h"

// models
#import "RQModelController.h"
#import "RQWeightLogEntry.h"

@implementation WeightLogEventEditViewController

#pragma mark -
#pragma mark Initialization

- (id)init
{
	if (self = [super initWithNibName:@"WeightLogEventEditView" bundle:nil]) {
		[[self navigationItem] setTitle:@"Edit Weight"];
		editMode = YES;
		wasCanceled = NO;
	}
	return self;
}

- (void)dealloc
{
	[_formatter release]; _formatter = nil;
	[tempDate release]; tempDate = nil;
	[tempWeight release]; tempWeight = nil;
	[weightLogEntry release]; weightLogEntry = nil;
	
	// outlets
	[saveButton release]; saveButton = nil;
	[tableView release]; tableView = nil;
	[dateCell release]; dateCell = nil;
	[weightCell release]; weightCell = nil;
	[dateLabel release]; dateLabel = nil;
	[weightTextField release]; weightTextField = nil;
	[datePicker release]; datePicker = nil;
	[weightUnitLabel release]; weightUnitLabel = nil;

	[super dealloc];
}

@synthesize delegate;
@synthesize tempDate;
@synthesize tempWeight;
@synthesize weightLogEntry;
@synthesize editMode;
@synthesize wasCanceled;

@synthesize saveButton;
@synthesize tableView;
@synthesize dateCell;
@synthesize weightCell;
@synthesize dateLabel;;
@synthesize weightTextField;
@synthesize datePicker;
@synthesize weightUnitLabel;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{ 
	[super viewDidLoad];
	
	[self.tableView setSeparatorColor:[UIColor colorWithRed:0.204 green:0.212 blue:0.222 alpha:1.000]];
	// YOU MUST DO THIS IN CODE, TRYING TO DO THIS IN IB VIA COLOR PICKER WILL RESULT IN BLACK CORNERS AROUND THE GROUPS
	self.tableView.backgroundColor = [UIColor clearColor];
	
	[self moveDatePickerViewOffScreen];
	
	_formatter = [[NSDateFormatter alloc] init];
	[_formatter setDateStyle:NSDateFormatterShortStyle];
	
	if (self.editMode) {
		self.tempDate = self.weightLogEntry.dateTaken;
		
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"RQDisplayWeightAsGrams"] boolValue]) {
			// convert from lbs (how we store weight) into kilograms
			// lbs / 2.2 = kilograms
			self.tempWeight = [self.weightLogEntry.weightTaken decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"2.2"]];
		} else {
			self.tempWeight = self.weightLogEntry.weightTaken;
		}
		
	} else {
		self.tempDate = [NSDate date];
	}
	
	[self.dateLabel setText:[_formatter stringForObjectValue:self.tempDate]];
	if (self.tempWeight) [self.weightTextField setText:[[[RQModelController defaultModelController] calorieFormatter] stringFromNumber:tempWeight]];
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"RQDisplayWeightAsGrams"] boolValue]) {
		self.weightUnitLabel.text = @"kg";
	} else {
		self.weightUnitLabel.text = @"lbs";
	}
	
	[self.weightTextField becomeFirstResponder];
	[self updateUI];
}

#pragma mark -
#pragma mark Actions

- (IBAction)saveOrCancelButtonPressed:(id)sender
{	
	if ([sender tag] == 1) {
		// save
		
		// bail if wight text isn't valid
		if ([self.weightTextField isFirstResponder]) {
			if (![self.weightTextField resignFirstResponder]) {
				return;
			}
		}
		
		if (self.editMode) {
			[self.weightLogEntry setDateTaken:self.tempDate];
			
			NSDecimalNumber *savedWeight = nil;
			if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"RQDisplayWeightAsGrams"] boolValue]) {
				// convert from kilograms into pounds
				// lbs / 2.2 = kilograms
				savedWeight = [self.tempWeight decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"2.2"]];
			} else {
				savedWeight = self.tempWeight;
			}
			[self.weightLogEntry setWeightTaken:savedWeight];
			
		} else {
			RQWeightLogEntry *newEntry = [[RQModelController defaultModelController] newWeightLogEntry];
			[newEntry setDateTaken:self.tempDate];
			
			NSDecimalNumber *savedWeight = nil;
			if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"RQDisplayWeightAsGrams"] boolValue]) {
				// convert from kilograms into pounds
				// lbs / 2.2 = kilograms
				savedWeight = [self.tempWeight decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"2.2"]];
			} else {
				savedWeight = self.tempWeight;
			}
			[newEntry setWeightTaken:savedWeight];
		}
		[[RQModelController defaultModelController] save];
		
	} else {
		// cancel
		self.wasCanceled = YES;
	}
	[self.delegate weightLogEventEditViewControllerDidEnd:self];
}

- (IBAction)datePickerValueChanged:(id)sender
{
	self.tempDate = self.datePicker.date;
	[self.dateLabel setText:[_formatter stringForObjectValue:self.tempDate]];
}

- (IBAction)weightTextFieldValueChanged:(id)sender
{
	NSDecimalNumber *newWeight = [NSDecimalNumber decimalNumberWithString:self.weightTextField.text];
	if ([newWeight compare:[NSDecimalNumber notANumber]] == NSOrderedSame) {
		self.tempWeight = nil;
	} else {
		self.tempWeight = newWeight;
	}
	[self updateUI];
}

#pragma mark -
#pragma mark UI sync

- (void)updateUI
{
	// enable or disable the save button based on if we have a valid weight (assume all dates are valid)
	if (self.tempWeight && self.tempDate) {
		[self.saveButton setEnabled:YES];
	} else {
		[self.saveButton setEnabled:NO];
	}
}

- (void)moveDatePickerViewOffScreen
{
	// make tableView fill void
	CGRect origTableViewFrame = self.tableView.frame;
	CGFloat newTableViewHeight = origTableViewFrame.size.height + self.datePicker.frame.size.height;
	CGRect newTableViewFrame = origTableViewFrame;
	newTableViewFrame.size.height = newTableViewHeight;
	
	// move date picker offscreen on bottom
	CGRect newDatePickerFrame = self.datePicker.frame;
	newDatePickerFrame.origin.y = self.view.frame.size.height;
	
	[UIView beginAnimations:@"DatePickerViewOuttro" context:NULL];
	self.tableView.frame = newTableViewFrame;
	self.datePicker.frame = newDatePickerFrame;
	[UIView commitAnimations];
}

- (void)moveDatePickerViewOnScreen
{
	if (self.datePicker.frame.origin.y >= self.view.frame.size.height) {
		
		self.datePicker.date = self.tempDate;
		
		CGRect origTableViewFrame = self.tableView.frame;
		CGFloat newTableViewHeight = origTableViewFrame.size.height - self.datePicker.frame.size.height;
		CGRect newTableViewFrame = origTableViewFrame;
		newTableViewFrame.size.height = newTableViewHeight;
		
		CGRect newDatePickerFrame = self.datePicker.frame;
		newDatePickerFrame.origin.y = self.view.frame.size.height - newDatePickerFrame.size.height;
		
		[UIView beginAnimations:@"DatePickerViewIntro" context:NULL];
		self.tableView.frame = newTableViewFrame;
		self.datePicker.frame = newDatePickerFrame;
		[UIView commitAnimations];
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"Enter Date / Weight:";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
	if (indexPath.row == 0) {
		cell = self.dateCell;
	} else {
		cell = self.weightCell;
	}
	cell.backgroundColor = [UIColor colorWithRed:0.060 green:0.069 blue:0.079 alpha:1.000];
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 1) {
		[self moveDatePickerViewOffScreen];
		[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
		[self.weightTextField becomeFirstResponder];
		
		return nil;
	} else {
		return indexPath;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0) {
		[self.weightTextField resignFirstResponder];
		[self moveDatePickerViewOnScreen];
	} else {
		
	}
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
	UIView *containerView =	[[[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 35)] autorelease];
    //containerView.backgroundColor = [UIColor orangeColor];
	UILabel *headerLabel = [[[UILabel alloc] initWithFrame:CGRectMake(25, 10, 300, 20)] autorelease];
    headerLabel.text = [self tableView:aTableView titleForHeaderInSection:section];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.shadowColor = [UIColor blackColor];
    headerLabel.shadowOffset = CGSizeMake(0, 1);
    headerLabel.font = [UIFont boldSystemFontOfSize:18];
    headerLabel.backgroundColor = [UIColor clearColor];
    [containerView addSubview:headerLabel];
	return containerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 35;
}

#pragma mark -
#pragma mark TextField delegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[self moveDatePickerViewOffScreen];
	[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
	if ([[textField text] length] >= 4) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Weight" message:@"Please type in a weight under 999." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert autorelease];
		return NO;
	} else {
		return YES;
	}
}

@end
