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

@protocol MainMenuViewControllerDelegate;

@class MainMenuViewController;
@class StoryViewController;
@class MapViewController;

@interface AppDelegate_iPhone : AppDelegate_Shared <MainMenuViewControllerDelegate, StoryViewControllerDelegate> {
	
}

@property (nonatomic, retain) MapViewController *mapViewController;
@property (nonatomic, retain) StoryViewController *storyViewController;
@property (nonatomic, retain) UIViewController *currentViewController;
@property (nonatomic, retain, readonly) MainMenuViewController *mainMenuViewController;

- (IBAction)doneBrowsingTreks:(id)sender;
- (void)setCurrentViewController:(UIViewController *)to animated:(BOOL)animate;

@end

