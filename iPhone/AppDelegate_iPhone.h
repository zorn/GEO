//
//  AppDelegate_iPhone.h
//  RunQuest
//
//  Created by Joe Walsh on 9/11/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate_Shared.h"
#import "MainMenuViewController.h"
#import "StoryViewController.h"
#import "SettingsViewController.h"
#import "MapViewController.h"
#import "DeveloperToolboxViewController.h"

@protocol MainMenuViewControllerDelegate;


@class MainMenuViewController;
@class StoryViewController;
@class SettingsViewController;
@class MapViewController;

@interface AppDelegate_iPhone : AppDelegate_Shared <MainMenuViewControllerDelegate, MapViewControllerDelegate, StoryViewControllerDelegate, SettingsViewControllerDelegate, DeveloperToolboxViewControllerDelegate> {
	
}
@property (nonatomic, retain) UINavigationController *developerToolboxNavigationController;
@property (nonatomic, retain) MapViewController *mapViewController;
@property (nonatomic, retain) StoryViewController *storyViewController;
@property (nonatomic, retain) SettingsViewController *settingsViewController;
@property (nonatomic, retain) UIViewController *currentViewController;
@property (nonatomic, retain, readonly) MainMenuViewController *mainMenuViewController;

- (IBAction)doneBrowsingTreks:(id)sender;
- (void)setCurrentViewController:(UIViewController *)to animated:(BOOL)animate;
- (void)updateAudioSystemVolumeSettings;

@end

