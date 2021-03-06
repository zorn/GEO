//
//  TreasureView.m
//  RunQuest
//
//  Created by Joe Walsh on 11/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TreasureAnnotationView.h"
#import "Treasure.h"
#import <QuartzCore/QuartzCore.h>

#define WIDTH 24.0f
#define HEIGHT 24.0f
#define OPACITY .94f
#define RED 0.1f
#define GREEN 0.1f
#define BLUE 1.0f

@implementation TreasureAnnotationView


- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
	if (( self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier] )) {
		self.draggable = NO;
		self.canShowCallout = NO;
		self.bounds = CGRectMake(0, 0, WIDTH, HEIGHT);
		[self setOpaque:NO];
	} return self;
}

- (void)animateEncounterWithDelegate:(id)delegate {
	[self.layer setOpacity:0];
	CABasicAnimation* grow = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	grow.fromValue = [NSNumber numberWithDouble:1];
	grow.toValue = [NSNumber numberWithDouble:5];
	grow.duration = .5;
	
	CABasicAnimation* fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
	fade.fromValue = [NSNumber numberWithDouble:OPACITY];
	fade.toValue = [NSNumber numberWithDouble:0];
	fade.duration = .5;
	
	CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	fade.timingFunction = timingFunction;
	grow.timingFunction = timingFunction;
	
	CAAnimationGroup *pulse = [CAAnimationGroup animation];
	pulse.animations = [NSArray arrayWithObjects:grow, fade, nil];
	pulse.duration = .5;
	pulse.delegate = delegate;
	
	[self.layer addAnimation:pulse forKey:@"pulse"];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	
	Treasure *annotation_ = self.annotation;
	CGFloat percentage = 1.0f*annotation_.remaining/annotation_.lifetime;
	CGFloat radians = 3*M_PI/2 - percentage*M_PI*2;
	
	CGFloat lineWidth = 3.0f;
	CGRect bounds_ = CGRectInset(self.bounds, lineWidth, lineWidth);
	
	[[UIColor colorWithRed:RED green:GREEN blue:BLUE alpha:OPACITY/2.0f] set];
	[[UIBezierPath  bezierPathWithOvalInRect:bounds_] fill];
	
	CGFloat midX = CGRectGetMidX(bounds_);
	CGFloat	midY = CGRectGetMidY(bounds_);
	CGPoint centerPoint = CGPointMake(midX, midY);
	
	UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:centerPoint radius:bounds_.size.width/2.0f startAngle:3*M_PI/2 endAngle:radians clockwise:NO];
	[path addLineToPoint:centerPoint];

	[path closePath];
	path.lineWidth = lineWidth;
	[[UIColor whiteColor] set];
	[path stroke];
	[[UIColor colorWithRed:RED green:GREEN blue:BLUE alpha:OPACITY] set];
	[path fill];
	[super drawRect:rect];
}


- (void)dealloc {
    [super dealloc];
}


@end
