#import "TrekListViewController.h"
#import "TrekViewController.h"
#import <CoreData/CoreData.h>

// models
#import "RQModelController.h"
#import "Trek.h"

// views
#import "TrekListCell.h"
#import "TrekListHeaderCell.h"

@implementation TrekListViewController

#pragma mark -
#pragma mark Initialization

- (id)init
{
	if (self = [super initWithNibName:@"TrekListView" bundle:nil]) {
		
		self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Workouts" 
															  image:[UIImage imageNamed:@"workout_log_tab_icon.png"] 
																tag:0] autorelease];
		[[self navigationItem] setTitle:@"Workout Summary"];
		UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Summary" style:UIBarButtonItemStyleBordered target:nil action:nil];
		[[self navigationItem] setBackBarButtonItem:newBackButton];
	}
	return self;
}

- (void)dealloc 
{	
	[tableView release];
	
	[_formatter release];
	_formatter = nil;
	
	[weekGroups release];
    [super dealloc];
}

@synthesize tableView;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	[self.tableView setSeparatorColor:[UIColor colorWithRed:0.204 green:0.212 blue:0.222 alpha:1.000]]; 
	
	// YOU MUST DO THIS IN CODE, TRYING TO DO THIS IN IB VIA COLOR PICKER WILL RESULT IN BLACK CORNERS AROUND THE GROUPS
	self.tableView.backgroundColor = [UIColor clearColor];
	
	_formatter = [[NSDateFormatter alloc] init];
	[_formatter setDateStyle:NSDateFormatterShortStyle];
	[self buildWeeklyGroups];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)buildWeeklyGroups
{
	weekGroups = [[NSMutableArray alloc] init];
	Trek *oldestTrek = [[RQModelController defaultModelController] oldestTrek];
	Trek *newestTrek = [[RQModelController defaultModelController] newestTrek];
	
	if (!oldestTrek) {
		return; // bail
 	}
	
	// Get the components of it's date
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit;
	NSDateComponents *oldestTrekDateComponents = [[NSCalendar currentCalendar] components:unitFlags fromDate:[oldestTrek date]];
	
	// Generate the starting sunday based on components and the day of the week
	NSInteger trekWeekday = [oldestTrekDateComponents weekday]; // 1-7, 1 is Sunday
	NSDate *startingSunday = [[NSCalendar currentCalendar] dateFromComponents:oldestTrekDateComponents];
	startingSunday = [startingSunday dateByAddingTimeInterval:60*60*24*-1*(trekWeekday-1)];
	
	NSArray *list;
	BOOL moreWeeksToShow = YES;
	while (moreWeeksToShow) {
		list = [[RQModelController defaultModelController] allTreksFromWeekStartingOnSundayDate:startingSunday];
		[weekGroups addObject:[NSDictionary dictionaryWithObjectsAndKeys:list, @"list", startingSunday, @"date", nil]];
		NSLog(@"list %@ for date %@", list, startingSunday);
		
		// advance one week
		startingSunday = [startingSunday dateByAddingTimeInterval:60*60*24*7];
		
		// stop if this new startingSunday is greater than the newestTrek date
		if ([[newestTrek date] compare:startingSunday] == NSOrderedAscending) {
			moreWeeksToShow = NO;
		}
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [weekGroups count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSDate *sunday = [[weekGroups objectAtIndex:section] objectForKey:@"date"];
	return [NSString stringWithFormat:@"Week of %@", [_formatter stringForObjectValue:sunday]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[weekGroups objectAtIndex:section] objectForKey:@"list"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TrekListCell *cell = (TrekListCell *)[self.tableView dequeueReusableCellWithIdentifier:@"TrekListCell"];
    if (cell == nil) {
        UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"TrekListCell" bundle:nil];
        cell = (TrekListCell *)temporaryController.view;
		[temporaryController release];
    }
    
	[self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(TrekListCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
	cell.backgroundColor = [UIColor colorWithRed:0.060 green:0.069 blue:0.079 alpha:1.000];
	
	NSDictionary *group = [weekGroups objectAtIndex:indexPath.section];
	NSArray *list = [group objectForKey:@"list"];
	Trek *trek = [list objectAtIndex:indexPath.row];
	
	[cell.dateLabel setText:[_formatter stringForObjectValue:[trek date]]];
	 
	NSDateFormatter *timeLengthFormatterNoSeconds = [[RQModelController defaultModelController] timeLengthFormatterNoSeconds];
	[cell.timeLabel	setText:[timeLengthFormatterNoSeconds stringForObjectValue:[NSDate dateWithTimeIntervalSinceReferenceDate:trek.duration]]];
	
	NSNumberFormatter *distanceFormatter = [[RQModelController defaultModelController] distanceFormatter];
	NSString *distanceText = [NSString stringWithFormat:@"%@ mi", [distanceFormatter stringForObjectValue:[NSNumber numberWithDouble:[trek distanceInMiles]]]];
	[cell.distanceLabel	setText:distanceText];
	
	NSNumberFormatter *calorieFormatter = [[RQModelController defaultModelController] calorieFormatter];
	NSString *calBurnText = [NSString stringWithFormat:@"%@ cal", [calorieFormatter stringForObjectValue:[NSNumber numberWithDouble:[trek caloriesBurned]]]];
	[cell.calorieLabel setText:calBurnText];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// TODO: Impliment
	TrekViewController *trekViewController = [[TrekViewController alloc] initWithNibName:@"TrekView" bundle:nil];
	//trekViewController.trek = 
	[self.navigationController pushViewController:trekViewController animated:YES];
	[trekViewController release];
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
	
	//TrekListHeaderCell *cell = (TrekListHeaderCell *)[self.tableView dequeueReusableCellWithIdentifier:@"TrekListHeaderCell"];
//    if (cell == nil) {
//        UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"TrekListHeaderCell" bundle:nil];
//        cell = (TrekListHeaderCell *)temporaryController.view;
//        [temporaryController release];
//    }
//	[cell.headerText setText:[self tableView:aTableView titleForHeaderInSection:section]];
//	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	//TrekListHeaderCell *cell = (TrekListHeaderCell *)[self.tableView dequeueReusableCellWithIdentifier:@"TrekListHeaderCell"];
//    if (cell == nil) {
//        UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"TrekListHeaderCell" bundle:nil];
//        cell = (TrekListHeaderCell *)temporaryController.view;
//        [temporaryController release];
//    }
//	return cell.frame.size.height;
	return 35;
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//	return self.footerView;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//	return self.footerView.frame.size.height; 
//}

@end

