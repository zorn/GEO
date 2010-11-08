//
//  RQMonsterTemplate.h
//  RunQuest
//
//  Created by Michael Zornek on 11/8/10.
//  Copyright 2010 Clickable Bliss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RQMob.h" // for RQElementalType

enum {
    RQMonsterMovementTypeFlying = 1,
    RQMonsterMovementTypeWarp = 2,
};
typedef NSUInteger RQMonsterMovementType;

@interface RQMonsterTemplate : NSObject {
	NSString *name;
	RQElementalType type;
	NSString *imageFileName;
	RQMonsterMovementType movementType;
}

@property (readwrite, copy) NSString *name;
@property (readwrite, assign) RQElementalType type;
@property (readwrite, copy) NSString *imageFileName;
@property (readwrite, assign) RQMonsterMovementType movementType;

@end
