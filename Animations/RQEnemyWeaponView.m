//
//  RQEnemyWeaponView.m
//  RunQuest
//
//  Created by Matthew Thomas on 10/31/10.
//  Copyright (c) 2010 Code/Caffeine. All rights reserved.
//

#import "RQEnemyWeaponView.h"


@implementation RQEnemyWeaponView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat locations[5] = {0.0, 0.4, 0.5, 0.6, 1.0};
    NSArray *colors = [[NSArray alloc] initWithObjects:(id)[UIColor clearColor].CGColor,
                       (id)[UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:0.5].CGColor,
                       (id)[UIColor greenColor].CGColor,
                       (id)[UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:0.5].CGColor,
                       (id)[UIColor clearColor].CGColor, nil];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)colors, locations);
    [colors release];
    CGColorSpaceRelease(colorSpace);
    
    CGPoint startPoint, endPoint;
    CGFloat startRadius, endRadius;
    startPoint.x = roundf(rect.size.width / 2.0);
    startPoint.y = roundf(rect.size.width / 2.0);
    endPoint.x = roundf(rect.size.width / 2.0);
    endPoint.y = roundf(rect.size.width / 2.0);
    startRadius = 0.0;
    endRadius = roundf(rect.size.width / 2.0);
    CGContextDrawRadialGradient(context, gradient, startPoint, startRadius, endPoint, endRadius, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
}


- (void)dealloc {
    [super dealloc];
}


@end
