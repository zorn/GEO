#import "StoryViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation StoryViewController

- (id)init
{
	if (self = [super initWithNibName:@"StoryView" bundle:nil]) {
		transitioning = NO;
		currentFrame = 1;
	}
	return self;
}

- (void)dealloc {
    [storyView1 release]; storyView1 = nil;
    [storyView2 release]; storyView2 = nil;
    [storyView3 release]; storyView3 = nil;
	
	
	[storyImageView1 release]; storyImageView1 = nil;
	[storyImageView2 release]; storyImageView2 = nil;
	[storyImageView3 release]; storyImageView3 = nil;

	[storyTextView1 release]; storyTextView1 = nil;
	[storyTextView2 release]; storyTextView2 = nil;
	[storyTextView3 release]; storyTextView3 = nil;

	[super dealloc];
}

@synthesize delegate;

@synthesize storyView1;
@synthesize storyView2;
@synthesize storyView3;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSLog(@"StoryViewController -viewDidLoad");
	
	UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
	[recognizer setNumberOfTapsRequired:1];
	[self.view addGestureRecognizer:recognizer];
	
	// settings for textViews;
	CGRect textViewFrame = CGRectMake(20, 480-20-130, 280, 130);
	UIColor *textViewBGColor = [UIColor colorWithWhite:0.000 alpha:0.650];
	UIColor *textViewTextColor = [UIColor whiteColor];
	
	UIImage *storyImage1 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"50321.jpg" ofType:nil]];
	storyImageView1 = [[UIImageView alloc] initWithImage:storyImage1];
	storyTextView1 = [[UITextView alloc] initWithFrame:CGRectZero];
	[self.view addSubview:storyImageView1];
	[self.view addSubview:storyTextView1];
	[storyTextView1 setEditable:NO];
	[storyTextView1 setTextColor:textViewTextColor];
	[storyTextView1 setBackgroundColor:textViewBGColor];
	[storyTextView1 setFrame:textViewFrame];
	[storyTextView1 setText:@"Then Kerrigan was like 'aww shit'..."];
	
	UIImage *storyImage2 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"51539.jpg" ofType:nil]];
	storyImageView2 = [[UIImageView alloc] initWithImage:storyImage2];
	storyImageView2.hidden = YES;
	storyTextView2 = [[UITextView alloc] initWithFrame:CGRectZero];
	storyTextView2.hidden = YES;
	[self.view addSubview:storyImageView2];
	[self.view addSubview:storyTextView2];
	[storyTextView2 setEditable:NO];
	[storyTextView2 setTextColor:textViewTextColor];
	[storyTextView2 setBackgroundColor:textViewBGColor];
	[storyTextView2 setFrame:textViewFrame];
	[storyTextView2 setText:@"Then Thrall was like 'no you didn't!!'..."];
	
	
	UIImage *storyImage3 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"53681.jpg" ofType:nil]];
	storyImageView3 = [[UIImageView alloc] initWithImage:storyImage3];
	storyImageView3.hidden = YES;
	storyTextView3 = [[UITextView alloc] initWithFrame:CGRectZero];
	storyTextView3.hidden = YES;
	[self.view addSubview:storyImageView3];
	[self.view addSubview:storyTextView3];
	[storyTextView3 setEditable:NO];
	[storyTextView3 setTextColor:textViewTextColor];
	[storyTextView3 setBackgroundColor:textViewBGColor];
	[storyTextView3 setFrame:textViewFrame];
	[storyTextView3 setText:@"Meanwhile at a spooky house..."];
	
	
//	[self.view addSubview:self.storyView1];
//	[self.view addSubview:self.storyView2]; self.storyView2.hidden = YES;
//	[self.view addSubview:self.storyView3]; self.storyView3.hidden = YES;
	
	[recognizer release]; recognizer = nil;
}

-(void)performImageViewTransition
{
	CATransition *transition = [CATransition animation];
	transition.duration = 0.75;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition.type = kCATransitionFade;
	transitioning = YES;
	transition.delegate = self;
	
	[self.view.layer addAnimation:transition forKey:nil];
	
	// Here we hide view1, and show view2, which will cause Core Animation to animate view1 away and view2 in.
	switch (currentFrame) {
		case 1:
			storyImageView1.hidden = YES;
			storyTextView1.hidden = YES;
			storyImageView2.hidden = NO;
			storyTextView2.hidden = NO;
			storyImageView3.hidden = YES;
			storyTextView3.hidden = YES;
			break;
		case 2:
			storyImageView1.hidden = YES;
			storyTextView1.hidden = YES;
			storyImageView2.hidden = YES;
			storyTextView2.hidden = YES;
			storyImageView3.hidden = NO;
			storyTextView3.hidden = NO;
			break;
	}
	
	currentFrame++;
}

-(void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	transitioning = NO;
}

-(IBAction)nextTransition:(id)sender
{
	if(!transitioning)
	{
		if (currentFrame >= 3) {
			[delegate storyViewControllerDidEnd:self];
		} else {
			[self performImageViewTransition];
		}
	}
}

- (void)tapRecognized:(UIGestureRecognizer *)recognizer
{
	[self nextTransition:self];
}

@end
