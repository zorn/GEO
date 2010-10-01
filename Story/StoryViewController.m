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
	
	
	[storyImageView1 release]; storyImageView1 = nil;
	[storyImageView2 release]; storyImageView2 = nil;
	[storyImageView3 release]; storyImageView3 = nil;
	[storyImageView3b release]; storyImageView3b = nil;
	[storyImageView3c release]; storyImageView3c = nil;
	[storyImageView4 release]; storyImageView4 = nil;
	[storyImageView5 release]; storyImageView5 = nil;
	[storyImageView6 release]; storyImageView6 = nil;

	[storyTextView1 release]; storyTextView1 = nil;
	[storyTextView2 release]; storyTextView2 = nil;
	[storyTextView3 release]; storyTextView3 = nil;
	[storyTextView3b release]; storyTextView3b = nil;
	[storyTextView3c release]; storyTextView3c = nil;
	[storyTextView4 release]; storyTextView4 = nil;
	[storyTextView5 release]; storyTextView5 = nil;
	[storyTextView6 release]; storyTextView6 = nil;

	[super dealloc];
}

@synthesize delegate;

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
	
	UIImage *storyImage1 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Panel1.png" ofType:nil]];
	storyImageView1 = [[UIImageView alloc] initWithImage:storyImage1];
	storyTextView1 = [[UITextView alloc] initWithFrame:CGRectZero];
	[self.view addSubview:storyImageView1];
	[self.view addSubview:storyTextView1];
	[storyTextView1 setEditable:NO];
	[storyTextView1 setTextColor:textViewTextColor];
	[storyTextView1 setBackgroundColor:textViewBGColor];
	[storyTextView1 setFrame:textViewFrame];
	[storyTextView1 setText:@"Panel1"];
	
	UIImage *storyImage2 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Panel2.png" ofType:nil]];
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
	[storyTextView2 setText:@"Panel2"];
	
	
	UIImage *storyImage3 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Panel3.png" ofType:nil]];
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
	[storyTextView3 setText:@"Panel3"];
	
	UIImage *storyImage3b = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Panel3b.png" ofType:nil]];
	storyImageView3b = [[UIImageView alloc] initWithImage:storyImage3b];
	storyImageView3b.hidden = YES;
	storyTextView3b = [[UITextView alloc] initWithFrame:CGRectZero];
	storyTextView3b.hidden = YES;
	[self.view addSubview:storyImageView3b];
	[self.view addSubview:storyTextView3b];
	[storyTextView3b setEditable:NO];
	[storyTextView3b setTextColor:textViewTextColor];
	[storyTextView3b setBackgroundColor:textViewBGColor];
	[storyTextView3b setFrame:textViewFrame];
	[storyTextView3b setText:@"Panel3b"];
	
	UIImage *storyImage3c = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Panel3c.png" ofType:nil]];
	storyImageView3c = [[UIImageView alloc] initWithImage:storyImage3c];
	storyImageView3c.hidden = YES;
	storyTextView3c = [[UITextView alloc] initWithFrame:CGRectZero];
	storyTextView3c.hidden = YES;
	[self.view addSubview:storyImageView3c];
	[self.view addSubview:storyTextView3c];
	[storyTextView3c setEditable:NO];
	[storyTextView3c setTextColor:textViewTextColor];
	[storyTextView3c setBackgroundColor:textViewBGColor];
	[storyTextView3c setFrame:textViewFrame];
	[storyTextView3c setText:@"Panel3c"];
	
	UIImage *storyImage4 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Panel4.png" ofType:nil]];
	storyImageView4 = [[UIImageView alloc] initWithImage:storyImage4];
	storyImageView4.hidden = YES;
	storyTextView4 = [[UITextView alloc] initWithFrame:CGRectZero];
	storyTextView4.hidden = YES;
	[self.view addSubview:storyImageView4];
	[self.view addSubview:storyTextView4];
	[storyTextView4 setEditable:NO];
	[storyTextView4 setTextColor:textViewTextColor];
	[storyTextView4 setBackgroundColor:textViewBGColor];
	[storyTextView4 setFrame:textViewFrame];
	[storyTextView4 setText:@"Panel4"];
	
	UIImage *storyImage5 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Panel5.png" ofType:nil]];
	storyImageView5 = [[UIImageView alloc] initWithImage:storyImage5];
	storyImageView5.hidden = YES;
	storyTextView5 = [[UITextView alloc] initWithFrame:CGRectZero];
	storyTextView5.hidden = YES;
	[self.view addSubview:storyImageView5];
	[self.view addSubview:storyTextView5];
	[storyTextView5 setEditable:NO];
	[storyTextView5 setTextColor:textViewTextColor];
	[storyTextView5 setBackgroundColor:textViewBGColor];
	[storyTextView5 setFrame:textViewFrame];
	[storyTextView5 setText:@"Panel5"];
	
	UIImage *storyImage6 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Panel6.png" ofType:nil]];
	storyImageView6 = [[UIImageView alloc] initWithImage:storyImage6];
	storyImageView6.hidden = YES;
	storyTextView6 = [[UITextView alloc] initWithFrame:CGRectZero];
	storyTextView6.hidden = YES;
	[self.view addSubview:storyImageView6];
	[self.view addSubview:storyTextView6];
	[storyTextView6 setEditable:NO];
	[storyTextView6 setTextColor:textViewTextColor];
	[storyTextView6 setBackgroundColor:textViewBGColor];
	[storyTextView6 setFrame:textViewFrame];
	[storyTextView6 setText:@"Panel6"];
	
	
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
	storyImageView1.hidden = YES;
	storyTextView1.hidden = YES;
	storyImageView2.hidden = YES;
	storyTextView2.hidden = YES;
	storyImageView3.hidden = YES;
	storyTextView3.hidden = YES;
	storyImageView3b.hidden = YES;
	storyTextView3b.hidden = YES;
	storyImageView3c.hidden = YES;
	storyTextView3c.hidden = YES;
	storyImageView4.hidden = YES;
	storyTextView4.hidden = YES;
	storyImageView5.hidden = YES;
	storyTextView5.hidden = YES;
	storyImageView6.hidden = YES;
	storyTextView6.hidden = YES;
	switch (currentFrame) {
		case 1:
			storyImageView2.hidden = NO;
			storyTextView2.hidden = NO;
			break;
		case 2:
			storyImageView3.hidden = NO;
			storyTextView3.hidden = NO;
			break;
		case 3:
			storyImageView3b.hidden = NO;
			storyTextView3b.hidden = NO;
			break;
		case 4:
			storyImageView3c.hidden = NO;
			storyTextView3c.hidden = NO;
			break;
		case 5:
			storyImageView4.hidden = NO;
			storyTextView4.hidden = NO;
			break;
		case 6:
			storyImageView5.hidden = NO;
			storyTextView5.hidden = NO;
			break;
		case 7:
			storyImageView6.hidden = NO;
			storyTextView6.hidden = NO;
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
		if (currentFrame >= 8) {
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
