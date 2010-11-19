#import <UIKit/UIKit.h>

@class TrekListCell;

@interface TrekListViewController : UITableViewController {
	NSDateFormatter *_formatter;
	NSMutableArray *weekGroups;
	
}

- (void)buildWeeklyGroups;
- (void)configureCell:(TrekListCell*)cell atIndexPath:(NSIndexPath*)indexPath;

@end
