//
//  RQEnemySprite.m
//  RunQuest
//
//  Created by Matthew Thomas on 9/18/10.
//  Copyright (c) 2010 Code/Caffeine. All rights reserved.
//

#import "RQEnemySprite.h"
#import "RQBarView.h"


@interface RQEnemySprite ()
@property (nonatomic, retain) UILabel *textLabel;
@property (nonatomic, retain) CALayer *highlightLayer;
@property (nonatomic, retain) RQBarView *enemyHealthMeter;
@end

@implementation RQEnemySprite
@synthesize textLabel;
@synthesize highlightLayer;
@synthesize enemyHealthMeter;
@synthesize invincible;

- (id)initWithView:(UIView *)theView {
    if ((self = [super initWithView:theView])) {
		textLabel = [[UILabel alloc] init];
		textLabel.font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:50.0];
		textLabel.textColor = [UIColor whiteColor];
		textLabel.layer.opacity = 0.0f;
		textLabel.backgroundColor = [UIColor clearColor];
		textLabel.shadowColor = [UIColor blackColor];
		textLabel.shadowOffset = CGSizeMake(0.0, 0.0);
		[self.view addSubview:textLabel];
				
		highlightLayer = [[CALayer alloc] init];
		highlightLayer.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
		highlightLayer.backgroundColor = [UIColor redColor].CGColor;
		highlightLayer.opacity = 0.0f;
		if ([self.imageView isKindOfClass:[UIImageView class]]) {
			UIImageView *maskView = [[UIImageView alloc] initWithImage:((UIImageView *)self.imageView).image];
			maskView.frame = CGRectMake(0.0f, 0.0f, self.imageView.frame.size.width, self.imageView.frame.size.height);
			highlightLayer.mask = maskView.layer;
			[maskView release];
		}
		[self.imageView.layer addSublayer:highlightLayer];
		
		enemyHealthMeter = [[RQBarView alloc] initWithFrame:CGRectMake(0.0, theView.frame.size.height+9.0, theView.frame.size.width, 9)];
		self.enemyHealthMeter.layer.opacity = 0.0f;
		[self.view addSubview:enemyHealthMeter];
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


- (void)hitWithText:(NSString *)hitText {
	textLabel.text = hitText;
	CGSize textSize = [textLabel.text sizeWithFont:[UIFont fontWithName:@"Helvetica-BoldOblique" size:50.0]];
	textSize.width += 5.0;
	CGRect textFrame = CGRectMake((fabsf(self.view.frame.size.width - textSize.width) / 2.0), 
								  0.0, 
								  textSize.width, 
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


- (void)strongHitAnimation {
	CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"transform"];
	move.fromValue = [NSValue valueWithCATransform3D:self.imageView.layer.transform];
	move.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0.0, 0.0, 1.0)];
	move.duration = 0.20;
	[self.imageView.layer addAnimation:move forKey:@"transform"];
}


- (void)runDeathAnimation
{
	CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"transform"];
	move.fromValue = [NSValue valueWithCATransform3D:self.view.layer.transform];
	move.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 1.0, 0.0, 0.0)];
	move.autoreverses = YES;
	move.repeatCount = HUGE_VALF;
	move.duration = 0.25;
	[self.imageView.layer addAnimation:move forKey:@"transform"];
}


- (void)setPercent:(CGFloat)percent duration:(CGFloat)duration {
	CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	fadeAnimation.duration = duration;
	fadeAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
	fadeAnimation.toValue = [NSNumber numberWithFloat:0.0f];
	[self.enemyHealthMeter.layer addAnimation:fadeAnimation forKey:@"opacity"];
	[self.enemyHealthMeter setPercent:percent duration:duration];
}

@end
