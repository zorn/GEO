//
//  RQBattleTestViewController.h
//  FlickSample
//
//  Created by Nome on 9/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RQBattleVictoryViewController.h"

@class RQBattle;
@class RQSprite;
@class RQEnemySprite;
@class RQWeaponSprite;
@class MapViewController;
@class RQPassthroughView;
@class AVCaptureSession;
@class AVCaptureVideoPreviewLayer;

#define RQBattleViewFlickThreshold 280.0

@protocol RQBattleViewControllerDelegate;
@protocol RQBattleVictoryViewControllerDelegate;

@interface RQBattleViewController : UIViewController <RQBattleVictoryViewControllerDelegate>
{
	RQBattleVictoryViewController *battleVictoryViewController;
	RQBattle *battle;
	
	RQEnemySprite *evilBoobsMonster;
	int monsterCounter;
	
	RQWeaponSprite *activeWeapon;
	UILabel *heroHeathLabel;
	RQPassthroughView *frontFlashView;
	
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
	
	//Camera stuff
#if TARGET_OS_EMBEDDED
	AVCaptureSession *_captureSession;
	AVCaptureVideoPreviewLayer *_captureLayer;
#endif
}

@property (readwrite, retain) RQBattleVictoryViewController *battleVictoryViewController;
@property (readwrite, assign) id <RQBattleViewControllerDelegate> delegate;
@property (readwrite, retain) RQBattle *battle;
@property (readwrite, retain) RQWeaponSprite *activeWeapon;
@property (nonatomic, retain) UIView *frontFlashView;

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


