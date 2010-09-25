//
//  MainMenuViewController.h
//  RunQuest
//
//  Created by Michael Zornek on 9/24/10.
//  Copyright 2010 Clickable Bliss. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MainMenuViewControllerDelegate;

@interface MainMenuViewController : UIViewController {

}

@property (readwrite, assign) id <MainMenuViewControllerDelegate> delegate;


- (IBAction)playButtonPressed:(id)sender;
- (IBAction)optionsButtonPressed:(id)sender;

@end


@protocol MainMenuViewControllerDelegate 
- (void)mainMenuViewControllerPlayButtonPressed:(MainMenuViewController *)controller;
@end