//
//  BeginEvent.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/25/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "BeginEvent.h"
#import "Scrubber.h"
#import "Player.h"
#import "Team.h"

@implementation BeginEvent

+(BeginEvent*) eventWithAction: (Action)anAction andPlayer: (Player*)player {
    BeginEvent* evt = [[BeginEvent alloc] init];
    evt.action = anAction;
    evt.player = player;
    NSAssert(player != nil, @"player cannot be nil in a BeginEvent");
    NSAssert(anAction == BeginPull || anAction == PickupDisc, @"Invalid action for begin event");
    return evt;
}

- (BOOL) isBeginEvent {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder: encoder];
    [encoder encodeObject: self.player forKey:kPlayerKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    self.player = [decoder decodeObjectForKey:kPlayerKey];
    [self ensureValid];
    return self;
}

- (NSDictionary*) asDictionaryWithScrubbing: (BOOL) shouldScrub {
    NSMutableDictionary* dict = [super asDictionaryWithScrubbing: shouldScrub];
    [dict setValue: @"Begin" forKey:kEventTypeProperty];
    
    switch (self.action) {
        case BeginPull: {
            [dict setValue: @"BeginPull" forKey:kActionKey];
            break;
        }
        case PickupDisc: {
            [dict setValue: @"PickupDisc" forKey:kActionKey];
            break;
        }
        default: {
        }
    }
    
    NSString *defenderName = shouldScrub ? [[Scrubber currentScrubber] substitutePlayerName:self.player.name isMale:self.player.isMale] : self.player.name;
    [dict setValue: defenderName forKey:kPlayerKey];
    
    return dict;
}

+(BeginEvent*)eventFromDictionary:(NSDictionary*) dict {
    NSString* dictAction = [dict valueForKey:kActionKey];
    
    Action action;
    if ([dictAction isEqualToString: @"BeginPull"]) {
        action = BeginPull;
    } else {
        action = PickupDisc;
    }

    return [BeginEvent eventWithAction: action andPlayer:[Team getPlayerNamed:[dict valueForKey:kPlayerKey]]];
}

- (id)copyWithZone:(NSZone *)zone {
    BeginEvent* evt = [super copyWithZone:nil];
    evt.player = self.player;
    return evt;
}


-(void)useSharedPlayers {
    // no-op...not applicable to BeginEvent
}

- (NSArray*) getPlayers {
    return @[self.player];
}

- (BOOL)isAnonymous {
    return (self.player == nil || self.player.isAnonymous);
}

-(void)ensureValid {
    if (self.player == nil) {
        self.player = [Player getAnonymous];
    }
}

-(void)setPlayer:(Player *)player {
    _player = player ? player : [Player getAnonymous];
}

- (NSString*)getDescription: (NSString*) teamName opponent: (NSString*) opponentName {
    switch (self.action) {
        case BeginPull: {
            if (self.isAnonymous) {
                return [NSString stringWithFormat:@"%@ pull begin", (teamName == nil ? @"Our" : teamName)];
            } else {
                return [NSString stringWithFormat:@"Pull begin from %@", self.player.name];
            }
        }
        default: {
            if (self.isAnonymous) {
                return [NSString stringWithFormat:@"%@ disk pickup", (teamName == nil ? @"Our" : teamName)];
            } else {
                return [NSString stringWithFormat:@"Disk pick up by %@", self.player.name];
            }
        }
    }
}


@end
