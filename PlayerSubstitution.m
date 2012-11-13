//
//  PlayerSubstitution.m
//  UltimateIPhone
//
//  Created by james on 10/31/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "PlayerSubstitution.h"
#import "Player.h"
#import "NSDictionary+JSON.h"
#import "Scrubber.h"
#import "Team.h"

#define kFromPlayerKey         @"fromPlayer"
#define kToPlayerKey           @"toPlayer"
#define kTimestampKey          @"timestamp"
#define kReasonKey           @"reason"

@implementation PlayerSubstitution

+(PlayerSubstitution*)fromDictionary:(NSDictionary*) dict {
    PlayerSubstitution* playerSub = [[PlayerSubstitution alloc] init];
    playerSub.fromPlayer = [Team getPlayerNamed:[dict valueForKey:kFromPlayerKey]];
    playerSub.toPlayer = [Team getPlayerNamed:[dict valueForKey:kToPlayerKey]];
    playerSub.reason = [dict intForJsonProperty:kReasonKey defaultValue: SubstitutionReasonOther];
    playerSub.timestamp = [dict doubleForJsonProperty:kTimestampKey defaultValue: 0.0f]; 
    return playerSub;
}

-(NSDictionary*) asDictionaryWithScrubbing: (BOOL) shouldScrub {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    NSString *fromPlayerName = shouldScrub ? [[Scrubber currentScrubber] substitutePlayerName:self.fromPlayer.name isMale:self.fromPlayer.isMale] : self.fromPlayer.name;
    [dict setValue: fromPlayerName forKey:kFromPlayerKey];
    NSString *toPlayerName = shouldScrub ? [[Scrubber currentScrubber] substitutePlayerName:self.toPlayer.name isMale:self.toPlayer.isMale] : self.toPlayer.name;
    [dict setValue: toPlayerName forKey:kToPlayerKey];
    [dict setValue: [NSNumber numberWithInt:self.reason] forKey:kReasonKey];
    [dict setValue: [NSNumber numberWithDouble:self.timestamp] forKey:kTimestampKey];
    return dict;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.fromPlayer = [decoder decodeObjectForKey:kFromPlayerKey];
        self.toPlayer = [decoder decodeObjectForKey:kToPlayerKey];
        self.timestamp = [decoder decodeDoubleForKey:kTimestampKey];
        self.reason = [decoder decodeIntForKey:kReasonKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.fromPlayer forKey:kFromPlayerKey];
    [encoder encodeObject:self.toPlayer forKey:kToPlayerKey];
    [encoder encodeDouble:self.timestamp forKey:kTimestampKey];
    [encoder encodeInt:self.reason forKey:kReasonKey];
}

- (id)copyWithZone:(NSZone *)zone {
    PlayerSubstitution* ps = [[[self class] alloc] init];
    ps.fromPlayer = self.fromPlayer;
    ps.toPlayer = self.toPlayer;
    ps.timestamp = self.timestamp;
    ps.reason = self.reason;
    return ps;
}

- (NSString* )description {
    NSString* reasonDescription = self.reason == SubstitutionReasonOther ? @"" : @" (injury)";
    return [NSString stringWithFormat:@"%@ in for %@%@", self.toPlayer.name, self.fromPlayer.name, reasonDescription];
}

@end
