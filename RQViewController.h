//
//  RQViewController.h
//  RunQuest
//
//  Created by Joe Walsh on 12/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RQViewControllerDelegate
- (void)viewControllerDidEnd:(UIViewController *)vc;
@end

@interface RQViewController : UIViewController {
	id <RQViewControllerDelegate> delegate;
}

@property (nonatomic, assign) id<RQViewControllerDelegate> delegate;

@end
