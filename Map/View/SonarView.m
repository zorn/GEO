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
#import "SonarLayer.h"

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
    
    CGFloat lineWidth = MKRoadWidthAtZoomScale(zoomScale);
	
    [objects lockForReading];
	CGPoint center = [self pointForMapPoint:MKMapPointForCoordinate(self.overlay.coordinate)];
	CLLocationDegrees radius = objects.radius;
    [objects unlockForReading];
	
	CGRect rect = CGRectMake(center.x - radius/2.0, center.y - radius/2.0, radius, radius);

	CGContextAddEllipseInRect(context, rect);
	CGContextSetRGBStrokeColor(context, 0, 0, 1.0, 0.5);
	CGContextSetLineWidth(context, lineWidth);
	CGContextStrokePath(context);

}


@end
