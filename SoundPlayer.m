//
//  SoundPlayer.m
//  Numbers
//
//  Created by james on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SoundPlayer.h"  
#import <AVFoundation/AVAudioPlayer.h>
#import <AudioToolbox/AudioToolbox.h>

@implementation SoundPlayer

+ (void) playKeyIgnored {
    [SoundPlayer playSound:@"Funk"];
}
+ (void) playMaxPlayersAlreadyOnField {
    [SoundPlayer playSound:@"Funk"];
}

+ (void) playSound: (NSString*) soundName {
    SystemSoundID sound;  
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:soundName ofType:@"aiff" inDirectory:@"sounds"]], &sound);  
    AudioServicesPlaySystemSound (sound);    
}

@end
