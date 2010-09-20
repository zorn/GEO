//
//  RQBattleTestViewController.h
//  FlickSample
//
//  Created by Nome on 9/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RQBattle;
@class RQSprite;
@class RQEnemySprite;
@class MapViewController;

@interface RQBattleTestViewController : UIViewController 
{
	MapViewController *mapViewController;
	RQBattle *battle;
	
	RQEnemySprite *evilBoobsMonster;
	int monsterCounter;
	
	RQSprite *magicPebble;
	
	NSTimeInterval previousTickTime;
	
	BOOL isTouching;
	NSTimeInterval previousTouchTimestamp;
	
	NSTimeInterval lastCollisionTime;
	
	// below stolen from OpenGL project template for game loop
    BOOL animating;
    BOOL displayLinkSupported;
    NSInteger animationFrameInterval;
    id displayLink;
    NSTimer *animationTimer;
	
}

@property (readwrite, retain) MapViewController *mapViewController;
@property (readwrite, retain) RQBattle *battle;

- (void)tick;
- (void)setupGameLoop;
- (void)startAnimation;
- (void)stopAnimation;

@end

