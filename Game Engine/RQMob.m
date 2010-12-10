#import <UIKit/UIKit.h> // for UIColor
#import "RQMob.h"
#import "RQConstants.h"

@implementation RQMob

- (void)awakeFromInsert
{
	[super awakeFromInsert];
	[self setLevel:1];
	
	// mirror the stuff from fetch
	[self setStaminaRegenRate:3.0];
	[self setSecondsLeftOfShields:0];
	[self setStamina:0];
}

- (void)awakeFromFetch
{
	[super awakeFromFetch];
	[self setStaminaRegenRate:3.0];
	[self setSecondsLeftOfShields:0];
	[self setStamina:0];
}

@dynamic name;
@dynamic spriteImageName;
@dynamic currentHPAsNumber;
@dynamic levelAsNumber;
@dynamic typeAsNumber;
@dynamic experiencePointsAsNumber;
@dynamic staminaAsNumber;
@dynamic staminaRegenRateAsNumber;
@dynamic secondsLeftOfShieldsAsNumber;
@dynamic glovePowerAsNumber;

- (NSInteger)currentHP {
    return [self.currentHPAsNumber integerValue];
}

- (void)setCurrentHP:(NSInteger)value {
	if (value > self.maxHP) {
		[self setCurrentHPAsNumber:[NSNumber numberWithInteger:self.maxHP]];
	}else if (value <= 0) {
		[self setCurrentHPAsNumber:[NSNumber numberWithInteger:0]];
	} else {
		[self setCurrentHPAsNumber:[NSNumber numberWithInteger:value]];
	}
}

- (NSInteger)maxHP {
	if ([self.name isEqualToString:@"Dr. Gordon"]) {
		return ((4*self.level)+1)*4*10;
	} else {
		return ((4*self.level)+1)*4;
	}
}

- (NSInteger)level {
    return [self.levelAsNumber integerValue];
}

- (void)setLevel:(NSInteger)value {
	[self setLevelAsNumber:[NSNumber numberWithInteger:value]];
}

- (RQElementalType)type {
	RQElementalType answer;
	switch ([self.typeAsNumber integerValue]) {
		case RQElementalTypeFire:
			answer = RQElementalTypeFire;
			break;
		case RQElementalTypeWater:
			answer = RQElementalTypeWater;
			break;
		case RQElementalTypeEarth:
			answer = RQElementalTypeWater;
			break;
		case RQElementalTypeAir:
			answer = RQElementalTypeAir;
			break;
	}
	return answer;
}

- (void)setType:(RQElementalType)value {
	[self setTypeAsNumber:[NSNumber numberWithInteger:value]];
}

- (NSInteger)experiencePoints {
    return [self.experiencePointsAsNumber integerValue];
}

- (void)setExperiencePoints:(NSInteger)value {
	[self setExperiencePointsAsNumber:[NSNumber numberWithInteger:value]];
}

- (float)stamina {
    return [self.staminaAsNumber floatValue];
}

- (void)setStamina:(float)value {
	if (value >= 1.0) {
		[self setStaminaAsNumber:[NSNumber numberWithFloat:1.0]];
	} else if (value <= 0.0) {
		[self setStaminaAsNumber:[NSNumber numberWithFloat:0.0]];
	} else {
		[self setStaminaAsNumber:[NSNumber numberWithFloat:value]];
	}
}

- (float)staminaRegenRate {
    return [self.staminaRegenRateAsNumber floatValue];
}

- (void)setStaminaRegenRate:(float)value {
	[self setStaminaRegenRateAsNumber:[NSNumber numberWithFloat:value]];
}

- (float)secondsLeftOfShields {
    return [self.secondsLeftOfShieldsAsNumber floatValue];
}

- (void)setSecondsLeftOfShields:(float)value {
	[self setSecondsLeftOfShieldsAsNumber:[NSNumber numberWithFloat:value]];
}

- (NSInteger)glovePower {
	return [self.glovePowerAsNumber integerValue];
}

- (void)setGlovePower:(NSInteger)value {
	if (value >= 100) {
		[self setGlovePowerAsNumber:[NSNumber numberWithInteger:100]];
	} else if (value <= 0) {
		[self setGlovePowerAsNumber:[NSNumber numberWithInteger:0]];
	} else {
		[self setGlovePowerAsNumber:[NSNumber numberWithInteger:value]];
	}
}

- (NSInteger)randomAttackValueAgainstMob:(RQMob *)mob withWeaponOfType:(RQElementalType)weaponType
{
	// baseAttack power * rand(.5 - 1.5) * stamina effect .. when stam is full it is 1.0
//	float randomAttackPower = self.baseAttackPower * ((((rand()%11)+5.0)/10.0));
	float randomAttackPower = self.baseAttackPower; // no more random addtion
	float staminaEffect = pow(self.stamina, 3.0);
	float weaponEffect = 1.0;
	if ([mob weakToType] == weaponType) {
		weaponEffect = 2.0;
	} else if ([mob strongToType] == weaponType) {
		weaponEffect = 0.5;
	}
	NSInteger result = lroundf(randomAttackPower * staminaEffect * weaponEffect);
	CCLOG(@"randomAttackPower %f * staminaEffect %f * weaponEffect %f = %d", randomAttackPower, staminaEffect, weaponEffect, result);
	return result;
}

+ (NSInteger)experinceNeededToLevelFromLevel:(NSInteger)level
{
	return pow(level,3);
}

- (NSInteger)experiencePointsWorth
{
	// returns the number of xp a monster of self.level will give to the hero upon defeat
	NSInteger a = [RQMob experinceNeededToLevelFromLevel:[self level]];
	NSInteger l = [self level];
	return (a/l)*4;
}

- (BOOL)increaseLevelIfNeeded
{
	NSInteger expectedLevel = [RQMob expectedLevelGivenExperiencePointTotal:self.experiencePoints];
	if (expectedLevel > self.level) {
		self.level = expectedLevel;
		return YES;
	} else {
		return NO;
	}
}

+ (NSInteger)expectedLevelGivenExperiencePointTotal:(NSInteger)total
{
	NSInteger calcTotal = 0;
	for (int i = 1; i < 51; i++) {
		calcTotal = calcTotal + [RQMob experinceNeededToLevelFromLevel:i];
		//NSLog(@"calcTotal %d, total %d", calcTotal, total);
		if (total - calcTotal <= 0) {
			//NSLog(@"expectedLevel is %d givenExperiencePointTotal: %d", i, total);
			return i;
		} 
	}
	return -1;
}

+ (NSInteger)expectedExperiencePointTotalGivenLevel:(NSInteger)someLevel
{
	NSInteger XPTotal = 0;
	for (int i = 1; i < someLevel+1; i++) {
		XPTotal = XPTotal + [RQMob experinceNeededToLevelFromLevel:i];
	}
	return XPTotal;
}

- (NSInteger)baseAttackPower
{
	if ([self.name isEqualToString:@"Dr. Gordon"]) {
		return lroundf((self.maxHP/10) / 5);
	} else {
		return lroundf(self.maxHP / 5);
	}	
}


- (RQElementalType)weakToType
{
	RQElementalType answer = 0;
		switch ([self.typeAsNumber integerValue]) {
			case RQElementalTypeFire:
				answer = RQElementalTypeWater;
				break;
			case RQElementalTypeWater:
				answer = RQElementalTypeAir;
				break;
			case RQElementalTypeEarth:
				answer = RQElementalTypeFire;
				break;
			case RQElementalTypeAir:
				answer = RQElementalTypeEarth;
				break;
		}
	return answer;
}

- (RQElementalType)strongToType
{
	RQElementalType answer = 0;
	switch ([self.typeAsNumber integerValue]) {
		case RQElementalTypeWater:
			answer = RQElementalTypeFire;
			break;
		case RQElementalTypeAir:
			answer = RQElementalTypeWater;
			break;
		case RQElementalTypeFire:
			answer = RQElementalTypeEarth;
			break;
		case RQElementalTypeEarth:
			answer = RQElementalTypeAir;
			break;
	}
	return answer;
}

@end
