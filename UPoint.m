//
//  UPoint.m
//  Ultimate
//
//  Created by Jim Geppert
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "UPoint.h"
#import "Player.h"
#import "Team.h"
#import "Event.h"
#import "PointSummary.h"
#import "Scrubber.h"
#import "PlayerSubstitution.h"

#define kSummaryProperty        @"summary"

@interface UPoint()

@end

@implementation UPoint
@synthesize events, line, summary, timeStartedSeconds, timeEndedSeconds;

-(NSMutableArray*)substitutions {
    if (!_substitutions) {
        _substitutions = [[NSMutableArray alloc] init];
    }
    return _substitutions;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"summary: %@ timeStartedSeconds=%d timeEndedSeconds=%d",summary, timeStartedSeconds, timeEndedSeconds];
}

-(id) init  {
    self = [super init];
    if (self) {
        self.events = [[NSMutableArray alloc] init];
        self.line = [[NSMutableArray alloc] init];
        self.substitutions = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder { 
    if (self = [super init]) { 
        self.events = [decoder decodeObjectForKey:kEventsKey]; 
        self.line = [decoder decodeObjectForKey:kLineKey]; 
        self.timeStartedSeconds = [decoder decodeDoubleForKey:kStartTimeKey]; 
        self.timeEndedSeconds = [decoder decodeDoubleForKey:kEndTimeKey];
        self.substitutions = [decoder decodeObjectForKey:kSubstitutionsKey]; 
    } 
    return self; 
} 

- (void)encodeWithCoder:(NSCoder *)encoder { 
    [encoder encodeObject:self.events forKey:kEventsKey]; 
    [encoder encodeObject:self.line forKey:kLineKey]; 
    [encoder encodeDouble:self.timeStartedSeconds forKey:kStartTimeKey]; 
    [encoder encodeDouble:self.timeEndedSeconds forKey:kEndTimeKey];
    [encoder encodeObject:self.substitutions forKey:kSubstitutionsKey];
} 

-(NSArray*)getEvents {
    return [NSArray arrayWithArray:self.events];
}

-(void)addEvent: (Event*) event {
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    if ([self.events count] == 0) {
        // if O-line, reduce the start time to account for the pull
        if (![event isPull]) {
            now -= 5;  // assume 5 seconds
        }
        self.timeStartedSeconds = now;
    }
    event.timestamp = now;
    self.timeEndedSeconds = [NSDate timeIntervalSinceReferenceDate];
    [self.events addObject:event];
}

-(Event*)getEventAtMostRecentIndex: (int) index {
    // events are stored in ascending order but we are being asked for an index in descending order
    int eventCount = [self.events count];
    if (eventCount > 0) {
        return [self.events objectAtIndex:(eventCount - index - 1)];
    } else {
        return nil;
    }
}

-(Event*)getLastEvent {
    if ([events count] > 0) {
        return [self.events lastObject];
    } else {
        return nil;
    }
}

-(NSEnumerator*)getLastEvents: (int) number {
    int numberToReturn = MIN(number, [self.events count]);
    NSArray* lastEvents = [self.events subarrayWithRange: NSMakeRange ([self.events count] - numberToReturn, numberToReturn)];
    return [lastEvents reverseObjectEnumerator];
}

-(void)removeLastEvent {
    if ([self.events count] > 0) {
        [self.events removeLastObject];
    }
}

-(BOOL)isFinished {
    return [self.events count] > 0 && [[self getLastEvent] isFinalEventOfPoint];
}

-(BOOL)isOurPoint {
    return [self isFinished] && [[self getLastEvent] isOurGoal];
}

-(int)getNumberOfEvents {
    return [self.events count];
}

+ (UPoint*) fromDictionary:(NSDictionary*) dict {
    UPoint* upoint = [[UPoint alloc] init];
    NSNumber* timeStart = [dict objectForKey:kStartTimeKey];
    NSNumber* timeEnd = [dict objectForKey:kEndTimeKey];
    upoint.timeStartedSeconds = timeStart ? [timeStart intValue] : 0;
    upoint.timeEndedSeconds = timeEnd ? [timeEnd intValue] : 0;
    NSArray* eventDicts = [dict objectForKey:kEventsKey];
    for (NSDictionary* eventDict in eventDicts) {
        [upoint.events addObject:[Event fromDictionary:eventDict]];
    }
    NSArray* playerLineNames = [dict objectForKey:kLineKey];
    NSMutableArray* line = [[NSMutableArray alloc] init];
    for (NSString* playerName in playerLineNames) {
        [line addObject: [Team getPlayerNamed:playerName]];
    }
    upoint.line = line;
    NSArray* playerSubDicts = [dict objectForKey:kSubstitutionsKey];
    if (playerSubDicts) {
        NSMutableArray* subs = [[NSMutableArray alloc] init];
        for (NSDictionary* subDict in playerSubDicts) {
            [subs addObject: [PlayerSubstitution fromDictionary:subDict]];
        }
        upoint.substitutions = subs;
    }
    return upoint;
}

-(NSDictionary*) asDictionaryWithScrubbing: (BOOL) shouldScrub {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    if (self.events && [self.events count] > 0) {
        NSMutableArray* eventDicts = [[NSMutableArray alloc] init];
        for (Event* event in self.events) {
            [eventDicts addObject:[event asDictionaryWithScrubbing: shouldScrub]];
        }
        [dict setValue: eventDicts forKey:kEventsKey];
    }
    if (self.line && [self.line count] > 0) {
        NSMutableArray* playerNames = [[NSMutableArray alloc] init];
        for (Player* player in self.line) {
            NSString *playerName = shouldScrub ? [[Scrubber currentScrubber] substitutePlayerName:player.name isMale:player.isMale] : player.name;
            [playerNames addObject:playerName];
        }
        [dict setValue: playerNames forKey:kLineKey];
    }
    if (self.summary) {
        [dict setValue: [self.summary asDictionary] forKey:kSummaryProperty];
    }
    [dict setValue:[NSNumber numberWithInt:timeStartedSeconds] forKey:kStartTimeKey];
    [dict setValue:[NSNumber numberWithInt:timeEndedSeconds] forKey:kEndTimeKey];
    if (self.substitutions && [self.substitutions count] > 0) {
        NSMutableArray* subDicts = [[NSMutableArray alloc] init];
        for (PlayerSubstitution* playerSub in self.substitutions) {
            [subDicts addObject: [playerSub asDictionaryWithScrubbing: shouldScrub]];
        }
        [dict setValue: subDicts forKey:kSubstitutionsKey];
    }
    return dict;
}

-(NSSet*)playersInEntirePoint {
    NSMutableSet* players = [NSMutableSet setWithArray:self.line];
    if ([self.substitutions count] > 0) {
        for (PlayerSubstitution* sub in self.substitutions) {
            [players removeObject:sub.toPlayer];
            [players removeObject:sub.fromPlayer];
        }
    } 
    return players;
}

-(NSSet*)playersInPartOfPoint {
    NSMutableSet* players = [NSMutableSet set];
    if ([self.substitutions count] > 0) {
        for (PlayerSubstitution* sub in self.substitutions) {
            [players addObject:sub.toPlayer];
            [players addObject:sub.fromPlayer];
        }
    } 
    return players;
}


@end
