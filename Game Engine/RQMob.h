#import <Foundation/Foundation.h>

@interface RQMob : NSObject 
{
	NSString *name;
	NSInteger currentHP;
	NSInteger maxHP;
	NSInteger level;
	NSInteger experiencePoints;
	float stamina; // 0.0 to 1.0 .. 1.0 is full
	float staminaRegenRate; // 1.75 is to say it should take to 1.75 seconds to reach full stamina
	
	NSInteger secondsLeftOfPhysicalShields;
	NSInteger secondsLeftOfMagicalShields;

}

@property (readwrite, copy) NSString *name;
@property (readwrite, assign) NSInteger currentHP;
@property (readwrite, assign) NSInteger maxHP;
@property (readwrite, assign) NSInteger level;
@property (readwrite, assign) NSInteger experiencePoints;
@property (readwrite, assign) float stamina;
@property (readwrite, assign) float staminaRegenRate;
@property (readwrite, assign) NSInteger secondsLeftOfPhysicalShields;
@property (readwrite, assign) NSInteger secondsLeftOfMagicalShields;

- (NSInteger)randomAttackValueAgainstMob:(RQMob *)mob;
- (NSInteger)randomStrongAttackValueAgainstMob:(RQMob *)mob;

+ (NSInteger)experinceNeedToLevelFromLevel:(NSInteger)level;

- (NSArray *)weapons;

@end
