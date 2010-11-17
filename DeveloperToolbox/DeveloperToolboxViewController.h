//
//  DeveloperToolboxViewController.h
//  RunQuest
//
//  Created by Michael Zornek on 10/15/10.
//  Copyright 2010 Clickable Bliss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoryViewController.h"

@protocol DeveloperToolboxViewControllerDelegate;

@interface DeveloperToolboxViewController : UIViewController <StoryViewControllerDelegate>
{
	UISwitch *mapBattleDemoOverride;
}

@property (readwrite, assign) id <DeveloperToolboxViewControllerDelegate> delegate;

@property (retain) IBOutlet UISwitch *mapBattleDemoOverride;


- (IBAction)loadCorePlotDemoOne:(id)sender;
- (IBAction)watchStory:(id)sender;
- (IBAction)editHero:(id)sender;

- (IBAction)mapBattleDemoModeValueChanged:(id)sender;


@end

@protocol DeveloperToolboxViewControllerDelegate
- (void)developerToolboxViewControllerDidEnd:(DeveloperToolboxViewController *)controller;
@end