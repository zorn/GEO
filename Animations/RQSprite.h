//
//  RQSprite.h
//  FlickSample
//
//  Created by Nome on 9/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RQSprite : NSObject {
	
	UIView *view;
	CGPoint position;
	CGPoint velocity;

}

@property(nonatomic, assign) CGPoint position;
@property(nonatomic, assign) CGPoint velocity;
@property(nonatomic, retain, readonly) UIView *view;

- (id)initWithView:(UIView *)theView;
- (BOOL)isIntersectingRect:(CGRect)otherRect;

@end