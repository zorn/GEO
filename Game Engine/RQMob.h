#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

enum {
    RQElementalTypeNone = 0,
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
@property (nonatomic, retain) NSString *spriteImageName;
@property (nonatomic, retain) NSNumber *currentHPAsNumber;
@property (nonatomic, retain) NSNumber *levelAsNumber;
@property (nonatomic, retain) NSNumber *typeAsNumber;
@property (nonatomic, retain) NSNumber *experiencePointsAsNumber;
@property (nonatomic, retain) NSNumber *staminaAsNumber;
@property (nonatomic, retain) NSNumber *staminaRegenRateAsNumber;
@property (nonatomic, retain) NSNumber *secondsLeftOfShieldsAsNumber;
@property (nonatomic, retain) NSNumber *glovePowerAsNumber;

@property (readwrite, assign) NSInteger currentHP;
@property (readonly, assign) NSInteger maxHP;
@property (readwrite, assign) NSInteger level;
@property (readwrite, assign) RQElementalType type;
@property (readwrite, assign) NSInteger experiencePoints;
@property (readwrite, assign) float stamina;
@property (readwrite, assign) float staminaRegenRate;
@property (readwrite, assign) float secondsLeftOfShields;
@property (readwrite, assign) NSInteger glovePower;

- (NSInteger)randomAttackValueAgainstMob:(RQMob *)mob withWeaponOfType:(RQElementalType)weaponType;

+ (NSInteger)experinceNeededToLevelFromLevel:(NSInteger)level;
- (NSInteger)experiencePointsWorth;
- (BOOL)increaseLevelIfNeeded;
+ (NSInteger)expectedLevelGivenExperiencePointTotal:(NSInteger)total;
+ (NSInteger)expectedExperiencePointTotalGivenLevel:(NSInteger)someLevel;
- (NSInteger)baseAttackPower;

- (RQElementalType)weakToType;
- (RQElementalType)strongToType;

@end
