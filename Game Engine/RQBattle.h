#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#define RQBattleFrameRate 30
#define RQBattleShieldLengthInSeconds 9

@class RQMob;

@interface RQBattle : NSObject 
{
	RQMob *hero;
	RQMob *enemy;
	
	AVAudioPlayer *hitSoundEffectPlayer;
	
	NSString *battleLog;
}

@property (readwrite, retain) RQMob *hero;
@property (readwrite, retain) RQMob *enemy;

@property (readwrite, copy) NSString *battleLog;

- (NSDictionary *)issueAttackCommandFrom:(RQMob *)mob;
- (void)issuePhysicalShieldCommandFrom:(RQMob *)mob;
- (void)issueMagicalShieldCommandFrom:(RQMob *)mob;

- (void)updateCombatantStamina;
- (void)runEnemyAI;

- (void)appendToBattleLog:(NSString *)logAddition;
- (BOOL)isBattleDone;

@end
