//
//  RQEnemySprite.m
//  RunQuest
//
//  Created by Matthew Thomas on 9/18/10.
//  Copyright (c) 2010 Code/Caffeine. All rights reserved.
//

#import "RQEnemySprite.h"


@interface RQEnemySprite ()
@property (nonatomic, retain) UILabel *textLabel;
@property (nonatomic, retain) CALayer *highlightLayer;
@end

@implementation RQEnemySprite
@synthesize textLabel;
@synthesize highlightLayer;

- (id)initWithView:(UIView *)theView {
    if ((self = [super initWithView:theView])) {
		textLabel = [[UILabel alloc] init];
		textLabel.font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:50.0];
		textLabel.textColor = [UIColor whiteColor];
		textLabel.layer.opacity = 0.0f;
		textLabel.backgroundColor = [UIColor clearColor];
		[self.view.layer addSublayer:textLabel.layer];
				
		highlightLayer = [[CALayer alloc] init];
		highlightLayer.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
		highlightLayer.backgroundColor = [UIColor redColor].CGColor;
		highlightLayer.opacity = 0.0f;
		if ([theView isKindOfClass:[UIImageView class]]) {
			UIImageView *maskView = [[UIImageView alloc] initWithImage:((UIImageView *)theView).image];
			maskView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
			highlightLayer.mask = maskView.layer;
			[maskView release];
		}
		[self.view.layer addSublayer:highlightLayer];
		
		enemyHealthMeter = [[UIProgressView	alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
		enemyHealthMeter.frame = CGRectMake(0.0, theView.frame.size.height+9.0, theView.frame.size.width, 9);
		[enemyHealthMeter setProgress:100.0];
		[theView addSubview:enemyHealthMeter];
	}
    return self;
}


- (void) dealloc
{
	[enemyHealthMeter release];
	[textLabel release];
	[highlightLayer release];
	[super dealloc];
}

- (UIProgressView *)enemyHealthMeter
{
	return enemyHealthMeter;
}

- (void)hitWithText:(NSString *)hitText {
	textLabel.text = hitText;
	CGSize textSize = [textLabel.text sizeWithFont:[UIFont fontWithName:@"Helvetica-BoldOblique" size:50.0]];
	CGRect textFrame = CGRectMake((self.view.frame.size.width / 2.0), 
								  (0.0 - (self.view.frame.size.height / 3.0)), 
								  textSize.width + 5.0, 
								  textSize.height);
	textLabel.frame = textFrame;
	
    CABasicAnimation *fadeInOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
	fadeInOut.fromValue = [NSNumber numberWithFloat:1.0];
	fadeInOut.toValue = [NSNumber numberWithFloat:0.0];
	fadeInOut.duration = 1.0;
	
	CABasicAnimation *grow = [CABasicAnimation animationWithKeyPath:@"transform"];
	grow.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
	grow.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)];
	grow.duration = 1.0;
	
	CAAnimationGroup *group = [CAAnimationGroup animation];
	group.animations = [NSArray arrayWithObjects:fadeInOut, grow, nil];
	
	[textLabel.layer addAnimation:group forKey:nil];
	 
	CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
	flash.fromValue = [NSNumber numberWithFloat:0.7f];
	flash.toValue = [NSNumber numberWithFloat:0.0f];
	flash.duration = 0.5;
	[self.highlightLayer addAnimation:flash forKey:@"opacity"];
	
	
	CABasicAnimation *moveUpAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
	moveUpAnimation.duration = 0.05;
	moveUpAnimation.autoreverses = YES;
	moveUpAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0.0f, -25.0f, 0.0f)];
	moveUpAnimation.fromValue = [NSValue valueWithCATransform3D:self.view.layer.transform];
	[self.view.layer addAnimation:moveUpAnimation forKey:@"transform"];
}

- (void)runDeathAnimation
{
	CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"transform"];
	move.fromValue = [NSValue valueWithCATransform3D:self.view.layer.transform];
	move.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 1.0, 0.0, 0.0)];
	move.autoreverses = YES;
	move.repeatCount = HUGE_VALF;
	move.duration = 0.5;
	[self.view.layer addAnimation:move forKey:@"position.x"];
}

@end
