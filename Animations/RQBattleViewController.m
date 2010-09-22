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
#import "MapViewController.h"
#import "RQBattle.h"
#import "RQMob.h"
#import "RQWeaponSprite.h"
#import "RQBattleVictoryViewController.h"

@implementation RQBattleViewController

- (id)init
{
	if (self = [super init]) {
		weaponSprites = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[self stopAnimation];
	[heroHeathLabel release]; heroHeathLabel = nil;
	[weaponSprites release]; weaponSprites = nil;
	[battleVictoryViewController release]; battleVictoryViewController = nil;
	[mapViewController release]; mapViewController = nil;
	[battle release]; battle = nil;
	[evilBoobsMonster release];
    [super dealloc];
}

@synthesize mapViewController;
@synthesize battleVictoryViewController;
@synthesize battle;
@synthesize activeWeapon;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	battle = [[RQBattle alloc] init];
	
	self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
	
	UIButton *runButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[runButton setTitle:@"Run" forState:UIControlStateNormal];
	[runButton addTarget:self action:@selector(runButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:runButton];
	[runButton setFrame:CGRectMake(self.view.frame.size.width-44.0, 0.0, 44.0, 44.0)];
	
	NSString *typicalHPReading = @"9999/9999";
	UIFont *heroHeathLabelFont = [UIFont boldSystemFontOfSize:22];
	CGSize heroHeathLabelSize = [typicalHPReading sizeWithFont:heroHeathLabelFont];
	heroHeathLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height - 110, self.view.frame.size.width/2, heroHeathLabelSize.height)];
	[self.view addSubview:heroHeathLabel];
	heroHeathLabel.font = heroHeathLabelFont;
	heroHeathLabel.textAlignment = UITextAlignmentRight;
	heroHeathLabel.backgroundColor = [UIColor clearColor];
	heroHeathLabel.textColor = [UIColor whiteColor];
	heroHeathLabel.shadowColor= [UIColor blackColor];
	heroHeathLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	heroHeathLabel.text = typicalHPReading;
	
	// setup weaponSprite Array
	RQWeaponSprite *weaponSprite;
	NSString *weaponImageName;
	UIImageView *weaponImageView;
	int xloc = 40;
	for (NSDictionary *weapon in self.battle.hero.weapons) {
		weaponImageName = [NSString stringWithFormat:@"%@_button", [weapon objectForKey:@"type"]]; 
		weaponImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:weaponImageName]];
		weaponSprite = [[RQWeaponSprite alloc] initWithView:weaponImageView];
		[weaponImageView release];
		[weaponSprite setWeaponDetails:weapon];
		[weaponSprites addObject:weaponSprite];
		[self.view addSubview:weaponSprite.view];
		weaponSprite.position = CGPointMake(xloc, self.view.frame.size.height - 40);
		weaponSprite.orininalPosition = weaponSprite.position;
		xloc = xloc + 80;
		weaponSprite.velocity = CGPointZero;
		[weaponSprite release]; weaponSprite = nil;
	}

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
	
	[self.battle updateCombatantStaminaBasedOnTimeDelta:deltaTime];
	
	
	CGFloat newMonsterX = 160.0 + (80.0 * sin((float)monsterCounter / 30.0));
	CGFloat newMonsterY = 100.0 + (30.0 * sin((float)monsterCounter / 15.0));
	
	evilBoobsMonster.position = CGPointMake(newMonsterX, newMonsterY);
	
	monsterCounter++;	
	
	
	// If they have let go of the weapon move it based on velocity.
	if (!self.activeWeapon.touch) {
		
		activeWeapon.position = CGPointMake(activeWeapon.position.x + (activeWeapon.velocity.x * deltaTime),
										    activeWeapon.position.y + (activeWeapon.velocity.y * deltaTime));
		
	}
	
	BOOL monsterHit = [evilBoobsMonster isIntersectingRect:activeWeapon.view.frame];
	
	if (monsterHit) {
		lastCollisionTime = currentTime;
		NSDictionary *result = [self.battle issueAttackCommandFrom:self.battle.hero];
		if ([[result objectForKey:@"status"] isEqualToString:@"hit"]) {
			[evilBoobsMonster hitWithText:[(NSNumber *)[result objectForKey:@"attackValue"] stringValue]];
			float hpPercent = self.battle.enemy.currentHP * 1.0f / self.battle.enemy.maxHP;
			//NSLog(@"hpPercent %d / %d = %f", self.battle.enemy.currentHP, self.battle.enemy.maxHP, hpPercent);
			[[evilBoobsMonster enemyHealthMeter] setProgress:hpPercent];
		}
	}
	
	if (currentTime > lastCollisionTime + 1.0) {
		
	}
	
	// Update the hero health meter
	heroHeathLabel.text = [NSString stringWithFormat:@"%d/%d", self.battle.hero.currentHP, self.battle.hero.maxHP];
	
	// Update the weapons to help visualize the hero stamina
	for (RQWeaponSprite *weaponSprite in weaponSprites) {
		weaponSprite.view.layer.opacity = self.battle.hero.stamina; 
	}
	
	// If the weapon leaves the view frame or we hit the monster reset the position of the weapon
	if ((!CGRectContainsPoint(self.view.frame, activeWeapon.position)) || monsterHit){
		activeWeapon.position = activeWeapon.orininalPosition;
		activeWeapon.velocity = CGPointZero;
		[self setActiveWeapon:nil];
	}
	
	// check for end of battle conditions and if done, present the victory screen
	if (self.battle.isBattleDone) {
		[self stopAnimation];
		[self presentVictoryScreen];
	}
	
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
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

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	// if this touch relivent to our activeWeapon?
	for (UITouch *touch in touches) {
		if ([touch isEqual:self.activeWeapon.touch]) {
			// if so, update the sprite
			CGPoint touchLocation = [touch locationInView:self.view];
			CGPoint previousTouchLocation = [touch previousLocationInView:self.view];
			self.activeWeapon.position = touchLocation;
			NSTimeInterval deltaTime = touch.timestamp - previousTouchTimestamp;
			CGFloat deltaX = touchLocation.x - previousTouchLocation.x;
			CGFloat deltaY = touchLocation.y - previousTouchLocation.y;
			deltaX /= deltaTime;
			deltaY /= deltaTime;
			CGPoint newVelocity = CGPointMake(deltaX, deltaY);
			self.activeWeapon.velocity = CGPointMake(self.activeWeapon.velocity.x * 0.9 + newVelocity.x * 0.1,
													 self.activeWeapon.velocity.y * 0.9 + newVelocity.y * 0.1);
			previousTouchTimestamp = touch.timestamp;
		}
	}
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	// if this touch relivent to our activeWeapon?
	for (UITouch *touch in touches) {
		if ([touch isEqual:self.activeWeapon.touch]) {
			self.activeWeapon.touch = nil;
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
	self.battleVictoryViewController = [[[RQBattleVictoryViewController alloc] init] autorelease];
	[self.battleVictoryViewController setBattleViewController:self];
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
	[self.mapViewController removeBattleView];
}

@end
