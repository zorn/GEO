//
//  RQBarView.h
//  AnimationTechDemo
//
//  Created by Matthew Thomas on 9/13/10.
//  Copyright 2010 Matthew Thomas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface RQBarView : UIView {
	float percent;
}
@property (nonatomic, assign) float percent;
- (id)initWithFrame:(CGRect)frame;
- (void)setPercent:(float)aPercent duration:(CFTimeInterval)duration;
@end
