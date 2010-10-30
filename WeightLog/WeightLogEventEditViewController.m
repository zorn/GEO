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
	
	[super dealloc];
}

@synthesize delegate;
@synthesize tempDate;
@synthesize tempWeight;
@synthesize weightLogEntry;
@synthesize editMode;

@synthesize saveButton;
@synthesize tableView;
@synthesize dateCell;
@synthesize weightCell;
@synthesize dateLabel;;
@synthesize weightTextField;
@synthesize datePicker;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{ 
	[super viewDidLoad];
	
	[self moveDatePickerViewOffScreen];
	
	_formatter = [[NSDateFormatter alloc] init];
	[_formatter setDateStyle:NSDateFormatterShortStyle];
	
	if (self.editMode) {
		self.tempDate = self.weightLogEntry.dateTaken;
		self.tempWeight = self.weightLogEntry.weightTaken;
	} else {
		self.tempDate = [NSDate date];
	}
	
	[self.dateLabel setText:[_formatter stringForObjectValue:self.tempDate]];
	if (self.tempWeight) [self.weightTextField setText:[NSString stringWithFormat:@"%@", self.tempWeight]];
	
	[self.weightTextField becomeFirstResponder];
	[self updateUI];
}

#pragma mark -
#pragma mark Actions

- (IBAction)saveOrCancelButtonPressed:(id)sender
{
	[self.weightTextField resignFirstResponder];
	if ([sender tag] == 1) {
		// save
		if (self.editMode) {
			[self.weightLogEntry setDateTaken:self.tempDate];
			[self.weightLogEntry setWeightTaken:self.tempWeight];
		} else {
			RQWeightLogEntry *newEntry = [[RQModelController defaultModelController] newWeightLogEntry];
			[newEntry setDateTaken:self.tempDate];
			[newEntry setWeightTaken:self.tempWeight];
		}
		[[RQModelController defaultModelController] save];
	} else {
		// cancel
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

@end
