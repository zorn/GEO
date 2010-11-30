//
//  RQHero.h
//  RunQuest
//
//  Created by Michael Zornek on 9/25/10.
//  Copyright 2010 Clickable Bliss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RQMob.h"

@interface RQHero : RQMob {

}

- (BOOL)canUseFireWeapon;
- (BOOL)canUseWaterWeapon;
- (BOOL)canUseEarthWeapon;
- (BOOL)canUseAirWeapon;
- (BOOL)canUseShields;

- (NSArray *)weapons;

- (BOOL)isLevelCapped;

@end
