#import <UIKit/UIKit.h>

@protocol StoryViewControllerDelegate;

@interface StoryViewController : UIViewController
{
	UIImageView *storyImageView1;
	UIImageView *storyImageView2;
	UIImageView *storyImageView3;
	UIImageView *storyImageView3b;
	UIImageView *storyImageView3c;
	UIImageView *storyImageView4;
	UIImageView *storyImageView5;
	UIImageView *storyImageView6;
	
	UITextView *storyTextView1;
	UITextView *storyTextView2;
	UITextView *storyTextView3;
	UITextView *storyTextView3b;
	UITextView *storyTextView3c;
	UITextView *storyTextView4;
	UITextView *storyTextView5;
	UITextView *storyTextView6;
	
	NSInteger currentFrame;
	
	BOOL transitioning;
}

@property (readwrite, assign) id <StoryViewControllerDelegate> delegate;

-(void)performImageViewTransition;

@end


@protocol StoryViewControllerDelegate 
- (void)storyViewControllerDidEnd:(StoryViewController *)controller;
@end