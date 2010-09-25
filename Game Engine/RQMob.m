#import <UIKit/UIKit.h> // for UIColor
#import "RQMob.h"

@implementation RQMob

- (void)awakeFromFetch
{
	[self setStaminaRegenRate:3.0];
	[self setSecondsLeftOfShields:0];
}

@dynamic name;
@dynamic currentHPAsNumber;
@dynamic maxHPAsNumber;
@dynamic levelAsNumber;
@dynamic experiencePointsAsNumber;
@dynamic staminaAsNumber;
@dynamic staminaRegenRateAsNumber;
@dynamic secondsLeftOfShieldsAsNumber;

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
    return [self.maxHPAsNumber integerValue];
}

- (void)setMaxHP:(NSInteger)value {
	[self setMaxHPAsNumber:[NSNumber numberWithInteger:value]];
}

- (NSInteger)level {
    return [self.levelAsNumber integerValue];
}

- (void)setLevel:(NSInteger)value {
	[self setLevelAsNumber:[NSNumber numberWithInteger:value]];
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
	if (value > 1.0) {
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

- (NSInteger)secondsLeftOfShields {
    return [self.secondsLeftOfShieldsAsNumber integerValue];
}

- (void)setSecondsLeftOfShields:(NSInteger)value {
	[self setSecondsLeftOfShieldsAsNumber:[NSNumber numberWithInteger:value]];
}

- (NSInteger)randomAttackValueAgainstMob:(RQMob *)mob
{
	// generate a random value to represnt an attack form self against mob
	// TODO: More interesting math
	return 5;
}

- (NSInteger)randomStrongAttackValueAgainstMob:(RQMob *)mob
{
	// generate a random value to represnt an attack form self against mob
	// TODO: More interesting math
	return [self randomAttackValueAgainstMob:mob]*2;
}

+ (NSInteger)experinceNeedToLevelFromLevel:(NSInteger)level
{
	return level^3;
}

- (NSArray *)weapons
{
	// classical D&D elemental system
	// Air has dominance over Water.
	// Water has dominance over Fire.
	// Fire has dominance over Earth.
	// Earth has dominance over Air.
	return [NSArray arrayWithObjects:
			[NSDictionary dictionaryWithObjectsAndKeys:@"fire", @"type", @"earth", @"strongTo", @"water", @"weakTo", [UIColor redColor], @"color", nil],
			[NSDictionary dictionaryWithObjectsAndKeys:@"water", @"type", @"fire", @"strongTo", @"wind", @"weakTo", [UIColor blueColor], @"color", nil],
			[NSDictionary dictionaryWithObjectsAndKeys:@"earth", @"type", @"wind", @"strongTo", @"fire", @"weakTo", [UIColor brownColor], @"color", nil],
			[NSDictionary dictionaryWithObjectsAndKeys:@"air", @"type", @"water", @"strongTo", @"earth", @"weakTo", [UIColor lightGrayColor], @"color", nil],
			nil];
}

@end
