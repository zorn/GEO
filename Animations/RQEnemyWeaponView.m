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

@synthesize type;

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
	// based on type use a different color
	UIColor *typeColor = [UIColor orangeColor];
	if (self.type == RQElementalTypeFire) {
		NSLog(@"using red color");
		typeColor = [UIColor redColor];
	} else if (self.type == RQElementalTypeWater) {
		NSLog(@"using blue color");
		typeColor = [UIColor blueColor];
	} else if (self.type == RQElementalTypeEarth) {
		NSLog(@"using green color");
		typeColor = [UIColor greenColor];
	} else if (self.type == RQElementalTypeAir) {
		NSLog(@"using gray color");
		typeColor = [UIColor colorWithRed:0.720 green:0.889 blue:0.998 alpha:1.000];
	}
	
	
    CGFloat locations[5] = {0.0, 0.4, 0.5, 0.6, 1.0};
    NSArray *colors = [[NSArray alloc] initWithObjects:(id)[UIColor clearColor].CGColor,
                       (id)typeColor.CGColor,
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
