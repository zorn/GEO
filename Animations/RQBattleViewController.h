//
//  RQBattleTestViewController.h
//  FlickSample
//
//  Created by Nome on 9/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RQBattleVictoryViewController.h"
#import "ShieldDrawLineView.h"

@class RQBattle;
@class RQSprite;
@class RQEnemySprite;
@class RQWeaponSprite;
@class MapViewController;
@class RQPassthroughView;
@class AVCaptureSession;
@class AVCaptureVideoPreviewLayer;
@class ShieldDrawLineView;

#define RQBattleViewFlickThreshold 280.0

@protocol RQBattleViewControllerDelegate;
@protocol RQBattleVictoryViewControllerDelegate;

@interface RQBattleViewController : UIViewController <RQBattleVictoryViewControllerDelegate, ShieldDrawLineViewDelegate>
{
	RQBattleVictoryViewController *battleVictoryViewController;
	RQBattle *battle;
	
	RQEnemySprite *evilBoobsMonster;
	int monsterCounter;
	
	BOOL didPauseIPod;
	
	RQWeaponSprite *activeWeapon;
	UILabel *heroHeathLabel;
	UILabel *heroGlovePowerLabel;
	RQPassthroughView *frontFlashView;
	
	UIImageView *leftShield;
	UIImageView *rightShield;
	ShieldDrawLineView *shieldDrawLineView;
	
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
}

@property (readwrite, retain) RQBattleVictoryViewController *battleVictoryViewController;
@property (readwrite, assign) id <RQBattleViewControllerDelegate> delegate;
@property (readwrite, retain) RQBattle *battle;
@property (readwrite, retain) RQWeaponSprite *activeWeapon;
@property (nonatomic, retain) UIView *frontFlashView;
@property (nonatomic, retain) UIImageView *leftShield;
@property (nonatomic, retain) UIImageView *rightShield;
@property (nonatomic, retain) ShieldDrawLineView *shieldDrawLineView;

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


