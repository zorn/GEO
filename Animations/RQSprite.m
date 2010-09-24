//
//  RQSprite.m
//  FlickSample
//
//  Created by Nome on 9/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RQSprite.h"


@interface RQSprite ()
@property(nonatomic, retain) UIView *view;
@end

@implementation RQSprite
@synthesize fullSize, view, velocity;
@dynamic position;
@synthesize orininalPosition;

#pragma mark -
#pragma mark Setup/Teardown
- (id)initWithView:(UIView *)theView {
    if ((self = [super init])) {
        view = [theView retain];
		fullSize = theView.frame.size;
    }
    return self;
}


- (void)dealloc {
	[view release];
	[super dealloc];
}


- (void)setPosition:(CGPoint)value {
	position = value;
	self.view.center = position;
}

- (CGPoint)position {
	return position;
}

- (BOOL)isIntersectingRect:(CGRect)otherRect {
	
	if ((self.view.frame.origin.x < otherRect.origin.x + otherRect.size.width &&
		 self.view.frame.origin.x + self.view.frame.size.width > otherRect.origin.x) &&
		(self.view.frame.origin.y < otherRect.origin.y + otherRect.size.height &&
		 self.view.frame.origin.y + self.view.frame.size.height > otherRect.origin.y))
		return YES;
		
	return NO;
}


@end
