#import <Foundation/Foundation.h>

@interface RQMob : NSObject 
{
	NSString *name;
	NSInteger currentHP;
	NSInteger maxHP;
	NSInteger level;
	NSInteger stamina;
	float staminaRegenRate; // how many seconds it should take for the stamina to fill from 0-100
	
	NSInteger secondsLeftOfPhysicalShields;
	NSInteger secondsLeftOfMagicalShields;

}

@property (readwrite, copy) NSString *name;
@property (readwrite, assign) NSInteger currentHP;
@property (readwrite, assign) NSInteger maxHP;
@property (readwrite, assign) NSInteger level;
@property (readwrite, assign) NSInteger stamina;
@property (readwrite, assign) float staminaRegenRate;
@property (readwrite, assign) NSInteger secondsLeftOfPhysicalShields;
@property (readwrite, assign) NSInteger secondsLeftOfMagicalShields;

- (NSInteger)randomAttackValueAgainstMob:(RQMob *)mob;
- (NSInteger)randomStrongAttackValueAgainstMob:(RQMob *)mob;

@end
