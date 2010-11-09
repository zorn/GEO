#import "RQModelController.h"
#import "RQBattle.h"
#import "RQMob.h"
#import "RQHero.h"
#import "RQEnemy.h"

@implementation RQBattle

- (id)init
{
	if (self = [super init]) {
		
	}
	return self;
}

- (void)dealloc
{
	[hero release]; hero = nil;
	[enemy release]; enemy = nil;
	[super dealloc]; 
}

@synthesize hero;
@synthesize enemy;

@synthesize battleLog;

- (NSDictionary *)issueAttackCommandFrom:(RQMob *)mob withWeaponOfType:(RQElementalType)weaponType
{
	// issues an attack and returns a dictionary with results of the attack
	NSInteger attackValue;
	srandom(time(NULL));
	if ((RQMob *)mob == hero) {
		attackValue = [self.hero randomAttackValueAgainstMob:self.enemy withWeaponOfType:weaponType];
		BOOL attackWasStrong = NO;
		if ([self.enemy weakToType] == weaponType) {
			attackWasStrong = YES;
		}
		// apply glove power to attackValue
		NSLog(@"orig: attackValue %i", attackValue); 
		attackValue = lroundf(attackValue * (1.0 + (self.hero.glovePower/100.0)));
		NSLog(@"new: attackValue %i", attackValue); 
		NSLog(@"glovePower: %i", self.hero.glovePower); 
		[self.enemy setCurrentHP:self.enemy.currentHP - attackValue];
		self.hero.stamina = 0.0;
		[self appendToBattleLog:[NSString stringWithFormat:@"%@ hits %@ with a normal attack for %i.", self.hero.name, self.enemy.name, attackValue]];
		return [NSDictionary dictionaryWithObjectsAndKeys:@"hit", @"status", [NSNumber numberWithInteger:attackValue], @"attackValue", [NSNumber numberWithBool:attackWasStrong], @"attackWasStrong", nil];
	} else if (mob == enemy) {
		attackValue = [self.enemy randomAttackValueAgainstMob:self.hero withWeaponOfType:weaponType];
		// If hero has sheids half the attack
		if (self.hero.secondsLeftOfShields > 0) {
			NSLog(@"halving attack value from sheilds from: %i", attackValue);
			attackValue = round(attackValue / 2);
			NSLog(@"new attack value: %i", attackValue);
		}
		[self.hero setCurrentHP:self.hero.currentHP - attackValue];
		[self.enemy setStamina:0.0];
		[self appendToBattleLog:[NSString stringWithFormat:@"%@ hits %@ with a normal attack for %i.", self.enemy.name, self.hero.name, attackValue]];
		return [NSDictionary dictionaryWithObjectsAndKeys:@"hit", @"status", [NSNumber numberWithInteger:attackValue], @"attackValue", [NSNumber numberWithBool:NO], @"attackWasStrong", nil];
	}
	
	// failure
	NSLog(@"ERROR: issueAttackCommandFrom mob but mob %@ is not in the battle %@.", mob, self);
	return [NSDictionary dictionaryWithObjectsAndKeys:@"error", @"status", [NSNumber numberWithInteger:0], @"attackValue", nil];
}

- (void)issueShieldCommandFrom:(RQMob *)mob
{
	if (mob == hero || mob == enemy) {
		[mob setSecondsLeftOfShields:RQBattleShieldLengthInSeconds];
	} else {
		NSLog(@"ERROR: issuePhysicalShieldCommandFrom mob but mob %@ is not in the battle %@.", mob, self);
	}
}

- (void)updateCombatantStaminaBasedOnTimeDelta:(NSTimeInterval)timeDelta
{
	//NSLog(@"updateCombatantStaminaBasedOnTimeDelta");
	float howMuchStaminaTheHeroWouldGainInAFullSecond = 1.0 / self.hero.staminaRegenRate;
	float oneFrameWorthForTheHero = timeDelta * howMuchStaminaTheHeroWouldGainInAFullSecond;
	[self.hero setStamina:self.hero.stamina + oneFrameWorthForTheHero];
	
	float howMuchStaminaTheEnemyWouldGainInAFullSecond = 1.0 / self.enemy.staminaRegenRate;
	float oneFrameWorthForTheEnemy = timeDelta * howMuchStaminaTheEnemyWouldGainInAFullSecond;
	[self.enemy setStamina:self.enemy.stamina + oneFrameWorthForTheEnemy];
}

- (void)updateHeroShieldsBasedOnTimeDelta:(NSTimeInterval)timeDelta
{
	if (self.hero.secondsLeftOfShields > 0.0) {
		float newShieldTime = self.hero.secondsLeftOfShields - timeDelta;
		if (newShieldTime < 0) {
			[self.hero setSecondsLeftOfShields:0.0];
		} else {
			[self.hero setSecondsLeftOfShields:newShieldTime];
		}
	}
}

- (void)appendToBattleLog:(NSString *)logAddition
{
	NSLog(@"%@", logAddition);
	[self setBattleLog:[self.battleLog stringByAppendingFormat:@"%@\n",logAddition]]; 
}

- (BOOL)isBattleDone
{
	if (self.enemy.currentHP == 0 || self.hero.currentHP == 0) {
		return YES;
	} else {
		return NO;
	}
}

- (void)issueBattleResults
{
	// if the winner was the hero issue him experience points
	
	// if the hero lost, take experience points away
	
}

- (BOOL)didHeroWin
{
	if (self.hero.currentHP > 0 && self.isBattleDone) {
		return YES;
	} else {
		return NO;
	}
}

@end
