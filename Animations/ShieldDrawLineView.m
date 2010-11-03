//
//  ShieldDrawLineView.m
//  RunQuest
//
//  Created by Michael Zornek on 11/2/10.
//  Copyright 2010 Clickable Bliss. All rights reserved.
//

#import "ShieldDrawLineView.h"
#import "Line.h"

@implementation ShieldDrawLineView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        beingConnected = NO;
    }
    return self;
}

- (void)dealloc {
    [shieldLineTouch release]; shieldLineTouch = nil;
    [shieldLine release]; shieldLine = nil;
	[super dealloc];
}

@synthesize delegate;
@synthesize shieldLineTouch;
@synthesize shieldLine;
@synthesize beingConnected;


- (float)shieldPower {
    return shieldPower;
}

- (void)setShieldPower:(float)value {
    if (shieldPower != value) {
        shieldPower = value;
		[self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect {
    
	CGContextRef context = UIGraphicsGetCurrentContext();
	if (self.beingConnected) {
		CGContextSetLineWidth(context, 10.0);
	} else {
		CGContextSetLineWidth(context, shieldPower);
	}
	
	CGContextSetLineCap(context, kCGLineCapRound);
	
	if (self.beingConnected) {
		[[UIColor whiteColor] set];
	} else {
		[[UIColor blueColor] set];
	}
	
	CGContextMoveToPoint(context, [self.shieldLine begin].x, [self.shieldLine begin].y);
	CGContextAddLineToPoint(context, [self.shieldLine end].x, [self.shieldLine end].y);
	CGContextStrokePath(context);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch *t in touches) {
		if ([self.delegate isTouchInsideShieldBase:t]) {
			CGRect shieldFrame = [self.delegate frameOfTouchedShieldBase:t];
			// generate a point from the center of the touched shield base
			CGPoint loc = CGPointMake(shieldFrame.origin.x + shieldFrame.size.width/2, shieldFrame.origin.y + shieldFrame.size.height/2);
			Line *newLine = [[Line alloc] init]; 
			[newLine setBegin:loc];
			[newLine setEnd:loc];
			self.shieldLineTouch = t;
			self.shieldLine = newLine;
			self.beingConnected = YES;
			[newLine release];
		}
	}
	[super touchesBegan:touches withEvent:event];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	// Update currentLocations
	for (UITouch *t in touches) {
		
		// if this touch was the one that started the shield, update the line we have
		if ([t isEqual:self.shieldLineTouch]) {
			
			if ([self.delegate isTouchInsideShieldBase:t] && [self.shieldLine width] > 200) {
				// end the connection
				CGPoint loc = [t locationInView:self];
				loc.y = self.shieldLine.begin.y;
				if (self.shieldLine.begin.x == 0) {
					loc.x = 320;
				} else {
					loc.x = 0;
				}
				
				[self.shieldLine setEnd:loc];
				self.shieldLineTouch = nil;
				self.beingConnected = NO;
				[self.delegate shieldsUp];
			} else {
				CGPoint loc = [t locationInView:self];
				loc.y = self.shieldLine.begin.y;
				[self.shieldLine setEnd:loc];
			}
		}
	}
	
	// Redraw
	[self setNeedsDisplay];
	[super touchesMoved:touches withEvent:event];
}

- (void)endTouches:(NSSet *)touches
{
	// Remove ending touches from dictionary
	for (UITouch *t in touches) {
		
		// if this touch was the one that started the shield
		if ([t isEqual:self.shieldLineTouch]) {
			
			// make sure it is inside the oposite shield sphere
			if ([self.delegate isTouchInsideShieldBase:t] && [self.shieldLine width] > 200) {
				CGPoint loc = [t locationInView:self];
				loc.y = self.shieldLine.begin.y;
				if (self.shieldLine.begin.x == 0) {
					loc.x = 320;
				} else {
					loc.x = 0;
				}
				[self.shieldLine setEnd:loc];
				self.shieldLineTouch = nil;
				[self.delegate shieldsUp];
			} else {
				// remove the line
				self.shieldLine = nil;
				self.shieldLineTouch = nil;
			}
			self.beingConnected = NO; // new color now that shield is done
			
		}
	}
	
	// Redraw
	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self endTouches:touches];
	[super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self endTouches:touches];
	[super touchesCancelled:touches withEvent:event];
}



@end
