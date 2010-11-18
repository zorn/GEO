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
@synthesize barColor;
@synthesize outlineColor;
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
	outlineColor = [[UIColor colorWithRed:0.294 green:0.329 blue:0.345 alpha:1.000] retain];
	vertical = self.frame.size.height > self.frame.size.width;
	CGColorRef color = [UIColor greenColor].CGColor;
	
	percentLayer = [[CALayer alloc] init];
	percentLayer.backgroundColor = color;
	CGRect percentLayerFrame = CGRectMake(2.0, 2.0, 0.0, 0.0);
	percentLayerFrame.size.width = vertical ? (self.frame.size.width - 4.0) : 0.0;
	percentLayerFrame.size.height = vertical ? 0.0 : (self.frame.size.height - 4.0);
	percentLayer.frame = percentLayerFrame;
	[self.layer addSublayer:percentLayer];
	
	self.layer.delegate = self;
	self.layer.borderWidth = 1.0;
	self.layer.borderColor = outlineColor.CGColor;
	self.layer.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3].CGColor;
	
	percent = 1.0f;	
}


- (void)dealloc {
	[barColor release];
	[outlineColor release];
    [super dealloc];
}

- (void)setPercent:(float)aPercent duration:(CFTimeInterval)duration {
	self.layer.borderColor = outlineColor.CGColor;
	if (self.barColor) {
		self.percentLayer.backgroundColor = self.barColor.CGColor;
	}
	else {
		CGFloat red = MIN(1.0, ((1.0f - aPercent) * 2));
		CGFloat green = MIN(1.0, aPercent * 2.0);
		CGColorRef color = [UIColor colorWithRed:red green:green blue:0.0f alpha:1.0f].CGColor;
		self.percentLayer.backgroundColor = color;
		self.layer.borderColor = color;
	}
	
	percent = aPercent;
	CGRect newPercentFrame = self.percentLayer.frame;
	if (vertical) {
		newPercentFrame.origin.y = (self.frame.size.height - 4.0) - (aPercent * (self.frame.size.height - 4.0)) + 2.0;
		newPercentFrame.size.height = (self.frame.size.height - 4.0) - newPercentFrame.origin.y + 2.0;
		if (duration > 0.0) {
			CABasicAnimation *originAnim = [CABasicAnimation animationWithKeyPath:@"frame.origin.y"];
			originAnim.fromValue = [NSNumber numberWithFloat:self.percentLayer.frame.origin.y];
			originAnim.toValue = [NSNumber numberWithFloat:newPercentFrame.origin.y];
			originAnim.duration = duration;
			
			CABasicAnimation *heightAnim = [CABasicAnimation animationWithKeyPath:@"frame.size.height"];
			heightAnim.fromValue = [NSNumber numberWithFloat:self.percentLayer.frame.size.height];
			heightAnim.toValue = [NSNumber numberWithFloat:newPercentFrame.size.height];
			heightAnim.duration = duration;
			
			CAAnimationGroup *frameAnim = [CAAnimationGroup animation];
			frameAnim.animations = [NSArray arrayWithObjects:originAnim, heightAnim, nil];
			[self.percentLayer addAnimation:frameAnim forKey:@"frame.origin.y"];			
		}
	}
	else {
		newPercentFrame.size.width = (self.frame.size.width - 4.0) * MIN(aPercent, 1.0);
		if (duration > 0.0) {
			CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"frame.size.width"];
			anim.fromValue = [NSNumber numberWithFloat:self.percentLayer.frame.size.width];
			anim.toValue = [NSNumber numberWithFloat:newPercentFrame.size.width];
			anim.duration = duration;
			[self.percentLayer addAnimation:anim forKey:@"frame.size.width"];			
		}
	}
	self.percentLayer.frame = newPercentFrame;
	percent = aPercent;
}


@end
