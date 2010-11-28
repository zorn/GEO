#import "WeightLogViewController.h"
#import "WeightLogListViewController.h"

// models
#import "RQModelController.h"
#import "RQWeightLogEntry.h"

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
	[newWeightButton release]; newWeightButton = nil;
	[listViewButton release]; listViewButton = nil;
	[graphDisplayView release]; graphDisplayView = nil;
	
	[super dealloc];
}

@synthesize weightLostToDateLabel;
@synthesize newWeightButton;
@synthesize listViewButton;
@synthesize graphDisplayView;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	graph = [[CPXYGraph alloc] initWithFrame:self.graphDisplayView.bounds];	
	// TODO: Move all of our own themeing into a class file
	//CPTheme *theme = [CPTheme themeNamed:kCPStocksTheme];
	//[graph applyTheme:theme];
	
	// theme stuff
	graph.fill = [CPFill fillWithColor:[CPColor clearColor]];
	
	CPLayerHostingView *hostingView = self.graphDisplayView;
	hostingView.hostedLayer = graph;
	graph.paddingLeft = 0.0;
	graph.paddingTop = 0.0;
	graph.paddingRight = 0.0;
	graph.paddingBottom = 0.0;

	// BLUE APPLE LOOK
//	CPGradient *stocksBackgroundGradient = [[[CPGradient alloc] init] autorelease];
//    stocksBackgroundGradient = [stocksBackgroundGradient addColorStop:[CPColor colorWithComponentRed:0.21569 green:0.28627 blue:0.44706 alpha:1.0] atPosition:0.0];
//	stocksBackgroundGradient = [stocksBackgroundGradient addColorStop:[CPColor colorWithComponentRed:0.09412 green:0.17255 blue:0.36078 alpha:1.0] atPosition:0.5];
//	stocksBackgroundGradient = [stocksBackgroundGradient addColorStop:[CPColor colorWithComponentRed:0.05882 green:0.13333 blue:0.33333 alpha:1.0] atPosition:0.5];
//	stocksBackgroundGradient = [stocksBackgroundGradient addColorStop:[CPColor colorWithComponentRed:0.05882 green:0.13333 blue:0.33333 alpha:1.0] atPosition:1.0];
//    stocksBackgroundGradient.angle = 270.0;
//	graph.plotAreaFrame.fill = [CPFill fillWithGradient:stocksBackgroundGradient];
	
	// gray
	CPGradient *stocksBackgroundGradient = [[[CPGradient alloc] init] autorelease];
    stocksBackgroundGradient = [stocksBackgroundGradient addColorStop:[CPColor colorWithComponentRed:0.166 green:0.166 blue:0.164 alpha:1.000] atPosition:0.0];
	stocksBackgroundGradient = [stocksBackgroundGradient addColorStop:[CPColor colorWithComponentRed:0.105 green:0.105 blue:0.105 alpha:1.000] atPosition:0.5];
	stocksBackgroundGradient = [stocksBackgroundGradient addColorStop:[CPColor colorWithComponentRed:0.0 green:0.0 blue:0.0 alpha:1.000] atPosition:0.5];
	stocksBackgroundGradient = [stocksBackgroundGradient addColorStop:[CPColor colorWithComponentRed:0.0 green:0.0 blue:0.0 alpha:1.000] atPosition:1.0];
    stocksBackgroundGradient.angle = 270.0;
	graph.plotAreaFrame.fill = [CPFill fillWithGradient:stocksBackgroundGradient];
	
	
	CPLineStyle *borderLineStyle = [CPLineStyle lineStyle];
	borderLineStyle.lineColor = [CPColor colorWithGenericGray:0.2];
	borderLineStyle.lineWidth = 0.0;
	
	graph.plotAreaFrame.borderLineStyle = borderLineStyle;
	graph.plotAreaFrame.cornerRadius = 14.0;
	
	
	// style buttons
	[[self.newWeightButton layer] setCornerRadius:8.0f];
	[[self.newWeightButton layer] setMasksToBounds:YES];
	[[self.newWeightButton layer] setBorderWidth:1.0f];
	[[self.newWeightButton layer] setBackgroundColor:[[UIColor colorWithRed:0.060 green:0.069 blue:0.079 alpha:1.000] CGColor]];
	[[self.newWeightButton layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
	[self.newWeightButton setTitleColor:[UIColor colorWithRed:0.629 green:0.799 blue:1.000 alpha:1.000] forState:UIControlStateNormal];
	
	[[self.listViewButton layer] setCornerRadius:8.0f];
	[[self.listViewButton layer] setMasksToBounds:YES];
	[[self.listViewButton layer] setBorderWidth:1.0f];
	[[self.listViewButton layer] setBackgroundColor:[[UIColor colorWithRed:0.060 green:0.069 blue:0.079 alpha:1.000] CGColor]];
	[[self.listViewButton layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
	[self.listViewButton setTitleColor:[UIColor colorWithRed:0.629 green:0.799 blue:1.000 alpha:1.000] forState:UIControlStateNormal];
}

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
	
	// update graph
	NSDecimalNumber *maxWeight = [[RQModelController defaultModelController] maxWeightLogged];
	if (!maxWeight) maxWeight = [NSDecimalNumber zero]; 
	NSDecimalNumber *minWeight = [[RQModelController defaultModelController] minWeightLogged];
	if (!minWeight) minWeight = [NSDecimalNumber zero];
	
	NSLog(@"max %@ min %@", maxWeight, minWeight);
	
	NSArray *entries = [[RQModelController defaultModelController] weightLogEntries];
	
	NSDecimalNumber *graphMin = [minWeight decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithString:@"10"]];
	NSDecimalNumber *graphLength = [[maxWeight decimalNumberBySubtracting:minWeight] decimalNumberByAdding:[NSDecimalNumber decimalNumberWithString:@"20"]];
	
	float paddingForYLabels = ((20*entries.count)/60);
	if (paddingForYLabels < 1) paddingForYLabels = 1.0; 
	
	
	CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
	if (entries.count > 0) {
		plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-paddingForYLabels) 
													   length:CPDecimalFromInteger([entries count]+paddingForYLabels)];
		plotSpace.yRange = [CPPlotRange plotRangeWithLocation:[graphMin decimalValue] 
													   length:[graphLength decimalValue]];
	} else {
		paddingForYLabels = 1.0;
		plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-paddingForYLabels) 
													   length:CPDecimalFromInteger(2+paddingForYLabels)];
		plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(150) 
													   length:CPDecimalFromFloat(50)];
	}
	
	
	CPScatterPlot *dataSourceLinePlot = [[[CPScatterPlot alloc] initWithFrame:graph.bounds] autorelease];
	dataSourceLinePlot.identifier = @"Weight";
	dataSourceLinePlot.dataLineStyle.lineWidth = 3.0f;
	dataSourceLinePlot.dataLineStyle.lineColor = [CPColor whiteColor];
	dataSourceLinePlot.dataSource = self;
	[graph addPlot:dataSourceLinePlot];
	
	CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
	
	CPLineStyle *ThreePXWhitelineStyle = [CPLineStyle lineStyle];
	ThreePXWhitelineStyle.lineColor = [CPColor whiteColor];
	ThreePXWhitelineStyle.lineWidth = 3.0f;
	
	CPLineStyle *OnePXWhitelineStyle = [CPLineStyle lineStyle];
	OnePXWhitelineStyle.lineColor = [CPColor whiteColor];
	OnePXWhitelineStyle.lineWidth = 1.0f;
	
	CPTextStyle *whiteTextStyle = [[[CPTextStyle alloc] init] autorelease];
	whiteTextStyle.color = [CPColor whiteColor];
	whiteTextStyle.fontSize = 14.0;
	
	//	axisSet.xAxis.majorIntervalLength = [[NSDecimalNumber decimalNumberWithString:@"5"] decimalValue];
	//	axisSet.xAxis.minorTicksPerInterval = 4;
	//	axisSet.xAxis.majorTickLineStyle = lineStyle;
	//	axisSet.xAxis.minorTickLineStyle = lineStyle;
	axisSet.xAxis.axisLineStyle = ThreePXWhitelineStyle;
	//	axisSet.xAxis.minorTickLength = 5.0f;
	//	axisSet.xAxis.majorTickLength = 7.0f;
	//axisSet.xAxis.labelExclusionRanges = [NSArray arrayWithObject:[CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-10000) 
	//																						  length:CPDecimalFromFloat(20000)]];
	
	axisSet.yAxis.majorIntervalLength = [[NSDecimalNumber decimalNumberWithString:@"10"] decimalValue];
	axisSet.yAxis.minorTicksPerInterval = 9;
	axisSet.yAxis.majorTickLineStyle = OnePXWhitelineStyle;
	axisSet.yAxis.minorTickLineStyle = OnePXWhitelineStyle;
	axisSet.yAxis.axisLineStyle = ThreePXWhitelineStyle;
	axisSet.yAxis.minorTickLength = 5.0f;
	axisSet.yAxis.majorTickLength = 7.0f;
	axisSet.yAxis.labelTextStyle = whiteTextStyle;

	//axisSet.yAxis.labelExclusionRanges = [NSArray arrayWithObject:[CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-10000) 
	//																						  length:CPDecimalFromFloat(20000)]];
	[graph reloadData];
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

#pragma mark -
#pragma mark Core Plot methods

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot; 
{
	//NSLog(@"numberOfRecordsForPlot: %@", plot);
	NSArray *entries = [[RQModelController defaultModelController] weightLogEntriesSortedByDate];
	//NSLog(@"returning %i", [entries count]);
	return [entries count];
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index;
{
	//NSLog(@"numberForPlot:%@ field:%i recordIndex:%i called...", plot, fieldEnum, index);
	switch (fieldEnum)
	{
		case CPScatterPlotFieldX: 
		{
			return [NSDecimalNumber numberWithInteger:index];
		}
		case CPScatterPlotFieldY:
		{
			NSArray *entries = [[RQModelController defaultModelController] weightLogEntriesSortedByDate];
			return [(RQWeightLogEntry *)[entries objectAtIndex:index] weightTaken];
		}
	}
	return nil;
}

@end
