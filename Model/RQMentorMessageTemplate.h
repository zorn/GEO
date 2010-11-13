//
//  RQMentorMessageTemplate.h
//  RunQuest
//
//  Created by Michael Zornek on 11/11/10.
//  Copyright 2010 Clickable Bliss. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    RQMessageEventTypeRandom = 1,
};
typedef NSUInteger RQMessageEventType;

enum {
    RQMechanicNone = 0,
    RQMechanicShields = 1,
};
typedef NSUInteger RQMechanic;

@interface RQMentorMessageTemplate : NSObject {
	RQMessageEventType eventType;
	RQMechanic relatedToMechanic;
	NSString *message;
}

@property (readwrite, assign) RQMessageEventType eventType;
@property (readwrite, assign) RQMechanic relatedToMechanic;
@property (readwrite, copy) NSString *message;

@end
