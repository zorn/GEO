//
//  RQHero.m
//  RunQuest
//
//  Created by Michael Zornek on 9/25/10.
//  Copyright 2010 Clickable Bliss. All rights reserved.
//

#import "RQHero.h"


@implementation RQHero

- (void)awakeFromInsert
{
	[super awakeFromInsert];
	[self setGlovePower:50.0];
}

- (BOOL)canUseFireWeapon
{
	return YES;
}

- (BOOL)canUseWaterWeapon
{
	if (self.level >= 5) {
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)canUseEarthWeapon
{
	if (self.level >= 15) {
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)canUseAirWeapon
{
	if (self.level >= 25) {
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)canUseShields
{
	if (self.level >= 10) {
		return YES;
	} else {
		return NO;
	}
}

- (NSArray *)weapons
{
	// classical D&D elemental system
	// Air has dominance over Water.
	// Water has dominance over Fire.
	// Fire has dominance over Earth.
	// Earth has dominance over Air.
	NSMutableArray *result = [NSMutableArray array];
	if (self.canUseFireWeapon) {
		[result addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger: RQElementalTypeFire], @"type", [UIColor redColor], @"color", nil]];
	}
	if (self.canUseWaterWeapon) {
		[result addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger: RQElementalTypeWater], @"type", [UIColor blueColor], @"color", nil]];
	}
	if (self.canUseEarthWeapon) {
		[result addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger: RQElementalTypeEarth], @"type", [UIColor brownColor], @"color", nil]];
	}
	if (self.canUseAirWeapon) {
		[result addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger: RQElementalTypeAir], @"type", [UIColor lightGrayColor], @"color", nil]];
	}
	return [NSArray arrayWithArray:result];
}

@end
