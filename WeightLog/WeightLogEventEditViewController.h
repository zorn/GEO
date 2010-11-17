#import <UIKit/UIKit.h>

@protocol WeightLogEventEditViewControllerDelegate;

@class RQWeightLogEntry;

@interface WeightLogEventEditViewController : UIViewController
{
	NSDateFormatter *_formatter;
	
	NSDate *tempDate;
	NSDecimalNumber *tempWeight;
	RQWeightLogEntry *weightLogEntry;
	BOOL editMode; // YES for when we are passed in an exsisting object to edit, NO for when we are to create a new object on save.
	BOOL wasCanceled;
	
	// outlets
	UIBarButtonItem *saveButton;
	UITableView *tableView;
	UITableViewCell *dateCell;
	UITableViewCell *weightCell;
	UILabel *dateLabel;
	UITextField *weightTextField;
	UIDatePicker *datePicker;
}

// ivars
@property (readwrite, assign) id <WeightLogEventEditViewControllerDelegate> delegate;
@property (readwrite, retain) NSDate *tempDate;
@property (readwrite, retain) NSDecimalNumber *tempWeight;
@property (readwrite, retain) RQWeightLogEntry *weightLogEntry;
@property (readwrite, assign) BOOL editMode;
@property (readwrite, assign) BOOL wasCanceled;

// outlets
@property (retain) IBOutlet UIBarButtonItem *saveButton;
@property (retain) IBOutlet UITableView *tableView;
@property (retain) IBOutlet UITableViewCell *dateCell;
@property (retain) IBOutlet UITableViewCell *weightCell;
@property (retain) IBOutlet UILabel *dateLabel;
@property (retain) IBOutlet UITextField *weightTextField;
@property (retain) IBOutlet UIDatePicker *datePicker;

#pragma mark -
#pragma mark Actions

- (IBAction)saveOrCancelButtonPressed:(id)sender;
- (IBAction)datePickerValueChanged:(id)sender;
- (IBAction)weightTextFieldValueChanged:(id)sender;

#pragma mark -
#pragma mark UI sync

- (void)updateUI;
- (void)moveDatePickerViewOffScreen;
- (void)moveDatePickerViewOnScreen;

@end

// Delegate Protocal
@protocol WeightLogEventEditViewControllerDelegate 
- (void)weightLogEventEditViewControllerDidEnd:(WeightLogEventEditViewController *)controller;
@end