//
//  MainMenuViewController.h
//  RunQuest
//
//  Created by Michael Zornek on 9/24/10.
//  Copyright 2010 Clickable Bliss. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MainMenuViewControllerDelegate;

@interface MainMenuViewController : UIViewController
{
	
}

@property (readwrite, assign) id <MainMenuViewControllerDelegate> delegate;


- (IBAction)playButtonPressed:(id)sender;
- (IBAction)optionsButtonPressed:(id)sender;

@end


@protocol MainMenuViewControllerDelegate 
- (void)presentStory:(MainMenuViewController *)controller;
- (void)mainMenuViewControllerPlayButtonPressed:(MainMenuViewController *)controller;
- (void)mainMenuViewControllerTreksButtonPressed:(MainMenuViewController *)controller;
- (void)mainMenuViewControllerOptionsButtonPressed:(MainMenuViewController *)controller;
@end