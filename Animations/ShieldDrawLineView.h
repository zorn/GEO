//
//  ShieldDrawLineView.h
//  RunQuest
//
//  Created by Michael Zornek on 11/2/10.
//  Copyright 2010 Clickable Bliss. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShieldDrawLineViewDelegate;

@class Line;

@interface ShieldDrawLineView : UIView
{
	UITouch *shieldLineTouch;
	Line *shieldLine;
	BOOL beingConnected;
	float shieldPower; // line width 
}
@property (readwrite, assign) id <ShieldDrawLineViewDelegate> delegate;

@property (readwrite, retain) UITouch *shieldLineTouch;
@property (readwrite, retain) Line *shieldLine;
@property (readwrite, assign) BOOL beingConnected;
@property (readwrite, assign) float shieldPower;


@end

@protocol ShieldDrawLineViewDelegate
- (BOOL)isTouchInsideShieldBase:(UITouch *)touch;
- (CGRect)frameOfTouchedShieldBase:(UITouch *)touch;
- (void)shieldsUp;
@end