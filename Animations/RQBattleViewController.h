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
@class RQWeaponSprite;
@class MapViewController;
@class RQBattleVictoryViewController;
@class AVCaptureSession;
@class RQAudioPlayer;

@protocol RQBattleViewControllerDelegate;

@interface RQBattleViewController : UIViewController 
{
	RQBattleVictoryViewController *battleVictoryViewController;
	MapViewController *mapViewController;
	RQBattle *battle;
	
	RQEnemySprite *evilBoobsMonster;
	int monsterCounter;
	
	RQWeaponSprite *activeWeapon;
	UILabel *heroHeathLabel;
	
	NSMutableArray *weaponSprites;
	
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

	// Audio stuff
	RQAudioPlayer *audioPlayer;
	
	//Camera stuff
#if TARGET_OS_EMBEDDED
	AVCaptureSession *_captureSession;
#endif
}

@property (readwrite, retain) RQBattleVictoryViewController *battleVictoryViewController;
@property (readwrite, assign) id <RQBattleViewControllerDelegate> delegate;
@property (readwrite, retain) RQBattle *battle;
@property (readwrite, retain) RQWeaponSprite *activeWeapon;

- (void)tick;
- (void)setupGameLoop;
- (void)startAnimation;
- (void)stopAnimation;

- (IBAction)runButtonPressed:(id)sender;
- (void)presentVictoryScreen;
- (void)dismissVictoryScreen;
- (void)returnToMapView;

@end

@protocol RQBattleViewControllerDelegate 

- (void)battleViewControllerDidEnd:(RQBattleViewController *)controller;

@end


