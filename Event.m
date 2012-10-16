//
//  Event.m
//  Ultimate
//
//  Created by james on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Event.h"
#import "OffenseEvent.h"
#import "DefenseEvent.h"
#import "Team.h"
#import "Game.h"

#define kIsHalftimeCauseKey     @"halftimeCause"


@implementation Event
@synthesize isHalftimeCause;

+(Event*)fromDictionary:(NSDictionary*) dict {
    NSString* type = [dict objectForKey:kEventTypeProperty];
    Event* event = nil;
    if ([type isEqualToString:@"Offense"]) {
        event = [OffenseEvent eventFromDictionary:dict];
    } else {
        event = [DefenseEvent eventFromDictionary:dict];
    }
    NSNumber* isCauseOfHalftime = [dict objectForKey:kIsHalftimeCauseKey];
    if (isCauseOfHalftime) {
        event.isHalftimeCause = [isCauseOfHalftime boolValue];
    } 
    return event;
}

- (NSMutableDictionary*) asDictionaryWithScrubbing: (BOOL) shouldScrub {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    if (self.isHalftimeCause) {
        [dict setValue: [NSNumber numberWithBool:self.isHalftimeCause] forKey:kIsHalftimeCauseKey];
    }
    return dict;
}

- (void)encodeWithCoder:(NSCoder *)encoder { 
    [encoder encodeInt: self.action forKey:kActionKey];
    if (self.isHalftimeCause) {
        [encoder encodeBool: self.isHalftimeCause forKey:kIsHalftimeCauseKey];
    }
} 

- (id)initWithCoder:(NSCoder *)decoder { 
    if (self = [super init]) { 
        self.action = [decoder decodeIntForKey:kActionKey];
        self.isHalftimeCause = [decoder decodeBoolForKey:kIsHalftimeCauseKey];
        [self ensureValid];
    } 
    return self; 
}

- (id)copyWithZone:(NSZone *)zone {
    Event* evt = [[[self class] alloc] init];
    evt.action = self.action;
    evt.isHalftimeCause = self.isHalftimeCause;
    return evt;
}

-(void)useSharedPlayers {
    [NSException raise:@"Method must be implemented in subclass" format:@"should be implemented in subclass"];
}

- (BOOL) isGoal {
    return NO;
}

- (BOOL) isD {
    return self.action == De;
}

- (BOOL) isDrop {
    return self.action == Drop;
}

- (BOOL) isThrowaway {
    return self.action == Throwaway;
}

- (BOOL) isOffenseThrowaway {
    return self.action == Throwaway && [self isOffense];
}

- (BOOL) isOurGoal {
    return NO;
}

- (BOOL) isTurnover {
   [NSException raise:@"Method must be implemented in subclass" format:@"should be implemented in subclass"];
    return NO;
}

- (BOOL) isFinalEventOfPoint {
    return NO;
}

- (NSString*)description {
    return [self getDescription];
}

- (NSString*)getDescription: (NSString*) teamName opponent: (NSString*) opponentName {
    [NSException raise:@"Method must be implemented in subclass" format:@"should be implemented in subclass"];
    return nil;
}

- (NSString*)getDescription {
    return [self getDescription:[Team getCurrentTeam].shortName opponent:[Game getCurrentGame].shortOpponentName];
}

- (BOOL) isOffense {
    return NO;
}

- (BOOL) causesDirectionChange {
    return !(self.action == Catch || self.action == Pull);
}

- (BOOL) causesLineChange {
    return self.action == Goal;
}

- (BOOL) isNextEventOffense {
    [NSException raise:@"Method must be implemented in subclass" format:@"should be implemented in subclass"];
    return NO;
}

- (NSArray*) getPlayers {
    [NSException raise:@"Method must be implemented in subclass" format:@"should be implemented in subclass"];
    return nil;
}

-(void)setIsHalftimeCause:(BOOL)isCauseOfHalftime {
    isHalftimeCause = isCauseOfHalftime;
    if ([Game hasCurrentGame]) {
        [[Game getCurrentGame] clearPointSummaries];
    }
}

-(BOOL)isHalftimeCause {
    return isHalftimeCause;
}

- (BOOL)isAnonymous {
    return NO;
}

-(void)setAction:(Action)action {
    _action = action;
    [self ensureValid];
}

-(void)ensureValid {
    // no-op...subclasses canm re-implement
}

@end
