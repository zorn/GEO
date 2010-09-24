#import "RQBattle.h"
#import "RQMob.h"

@implementation RQBattle

- (id)init
{
	if (self = [super init]) {
		
		// hard coding battle for now
		
		RQMob *newMob;
		
		newMob = [[RQMob alloc] init];
		[newMob setName:@"Hero Mike"];
		[newMob setMaxHP:30];
		[newMob setCurrentHP:30];
		[newMob setLevel:5];
		[newMob setStamina:0];
		[self setHero:newMob];
		[newMob release]; newMob = nil;
		
		newMob = [[RQMob alloc] init];
		[newMob setName:@"Evil Snorlax"];
		[newMob setMaxHP:25];
		[newMob setCurrentHP:25];
		[newMob setLevel:3];
		[newMob setStamina:0];
		[newMob setStaminaRegenRate:8.0];
		[self setEnemy:newMob];
		[newMob release]; newMob = nil;
		
//		NSString *pathToHitSoundEffectPlayer = [[NSBundle mainBundle] pathForResource:@"Critical_Hit" ofType:@"m4a"];
//		hitSoundEffectPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:pathToHitSoundEffectPlayer] error:NULL];
//		[hitSoundEffectPlayer prepareToPlay];
		//[hitSoundEffectPlayer setDelegate:self];
		
		[self setBattleLog:[NSString stringWithFormat:@"Battle started at: %@\n", [NSDate date]]];
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

- (NSDictionary *)issueAttackCommandFrom:(RQMob *)mob
{
	// issues an attack and returns a dictionary with results of the attack
	NSInteger attackValue;
	srandom(time(NULL));
	if (mob == hero) {
		attackValue = [self.hero randomAttackValueAgainstMob:self.enemy];
//		if (self.hero.stamina < 100) {
//			// if the stamina wasn't full the attack value is decreased
//			if (rand() % 100 > 40.0) {
//				attackValue = floor(attackValue / (2 + (rand() % 10)))+1;
//			} else {
//				self.hero.stamina = 0;
//				[self appendToBattleLog:[NSString stringWithFormat:@"%@'s attack missed!", self.hero.name]];
//				return [NSDictionary dictionaryWithObjectsAndKeys:@"miss", @"status", [NSNumber numberWithInteger:0], @"attackValue", nil];
//			}
//		}
		[self.enemy setCurrentHP:self.enemy.currentHP - attackValue];
		[hitSoundEffectPlayer play];
		self.hero.stamina = 0;
		[self appendToBattleLog:[NSString stringWithFormat:@"%@ hits %@ with a normal attack for %i.", self.hero.name, self.enemy.name, attackValue]];
		return [NSDictionary dictionaryWithObjectsAndKeys:@"hit", @"status", [NSNumber numberWithInteger:attackValue], @"attackValue", nil];
	} else if (mob == enemy) {
		attackValue = [self.enemy randomAttackValueAgainstMob:self.hero];
		[self.hero setCurrentHP:self.hero.currentHP - attackValue];
		self.enemy.stamina = 0;
		[self appendToBattleLog:[NSString stringWithFormat:@"%@ hits %@ with a normal attack for %i.", self.enemy.name, self.hero.name, attackValue]];
		return [NSDictionary dictionaryWithObjectsAndKeys:@"hit", @"status", [NSNumber numberWithInteger:attackValue], @"attackValue", nil];
	}
	
	// failure
	NSLog(@"ERROR: issueAttackCommandFrom mob but mob %@ is not in the battle %@.", mob, self);
	return [NSDictionary dictionaryWithObjectsAndKeys:@"error", @"status", [NSNumber numberWithInteger:0], @"attackValue", nil];
}

- (void)issuePhysicalShieldCommandFrom:(RQMob *)mob
{
	if (mob == hero || mob == enemy) {
		[mob setSecondsLeftOfPhysicalShields:RQBattleShieldLengthInSeconds];
	} else {
		NSLog(@"ERROR: issuePhysicalShieldCommandFrom mob but mob %@ is not in the battle %@.", mob, self);
	}
}

- (void)issueMagicalShieldCommandFrom:(RQMob *)mob
{
	if (mob == hero || mob == enemy) {
		[mob setSecondsLeftOfMagicalShields:RQBattleShieldLengthInSeconds];
	} else {
		NSLog(@"ERROR: issueMagicalShieldCommandFrom mob but mob %@ is not in the battle %@.", mob, self);
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

- (void)runEnemyAI
{
	if (self.enemy.stamina == 100) {
		[self issueAttackCommandFrom:self.enemy];
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

@end
