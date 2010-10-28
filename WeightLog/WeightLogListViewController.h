#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "WeightLogEventEditViewController.h"

@class NSFetchedResultsController;
@class WeightLogListCell;

@interface WeightLogListViewController : UIViewController <WeightLogEventEditViewControllerDelegate, NSFetchedResultsControllerDelegate>
{
	NSDateFormatter *_formatter;
	NSFetchedResultsController *fetchedResultsController;
	
	// outlets
	UITableView *tableView;
	UITableViewCell *cellTemplate;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

// outlets
@property (retain) IBOutlet UITableView *tableView;
@property (retain) IBOutlet UITableViewCell *cellTemplate;


- (void)configureCell:(WeightLogListCell*)cell atIndexPath:(NSIndexPath*)indexPath;


@end
