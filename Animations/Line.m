//
//  Line.m
//  TouchTracker
//
//  Created by Alex Silverman on 7/28/09.
//  Copyright 2009 Big Nerd Ranch. All rights reserved.
//

#import "Line.h"


@implementation Line

@synthesize begin, end;

- (float)width
{
	CGFloat deltaX = end.x - begin.x;
	CGFloat deltaY = end.y - begin.y;
	return sqrtf(deltaX*deltaX + deltaY*deltaY );
}

@end
