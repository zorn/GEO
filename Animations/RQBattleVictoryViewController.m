    //
//  RQBattleVictoryViewController.m
//  RunQuest
//
//  Created by Michael Zornek on 9/22/10.
//  Copyright 2010 Clickable Bliss. All rights reserved.
//

#import "SimpleAudioEngine.h"
#import "RQBattleVictoryViewController.h"
#import "RQBattleViewController.h"
#import "RQBattle.h"
#import "RQHero.h"
#import "RQEnemy.h"

@implementation RQBattleVictoryViewController

- (id)init
{
	if (self = [super initWithNibName:@"BattleVictoryView" bundle:nil]) {
		experienceGained = 0;
	}
	return self;
}

- (void)dealloc 
{
	NSLog(@"RQBattleVictoryViewController -dealloc called...");
	[xpCountTimer invalidate]; [xpCountTimer release]; xpCountTimer = nil;

	[victoryTitle release]; victoryTitle = nil;
	[battleXPLabel release]; battleXPLabel = nil;
	[battleXPCountLabel release]; battleXPCountLabel = nil;
	[heroXPLabel release]; heroXPLabel = nil;
	[heroXPCountLabel release]; heroXPCountLabel = nil;
	[newLevelBannerLabel release]; newLevelBannerLabel = nil;
	[newLevelMessageLabel release]; newLevelMessageLabel = nil;
	[battle release]; battle = nil;
	[super dealloc];
}

@synthesize victoryTitle;
@synthesize battleXPLabel;
@synthesize battleXPCountLabel;
@synthesize heroXPLabel;
@synthesize heroXPCountLabel;
@synthesize newLevelBannerLabel;
@synthesize newLevelMessageLabel;
@synthesize battle;
@synthesize delegate;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSLog(@"RQBattleVictoryViewController -viewDidLoad");

	UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
	[recognizer setNumberOfTapsRequired:2];
	[self.view addGestureRecognizer:recognizer];
	[recognizer release]; recognizer = nil;
	
	if (self.battle.hero.currentHP) {
		[self.victoryTitle setText:@"You Won!"];
	} else {
		[self.victoryTitle setText:@"You Lost"];
	}
	[self.newLevelBannerLabel setHidden:YES];
	[self.newLevelMessageLabel setHidden:YES];
	
	if (self.battle.didHeroWin) {
		experienceGained = self.battle.enemy.experiencePointsWorth;
		[self performSelector:@selector(startXPAnimation) withObject:nil afterDelay:0.5];
	}
	
	[self.battleXPLabel setText:@"Battle experience:"];
	[self.battleXPCountLabel setText:[NSString stringWithFormat:@"%d", experienceGained]];
	
	[self.heroXPLabel setText:[NSString stringWithFormat:@"%@'s experience:", self.battle.hero.name]];
	[self.heroXPCountLabel setText:[NSString stringWithFormat:@"%d", self.battle.hero.experiencePoints]];
	
}

- (void)startXPAnimation
{
	xpCountTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0/10.0 target:self selector:@selector(animateXPGains) userInfo:nil repeats:YES] retain];
}

- (void)animateXPGains
{
	[self animateXPGainsJumpToLast:NO];
}

- (void)animateXPGainsJumpToLast:(BOOL)jumpToLastFrame
{
	if (experienceGained > 0) {
		if (jumpToLastFrame == YES) {
			self.battle.hero.experiencePoints = self.battle.hero.experiencePoints + experienceGained;
			experienceGained = 0;
		} else {
			experienceGained = experienceGained - 1;
			self.battle.hero.experiencePoints = self.battle.hero.experiencePoints + 1;
		}
		
		[self.battleXPCountLabel setText:[NSString stringWithFormat:@"%d", experienceGained]];
		[self.heroXPCountLabel setText:[NSString stringWithFormat:@"%d", self.battle.hero.experiencePoints]];
		[[SimpleAudioEngine sharedEngine] playEffect:@"Coin.wav"];
		if ([self.battle.hero increaseLevelIfNeeded]) {
			[self.newLevelBannerLabel setHidden:NO];
			[self.newLevelBannerLabel setText:@"New Level!"];
			[self.newLevelMessageLabel setHidden:NO];
			[self.newLevelMessageLabel setText:[NSString stringWithFormat:@"%@ is now level %d", self.battle.hero.name, self.battle.hero.level]];
			[[SimpleAudioEngine sharedEngine] playEffect:@"levelUp.m4a"];
		}
	}
	
	if (experienceGained <= 0) {
		[xpCountTimer invalidate]; [xpCountTimer release]; xpCountTimer = nil;
	}
}



- (void)tapRecognized:(UIGestureRecognizer *)recognizer
{
	if (experienceGained > 0) {
		// they are still animating xp gains, don't quit just yet
		[self animateXPGainsJumpToLast:YES];
		//[self performSelector:@selector(tapRecognized:) withObject:nil afterDelay:1.0];
	} else {
		[delegate battleVictoryControllerDidEnd:self];
	}
}

@end
