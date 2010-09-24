#import <UIKit/UIKit.h>

@protocol RQBattleVictoryViewControllerDelegate;

@interface RQBattleVictoryViewController : UIViewController
{
	
}

@property (readwrite, assign) id <RQBattleVictoryViewControllerDelegate> delegate;

@end

@protocol RQBattleVictoryViewControllerDelegate 

- (void)battleVictoryControllerDidEnd:(RQBattleVictoryViewController *)controller;

@end