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
#import "Team.h"
#import "Game.h"

#define kTimestampKey     @"timestamp"
#define kIsHalftimeCauseKey     @"halftimeCause"

@interface  Event()

@end

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
        NSLog(@"dict.details is %@", dict);
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
} 

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) { 
        self.action = [decoder decodeIntForKey:kActionKey];
        self.timestamp = [decoder decodeDoubleForKey:kTimestampKey];
        self.details = [decoder decodeObjectForKey:kDetailsKey];
        self.isHalftimeCause = [decoder decodeBoolForKey:kIsHalftimeCauseKey];
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

- (BOOL) isPull {
    return NO;
}

- (BOOL) isPullOb {
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

@end
