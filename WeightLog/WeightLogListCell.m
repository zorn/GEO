//
//  WeightLogListCell.m
//  RunQuest
//
//  Created by Michael Zornek on 10/26/10.
//  Copyright 2010 Clickable Bliss. All rights reserved.
//

#import "WeightLogListCell.h"


@implementation WeightLogListCell

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
    [weightLabel release]; weightLabel = nil;
    [weightLostLabel release]; weightLostLabel = nil;
    [dateLabel release]; dateLabel = nil;
	[super dealloc];
}

@synthesize weightLabel;
@synthesize weightLostLabel;
@synthesize dateLabel;

@end
