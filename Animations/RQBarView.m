//
//  RQBarView.m
//  AnimationTechDemo
//
//  Created by Matthew Thomas on 9/13/10.
//  Copyright 2010 Matthew Thomas. All rights reserved.
//

#import "RQBarView.h"


@interface RQBarView ()
@property (nonatomic, retain) CALayer *percentLayer;
- (void)initialization;
@end


@implementation RQBarView
@dynamic percent;
@synthesize barColor;
@synthesize percentLayer;


- (id) initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self initialization];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
		[self initialization];
    }
    return self;
}


- (void)initialization
{
	// Initialization code
	CGColorRef color = [UIColor greenColor].CGColor;
	
	percentLayer = [[CALayer alloc] init];
	percentLayer.backgroundColor = color;
	percentLayer.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
	[self.layer addSublayer:percentLayer];
	
	self.layer.delegate = self;
	self.layer.borderWidth = 2;
	self.layer.borderColor = color;
	self.layer.cornerRadius = self.frame.size.height / 2.0;
	self.layer.masksToBounds = YES;
	self.layer.backgroundColor = [UIColor blackColor].CGColor;
	
	percent = 1.0f;	
}


- (void)dealloc {
	[barColor release];
    [super dealloc];
}

- (void)setPercent:(float)aPercent duration:(CFTimeInterval)duration {
	if (self.barColor) {
		self.percentLayer.backgroundColor = self.barColor.CGColor;
		self.layer.borderColor = self.barColor.CGColor;
	}
	else {
		CGFloat red = MIN(1.0, ((1.0f - aPercent) * 2));
		CGFloat green = MIN(1.0, aPercent * 2.0);
		CGColorRef color = [UIColor colorWithRed:red green:green blue:0.0f alpha:1.0f].CGColor;
		self.percentLayer.backgroundColor = color;
		self.layer.borderColor = color;		
	}
	
	// only animate when the duration is greater than zero
	if (duration > 0) {
		CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"frame.size.width"];
		anim.fromValue = [NSNumber numberWithFloat:self.percent];
		anim.toValue = [NSNumber numberWithFloat:aPercent];
		anim.duration = duration;
		[self.percentLayer addAnimation:anim forKey:@"frame.size.width"];
	}
	self.percent = aPercent;
}


- (void)setPercent:(float)aPercent {
	percent = aPercent;
	CGRect percentFrame = self.percentLayer.frame;
	percentFrame.size.width = self.frame.size.width * MIN(aPercent, 1.0);
	self.percentLayer.frame = percentFrame;
}


- (float)percent {
	return percent;
}


@end
