//
//  RQPassthroughView.m
//  RunQuest
//
//  Created by Matthew Thomas on 9/29/10.
//  Copyright 2010 Matthew Thomas. All rights reserved.
//

#import "RQPassthroughView.h"


@implementation RQPassthroughView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
	return NO;
}


//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//	return [super hitTest:point withEvent:event];
//}


@end
