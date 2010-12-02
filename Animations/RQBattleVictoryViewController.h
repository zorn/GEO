#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol RQBattleVictoryViewControllerDelegate;

@class RQBattle;
@class RQBarView;

@interface RQBattleVictoryViewController : UIViewController
{
	RQBattle *battle;
	
	NSTimer *xpCountTimer;
	
	NSInteger experienceGained;
	NSInteger experienceCountByAmount;
}

@property (nonatomic, retain) IBOutlet RQBarView *xpBarView;
@property (nonatomic, retain) IBOutlet UILabel *heroLevelLabel;
@property (nonatomic, retain) IBOutlet UILabel *heroXPFractionLabel;
@property (nonatomic, retain) IBOutlet UILabel *heroXPReceivedLabel;
@property (nonatomic, retain) IBOutlet UIView *moreInfoContainerView;
@property (nonatomic, retain) IBOutlet UIImageView *victoryText;
@property (nonatomic, retain) IBOutlet UITextView *mentorMessageTextView;
@property (nonatomic, retain) IBOutlet UIImageView *mentorAvatarImageView;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageView;
@property (readwrite, retain) RQBattle *battle;

@property (readwrite, assign) id <RQBattleVictoryViewControllerDelegate> delegate;

- (void)animateXPGains;
- (void)animateXPGainsJumpToLast:(BOOL)jumpToLastFrame;

@end










@protocol RQBattleVictoryViewControllerDelegate 
- (void)battleVictoryControllerDidEnd:(RQBattleVictoryViewController *)controller;
@end