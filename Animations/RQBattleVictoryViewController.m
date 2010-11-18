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

// models
#import "RQModelController.h"
#import "RQMentorMessageTemplate.h"

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
@synthesize mentorMessageTextView;
@synthesize mentorAvatarImageView;


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
	[mentorMessageTextView release];
	[mentorAvatarImageView release];
	
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
	NSLog(@"RQBattleVictoryViewController -viewDidLoad");
	
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
	[self.mentorMessageTextView setText:mentorMessage.message];
	
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
	if (experienceGained > 0) {
		if (jumpToLastFrame == YES) {
			self.battle.hero.experiencePoints = self.battle.hero.experiencePoints + experienceGained;
			experienceGained = 0;
		} else {
			
			experienceGained = experienceGained - experienceCountByAmount;
			self.battle.hero.experiencePoints = self.battle.hero.experiencePoints + experienceCountByAmount;
		}
		
		[[SimpleAudioEngine sharedEngine] playEffect:@"Coin.wav"];
		if ([self.battle.hero increaseLevelIfNeeded]) {
			NSLog(@"newLevel: %d", self.battle.hero.level);
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
	//NSLog(@"hero level %i, heroCurrentXP %i, totalXPForLevel %i, xpPercent %f", self.battle.hero.level, heroCurrentXP, totalXPForLevel, xpPercent);
	
	[self.xpBarView setPercent:xpPercent duration:0.0];
	self.heroLevelLabel.text = [NSString stringWithFormat:@"Level %d", self.battle.hero.level];
	self.heroXPFractionLabel.text = [NSString stringWithFormat:@"%d/%d", 
									 heroCurrentXP, 
									 totalXPForLevel];
}

@end
