//
//  RQWeaponSprite.h
//  RunQuest
//
//  Created by Michael Zornek on 9/20/10.
//  Copyright 2010 Clickable Bliss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "RQSprite.h"

#define RQWeaponSpriteInnerBoxWidth 36.0

@interface RQWeaponSprite : RQSprite
{
	NSDictionary *weaponDetails;
	NSInteger stamina;
	UITouch *touch;
}

@property (readwrite, retain) NSDictionary *weaponDetails;
@property (readwrite, assign) NSInteger stamina;
@property (readwrite, retain) UITouch *touch;

@end
