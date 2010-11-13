//
//  EnemyAnnotationLayer.m
//  RunQuest
//
//  Created by Joe Walsh on 9/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EnemyAnnotationLayer.h"


@implementation EnemyAnnotationLayer


-(void) drawInContext:(CGContextRef)context {
	CGRect rect = self.bounds;
	CGContextSetRGBFillColor(context, 1., 0, 0, .5);
	CGContextFillEllipseInRect(context, rect);
}


@end
