//
//  RQAudioUtil.m
//  RunQuest
//
//  Created by Matthew Thomas on 9/28/10.
//  Copyright 2010 Matthew Thomas. All rights reserved.
//

#import "RQAudioUtil.h"
#import "CDAudioManager.h"


@interface RQAudioUtil ()
@property (nonatomic, retain) CDLongAudioSourceFader *fader;
@property (nonatomic, assign) NSTimer *timer;
- (void)modifyProperty;
@end


@implementation RQAudioUtil
@synthesize fader;
@synthesize timer;

- (void) dealloc
{
	[timer invalidate];
	[fader release];
	[super dealloc];
}



- (void)fadeBackgroundMusic:(CGFloat)time {
	//Background music is mapped to the left "channel"
	CDLongAudioSource *player = [[CDAudioManager sharedManager] audioSourceForChannel:kASC_Left];
	self.fader = [[[CDLongAudioSourceFader alloc] init:player interpolationType:kIT_Exponential startVal:player.volume endVal:0.0] autorelease];
	[fader setStopTargetWhenComplete:YES];
	
	self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(modifyProperty) userInfo:nil repeats:YES];
}


- (void)modifyProperty {
	NSLog(@"asdf");
}

@end
