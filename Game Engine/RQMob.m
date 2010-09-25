#import "RQMob.h"

@implementation RQMob

- (id)init
{
	if (self = [super init]) {
		staminaRegenRate = 3.0;
		secondsLeftOfShields = 0;
	}
	return self;
}

- (void)dealloc
{
	[name release]; name = nil;
	[super dealloc]; 
}

@synthesize name;

- (NSInteger)currentHP {
    return currentHP;
}

- (void)setCurrentHP:(NSInteger)value {
	currentHP = value;
	if (currentHP > maxHP) {
		currentHP = maxHP;
	}
	if (currentHP < 0) {
		currentHP = 0;
	}
}

@synthesize maxHP;
@synthesize level;
@synthesize experiencePoints;

- (float)stamina {
    return stamina;
}

- (void)setStamina:(float)value {
	stamina = value;
	if (stamina > 1.0) {
		stamina = 1.0;
	}
	if (stamina < 0.0) {
		stamina = 0.0;
	}
}

@synthesize staminaRegenRate;
@synthesize secondsLeftOfShields;

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
