//
//  Line.h
//  TouchTracker
//
//  Created by Alex Silverman on 7/28/09.
//  Copyright 2009 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Line : NSObject {
	CGPoint begin;
	CGPoint end;
}
@property (nonatomic) CGPoint begin;
@property (nonatomic) CGPoint end;

- (float)width;

@end
