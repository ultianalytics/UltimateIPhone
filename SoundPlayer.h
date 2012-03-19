//
//  SoundPlayer.h
//  Numbers
//
//  Created by james on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>


@interface SoundPlayer : NSObject<AVAudioPlayerDelegate> {
}

#pragma mark PUBLIC METHODS

+ (void) playKeyIgnored;
+ (void) playMaxPlayersAlreadyOnField;
+ (void) playSound: (NSString*) soundName;
@end
