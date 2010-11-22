#import <UIKit/UIKit.h>

@class TrekListCell;

@interface TrekListViewController : UIViewController {
	NSDateFormatter *_formatter;
	NSMutableArray *weekGroups;
	
	UITableView *tableView;
	
}

- (void)buildWeeklyGroups;
- (void)configureCell:(TrekListCell*)cell atIndexPath:(NSIndexPath*)indexPath;

// outlets
@property (retain) IBOutlet UITableView *tableView;

@end
