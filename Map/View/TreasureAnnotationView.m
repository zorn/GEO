//
//  TreasureView.m
//  RunQuest
//
//  Created by Joe Walsh on 11/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TreasureAnnotationView.h"

#define WIDTH 22.0f
#define HEIGHT 22.0f
#define OPACITY .75f
@implementation TreasureAnnotationView


- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
	if (( self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier] )) {
		self.draggable = NO;
		self.canShowCallout = NO;
		self.bounds = CGRectMake(0, 0, WIDTH, HEIGHT);
		[self setOpaque:NO];
	} return self;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	[[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:OPACITY] set];
	[[UIBezierPath bezierPathWithRoundedRect:[self bounds] cornerRadius:WIDTH/3.0f] fill];
	[super drawRect:rect];
}


- (void)dealloc {
    [super dealloc];
}


@end
