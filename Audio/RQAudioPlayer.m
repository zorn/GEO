//
//  RQAudioPlayer.m
//  SoundTest
//
//  Created by Matt Thomas on 9/22/10.
//  Copyright 2010 Matt Thomas. All rights reserved.
//

#import "RQAudioPlayer.h"
#import "MyOpenALSupport.h"


@interface RQAudioPlayer ()
@property (nonatomic, assign) ALCcontext *context;
@property (nonatomic, assign) ALCdevice  *device;
@property (nonatomic, retain) NSMutableDictionary *sounds;
- (void)setupOpenAL;
- (void)teardownOpenAL;
- (void)loadSoundFromFile:(NSString *)file;
@end


@implementation RQAudioPlayer
@synthesize isPlaying;
@synthesize iPodIsPlaying;
@synthesize wasInterrupted;
@dynamic soundNames;
// private
@synthesize context;
@synthesize device;
@synthesize sounds;

- (id)init {
    self = [super init];
    if (self != nil) {
        sounds = [[NSMutableDictionary alloc] init];
        [self setupOpenAL];
//		[self loadSoundFromFile:@"Computer_Data_001.caf"];
//		[self loadSoundFromFile:@"Critical_Hit.caf"];
//		[self loadSoundFromFile:@"GunShot_002.caf"];
		[self loadSoundFromFile:@"Hit_001.caf"];
		[self loadSoundFromFile:@"Hit_002.caf"];
		[self loadSoundFromFile:@"Hit_004.caf"];
//		[self loadSoundFromFile:@"Laser.caf"];
		[self loadSoundFromFile:@"Miss_001.caf"];
		[self loadSoundFromFile:@"Punch_001.caf"];
//		[self loadSoundFromFile:@"Servo_Movement_01.caf"];
//		[self loadSoundFromFile:@"Shields_up.caf"];
		[self loadSoundFromFile:@"Wack_001.caf"];
//		[self loadSoundFromFile:@"chimp_001.caf"];
//		[self loadSoundFromFile:@"disappear.caf"];
//		[self loadSoundFromFile:@"fs_gunshot_001.caf"];
//		[self loadSoundFromFile:@"fs_small_thud.caf"];
//		[self loadSoundFromFile:@"fs_sword_slice.caf"];
//		[self loadSoundFromFile:@"missing_002.caf"];
		[self loadSoundFromFile:@"RQ_Battle_Song.m4a"];
//		[self loadSoundFromFile:@"RQ_MenuSong.m4a"];
//		[self loadSoundFromFile:@"Victory song_nintendo_style.m4a"];
//		[self loadSoundFromFile:@"VictorySoundPlaceholder.m4a"];
//		[self loadSoundFromFile:@"menu battle song 002.m4a"];
//		[self loadSoundFromFile:@"victory_003.m4a"];
//		[self loadSoundFromFile:@"victory_lite.m4a"];
//		[self loadSoundFromFile:@"victory_long.m4a"];
//		[self loadSoundFromFile:@"victory_song_002.m4a"];		
    }
    return self;
}


- (void)dealloc {
    [self teardownOpenAL];
    [sounds release];
    [super dealloc];
}


- (NSArray *)soundNames {
	return [self.sounds allKeys];
}


- (void)setupOpenAL {
    device = alcOpenDevice(NULL);
    if (device) {
        context = alcCreateContext(device, NULL);
        alcMakeContextCurrent(context);
    }
    else {
        NSLog(@"error getting device");
    }
}


- (void)teardownOpenAL {
    alcDestroyContext(context);
    alcCloseDevice(device);
}

- (void)playSoundNamed:(NSString *)soundName {
    if (RQAudioPlayerPlayAudioDuringDevelopment == NO) {
		NSLog(@"Did not play sound %@ because RQAudioPlayerPlayAudioDuringDevelopment is set to NO.", soundName);
		return; 
	}
	NSNumber *sound = [self.sounds objectForKey:soundName];
    if (sound) {
        NSUInteger soundID = [sound unsignedIntValue];
        alSourcePlay(soundID);
    }
}


- (void)stopSoundNamed:(NSString *)soundName; {
	NSNumber *sound = [sounds objectForKey:soundName];
	if (sound) {
        NSUInteger soundID = [sound unsignedIntValue];
        alSourceStop(soundID);
    }
}


- (void)loadSoundFromFile:(NSString *)file {
	ALvoid *outData;
	ALenum error = AL_NO_ERROR;
	ALenum format;
	ALsizei size;
	ALsizei freq;
    
	NSBundle *bundle = [NSBundle mainBundle];
    
	// get some audio data from a wave file
    NSUInteger dot = [file rangeOfString:@"."].location;
    if (dot != NSNotFound) {
        NSLog(@"%@ %@", [file substringToIndex:dot], [file substringFromIndex:dot]);
		NSString *filePath = [bundle pathForResource:[file substringToIndex:dot] ofType:[file substringFromIndex:(dot + 1)]];
		
		if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
			CFURLRef fileURL = (CFURLRef)[[NSURL fileURLWithPath:filePath] retain];
			
			if (fileURL) {
				outData = MyGetOpenALAudioData(fileURL, &size, &format, &freq);
				
				if((error = alGetError()) != AL_NO_ERROR) {
					printf("error loading sound: %x", error);
					exit(1);
				}
				
				// grab a buffer ID from openAL
				NSUInteger bufferID;
				alGenBuffers(1, &bufferID);
				
				// load the awaiting data blob into the openAL buffer.
				alBufferData(bufferID, format, outData, size, freq); 
				
				// save the buffer so we can release it later
				//            [bufferStorageArray addObject:[NSNumber numberWithUnsignedInteger:bufferID]];
				
				// grab a source ID from openAL
				NSUInteger sourceID;
				alGenSources(1, &sourceID); 
				
				// attach the buffer to the source
				alSourcei(sourceID, AL_BUFFER, bufferID);
				// set some basic source prefs
				alSourcef(sourceID, AL_PITCH, 1.0f);
				alSourcef(sourceID, AL_GAIN, 1.0f);
				
				// store this for future use
				[sounds setObject:[NSNumber numberWithUnsignedInt:sourceID] forKey:file];	
				
				// clean up the buffer
				if (outData)
				{
					free(outData);
					outData = NULL;
				}
			}
			else {
				NSLog(@"file not found.");
			}
			CFRelease(fileURL);
		}
	}
}


@end
