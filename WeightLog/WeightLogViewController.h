#import <UIKit/UIKit.h>
#import "WeightLogEventEditViewController.h"
#import "CorePlot-CocoaTouch.h"

@interface WeightLogViewController : UIViewController <WeightLogEventEditViewControllerDelegate, CPPlotDataSource>
{
	CPXYGraph *graph;
	
	// outlets
	UILabel *weightLostToDateLabel;
	UIButton *newWeightButton;
	UIButton *listViewButton;
	CPLayerHostingView *graphDisplayView;
}

// outlets
@property (retain) IBOutlet UILabel *weightLostToDateLabel;
@property (retain) IBOutlet UIButton *newWeightButton;
@property (retain) IBOutlet UIButton *listViewButton;
@property (retain) IBOutlet CPLayerHostingView *graphDisplayView;

- (IBAction)enterTodaysWeight:(id)sender;
- (IBAction)editPreviousWeightins:(id)sender;

@end
