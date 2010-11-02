//
//  HeroEditViewController.h
//  RunQuest
//
//  Created by Michael Zornek on 11/1/10.
//  Copyright 2010 Clickable Bliss. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HeroEditViewController : UIViewController
{
	// outlets
	UILabel *heroCurrentLevelLabel;
	UISlider *heroLevelSlider;
}

@property (retain) IBOutlet UILabel *heroCurrentLevelLabel;
@property (retain) IBOutlet UISlider *heroLevelSlider;

#pragma mark -
#pragma mark Actions

- (IBAction)heroLevelSliderValueChanged:(id)sender;

@end
