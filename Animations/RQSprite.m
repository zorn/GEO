//
//  RQSprite.m
//  FlickSample
//
//  Created by Nome on 9/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RQSprite.h"

#define SAMPLE_SIZE 3

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
		samples = 0;
		positions = malloc( sizeof(CGPoint) * SAMPLE_SIZE);
		times = malloc(sizeof(CFTimeInterval)*SAMPLE_SIZE);
		pthread_rwlock_init(&rwLock, NULL);
    }
    return self;
}


- (void)dealloc {
	pthread_rwlock_destroy(&rwLock);
	free(positions);
	free(times);
	[view release];
	[super dealloc];
}

- (CGPoint)averageVelocity {
	
	if ( samples > 1 ) {
		pthread_rwlock_rdlock(&rwLock);
		CFTimeInterval time =  times[samples - 1] - times[0];
		CGPoint oldPoint = positions[0];
		CGPoint newPoint = positions[samples - 1];
		CGFloat deltaX = newPoint.x - oldPoint.x;
		CGFloat deltaY = newPoint.y - oldPoint.y;
		pthread_rwlock_unlock(&rwLock);
		if ( time > 0 )
			return CGPointMake(deltaX/time, deltaY/time);
		else
			return CGPointZero;
	}
	else {
		return CGPointZero;
	}
}
- (void)setVelocity:(CGPoint)velo {
	pthread_rwlock_wrlock(&rwLock);
	samples = 0;
	velocity = velo;
	pthread_rwlock_unlock(&rwLock);
}

- (void)setPosition:(CGPoint)pos atTime:(CFTimeInterval)time {
	pthread_rwlock_wrlock(&rwLock);
	if ( samples < SAMPLE_SIZE ) {
		positions[samples] = pos;
		times[samples] = time;
		samples++;
	}
	else {
		for ( NSUInteger i = 1; i < samples; i++ ) {
			positions[i - 1] = positions[i];
			times[i - 1] = times[i];
		}
		positions[samples - 1] = pos;
		times[samples - 1] = time;
	}
	pthread_rwlock_unlock(&rwLock);
	[self setPosition:pos];
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
