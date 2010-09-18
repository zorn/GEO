//
//  RQBattleTestViewController.m
//  FlickSample
//
//  Created by Nome on 9/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RQBattleTestViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "RQSprite.h"
#import "RQEnemySprite.h"


@implementation RQBattleTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
	
	UIView *pebbleView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 40.0, 40.0)];
	pebbleView.backgroundColor = [UIColor redColor];
	magicPebble = [[RQSprite alloc] initWithView:pebbleView];
	[pebbleView release];
	
	[self.view addSubview:magicPebble.view];

	magicPebble.position = CGPointMake(160.0, 420.0);
	magicPebble.velocity = CGPointZero;
	
	
	UIImageView *monsterView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"boobs.png"]];
    monsterView.frame = CGRectMake(1.350, 8.5, 106.0, 80.0);
	evilBoobsMonster = [[RQEnemySprite alloc] initWithView:monsterView];
	[monsterView release];

	[self.view addSubview:evilBoobsMonster.view];
	
	evilBoobsMonster.position = CGPointMake(160.0, 100.0);
	evilBoobsMonster.velocity = CGPointZero;
	
	monsterCounter = 0;
	lastCollisionTime = 0.0;
	
	
	[self setupGameLoop];
	[self startAnimation];
	
}


- (void)tick {
	
	NSTimeInterval currentTime = CACurrentMediaTime();
	NSTimeInterval deltaTime = currentTime - previousTickTime;
	previousTickTime = currentTime;
	
	
	
	CGFloat newMonsterX = 160.0 + (80.0 * sin((float)monsterCounter / 30.0));
	CGFloat newMonsterY = 100.0 + (30.0 * sin((float)monsterCounter / 15.0));
	
	evilBoobsMonster.position = CGPointMake(newMonsterX, newMonsterY);
	
	monsterCounter++;	
	
	
	
	if (!isTouching) {
		
		magicPebble.position = CGPointMake(magicPebble.position.x + (magicPebble.velocity.x * deltaTime),
										   magicPebble.position.y + (magicPebble.velocity.y * deltaTime));
		
	}
	
	BOOL monsterHit = [evilBoobsMonster isIntersectingRect:magicPebble.view.frame];
	
	if (monsterHit) {
		
		lastCollisionTime = currentTime;
		srand(time(0));
		int num = rand() % 255;
		[evilBoobsMonster hitWithText:[NSString stringWithFormat:@"%d", num]];
//		hitLabel.hidden = NO;
	}
	
	if (currentTime > lastCollisionTime + 1.0) {
		
//		if (!hitLabel.hidden)
//			hitLabel.hidden = YES;

	}
	
	
	if ((!CGRectContainsPoint(self.view.frame, magicPebble.position)) || monsterHit) {
		
		magicPebble.position = CGPointMake(160.0, 420.0);
		magicPebble.velocity = CGPointZero;
		
	}
	
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	UITouch *touch = [touches anyObject];
	CGPoint touchLocation = [touch locationInView:self.view];
	
	if (CGRectContainsPoint(magicPebble.view.frame, touchLocation)) {
		isTouching = YES;
		previousTouchTimestamp = touch.timestamp;
	}
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

	UITouch *touch = [touches anyObject];
	CGPoint touchLocation = [touch locationInView:self.view];
	CGPoint previousTouchLocation = [touch previousLocationInView:self.view];
	
	if (isTouching) {

		magicPebble.position = touchLocation;
		
		NSTimeInterval deltaTime = touch.timestamp - previousTouchTimestamp;

		CGFloat deltaX = touchLocation.x - previousTouchLocation.x;
		CGFloat deltaY = touchLocation.y - previousTouchLocation.y;
		
		deltaX /= deltaTime;
		deltaY /= deltaTime;
		
		CGPoint newVelocity = CGPointMake(deltaX, deltaY);
		
		
		magicPebble.velocity = CGPointMake(magicPebble.velocity.x * 0.9 + newVelocity.x * 0.1,
										   magicPebble.velocity.y * 0.9 + newVelocity.y * 0.1);
		
		previousTouchTimestamp = touch.timestamp;

	}
	
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
//	UITouch *touch = [touches anyObject];
//	CGPoint touchLocation = [touch locationInView:self.view];
	
	isTouching = NO;
	
}


- (void)dealloc {
	[self stopAnimation];
	[magicPebble release];
	[evilBoobsMonster release];
    [super dealloc];
}


/************************************************************
 * Code below stolen from the built-in OpenGL project template to run the game loop
 ************************************************************/

- (void)setupGameLoop {
	
	
    animating = FALSE;
    displayLinkSupported = FALSE;
    animationFrameInterval = 1;
    displayLink = nil;
    animationTimer = nil;
    
    // Use of CADisplayLink requires iOS version 3.1 or greater.
	// The NSTimer object is used as fallback when it isn't available.
    NSString *reqSysVer = @"3.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
        displayLinkSupported = TRUE;
}	

- (void)startAnimation {
    if (!animating) {
        if (displayLinkSupported) {
            /*
			 CADisplayLink is API new in iOS 3.1. Compiling against earlier versions will result in a warning, but can be dismissed if the system version runtime check for CADisplayLink exists in -awakeFromNib. The runtime check ensures this code will not be called in system versions earlier than 3.1.
			 */
            displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(tick)];
            [displayLink setFrameInterval:animationFrameInterval];
            
            // The run loop will retain the display link on add.
            [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
        else
            animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(tick) userInfo:nil repeats:TRUE];
        
        animating = TRUE;
    }
}

- (void)stopAnimation {
    if (animating) {
        if (displayLinkSupported) {
            [displayLink invalidate];
            displayLink = nil;
        } else {
            [animationTimer invalidate];
            animationTimer = nil;
        }
        
        animating = FALSE;
    }
}




@end
