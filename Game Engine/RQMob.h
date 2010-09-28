#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

enum {
    RQElementalTypeFire = 1,
    RQElementalTypeWater = 2,
    RQElementalTypeEarth = 3,
    RQElementalTypeAir = 4,
};
typedef NSUInteger RQElementalType;

@interface RQMob : NSManagedObject 
{

}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *currentHPAsNumber;
@property (nonatomic, retain) NSNumber *levelAsNumber;
@property (nonatomic, retain) NSNumber *experiencePointsAsNumber;
@property (nonatomic, retain) NSNumber *staminaAsNumber;
@property (nonatomic, retain) NSNumber *staminaRegenRateAsNumber;
@property (nonatomic, retain) NSNumber *secondsLeftOfShieldsAsNumber;

@property (readwrite, assign) NSInteger currentHP;
@property (readonly, assign) NSInteger maxHP;
@property (readwrite, assign) NSInteger level;
@property (readwrite, assign) NSInteger experiencePoints;
@property (readwrite, assign) float stamina;
@property (readwrite, assign) float staminaRegenRate;
@property (readwrite, assign) NSInteger secondsLeftOfShields;

- (NSInteger)randomAttackValueAgainstMob:(RQMob *)mob;

+ (NSInteger)experinceNeededToLevelFromLevel:(NSInteger)level;
- (NSInteger)experiencePointsWorth;
- (BOOL)increaseLevelIfNeeded;
+ (NSInteger)expectedLevelGivenExperiencePointTotal:(NSInteger)total;
- (NSInteger)baseAttackPower;

- (NSArray *)weapons;

@end
