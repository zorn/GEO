//
//  RQEnemySprite.h
//  RunQuest
//
//  Created by Matthew Thomas on 9/18/10.
//  Copyright (c) 2010 Code/Caffeine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "RQSprite.h"

@class RQBarView;

@interface RQEnemySprite : RQSprite
{
}
@property (nonatomic, assign) BOOL invincible;
- (void)hitWithText:(NSString *)hitText;
- (void)strongHitAnimation;
- (void)runDeathAnimation;
- (void)setPercent:(CGFloat)percent duration:(CGFloat)duration;

@end
