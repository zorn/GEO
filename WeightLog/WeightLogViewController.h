#import <UIKit/UIKit.h>
#import "WeightLogEventEditViewController.h"

@interface WeightLogViewController : UIViewController <WeightLogEventEditViewControllerDelegate>
{

}

- (IBAction)enterTodaysWeight:(id)sender;
- (IBAction)editPreviousWeightins:(id)sender;

@end
