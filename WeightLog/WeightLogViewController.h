#import <UIKit/UIKit.h>
#import "WeightLogEventEditViewController.h"

@interface WeightLogViewController : UIViewController <WeightLogEventEditViewControllerDelegate>
{
	// outlets
	UILabel *weightLostToDateLabel;
	UIButton *listViewButton;
}

// outlets
@property (retain) IBOutlet UILabel *weightLostToDateLabel;
@property (retain) IBOutlet UIButton *listViewButton;

- (IBAction)enterTodaysWeight:(id)sender;
- (IBAction)editPreviousWeightins:(id)sender;

@end
