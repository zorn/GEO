#import <UIKit/UIKit.h>

#import "RQBattleViewController.h"

@protocol StoryViewControllerDelegate;

@interface StoryViewController : UIViewController <RQBattleViewControllerDelegate>
{
	UIImageView *currentStoryImageView;
	UITextView *currentStoryTextView;
	
	CGRect textViewFrame;
	UIColor *textViewBGColor;
	UIColor *textViewTextColor;
	UIFont *textViewFont;
	
	NSInteger currentFrame;
	
	BOOL transitioning;
	
	NSMutableArray *introStory;
	NSMutableArray *finalBattleStory;
	NSString *storyToShow;
}

@property (readwrite, assign) id <StoryViewControllerDelegate> delegate;
@property (nonatomic, assign) CGRect textViewFrame;
@property (nonatomic, retain) UIColor *textViewBGColor;
@property (nonatomic, retain) UIColor *textViewTextColor;
@property (nonatomic, retain) UIFont *textViewFont;
@property (nonatomic, copy) NSString *storyToShow;

- (void)loadFirstStoryFrame;
-(void)performImageViewTransition;

@end


@protocol StoryViewControllerDelegate 
- (void)storyViewControllerDidEnd:(StoryViewController *)controller;
@end