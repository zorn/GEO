//
//  TrekListCell.m
//  RunQuest
//
//  Created by Michael Zornek on 11/18/10.
//  Copyright 2010 Clickable Bliss. All rights reserved.
//

#import "TrekListCell.h"


@implementation TrekListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[dateLabel release]; dateLabel = nil;
	[distanceLabel release]; distanceLabel = nil;
	[timeLabel release]; timeLabel = nil;
	[calorieLabel release]; calorieLabel = nil;
	[super dealloc];
}

@synthesize dateLabel;
@synthesize distanceLabel;
@synthesize timeLabel;
@synthesize calorieLabel;


@end
