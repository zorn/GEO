//
//  WeightLogListCell.h
//  RunQuest
//
//  Created by Michael Zornek on 10/26/10.
//  Copyright 2010 Clickable Bliss. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WeightLogListCell : UITableViewCell {
	UILabel *weightLabel;
	UILabel *weightLostLabel;
	UILabel *dateLabel;
}
@property (retain) IBOutlet UILabel *weightLabel;
@property (retain) IBOutlet UILabel *weightLostLabel;
@property (retain) IBOutlet UILabel *dateLabel;

@end
