#import <UIKit/UIKit.h>

@class RQBattleViewController;

@interface RQBattleVictoryViewController : UIViewController
{
	RQBattleViewController *battleViewController;
}

@property (readwrite, retain) RQBattleViewController *battleViewController;


@end
