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

@protocol MainMenuViewControllerDelegate;

@class MainMenuViewController;
@class MapViewController;

@interface AppDelegate_iPhone : AppDelegate_Shared <MainMenuViewControllerDelegate> {
	
}

@property (nonatomic, retain) MapViewController *mapViewController;
@property (nonatomic, retain) UIViewController *currentViewController;
@property (nonatomic, retain, readonly) MainMenuViewController *mainMenuViewController;

- (IBAction)doneBrowsingTreks:(id)sender;
- (void)setCurrentViewController:(UIViewController *)to animated:(BOOL)animate;

@end

