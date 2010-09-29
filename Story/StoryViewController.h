#import <UIKit/UIKit.h>

@protocol StoryViewControllerDelegate;

@interface StoryViewController : UIViewController
{
	UIView *storyView1;
	UIView *storyView2;
	UIView *storyView3;
	
	
	
	UIImageView *storyImageView1;
	UIImageView *storyImageView2;
	UIImageView *storyImageView3;
	
	UITextView *storyTextView1;
	UITextView *storyTextView2;
	UITextView *storyTextView3;
	
	NSInteger currentFrame;
	
	BOOL transitioning;
}

@property (readwrite, assign) id <StoryViewControllerDelegate> delegate;

@property (retain) IBOutlet UIView *storyView1;
@property (retain) IBOutlet UIView *storyView2;
@property (retain) IBOutlet UIView *storyView3;

-(void)performImageViewTransition;


@end


@protocol StoryViewControllerDelegate 
- (void)storyViewControllerDidEnd:(StoryViewController *)controller;
@end