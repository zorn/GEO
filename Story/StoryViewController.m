#import "StoryViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SimpleAudioEngine.h"

@implementation StoryViewController

- (id)init
{
	if (self = [super initWithNibName:@"StoryView" bundle:nil]) {
		self.wantsFullScreenLayout = YES;
		transitioning = NO;
		currentFrame = 0;
	}
	return self;
}

- (void)dealloc
{	
	[introStory release];
	[textViewBGColor release];
	[textViewTextColor release];
	[textViewFont release];
	
	[super dealloc];
}

@synthesize delegate;
@synthesize textViewFrame;
@synthesize textViewBGColor;
@synthesize textViewTextColor;
@synthesize textViewFont;

#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	[super viewWillAppear:animated];
	
	[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"storyboard_song.m4a" loop:YES];
}

- (void)viewDidLoad
{
	NSLog(@"StoryViewController -viewDidLoad");
	[super viewDidLoad];
	
	// Create array to store the story frames and text
	introStory = [[NSMutableArray alloc] init];
	NSMutableDictionary *newStoryFrame;
	
	newStoryFrame = [[NSMutableDictionary alloc] init];
	[newStoryFrame setObject:@"Panel1.png" forKey:@"imageName"];
	[newStoryFrame setObject:@"Just another day after work, watching television…\n\nWe interrupt your daily boring TV routine for this IMPORTANT announcement!" forKey:@"storyText"];
	[introStory addObject:newStoryFrame];
	[newStoryFrame release]; newStoryFrame = nil;
	
	newStoryFrame = [[NSMutableDictionary alloc] init];
	[newStoryFrame setObject:@"Panel2.png" forKey:@"imageName"];
	[newStoryFrame setObject:@"This is just in! Strange portals are popping up everywhere around the globe! Massive swarms of unusual creatures are coming out and attacking people on site. Where do they come from? Why are they here?" forKey:@"storyText"];
	[introStory addObject:newStoryFrame];
	[newStoryFrame release]; newStoryFrame = nil;
	
	newStoryFrame = [[NSMutableDictionary alloc] init];
	[newStoryFrame setObject:@"Panel3.png" forKey:@"imageName"];
	[newStoryFrame setObject:@"Wait! Who let that creature in?! What do you want!? Stop! NO! Not my mustache~! NOOooooo~!!" forKey:@"storyText"];
	[introStory addObject:newStoryFrame];
	[newStoryFrame release]; newStoryFrame = nil;
	
	newStoryFrame = [[NSMutableDictionary alloc] init];
	[newStoryFrame setObject:@"Panel3b.png" forKey:@"imageName"];
	[newStoryFrame setObject:@"BZZZZZZZZZ" forKey:@"storyText"];
	[introStory addObject:newStoryFrame];
	[newStoryFrame release]; newStoryFrame = nil;
	
	newStoryFrame = [[NSMutableDictionary alloc] init];
	[newStoryFrame setObject:@"Panel3c.png" forKey:@"imageName"];
	[newStoryFrame setObject:@"YOU! You have the power to stop this! The world needs your strength!" forKey:@"storyText"];
	[introStory addObject:newStoryFrame];
	[newStoryFrame release]; newStoryFrame = nil;
	
	newStoryFrame = [[NSMutableDictionary alloc] init];
	[newStoryFrame setObject:@"Panel4.png" forKey:@"imageName"];
	[newStoryFrame setObject:@"You come from the same world as those creatures. There your ancestors were known as Rangers, special warriors with the power to control the elements. You are the last of this bloodline and so it falls to you to defend the world." forKey:@"storyText"];
	[introStory addObject:newStoryFrame];
	[newStoryFrame release]; newStoryFrame = nil;
	
	newStoryFrame = [[NSMutableDictionary alloc] init];
	[newStoryFrame setObject:@"Panel5.png" forKey:@"imageName"];
	[newStoryFrame setObject:@"To help I’m teleporting you this special glove called the Guardian. It was the weapon of choice for the Rangers. It will help you battle your foes and over time grow more powerful. Be warned however, with this power monsters will be drawn to you." forKey:@"storyText"];
	[introStory addObject:newStoryFrame];
	[newStoryFrame release]; newStoryFrame = nil;
	
	newStoryFrame = [[NSMutableDictionary alloc] init];
	[newStoryFrame setObject:@"Panel6.png" forKey:@"imageName"];
	[newStoryFrame setObject:@"My name is Dr. Gordon. I will be your guide on this journey to defend the world! What are you waiting for?! Get off that couch and MOVE!" forKey:@"storyText"];
	[introStory addObject:newStoryFrame];
	[newStoryFrame release]; newStoryFrame = nil;
	
	// add tap to view to progress story
	UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
	[recognizer setNumberOfTapsRequired:1];
	[self.view addGestureRecognizer:recognizer];
	[recognizer release]; recognizer = nil;
	
	// settings for textViews;
	self.textViewFrame = CGRectMake(20, 480-20-130, 280, 130);
	self.textViewBGColor = [UIColor colorWithWhite:0.000 alpha:0.650];
	self.textViewTextColor = [UIColor whiteColor];
	self.textViewFont = [UIFont fontWithName:@"Helvetica" size:13.0];
	
	// add the first story frame to the view
	NSMutableDictionary *firstStoryFrame = [introStory objectAtIndex:0];
	
	UIImage *storyImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[firstStoryFrame objectForKey:@"imageName"] ofType:nil]];
	currentStoryImageView = [[UIImageView alloc] initWithImage:storyImage];
	currentStoryTextView = [[UITextView alloc] initWithFrame:CGRectZero];
	[self.view addSubview:currentStoryImageView];
	[self.view addSubview:currentStoryTextView];
	[currentStoryImageView release];
	[currentStoryTextView release];
	[currentStoryTextView setEditable:NO];
	[currentStoryTextView setFont:self.textViewFont];
	[currentStoryTextView setTextColor:self.textViewTextColor];
	[currentStoryTextView setBackgroundColor:self.textViewBGColor];
	[currentStoryTextView setFrame:self.textViewFrame];
	[currentStoryTextView setText:[firstStoryFrame objectForKey:@"storyText"]];
	
}

-(void)performImageViewTransition
{
	// add the next story frame to the view
	NSMutableDictionary *nextStoryFrame = [introStory objectAtIndex:currentFrame+1];
	
	UIImage *storyImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[nextStoryFrame objectForKey:@"imageName"] ofType:nil]];
	UIImageView *nextImageView = [[UIImageView alloc] initWithImage:storyImage];
	UITextView *nextTextView = [[UITextView alloc] initWithFrame:CGRectZero];
	[self.view addSubview:nextImageView];
	[self.view addSubview:nextTextView];
	[nextImageView release];
	[nextTextView release];
	[nextTextView setEditable:NO];
	[nextTextView setFont:self.textViewFont];
	[nextTextView setTextColor:self.textViewTextColor];
	[nextTextView setBackgroundColor:self.textViewBGColor];
	[nextTextView setFrame:self.textViewFrame];
	[nextTextView setText:[nextStoryFrame objectForKey:@"storyText"]];
	nextImageView.hidden = YES;
	nextTextView.hidden = YES;
	
	CATransition *transition = [CATransition animation];
	transition.duration = 0.75;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition.type = kCATransitionFade;
	transitioning = YES;
	transition.delegate = self;
	
	[self.view.layer addAnimation:transition forKey:nil];
	
	// Here we hide view1, and show view2, which will cause Core Animation to animate view1 away and view2 in.
	currentStoryImageView.hidden = YES;
	currentStoryTextView.hidden = YES;
	nextImageView.hidden = NO;
	nextTextView.hidden = NO;
	
	currentFrame++;
	
	currentStoryImageView = nextImageView;
	currentStoryTextView = nextTextView;
}

-(void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	transitioning = NO;
}

-(IBAction)nextTransition:(id)sender
{
	if(!transitioning)
	{
		if (currentFrame >= [introStory count] - 1) {
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
