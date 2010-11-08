#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "RQMob.h"

#define RQBattleFrameRate 30
#define RQBattleShieldLengthInSeconds 9

@class RQHero;
@class RQEnemy;

@interface RQBattle : NSObject 
{
	RQHero *hero;
	RQEnemy *enemy;
		
	NSString *battleLog;
}

@property (readwrite, retain) RQHero *hero;
@property (readwrite, retain) RQEnemy *enemy;

@property (readwrite, copy) NSString *battleLog;

- (NSDictionary *)issueAttackCommandFrom:(RQMob *)mob withWeaponOfType:(RQElementalType)weaponType;
- (void)issueShieldCommandFrom:(RQMob *)mob;

- (void)updateCombatantStaminaBasedOnTimeDelta:(NSTimeInterval)timeDelta;
- (void)updateHeroShieldsBasedOnTimeDelta:(NSTimeInterval)timeDelta;

- (void)appendToBattleLog:(NSString *)logAddition;
- (BOOL)isBattleDone;

- (void)issueBattleResults;
- (BOOL)didHeroWin;

@end
