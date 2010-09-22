//
//  RQAudioPlayer.h
//  SoundTest
//
//  Created by Matt Thomas on 9/22/10.
//  Copyright 2010 Matt Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>

@interface RQAudioPlayer : NSObject {

}

@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) UInt32 iPodIsPlaying;
@property (nonatomic, assign) BOOL wasInterrupted;
@property (readonly) NSArray *soundNames;

- (void)playSoundNamed:(NSString *)soundName;
- (void)stopSoundNamed:(NSString *)soundName;

@end
