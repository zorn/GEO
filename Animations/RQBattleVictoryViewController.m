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
#import "RQConstants.h"
#import "RQBattle.h"
#import "RQHero.h"
#import "RQEnemy.h"
#import "RQBarView.h"

// models
#import "RQModelController.h"
#import "RQMentorMessageTemplate.h"

@interface RQBattleVictoryViewController ()
- (void)updateViewToShowMaxLevel;
- (void)updateStats;
@end


@implementation RQBattleVictoryViewController

@synthesize continueWorkoutButton;
@synthesize xpBarView;
@synthesize heroLevelLabel;
@synthesize heroXPFractionLabel;
@synthesize heroXPReceivedLabel;
@synthesize moreInfoContainerView;
@synthesize victoryText;
@synthesize maxLevelTitleImage;
@synthesize mentorMessageTextView;
@synthesize mentorAvatarImageView;
@synthesize backgroundImageView;

- (id)init
{
	if (self = [super initWithNibName:@"RQBattleVictoryViewController" bundle:nil]) {
		experienceGained = 0;
	}
	return self;
}

- (void)dealloc 
{
	CCLOG(@"RQBattleVictoryViewController -dealloc called...");
	[xpCountTimer invalidate]; [xpCountTimer release]; xpCountTimer = nil;
	
	[continueWorkoutButton release];
	[xpBarView release];
	[heroLevelLabel release];
	[heroXPFractionLabel release];
	[heroXPReceivedLabel release];
	[moreInfoContainerView release];
	[maxLevelTitleImage release];
	[victoryText release];
	[mentorMessageTextView release];
	[mentorAvatarImageView release];
	[backgroundImageView release];
	
	[battle release]; battle = nil;
	[super dealloc];
}

@synthesize battle;
@synthesize delegate;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	CCLOG(@"RQBattleVictoryViewController -viewDidLoad");
	
	xpBarView.barColor = [UIColor whiteColor];
	xpBarView.outlineColor = [UIColor colorWithWhite:0.6 alpha:1.0];
	self.heroXPReceivedLabel.alpha = 0.0f;
	self.heroXPReceivedLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);
	self.moreInfoContainerView.layer.cornerRadius = 6.0;
	[self updateStats];
	
	// setup the mentor avatar and message
	RQMentorMessageTemplate *mentorMessage = [[RQModelController defaultModelController] randomMentorMessageBasedOnBattle:self.battle];
	UIImage *mentorImage = [UIImage imageNamed:@"mentor_message_avatar_calm.png"];
	[self.mentorAvatarImageView setImage:mentorImage];
	
	if (self.battle.didHeroWin) {
		[self.mentorMessageTextView setText:mentorMessage.message];
	} else {
		[self.mentorMessageTextView setText:@"That was a pretty poor fight. Perhaps you aren't the ranger for this job. I'll heal you up a bit. Keep moving to regenerate more health."];
	}
	
	if (self.battle.didHeroWin) {
		self.backgroundImageView.image = [UIImage imageNamed:@"battle_victory_background"];
		self.victoryText.image = [UIImage imageNamed:@"victory_view_test_victory.png"];
	}
	else {
		self.backgroundImageView.image = [UIImage imageNamed:@"battle_failure_background"];
		self.victoryText.image = [UIImage imageNamed:@"victory_view_test_failure.png"];
	}

	UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
	[recognizer setNumberOfTapsRequired:2];
	[self.view addGestureRecognizer:recognizer];
	[recognizer release]; recognizer = nil;
	
	if (self.battle.didHeroWin) {
		experienceGained = self.battle.enemy.experiencePointsWorth;
		self.heroXPReceivedLabel.text = [NSString stringWithFormat:@"+%d", experienceGained];
		[self performSelector:@selector(startXPAnimation) withObject:nil afterDelay:0.0];
		[UIView animateWithDuration:1.0 
							  delay:0.0 
							options:UIViewAnimationOptionAllowUserInteraction 
						 animations:^(void) {
							 self.heroXPReceivedLabel.alpha = 1.0;
							 self.heroXPReceivedLabel.transform = CGAffineTransformIdentity;
						 } 
						 completion:NULL];		
	} else {
		self.heroXPReceivedLabel.hidden = YES;
		self.heroLevelLabel.hidden = YES;
		self.xpBarView.hidden = YES;
		self.heroXPFractionLabel.hidden = YES;
	}
	
	// If the hero lost throw him a bone and give him some HP
	if (!self.battle.didHeroWin) {
		self.battle.hero.currentHP = lroundf(self.battle.hero.maxHP * 0.3);
	}
	
	[self updateViewToShowMaxLevel];
	
	//style the continue workout button
	[[self.continueWorkoutButton layer] setCornerRadius:8.0f];
	[[self.continueWorkoutButton layer] setMasksToBounds:YES];
	[[self.continueWorkoutButton layer] setBorderWidth:1.0f];
	[[self.continueWorkoutButton layer] setBackgroundColor:[[UIColor colorWithRed:0.060 green:0.069 blue:0.079 alpha:1.000] CGColor]];
	[[self.continueWorkoutButton layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
	[self.continueWorkoutButton setTitleColor:[UIColor colorWithRed:0.629 green:0.799 blue:1.000 alpha:1.000] forState:UIControlStateNormal];
}

- (void)updateViewToShowMaxLevel
{
	if (self.battle.didHeroWin && [self.battle.hero isLevelCapped]) {
		self.heroXPReceivedLabel.hidden = YES;
		self.heroLevelLabel.hidden = YES;
		self.xpBarView.hidden = YES;
		self.heroXPFractionLabel.hidden = YES;
		self.victoryText.hidden = YES;
		
		self.maxLevelTitleImage.hidden = NO;
		self.backgroundImageView.image = [UIImage imageNamed:@"battle_max_level_background.png"];

	}
}

- (void)startXPAnimation
{
	xpCountTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0/10.0 target:self selector:@selector(animateXPGains) userInfo:nil repeats:YES] retain];
	experienceCountByAmount = floor(experienceGained / 40) + 1;
}

- (void)animateXPGains
{
	[self animateXPGainsJumpToLast:NO];
}

- (void)animateXPGainsJumpToLast:(BOOL)jumpToLastFrame
{
	if (self.battle.hero.isLevelCapped) {
		experienceGained = 0;
		[xpCountTimer invalidate]; [xpCountTimer release]; xpCountTimer = nil;
		return; // bail
	}
	
	if (experienceGained > 0) {
		if (jumpToLastFrame == YES) {
			self.battle.hero.experiencePoints = self.battle.hero.experiencePoints + experienceGained;
			experienceGained = 0;
		} else {
			experienceGained = experienceGained - experienceCountByAmount;
			self.battle.hero.experiencePoints = self.battle.hero.experiencePoints + experienceCountByAmount;
		}
		
		[[SimpleAudioEngine sharedEngine] playEffect:@"spaceBeat.m4a"];
		if ([self.battle.hero increaseLevelIfNeeded]) {
			CCLOG(@"newLevel: %d", self.battle.hero.level);
			[[SimpleAudioEngine sharedEngine] playEffect:@"levelUp.m4a"];
			
			self.heroLevelLabel.text = [NSString stringWithFormat:@"Level %d", self.battle.hero.level];
			CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
			anim.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
			anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.5, 1.5, 1.5)];
			anim.duration = 0.5;
			anim.autoreverses = YES;
			[self.heroLevelLabel.layer addAnimation:anim forKey:@"transform"];

			RQBarView *newXPBar = [[RQBarView alloc] initWithFrame:self.xpBarView.frame];
			[self.xpBarView removeFromSuperview];
			self.xpBarView = newXPBar;
			[newXPBar release];
			[self.xpBarView setPercent:0.0 duration:0.0];
			self.xpBarView.barColor = [UIColor whiteColor];
			self.xpBarView.outlineColor = [UIColor colorWithWhite:0.6 alpha:1.0];
			[self.view addSubview:self.xpBarView];
			
			// if they are leveling up to 50, show alert congratulating them on max level and to look for new button on home screen
			if (self.battle.hero.level == 50) {
				UIAlertView *levelCapMessage = [[UIAlertView alloc] initWithTitle:@"Congratulations!" message:@"After much hard work it seems you have finally fully re-powered your glove. Please see me after you are done your workout." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[levelCapMessage show];
				[levelCapMessage autorelease];
			}
		}
	}
	[self updateStats];
	
	if (experienceGained <= 0) {
		[xpCountTimer invalidate]; [xpCountTimer release]; xpCountTimer = nil;
	}
}



- (void)tapRecognized:(UIGestureRecognizer *)recognizer
{
	if (experienceGained > 0) {
		// they are still animating xp gains, don't quit just yet
		[self animateXPGainsJumpToLast:YES];
		[self performSelector:@selector(tapRecognized:) withObject:nil afterDelay:0.0];
	} else {
		[delegate battleVictoryControllerDidEnd:self];
	}
}

- (IBAction)continueWorkout
{
	[self tapRecognized:nil];
}

- (void)updateStats
{
	// these var labels don't make much sense but the math is right, I think.
	NSInteger heroCurrentXP = self.battle.hero.experiencePoints;
	NSInteger totalXPForLevel;
	if (self.battle.hero.level > 1) {
		totalXPForLevel = [RQMob expectedExperiencePointTotalGivenLevel:self.battle.hero.level] - [RQMob expectedExperiencePointTotalGivenLevel:self.battle.hero.level-1];
		heroCurrentXP = heroCurrentXP - [RQMob expectedExperiencePointTotalGivenLevel:self.battle.hero.level-1];
	} else {
		totalXPForLevel = [RQMob expectedExperiencePointTotalGivenLevel:self.battle.hero.level];
	}
	
	CGFloat xpPercent = ((CGFloat)heroCurrentXP / totalXPForLevel);
	//CCLOG(@"hero level %i, heroCurrentXP %i, totalXPForLevel %i, xpPercent %f", self.battle.hero.level, heroCurrentXP, totalXPForLevel, xpPercent);
	
	[self.xpBarView setPercent:xpPercent duration:0.0];
	self.heroLevelLabel.text = [NSString stringWithFormat:@"Level %d", self.battle.hero.level];
	self.heroXPFractionLabel.text = [NSString stringWithFormat:@"%d/%d", 
									 heroCurrentXP, 
									 totalXPForLevel];
}

@end
