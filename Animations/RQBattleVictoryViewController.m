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
#import "RQBarView.h"


@interface RQBattleVictoryViewController ()
- (void)updateStats;
@end


@implementation RQBattleVictoryViewController
@synthesize xpBarView;
@synthesize heroLevelLabel;
@synthesize heroXPFractionLabel;
@synthesize heroXPReceivedLabel;
@synthesize moreInfoContainerView;
@synthesize silhouetteView;
@synthesize victoryText;

- (id)init
{
	if (self = [super initWithNibName:@"RQBattleVictoryViewController" bundle:nil]) {
		experienceGained = 0;
	}
	return self;
}

- (void)dealloc 
{
	NSLog(@"RQBattleVictoryViewController -dealloc called...");
	[xpCountTimer invalidate]; [xpCountTimer release]; xpCountTimer = nil;
	
	[xpBarView release];
	[heroLevelLabel release];
	[heroXPFractionLabel release];
	[heroXPReceivedLabel release];
	[moreInfoContainerView release];
	[silhouetteView release];
	[victoryText release];
	
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
	
	xpBarView.barColor = [UIColor whiteColor];
	self.heroXPReceivedLabel.alpha = 0.0f;
	self.heroXPReceivedLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);
	self.moreInfoContainerView.layer.cornerRadius = 6.0;
	[self updateStats];
	
	CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
	gradientLayer.frame = self.view.frame;
	if (self.battle.didHeroWin) {
		gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:0.086 green:0.080 blue:0.563 alpha:1.000].CGColor, 
								(id)[UIColor colorWithRed:0.339 green:0.085 blue:0.563 alpha:1.000].CGColor, nil];
		self.silhouetteView.image = [UIImage imageNamed:@"victorySilhouette"];
		self.victoryText.image = [UIImage imageNamed:@"victoryText"];
	}
	else {
		gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor blackColor].CGColor, 
								(id)[UIColor colorWithRed:0.502 green:0.000 blue:0.000 alpha:1.000].CGColor, nil];
		self.silhouetteView.image = [UIImage imageNamed:@"failureSilhouette"];
		self.victoryText.image = [UIImage imageNamed:@"failureText"];
	}
	[self.view.layer insertSublayer:gradientLayer atIndex:0];

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
		self.heroXPReceivedLabel.text = [NSString stringWithFormat:@"+%d", experienceGained];
		[self performSelector:@selector(startXPAnimation) withObject:nil afterDelay:0.5];
		[UIView animateWithDuration:1.0 
							  delay:0.0 
							options:UIViewAnimationOptionAllowUserInteraction 
						 animations:^(void) {
							 self.heroXPReceivedLabel.alpha = 1.0;
							 self.heroXPReceivedLabel.transform = CGAffineTransformIdentity;
						 } 
						 completion:NULL];		
	}
	
	[self.battleXPLabel setText:@"Battle experience:"];
	[self.battleXPCountLabel setText:[NSString stringWithFormat:@"%d", experienceGained]];
	
	[self.heroXPLabel setText:[NSString stringWithFormat:@"%@'s experience:", self.battle.hero.name]];
	[self.heroXPCountLabel setText:[NSString stringWithFormat:@"%d", self.battle.hero.experiencePoints]];
	
}

- (void)startXPAnimation
{
	xpCountTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0/10.0 target:self selector:@selector(animateXPGains) userInfo:nil repeats:YES] retain];
//	self.battle.hero.experiencePoints += experienceGained;
//	self.heroXPReceivedLabel.text = [NSString stringWithFormat:@"+%d", experienceGained];
//	CGFloat xpPercent = (CGFloat)self.battle.hero.experiencePoints / (CGFloat)[RQMob expectedExperiencePointTotalGivenLevel:self.battle.hero.level];
//	NSLog(@"xp: %f, total: %f, percent: %f", (CGFloat)self.battle.hero.experiencePoints, (CGFloat)[RQMob expectedExperiencePointTotalGivenLevel:self.battle.hero.level], xpPercent);
//	[xpBarView setPercent:xpPercent duration:3.0];
//	self.heroLevelLabel.text = [NSString stringWithFormat:@"Level %d", self.battle.hero.level];
//	self.heroXPFractionLabel.text = [NSString stringWithFormat:@"%d/%d", 
//									 self.battle.hero.experiencePoints, 
//									 [RQMob expectedExperiencePointTotalGivenLevel:self.battle.hero.level]];
//	self.moreInfoContainerView.layer.cornerRadius = 6.0;
//	
//	[UIView animateWithDuration:1.0 
//						  delay:0.0 
//						options:UIViewAnimationOptionAllowUserInteraction 
//					 animations:^(void) {
//						 self.heroXPReceivedLabel.alpha = 1.0;
//						 self.heroXPReceivedLabel.transform = CGAffineTransformIdentity;
//					 } 
//					 completion:NULL];
//	
//	experienceGained = 0;
}

- (void)animateXPGains
{
	[self animateXPGainsJumpToLast:NO];
}

- (void)animateXPGainsJumpToLast:(BOOL)jumpToLastFrame
{
	[self updateStats];
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
			NSLog(@"newLevel: %d", self.battle.hero.level);
			[self.newLevelBannerLabel setHidden:NO];
			[self.newLevelBannerLabel setText:@"New Level!"];
			[self.newLevelMessageLabel setHidden:NO];
			[self.newLevelMessageLabel setText:[NSString stringWithFormat:@"%@ is now level %d", self.battle.hero.name, self.battle.hero.level]];
			[[SimpleAudioEngine sharedEngine] playEffect:@"levelUp.m4a"];
			
			[xpBarView setPercent:100.0 duration:0.0];
			self.heroLevelLabel.text = [NSString stringWithFormat:@"Level %d", self.battle.hero.level];
			[UIView animateWithDuration:0.5 
								  delay:0.0 
								options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAutoreverse 
							 animations:^(void) {
								 self.heroLevelLabel.transform = CGAffineTransformMakeScale(1.5, 1.5);
							 } 
							 completion:^(BOOL finished) {
								 self.heroLevelLabel.transform = CGAffineTransformIdentity;
							 }];
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
		//[self animateXPGainsJumpToLast:YES];
		//[self performSelector:@selector(tapRecognized:) withObject:nil afterDelay:1.0];
	} else {
		[delegate battleVictoryControllerDidEnd:self];
	}
}


- (void)updateStats
{
	CGFloat xpNeededToLevel = (CGFloat)[RQMob experinceNeededToLevelFromLevel:self.battle.hero.level];
	CGFloat xpPercent = ((CGFloat)self.battle.hero.experiencePoints - xpNeededToLevel) / (CGFloat)[RQMob experinceNeededToLevelFromLevel:self.battle.hero.level];
	NSLog(@"xp: %f, total: %f, percent: %f", ((CGFloat)self.battle.hero.experiencePoints - xpNeededToLevel), (CGFloat)[RQMob expectedExperiencePointTotalGivenLevel:self.battle.hero.level], xpPercent);
	[xpBarView setPercent:xpPercent duration:0.0];
	self.heroLevelLabel.text = [NSString stringWithFormat:@"Level %d", self.battle.hero.level];
	self.heroXPFractionLabel.text = [NSString stringWithFormat:@"%d/%d", 
									 self.battle.hero.experiencePoints, 
									 [RQMob expectedExperiencePointTotalGivenLevel:(CGFloat)self.battle.hero.level]];	
}

@end
