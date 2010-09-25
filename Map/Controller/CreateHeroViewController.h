//
//  CreateHeroViewController.h
//  RunQuest
//
//  Created by Michael Zornek on 9/25/10.
//  Copyright 2010 Clickable Bliss. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CreateHeroViewControllerDelegate;

@interface CreateHeroViewController : UIViewController {
	UITextField *heroNameTextField;
}

@property (retain) IBOutlet UITextField *heroNameTextField;
@property (readwrite, assign) id <CreateHeroViewControllerDelegate> delegate;

- (IBAction)createHeroButtonPressed:(id)sender;

@end

@protocol CreateHeroViewControllerDelegate 
- (void)createHeroViewControllerDidEnd:(CreateHeroViewController *)controller;
@end