//
//  RQBattleTestViewController.m
//  FlickSample
//
//  Created by Nome on 9/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RQBattleViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "RQSprite.h"
#import "RQEnemySprite.h"
#import "RQBattle.h"
#import "RQMob.h"
#import "RQHero.h"
#import "RQEnemy.h"
#import "RQWeaponSprite.h"
#import "RQBattleVictoryViewController.h"
#import "SimpleAudioEngine.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "RQModelController.h"
#import "M3CoreDataManager.h"
#import "RQPassthroughView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AppDelegate_iPhone.h"
#import "RQEnemyWeaponView.h"
#import "RQBarView.h"

// view
#import "ShieldDrawLineView.h"


@interface RQBattleViewController ()
@property (nonatomic, assign) BOOL enemyShotFired;
@property (nonatomic, retain) RQEnemyWeaponView *enemyShotView;
@end


@implementation RQBattleViewController
@synthesize enemyShotFired;
@synthesize enemyShotView;

- (id)init
{
	if (self = [super initWithNibName:@"BattleView" bundle:nil]) {
		weaponSprites = [[NSMutableArray alloc] init];
		battle = [[RQBattle alloc] init];
	}
	return self;
}

- (void)dealloc
{
	NSLog(@"RQBattleViewController -dealloc called...");
	[self stopAnimation];
	[shieldDrawLineView release]; shieldDrawLineView = nil;
	[backgroundImageView release], backgroundImageView = nil;
	[shieldLightning release], shieldLightning = nil;
	[rightShield release], rightShield = nil;
	[leftShield release], leftShield = nil;
	[frontFlashView release], frontFlashView = nil;
	[heroGlovePowerBar release];
	[weaponSprites release]; weaponSprites = nil;
	[battleVictoryViewController release]; battleVictoryViewController = nil;
	[battle release]; battle = nil;
	[evilBoobsMonster release];
    [enemyShotView release];
    [super dealloc];
}
@synthesize delegate;
@synthesize battleVictoryViewController;
@synthesize battle;
@synthesize activeWeapon;
@synthesize frontFlashView;
@synthesize leftShield;
@synthesize rightShield;
@synthesize shieldLightning;
@synthesize backgroundImageView;
@synthesize shieldDrawLineView;

- (void)viewDidLoad {
    [super viewDidLoad];

	self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
	
	// create background image view
	UIImage *backgroundImage = [UIImage imageNamed:@"cloud_backdrop.png"];
	UIImageView *temp = [[UIImageView alloc] initWithImage:backgroundImage];
	self.backgroundImageView = temp;
	[temp release];
	[self.view addSubview:self.backgroundImageView];
	
	// create weapon shelf image view
	UIImage *weaponShelfImage = [UIImage imageNamed:@"weapon_shelf.png"];
	UIImageView *weaponShelfImageView = [[UIImageView alloc] initWithImage:weaponShelfImage];
	[self.view addSubview:weaponShelfImageView];
	CGRect newFrame = weaponShelfImageView.frame;
	newFrame.origin.y = self.view.frame.size.height - weaponShelfImageView.frame.size.height;
	newFrame.origin.x = (self.view.frame.size.width - weaponShelfImageView.frame.size.width)/2;
	weaponShelfImageView.frame = newFrame;
	
	// Setup hp meter
	heroGlovePowerBar = [[RQBarView alloc] initWithFrame:CGRectMake(8.0, 25.0, 10.0, 245.0)];
	heroGlovePowerBar.barColor = [UIColor colorWithRed:0.080 green:0.583 blue:1.0 alpha:0.7];
	[self.view addSubview:heroGlovePowerBar];
	
	UIImageView *gloveImageLabel = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"glove_label"]];
	CGRect gloveImageLabelFrame = gloveImageLabel.frame;
	gloveImageLabelFrame.origin.y = 275.0;
	gloveImageLabel.frame = gloveImageLabelFrame;
	[self.view addSubview:gloveImageLabel];
	[gloveImageLabel release];
	
	// Setup glove power meter
	heroHealthBar = [[RQBarView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 18.0, 25.0, 10.0, 245.0)];
	heroHealthBar.barColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.7];
	[self.view addSubview:heroHealthBar];
	
	UIImageView *hpImageLabel = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hp_label"]];
	CGRect hpImageLabelFrame = hpImageLabel.frame;
	hpImageLabelFrame.origin.y = 275.0;
	hpImageLabelFrame.origin.x = (self.view.frame.size.width - hpImageLabelFrame.size.width) + 2.0;
	hpImageLabel.frame = hpImageLabelFrame;
	[self.view addSubview:hpImageLabel];
	[hpImageLabel release];
	
	// Setup the flick threshold visual
	//UIView *flickThresholdLine = [[UIView alloc] initWithFrame:CGRectMake(0, RQBattleViewFlickThreshold, self.view.frame.size.width, 2.0)];
//	[self.view addSubview:flickThresholdLine];
//	flickThresholdLine.backgroundColor = [UIColor yellowColor];
	
	// setup weaponSprite Array
	RQWeaponSprite *weaponSprite;
	NSString *weaponImageName;
	RQElementalType weaponType;
	UIImageView *weaponImageView;
	
	float spacerWidth = 320 / (self.battle.hero.weapons.count+1);
	NSLog(@"spacerWidth: %f", spacerWidth);
	int weaponPlace = 0;
	float xloc = 0;
	for (NSDictionary *weapon in self.battle.hero.weapons) {
		
		weaponType = RQElementalTypeNone;
		
		NSLog(@"building weapon: %@", weapon);
		switch ([[weapon objectForKey:@"type"] integerValue]) {
			case RQElementalTypeFire:
				weaponImageName = @"fire_weapon";
				weaponType = RQElementalTypeFire;
				break;
			case RQElementalTypeWater:
				weaponImageName = @"water_weapon";
				weaponType = RQElementalTypeWater;
				break;
			case RQElementalTypeEarth:
				weaponImageName = @"earth_weapon";
				weaponType = RQElementalTypeEarth;
				break;
			case RQElementalTypeAir:
				weaponImageName = @"air_weapon";
				weaponType = RQElementalTypeAir;
				break;
		}
		
		weaponImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:weaponImageName]];
		weaponSprite = [[RQWeaponSprite alloc] initWithView:weaponImageView];
		[weaponImageView release];
		[weaponSprite setWeaponDetails:weapon];
		[weaponSprite setType:weaponType];
		[weaponSprites addObject:weaponSprite];
		[self.view addSubview:weaponSprite.view];

		xloc = xloc + spacerWidth;

		NSLog(@"xloc: %f", xloc);
		weaponSprite.position = CGPointMake(xloc, self.view.frame.size.height - 40);
		weaponSprite.orininalPosition = weaponSprite.position;
		
		weaponSprite.velocity = CGPointZero;

		weaponPlace++;
		
		[weaponSprite release]; weaponSprite = nil;
	}
	
	if (self.battle.hero.canUseShields) {
		// make two shield sprites
		UIImage *shieldImageLeft = [UIImage imageNamed:@"shield_orb_left.png"];
		UIImage *shieldImageRight = [UIImage imageNamed:@"shield_orb_right.png"];
		leftShield = [[UIImageView alloc] initWithImage:shieldImageLeft];
		CGRect newLeftFrame = leftShield.frame;
		newLeftFrame.origin.x = 0 - 12; // 12 is defined via the design of the image
		newLeftFrame.origin.y = self.view.frame.size.height - 160;
		[self.view addSubview:leftShield];
		[leftShield setFrame:newLeftFrame];
		
		rightShield = [[UIImageView alloc] initWithImage:shieldImageRight];
		CGRect newRightFrame = leftShield.frame;
		newRightFrame.origin.x = self.view.frame.size.width - newRightFrame.size.width + 12;  // 12 is defined via the design of the image
		newRightFrame.origin.y = self.view.frame.size.height - 160;
		[self.view addSubview:rightShield];
		[rightShield setFrame:newRightFrame];
		
		UIImage *firstLightningImage = [UIImage imageNamed:@"shield_lightning1.png"];
		NSArray *shieldImages = [[NSArray alloc] initWithObjects:firstLightningImage, 
								 [UIImage imageNamed:@"shield_lightning2.png"], 
								 [UIImage imageNamed:@"shield_lightning3.png"], 
								 [UIImage imageNamed:@"shield_lightning4.png"], 
								 nil];
		shieldLightning = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 
																		0.0, 
																		firstLightningImage.size.width, 
																		firstLightningImage.size.height)];
		shieldLightning.animationImages = shieldImages;
		shieldLightning.animationDuration = 0.25;
		shieldLightning.animationRepeatCount = 0;
		[shieldLightning startAnimating];
		
		CGRect newShieldLightningFrame = shieldLightning.frame;
		newShieldLightningFrame.origin.x = newLeftFrame.size.width - 12 - 15;
		newShieldLightningFrame.origin.y = self.view.frame.size.height - 160 - newLeftFrame.size.height/2 + 10;
		[self.view addSubview:shieldLightning];
		[shieldLightning setFrame:newShieldLightningFrame];
		
		shieldDrawLineView = [[ShieldDrawLineView alloc] initWithFrame:self.view.frame];
		[shieldDrawLineView setBackgroundColor:[UIColor clearColor]];
		[shieldDrawLineView setDelegate:self];
		[self.view addSubview:shieldDrawLineView];
	}
	
	UIImage *monsterImage = [UIImage imageNamed:self.battle.enemy.spriteImageName];
	
	UIImageView *monsterView = [[UIImageView alloc] initWithImage:monsterImage];
	//NSLog(@"w %f h %f s %f", monsterImage.size.width, monsterImage.size.height, monsterImage.scale);
    monsterView.frame = CGRectMake(1.350, 8.5, monsterImage.size.width, monsterImage.size.height);
	evilBoobsMonster = [[RQEnemySprite alloc] initWithView:monsterView];
	[monsterView release];

	[self.view addSubview:evilBoobsMonster.view];
	
	evilBoobsMonster.position = CGPointMake(160.0, 100.0);
	evilBoobsMonster.velocity = CGPointZero;
	
	monsterCounter = 0;
	lastCollisionTime = 0.0;
	
	// Setup the self hit visual
	self.frontFlashView = [[[RQPassthroughView alloc] initWithFrame:self.view.frame] autorelease];
	CGRect ffFrame = self.frontFlashView.frame;
	ffFrame.origin.x = 0.0;
	ffFrame.origin.y = 0.0;
	self.frontFlashView.frame = ffFrame;
	frontFlashView.alpha = 0.0;
	frontFlashView.backgroundColor = [UIColor redColor];
	[self.view addSubview:frontFlashView];
	
	[self setupGameLoop];
	[self startAnimation];
	
	// If the user would like us to mute the iPod during battles to hear our own sweet music and the iPod is in fact playing
#if !(TARGET_IPHONE_SIMULATOR)
	didPauseIPod = NO;
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"RQSoundMuteIPod"] boolValue] && [[MPMusicPlayerController iPodMusicPlayer] playbackState] == MPMusicPlaybackStatePlaying ) {
		NSLog(@"pauseing iPod");
		[[MPMusicPlayerController iPodMusicPlayer] pause];
		[[CDAudioManager sharedManager] setMode:kAMM_FxPlusMusic];
		didPauseIPod = YES;
	}
#endif

    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"RQ_Battle_Song.m4a" loop:YES];
	
	// Setup the run button
	UIButton *runButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[runButton setTitle:@"Run" forState:UIControlStateNormal];
	[runButton addTarget:self action:@selector(runButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:runButton];
	[runButton setFrame:CGRectMake(self.view.frame.size.width-44.0, 0.0, 44.0, 44.0)];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}


- (void)tick
{	
	NSTimeInterval currentTime = CACurrentMediaTime();
	NSTimeInterval deltaTime = currentTime - previousTickTime;
	previousTickTime = currentTime;
	
	//NSLog(@"tick, battle status hero %@ and enemy %@", self.battle.hero, self.battle.enemy);

	
	// game sim stuff
	[self.battle updateCombatantStaminaBasedOnTimeDelta:deltaTime];
	
	
	// update the shield line for major incriments
	if (self.shieldDrawLineView.shieldPower - self.battle.hero.secondsLeftOfShields > 1.0 || self.battle.hero.secondsLeftOfShields == RQMaxSecondsOfShields || self.battle.hero.secondsLeftOfShields == 0.0) {
		[self.shieldDrawLineView setShieldPower:[[self.battle hero] secondsLeftOfShields]];
		shieldLightning.layer.opacity = [[self.battle hero] secondsLeftOfShields] / RQMaxSecondsOfShields;
		
	}
	[self.battle updateHeroShieldsBasedOnTimeDelta:deltaTime];
	
	// Move the monster around
	CGFloat newMonsterX = 160.0 + (80.0 * sin((float)monsterCounter / 30.0));
	CGFloat newMonsterY = 100.0 + (30.0 * sin((float)monsterCounter / 15.0));
	CGFloat newMonsterZ = 0.75 + (0.5 * sin((float)monsterCounter * 0.008));
	evilBoobsMonster.imageView.transform = CGAffineTransformMakeScale(newMonsterZ, newMonsterZ);
	evilBoobsMonster.position = CGPointMake(newMonsterX, newMonsterY);
	monsterCounter++;
	
	// move the bk
	if (self.backgroundImageView.frame.origin.x > -960.0) {
		CGRect newBackgroundFrame = self.backgroundImageView.frame;
		newBackgroundFrame.origin.x = newBackgroundFrame.origin.x - (deltaTime * (960/60));
		self.backgroundImageView.frame = newBackgroundFrame;
	} else {
		CGRect newBackgroundFrame = self.backgroundImageView.frame;
		newBackgroundFrame.origin.x = 0;
		newBackgroundFrame.origin.x = newBackgroundFrame.origin.x - (deltaTime * (960/60));
		self.backgroundImageView.frame = newBackgroundFrame;
	}
	
	
	// Figure out if the monster has been hit
	BOOL monsterHit = NO;
	if (activeWeapon) {
		monsterHit = [evilBoobsMonster isIntersectingRect:activeWeapon.view.frame];
	}
	
	if (monsterHit) {
		lastCollisionTime = currentTime;
		NSDictionary *result = [self.battle issueAttackCommandFrom:self.battle.hero withWeaponOfType:activeWeapon.type];
		if ([[result objectForKey:@"status"] isEqualToString:@"hit"]) {
			[evilBoobsMonster hitWithText:[(NSNumber *)[result objectForKey:@"attackValue"] stringValue]];
			float hpPercent = self.battle.enemy.currentHP * 1.0f / self.battle.enemy.maxHP;
			[evilBoobsMonster setPercent:hpPercent duration:1.0];
			
			if ( [[result objectForKey:@"attackWasStrong"] boolValue] == YES ) {
				[[SimpleAudioEngine sharedEngine] playEffect:@"Hit_002.caf"];
				[evilBoobsMonster strongHitAnimation];
				NSLog(@"stong attack");
			} else {
				[[SimpleAudioEngine sharedEngine] playEffect:@"Critical_Hit.caf"];
			}
				
			
		}
	} else {
		// If they have let go of the weapon move it based on velocity.
		if (!self.activeWeapon.touch)
		{
			activeWeapon.position = CGPointMake(activeWeapon.position.x + (activeWeapon.averageVelocity.x * deltaTime),
												activeWeapon.position.y + (activeWeapon.averageVelocity.y * deltaTime));
			// While moving the weapon we want to simulate perspective
			// If the weapon is past the flick threshold start to scale the weapon sprite
			if (activeWeapon.position.y < RQBattleViewFlickThreshold) {
				float scaleBasedOnPosition = ((activeWeapon.position.y / RQBattleViewFlickThreshold) * 50 + 50) / 100;
				CGRect newFrame = CGRectMake(activeWeapon.view.frame.origin.x, activeWeapon.view.frame.origin.y, activeWeapon.fullSize.width * scaleBasedOnPosition, activeWeapon.fullSize.height * scaleBasedOnPosition);
				activeWeapon.view.frame = newFrame;
			}
		}
		
		// Run ememy AI if they have not been hit
        if (!self.enemyShotFired && (self.battle.enemy.stamina > 0.85)) {
            self.enemyShotFired = YES;
            float shotWidth = self.view.frame.size.width; 
			self.enemyShotView = [[[RQEnemyWeaponView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, shotWidth, shotWidth)] autorelease];
            self.enemyShotView.center = evilBoobsMonster.view.center;
            self.enemyShotView.transform = CGAffineTransformMakeScale(0.1, 0.1);
            self.enemyShotView.alpha = 0.6f;
            [self.view addSubview:self.enemyShotView];
            [UIView animateWithDuration:0.5 
                                  delay:0.0 
                                options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveEaseIn 
                             animations:^(void) { 
                                 self.enemyShotView.transform = CGAffineTransformIdentity;
                                 self.enemyShotView.center = self.view.center;
            } 
                             completion:NULL];
        }
		if (self.battle.enemy.stamina >= 1.0) {
            self.enemyShotFired = NO;
            [self.enemyShotView removeFromSuperview];
            self.enemyShotView = nil;
            
			NSDictionary *enemyAttackResult = [self.battle issueAttackCommandFrom:self.battle.enemy  withWeaponOfType:RQElementalTypeNone];
			if ([[enemyAttackResult objectForKey:@"status"] isEqualToString:@"hit"]) {
				AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
				[[SimpleAudioEngine sharedEngine] playEffect:@"Critical_Hit.caf"];
				CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
				flash.fromValue = [NSNumber numberWithFloat:0.0f];
				flash.toValue = [NSNumber numberWithFloat:0.8f];
				flash.autoreverses = YES;
				flash.duration = 0.3;
				flash.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
				[self.frontFlashView.layer addAnimation:flash forKey:@"opacity"];
			}
		} // end ememy AI
	}
	
	if (currentTime > lastCollisionTime + 1.0) {
		
	}
	
	// Update the hero health meter
	[heroHealthBar setPercent:((float)self.battle.hero.currentHP / (float)self.battle.hero.maxHP) duration:0.3];
	[heroGlovePowerBar setPercent:((float)self.battle.hero.glovePower / 100.0) duration:0.1];
	
	// Update the weapons to help visualize the hero stamina
	for (RQWeaponSprite *weaponSprite in weaponSprites) {
		float previousOpacity = weaponSprite.view.layer.opacity;
		weaponSprite.view.layer.opacity = self.battle.hero.stamina;
		NSString *weaponImageName;
		switch (weaponSprite.type) {
			case RQElementalTypeFire:
				if (self.battle.hero.stamina >= 1.0) {
					weaponImageName = @"fire_weapon";
				} else {
					weaponImageName = @"fire_weapon_desaturated";
				}
				break;
			case RQElementalTypeWater:
				if (self.battle.hero.stamina >= 1.0) {
					weaponImageName = @"water_weapon";
				} else {
					weaponImageName = @"water_weapon_desaturated";
				}
				break;
			case RQElementalTypeEarth:
				if (self.battle.hero.stamina >= 1.0) {
					weaponImageName = @"earth_weapon";
				} else {
					weaponImageName = @"earth_weapon_desaturated";
				}
				break;
			case RQElementalTypeAir:
				if (self.battle.hero.stamina >= 1.0) {
					weaponImageName = @"air_weapon";
				} else {
					weaponImageName = @"air_weapon_desaturated";
				}
				break;
		}
		// sub in new image view
		[(UIImageView *)weaponSprite.imageView setImage:[UIImage imageNamed:weaponImageName]];
		
		
		// if we are at the last step of making the weapons enabled play a sound cue
		if (previousOpacity < weaponSprite.view.layer.opacity && weaponSprite.view.layer.opacity >= 1.0) {
			[[SimpleAudioEngine sharedEngine] playEffect:@"chimp_001.caf"];
		}
	}
	
	// If the weapon leaves the view frame or we hit the monster reset the position of the weapon
	if ((!CGRectContainsPoint(self.view.frame, activeWeapon.position)) || monsterHit){
		activeWeapon.view.frame = CGRectMake(activeWeapon.view.frame.origin.x, activeWeapon.view.frame.origin.y, activeWeapon.fullSize.width, activeWeapon.fullSize.height);
		// Make sure to edit the position after setting the frame (for scale) .. doing it before results in a slight error in position.
		activeWeapon.position = activeWeapon.orininalPosition;
		activeWeapon.velocity = CGPointZero;
		[self setActiveWeapon:nil];
	}
	
	// check for end of battle conditions and if done, present the victory screen
	if (self.battle.isBattleDone) {
		[self stopAnimation];
		if (self.battle.hero.currentHP > 0) {
			[UIView animateWithDuration:1.0 
								  delay:0.0 
								options:UIViewAnimationCurveLinear 
							 animations:^(void) {
								 [evilBoobsMonster runDeathAnimation];
								 evilBoobsMonster.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
							 } 
							 completion:^(BOOL finished) {
								 [self presentVictoryScreen];
							 }];
		} else {
			[self presentVictoryScreen];
		}
		
	}
	
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// If the user tries to active a weapon while the hero stamina is not full, say no
	
	
	// When a touch begins we need to assign an active weapon (as long as there isn't a current active weapon)
	if (!activeWeapon) {
		UITouch *touch = [touches anyObject];
		CGPoint touchLocation = [touch locationInView:self.view];
		
		// find out which weapon they are touching
		for (RQWeaponSprite *weapon in weaponSprites) {
			if (CGRectContainsPoint(weapon.view.frame, touchLocation)) {
				weapon.touch = touch;
				[self setActiveWeapon:weapon];
				previousTouchTimestamp = touch.timestamp;
			}
		}
	}
}

- (void)releaseActiveWeapon {
	// when touch is nil the game loop will begin to update it's position based on velocity
	self.activeWeapon.touch = nil;
	//NSLog(@"self.activeWeapon.velocity x %f y %f", self.activeWeapon.velocity.x, self.activeWeapon.velocity.y);
	
	// if the velocity was too low do not "fire" the weapon but reset it
	float min_velocity = 1000.0;
	if ( sqrt(pow(self.activeWeapon.averageVelocity.x, 2) + pow(self.activeWeapon.averageVelocity.y, 2)) < min_velocity )
	{
		CGFloat deltaX = -.1f*(activeWeapon.position.x - activeWeapon.orininalPosition.x);
		CGFloat deltaY = -.1f*(activeWeapon.position.y - activeWeapon.orininalPosition.y);
		
		[UIView animateWithDuration:0.25f 
						 animations:
		 ^{activeWeapon.position = CGPointMake(activeWeapon.orininalPosition.x + deltaX, activeWeapon.orininalPosition.y + deltaY);} 
						 completion: 
		 ^(BOOL finished){[UIView animateWithDuration:0.1 animations:^{activeWeapon.position = activeWeapon.orininalPosition;
			[self setActiveWeapon:nil];}]; }];
		activeWeapon.velocity = CGPointZero;
		
		
	} else {
		// Only play the launch sounds when the weapon will be moving
		[[SimpleAudioEngine sharedEngine] playEffect:@"Laser.caf"];
		self.battle.hero.glovePower = self.battle.hero.glovePower - 5;
	}
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	// if this touch relivent to our activeWeapon?
	for (UITouch *touch in touches) {
		if ([touch isEqual:self.activeWeapon.touch]) {
			
			// If the touch has moved the weapon past the flick threshold then end the touch so natural movement can start
			CGPoint touchLocation = [touch locationInView:self.view];
			if (touchLocation.y <= RQBattleViewFlickThreshold) {
				[self releaseActiveWeapon];
			} else {
				// If they are still under the threshold update weapon tracking
				// if so, update the sprite
				[self.activeWeapon setPosition:touchLocation atTime:touch.timestamp];
				//CGPoint previousTouchLocation = [touch previousLocationInView:self.view];
//				self.activeWeapon.position = touchLocation;
//				NSTimeInterval deltaTime = touch.timestamp - previousTouchTimestamp;
//				CGFloat deltaX = touchLocation.x - previousTouchLocation.x;
//				CGFloat deltaY = touchLocation.y - previousTouchLocation.y;
//				deltaX /= deltaTime;
//				deltaY /= deltaTime;
//				CGPoint newVelocity = CGPointMake(deltaX, deltaY);
//				self.activeWeapon.velocity = CGPointMake(newVelocity.x, newVelocity.y);
//				previousTouchTimestamp = touch.timestamp;
			}
		}
	}
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	// if this touch relivent to our activeWeapon?
	for (UITouch *touch in touches) {
		if ([touch isEqual:self.activeWeapon.touch]) {
			[self releaseActiveWeapon];
		}
	}
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
    previousTickTime = CACurrentMediaTime();
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

- (IBAction)runButtonPressed:(id)sender
{
	// Add logic that penelizes a player from running
	[self returnToMapView];
}
		 
- (void)presentVictoryScreen
{
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	if (self.battle.hero.currentHP > 0) {
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"victory_song_002.m4a" loop:NO];
	} else {
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"You lose.m4a" loop:NO];
	}
	self.battleVictoryViewController = [[[RQBattleVictoryViewController alloc] init] autorelease];
	[self.battleVictoryViewController setDelegate:self];
	[self.battleVictoryViewController setBattle:self.battle];
	[self.view.window addSubview:self.battleVictoryViewController.view];
    self.battleVictoryViewController.view.frame = self.view.window.bounds;
	self.view.hidden = YES;
}

- (void)dismissVictoryScreen
{
	[self.battleVictoryViewController.view removeFromSuperview];
	[self returnToMapView];
}

- (void)returnToMapView
{
    [self stopAnimation];
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	
	// If the user would like us to pause the iPod during battles to hear our own sweet music
	// Only play the iPod if we previously paused it
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"RQSoundMuteIPod"] boolValue] && didPauseIPod == YES) {
		NSLog(@"playing iPod");
		[[MPMusicPlayerController iPodMusicPlayer] play];
		[[CDAudioManager sharedManager] setMode:kAMM_FxPlusMusicIfNoOtherAudio];
		
		// trying to fix a bug where in the sound effect don't play after the first battle if we are pausing iPod
		[[CDAudioManager sharedManager] setMute:NO];
		[[CDAudioManager sharedManager] setEnabled:YES];
		[[SimpleAudioEngine sharedEngine] setMute:NO];
		[[SimpleAudioEngine sharedEngine] setEnabled:YES];
	}
	
	[delegate battleViewControllerDidEnd:self];
}

- (void)battleVictoryControllerDidEnd:(RQBattleVictoryViewController *)controller;
{
	[self.battleVictoryViewController.view removeFromSuperview];
	[self setBattleVictoryViewController:nil];
	[[[RQModelController defaultModelController] coreDataManager] save];
	[self returnToMapView];
}

#pragma mark -
#pragma mark ShieldDrawLineViewDelegate Methods

- (BOOL)isTouchInsideShieldBase:(UITouch *)touch
{
	CGRect temp = [self frameOfTouchedShieldBase:touch];
	if (CGRectEqualToRect(temp, CGRectZero)) {
		return NO;
	} else {
		return YES;
	}
}

- (CGRect)frameOfTouchedShieldBase:(UITouch *)touch
{
	CGPoint touchLocation = [touch locationInView:self.view];
	if (CGRectContainsPoint(self.leftShield.frame, touchLocation)) {
		return self.leftShield.frame;
	} else if (CGRectContainsPoint(self.rightShield.frame, touchLocation)) {
		return self.rightShield.frame;
	} else {
		return CGRectZero;
	}
}

- (void)shieldsUp
{
	// give the hero 10 seconds of shields
	[self.battle.hero setSecondsLeftOfShields:RQMaxSecondsOfShields];
	[[SimpleAudioEngine sharedEngine] playEffect:@"Shields_up.caf"];
}

@end
