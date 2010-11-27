//
//  EnemyAnnotationView.m
//  RunQuest
//
//  Created by Joe Walsh on 9/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EnemyAnnotationView.h"
#import "EnemyAnnotationLayer.h"
#import "EnemyMapSpawn.h";

#define NON_PULSING_RADIUS 22.0f
#define PULSING_RADIUS 42.0f
#define BASE_OPACITY .75f

@implementation EnemyAnnotationView
@synthesize pulsing;

//+ (Class)layerClass { 
//	return [EnemyAnnotationLayer class];
//}

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
	if (( self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier] )) {
		self.draggable = NO;
		self.canShowCallout = NO;
		self.bounds = CGRectMake(0, 0, NON_PULSING_RADIUS, NON_PULSING_RADIUS);
		self.opaque = NO;
		self.pulsing = NO;
		self.layer.opacity = BASE_OPACITY;
	} return self;
}

- (void)setPulsing:(BOOL)shouldPulse {
	if ( !self.isPulsing && shouldPulse ) {
		self.layer.opacity = BASE_OPACITY;
		CABasicAnimation* grow = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
		grow.fromValue = [NSNumber numberWithDouble:1];
		grow.toValue = [NSNumber numberWithDouble:2];
		grow.duration = .75;
		
		CABasicAnimation* fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
		fade.fromValue = [NSNumber numberWithDouble:BASE_OPACITY];
		fade.toValue = [NSNumber numberWithDouble:1];
		fade.duration = .75;
		
		CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
		fade.timingFunction = timingFunction;
		grow.timingFunction = timingFunction;
		
		CAAnimationGroup *pulse = [CAAnimationGroup animation];
		pulse.animations = [NSArray arrayWithObjects:grow, fade, nil];
		pulse.repeatCount = CGFLOAT_MAX;
		pulse.autoreverses = YES;
		pulse.duration = 1.0;
		
		[self.layer addAnimation:pulse forKey:@"pulse"];
	}
	else if ( self.isPulsing && !shouldPulse ) {
		[self.layer removeAllAnimations];
		self.bounds = CGRectMake(0, 0, NON_PULSING_RADIUS, NON_PULSING_RADIUS);
		self.layer.opacity = BASE_OPACITY;
	}
	
	pulsing = shouldPulse;
}

- (void)pulse {
	self.layer.opacity = 0.0f;
	self.bounds = CGRectMake(0, 0, PULSING_RADIUS, PULSING_RADIUS);
	CABasicAnimation* grow = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	grow.fromValue = [NSNumber numberWithDouble:0];
	grow.toValue = [NSNumber numberWithDouble:1];
	grow.duration = .75;
	
	CABasicAnimation* fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
	fade.fromValue = [NSNumber numberWithDouble:1];
	fade.toValue = [NSNumber numberWithDouble:0];
	fade.duration = .75;
	
	CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	fade.timingFunction = timingFunction;
	grow.timingFunction = timingFunction;
	
	CAAnimationGroup *pulse = [CAAnimationGroup animation];
	pulse.animations = [NSArray arrayWithObjects:grow, fade, nil];
	pulse.repeatCount = 1;
	pulse.duration = 1.5;
	
	[self.layer addAnimation:pulse forKey:@"pulse"];
}

- (void)stopPulsing {
	self.bounds = CGRectMake(0, 0, NON_PULSING_RADIUS, NON_PULSING_RADIUS);
	self.layer.opacity = BASE_OPACITY;
}

- (void)drawRect:(CGRect)rect {
	CGFloat stroke = 2.0f;
	CGRect bounds_ = CGRectInset(self.bounds, stroke, stroke);
	[[UIColor colorWithRed:1 green:.1 blue:.1 alpha:.8f] set];
	UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:bounds_];
	[path fill];
	if ( !self.isPulsing ) {
		[[UIColor whiteColor] set];
		path.lineWidth = stroke;
		[path stroke];
	}
	[super drawRect:rect];
}


@end
