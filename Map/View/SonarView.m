//
//  SonarView.m
//  RunQuest
//
//  Created by Joe Walsh on 9/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SonarView.h"
#import "Sonar.h"
#import <QuartzCore/QuartzCore.h>

@implementation SonarView

- (id)initWithOverlay:(id <MKOverlay>)overlay {
	if (( self = [super initWithOverlay:overlay] )) {
	}return self;
}

- (void)drawMapRect:(MKMapRect)mapRect
          zoomScale:(MKZoomScale)zoomScale
          inContext:(CGContextRef)context
{
    Sonar *objects = (Sonar *)(self.overlay);

	CGRect rectToDraw = [self rectForMapRect:mapRect];
	
    [objects lockForReading];
	CLLocationCoordinate2D coordinate = self.overlay.coordinate;
	CGPoint center = [self pointForMapPoint:MKMapPointForCoordinate(coordinate)];
	CLLocationDistance radius = objects.range;
    [objects unlockForReading];
	
	double mapPointsPerMeter = MKMapPointsPerMeterAtLatitude(coordinate.latitude);
	radius = mapPointsPerMeter * radius;
	
	CGFloat heroRadius = 20*mapPointsPerMeter;
	CGRect rect = CGRectMake(center.x - radius/2.0f, center.y - radius/2.0f, radius, radius);
	CGRect heroRect = CGRectMake(center.x - heroRadius/2.0f, center.y - heroRadius/2.0f, heroRadius, heroRadius);
	
	CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 0.75f);
	CGContextFillRect(context, rectToDraw);
	if ( CGRectIntersectsRect(rectToDraw, rect ) ) {
		CGContextClearRect(context, rect);
		CGContextSaveGState(context);
		CGContextSetBlendMode(context, kCGBlendModeCopy);
		CGContextAddEllipseInRect(context, rect);
		CGContextAddRect(context, CGRectInset(rect, -100.0f, -100.0f));
		CGContextClosePath(context);
		CGContextEOFillPath(context);
		
		CGContextSetRGBFillColor(context, 0.0f, 0.0f, 1.0f, 0.75f);
		CGContextAddEllipseInRect(context, heroRect);
		CGContextFillPath(context);
		
		CGContextRestoreGState(context);
	}
}


@end
