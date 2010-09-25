#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#define RQBattleFrameRate 30
#define RQBattleShieldLengthInSeconds 9

@class RQMob;
@class RQHero;
@class RQEnemy;

@interface RQBattle : NSObject 
{
	RQHero *hero;
	RQEnemy *enemy;
	
	AVAudioPlayer *hitSoundEffectPlayer;
	
	NSString *battleLog;
}

@property (readwrite, retain) RQHero *hero;
@property (readwrite, retain) RQEnemy *enemy;

@property (readwrite, copy) NSString *battleLog;

- (NSDictionary *)issueAttackCommandFrom:(RQMob *)mob;
- (void)issueShieldCommandFrom:(RQMob *)mob;

- (void)updateCombatantStaminaBasedOnTimeDelta:(NSTimeInterval)timeDelta;
- (void)runEnemyAI;

- (void)appendToBattleLog:(NSString *)logAddition;
- (BOOL)isBattleDone;

@end
