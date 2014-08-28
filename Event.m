//
//  Event.m
//  Ultimate
//
//  Created by Jim Geppert
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "Event.h"
#import "OffenseEvent.h"
#import "DefenseEvent.h"
#import "CessationEvent.h"
#import "Team.h"
#import "Game.h"
#import "EventPosition.h"

#define kTimestampKey     @"timestamp"
#define kIsHalftimeCauseKey     @"halftimeCause"
#define kPositionKey     @"pos"
#define kBeginPositionKey     @"posBegin"

@interface  Event()

@end

@implementation Event
@synthesize isHalftimeCause;

+(Event*)fromDictionary:(NSDictionary*) dict {
    NSString* type = [dict objectForKey:kEventTypeProperty];
    Event* event = nil;
    if ([type isEqualToString:@"Cessation"]) {
        event = [CessationEvent eventFromDictionary:dict];
    } else if ([type isEqualToString:@"Offense"]) {
        event = [OffenseEvent eventFromDictionary:dict];
    } else {
        event = [DefenseEvent eventFromDictionary:dict];
    }
    NSNumber* timestampNumber = [dict objectForKey:kTimestampKey];
    if (timestampNumber) {
        double ts = [timestampNumber doubleValue];
        event.timestamp = ts;
    }
    NSNumber* isCauseOfHalftime = [dict objectForKey:kIsHalftimeCauseKey];
    if (isCauseOfHalftime) {
        event.isHalftimeCause = [isCauseOfHalftime boolValue];
    }
    event.details = [dict objectForKey:kDetailsKey];
    NSDictionary* positionDict = [dict objectForKey:kPositionKey];
    if (positionDict) {
        event.position = [EventPosition fromDictionary:positionDict];
    }
    NSDictionary* beginPosition = [dict objectForKey:kBeginPositionKey];
    if (beginPosition) {
        event.beginPosition = [EventPosition fromDictionary:beginPosition];
    }
    return event;
}

-(NSMutableDictionary*)details {
    if (!_details) {
        _details = [[NSMutableDictionary alloc] init];
    }
    return _details;
}

- (NSMutableDictionary*) asDictionaryWithScrubbing: (BOOL) shouldScrub {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setValue: [NSNumber numberWithDouble:self.timestamp] forKey:kTimestampKey];
    if (self.isHalftimeCause) {
        [dict setValue: [NSNumber numberWithBool:self.isHalftimeCause] forKey:kIsHalftimeCauseKey];
    }
    if (_details && [_details count] > 0) {
        [dict setValue:self.details forKey:kDetailsKey];
    }
    if (self.position) {
        [dict setValue:[self.position asDictionary] forKey:kPositionKey];
    }
    if (self.beginPosition) {
        [dict setValue:[self.beginPosition asDictionary] forKey:kBeginPositionKey];
    }
    return dict;
}

- (void)encodeWithCoder:(NSCoder *)encoder { 
    [encoder encodeInt: self.action forKey:kActionKey];
    [encoder encodeDouble:self.timestamp forKey:kTimestampKey];
    if (self.isHalftimeCause) {
        [encoder encodeBool: self.isHalftimeCause forKey:kIsHalftimeCauseKey];
    }
    if (_details && [_details count] > 0) {
        [encoder encodeObject:self.details forKey:kDetailsKey];
    }
    if (self.position) {
        [encoder encodeObject:self.position forKey:kPositionKey];
    }
    if (self.beginPosition) {
        [encoder encodeObject:self.beginPosition forKey:kBeginPositionKey];
    }
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) { 
        self.action = [decoder decodeIntForKey:kActionKey];
        self.timestamp = [decoder decodeDoubleForKey:kTimestampKey];
        self.details = [decoder decodeObjectForKey:kDetailsKey];
        self.isHalftimeCause = [decoder decodeBoolForKey:kIsHalftimeCauseKey];
        self.position = [decoder decodeObjectForKey:kPositionKey];
        self.beginPosition = [decoder decodeObjectForKey:kBeginPositionKey];
        [self ensureValid];
    } 
    return self; 
}

- (id)copyWithZone:(NSZone *)zone {
    Event* evt = [[[self class] alloc] init];
    evt.action = self.action;
    evt.timestamp  = self.timestamp;
    evt.details = [[self.details copyWithZone:zone] mutableCopy];
    evt.isHalftimeCause = self.isHalftimeCause;
    evt.position = self.position;
    evt.beginPosition = self.beginPosition;
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

- (BOOL) isDefenseThrowaway {
    return self.action == Throwaway && ![self isOffense];
}

- (BOOL) isOurGoal {
    return NO;
}

- (BOOL) isTheirGoal {
    return NO;
}

- (BOOL) isTurnover {
   [NSException raise:@"Method must be implemented in subclass" format:@"should be implemented in subclass"];
    return NO;
}

- (BOOL) isPull {
    return self.action == Pull || self.action == PullOb;
}

- (BOOL) isPullIb {
    return self.action == Pull;
}

- (BOOL) isPullOb {
    return self.action == PullOb;
}

- (BOOL) isOpponentPull {
    return self.action == OpponentPull || self.action == OpponentPullOb;
}

- (BOOL) isOpponentPullIb {
    return self.action == OpponentPull;
}

- (BOOL) isOpponentPullOb {
    return self.action == OpponentPullOb;
}

- (BOOL) isOpponentCatch {
    return self.action == OpponentCatch;
}

- (BOOL) isCallahan {
    return NO;
}

- (BOOL) isFinalEventOfPoint {
    return NO;
}

- (BOOL) isCessationEvent {
    return NO;
}

- (BOOL) isPickupDisc {
    return self.action == PickupDisc;
}

- (BOOL) isPullBegin {
    return self.action == PullBegin;
}

- (BOOL) isPlayEvent {
    return NO;    
}

- (NSString*)description {
    return [self getDescription];
}

- (NSString*)getDescription: (NSString*) teamName opponent: (NSString*) opponentName {
    [NSException raise:@"Method must be implemented in subclass" format:@"should be implemented in subclass"];
    return nil;
}

- (NSString*)positionalDescription {
    return @"";
}

- (NSString*)getDescription {
    return [self getDescription:[Team getCurrentTeam].shortName opponent:[Game getCurrentGame].shortOpponentName];
}

- (BOOL) isOffense {
    return NO;
}

- (BOOL) isDefense {
    return NO;
}

- (BOOL) isPeriodEnd {
    return NO;
}

- (BOOL) causesDirectionChange {
    return !(self.action == Catch || self.action == Pull || self.action == PullOb);
}

- (BOOL) causesLineChange {
    return [self isGoal];
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
    // no-op...subclasses can re-implement
}


-(void)setDetailIntValue:(int)value forKey:(NSString *)key {
    [self.details setValue:[NSNumber numberWithInt:value] forKey:key];
}

-(int)intDetailValueForKey: (NSString *)key default: (int)defaultValue {
    if (!_details) {  // optimization...don't create dictionary unless needed
        return defaultValue;
    }
    NSNumber* value = [self.details valueForKey:key];
    return value ? value.intValue : defaultValue;
}

-(Player*)playerOne {
    return nil;
}

-(Player*)playerTwo {
    return nil;
}

@end
