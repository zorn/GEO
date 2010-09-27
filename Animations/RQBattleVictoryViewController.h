#import <UIKit/UIKit.h>

@protocol RQBattleVictoryViewControllerDelegate;

@class RQBattle;

@interface RQBattleVictoryViewController : UIViewController
{
	UILabel *victoryTitle;
	UILabel *battleXPLabel;
	UILabel *battleXPCountLabel;
	UILabel *heroXPLabel;
	UILabel *heroXPCountLabel;
	UILabel *newLevelBannerLabel;
	UILabel *newLevelMessageLabel;
	RQBattle *battle;
	
	NSTimer *xpCountTimer;
	
	NSInteger experienceGained;
}

@property (retain) IBOutlet UILabel *victoryTitle;
@property (retain) IBOutlet UILabel *battleXPLabel;
@property (retain) IBOutlet UILabel *battleXPCountLabel;
@property (retain) IBOutlet UILabel *heroXPLabel;
@property (retain) IBOutlet UILabel *heroXPCountLabel;
@property (retain) IBOutlet UILabel *newLevelBannerLabel;
@property (retain) IBOutlet UILabel *newLevelMessageLabel;
@property (readwrite, retain) RQBattle *battle;

@property (readwrite, assign) id <RQBattleVictoryViewControllerDelegate> delegate;

- (void)animateXPGains;
- (void)animateXPGainsJumpToLast:(BOOL)jumpToLastFrame;

@end










@protocol RQBattleVictoryViewControllerDelegate 
- (void)battleVictoryControllerDidEnd:(RQBattleVictoryViewController *)controller;
@end