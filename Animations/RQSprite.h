//
//  RQSprite.h
//  FlickSample
//
//  Created by Nome on 9/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <pthread.h>

@interface RQSprite : NSObject {
	
	UIView *view;
	UIView *imageView;
	CGSize fullSize;
	CGPoint position;
	CGPoint orininalPosition;
	
	CGPoint *positions;
	CFTimeInterval *times;
	NSUInteger samples;
	pthread_rwlock_t rwLock;
}

@property(nonatomic, assign) CGSize fullSize;
@property(nonatomic, assign) CGPoint position;
@property(nonatomic, assign) CGPoint orininalPosition;
@property(nonatomic, assign) CGPoint velocity;
@property(nonatomic, retain, readonly) UIView *view;
@property(nonatomic, retain, readonly) UIView *imageView;
@property(readonly) CGPoint	averageVelocity;

- (id)initWithView:(UIView *)theView;
- (BOOL)isIntersectingRect:(CGRect)otherRect;
- (void)setPosition:(CGPoint)pos atTime:(CFTimeInterval)time;

@end
