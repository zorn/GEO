#import <UIKit/UIKit.h>

@interface TrekListCell : UITableViewCell {
	UILabel *dateLabel;
	UILabel *distanceLabel;
	UILabel *timeLabel;
	UILabel *calorieLabel;
}

@property (retain) IBOutlet UILabel *dateLabel;
@property (retain) IBOutlet UILabel *distanceLabel;
@property (retain) IBOutlet UILabel *timeLabel;
@property (retain) IBOutlet UILabel *calorieLabel;

@end
