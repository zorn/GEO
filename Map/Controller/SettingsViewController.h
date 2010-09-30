//
//  SettingViewController.h
//  RunQuest
//
//  Created by Michael Zornek on 9/29/10.
//  Copyright 2010 Clickable Bliss. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsViewControllerDelegate;

@interface SettingsViewController : UIViewController
{
	UISwitch *pauseIPodSwitch;
	UISlider *backgroundMusicVolumeSlider;
	UISlider *effectSoundVolumeSlider;
}

@property (readwrite, assign) id <SettingsViewControllerDelegate> delegate;

@property (retain) IBOutlet UISwitch *pauseIPodSwitch;
@property (retain) IBOutlet UISlider *backgroundMusicVolumeSlider;
@property (retain) IBOutlet UISlider *effectSoundVolumeSlider;


- (IBAction)doneButtonAction:(id)sender;

@end

@protocol SettingsViewControllerDelegate 
- (void)settingsViewControllerDidEnd:(SettingsViewController *)controller;
@end