//
//  SettingViewController.h
//  RunQuest
//
//  Created by Michael Zornek on 9/29/10.
//  Copyright 2010 Clickable Bliss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@protocol SettingsViewControllerDelegate;

@interface SettingsViewController : UIViewController <MFMailComposeViewControllerDelegate>
{
	UITableView *tableView;
	UISwitch *pauseIPodSwitch;
	UISlider *backgroundMusicVolumeSlider;
	UISlider *effectSoundVolumeSlider;
	
	UITableViewCell *iPodSettingTableViewCell;
	UITableViewCell *musicSettingTableViewCell;
	UITableViewCell *effectSoundSettingTableViewCell;
	
	UISegmentedControl *distanceSegmentControl;
	UITableViewCell *distanceTableViewCell;
}

@property (readwrite, assign) id <SettingsViewControllerDelegate> delegate;

@property (retain) IBOutlet UITableView *tableView;
@property (retain) IBOutlet UISwitch *pauseIPodSwitch;
@property (retain) IBOutlet UISlider *backgroundMusicVolumeSlider;
@property (retain) IBOutlet UISlider *effectSoundVolumeSlider;

@property (retain) IBOutlet UITableViewCell *iPodSettingTableViewCell;
@property (retain) IBOutlet UITableViewCell *musicSettingTableViewCell;
@property (retain) IBOutlet UITableViewCell *effectSoundSettingTableViewCell;
@property (retain) IBOutlet UITableViewCell *emailFeedbackCell;

@property (retain) IBOutlet UISegmentedControl *distanceSegmentControl;
@property (retain) IBOutlet UITableViewCell *distanceTableViewCell;

- (IBAction)doneButtonAction:(id)sender;
- (IBAction)updateDefautsBasedOnUI;
- (IBAction)playSampleSoundEffect;
- (IBAction)showContactUsMail:(id)sender;

@end

@protocol SettingsViewControllerDelegate 
- (void)settingsViewControllerDidEnd:(SettingsViewController *)controller;
@end