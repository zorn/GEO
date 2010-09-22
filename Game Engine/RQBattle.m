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
		[self setHero:newMob];
		[newMob release]; newMob = nil;
		
		newMob = [[RQMob alloc] init];
		[newMob setName:@"Evil Snorlax"];
		[newMob setMaxHP:25];
		[newMob setCurrentHP:25];
		[newMob setLevel:3];
		[self setEnemy:newMob];
		[newMob release]; newMob = nil;
		
		NSString *pathToHitSoundEffectPlayer = [[NSBundle mainBundle] pathForResource:@"Critical_Hit" ofType:@"m4a"];
		hitSoundEffectPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:pathToHitSoundEffectPlayer] error:NULL];
		[hitSoundEffectPlayer prepareToPlay];
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

- (void)issueAttackCommandFrom:(RQMob *)mob
{
	NSInteger attackValue;
	srandom(time(NULL));
	if (mob == hero) {
		attackValue = [self.hero randomAttackValueAgainstMob:self.enemy];
		if (self.hero.stamina < 100) {
			// if the stamina wasn't full the attack value is decreased
			if (rand() % 100 > 40.0) {
				attackValue = floor(attackValue / (2 + (rand() % 10)))+1;
			} else {
				self.hero.stamina = 0;
				[self appendToBattleLog:[NSString stringWithFormat:@"%@'s attack missed!", self.hero.name]];
				return;
			}
		}
		[self.enemy setCurrentHP:self.enemy.currentHP - attackValue];
		[hitSoundEffectPlayer play];
		self.hero.stamina = 0;
		[self appendToBattleLog:[NSString stringWithFormat:@"%@ hits %@ with a normal attack for %i.", self.hero.name, self.enemy.name, attackValue]];
	} else if (mob == enemy) {
		attackValue = [self.enemy randomAttackValueAgainstMob:self.hero];
		[self.hero setCurrentHP:self.hero.currentHP - attackValue];
		self.enemy.stamina = 0;
		[self appendToBattleLog:[NSString stringWithFormat:@"%@ hits %@ with a normal attack for %i.", self.enemy.name, self.hero.name, attackValue]];
	} else {
		NSLog(@"ERROR: issueAttackCommandFrom mob but mob %@ is not in the battle %@.", mob, self);
	}
}

- (void)issueStrongAttackCommandFrom:(RQMob *)mob
{
	if (mob == hero) {
		self.hero.stamina = 0; 
	} else if (mob == enemy) {
		
	} else {
		NSLog(@"ERROR: issueStrongAttackCommandFrom mob but mob %@ is not in the battle %@.", mob, self);
	}
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

- (void)updateCombatantStamina
{
	float howMuchStaminaTheHeroWouldGainInAFullSecond = 100 / self.hero.staminaRegenRate;
	NSInteger oneFrameWorthForTheHero = floor(howMuchStaminaTheHeroWouldGainInAFullSecond / RQBattleFrameRate);
	[self.hero setStamina:self.hero.stamina + oneFrameWorthForTheHero];
	
	float howMuchStaminaTheEnemyWouldGainInAFullSecond = 100 / self.enemy.staminaRegenRate;
	NSInteger oneFrameWorthForTheEnemy = floor(howMuchStaminaTheEnemyWouldGainInAFullSecond / RQBattleFrameRate);
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


@end
