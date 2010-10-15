#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface CorePlotTestViewController : UIViewController <CPPlotDataSource>
{
	CPXYGraph *graph;
	
	// outlets
	CPLayerHostingView *graphDisplayView;
}

@property (retain) IBOutlet CPLayerHostingView *graphDisplayView;


@end