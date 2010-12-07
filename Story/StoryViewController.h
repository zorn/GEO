#import <UIKit/UIKit.h>

@protocol StoryViewControllerDelegate;

@interface StoryViewController : UIViewController
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
}

@property (readwrite, assign) id <StoryViewControllerDelegate> delegate;
@property (nonatomic, assign) CGRect textViewFrame;
@property (nonatomic, retain) UIColor *textViewBGColor;
@property (nonatomic, retain) UIColor *textViewTextColor;
@property (nonatomic, retain) UIFont *textViewFont;


-(void)performImageViewTransition;

@end


@protocol StoryViewControllerDelegate 
- (void)storyViewControllerDidEnd:(StoryViewController *)controller;
@end