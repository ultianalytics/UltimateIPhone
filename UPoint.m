//
//  UPoint.m
//  Ultimate
//
//  Created by james on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UPoint.h"
#import "Player.h"

#define kSummaryProperty        @"summary"

@implementation UPoint
@synthesize events, line, summary, timeStartedSeconds, timeEndedSeconds;

-(id) init  {
    self = [super init];
    if (self) {
        self.events = [[NSMutableArray alloc] init];
        self.line = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder { 
    if (self = [super init]) { 
        self.events = [decoder decodeObjectForKey:kEventsKey]; 
        self.line = [decoder decodeObjectForKey:kLineKey]; 
        self.timeStartedSeconds = [decoder decodeDoubleForKey:kStartTimeKey]; 
        self.timeEndedSeconds = [decoder decodeDoubleForKey:kEndTimeKey]; 
    } 
    return self; 
} 

- (void)encodeWithCoder:(NSCoder *)encoder { 
    [encoder encodeObject:self.events forKey:kEventsKey]; 
    [encoder encodeObject:self.line forKey:kLineKey]; 
    [encoder encodeDouble:self.timeStartedSeconds forKey:kStartTimeKey]; 
    [encoder encodeDouble:self.timeEndedSeconds forKey:kEndTimeKey]; 
} 

-(NSArray*)getEvents {
    return [NSArray arrayWithArray:self.events];
}

-(void)addEvent: (Event*) event {
    if ([self.events count] == 0) {
        self.timeStartedSeconds = [NSDate timeIntervalSinceReferenceDate] - 5; // assume 5 seconds gas
    }
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

-(NSDictionary*) asDictionary {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    if (self.events && [self.events count] > 0) {
        NSMutableArray* eventDicts = [[NSMutableArray alloc] init];
        for (Event* event in self.events) {
            [eventDicts addObject:[event asDictionary]];
        }
        [dict setValue: eventDicts forKey:kEventsKey];
    }
    if (self.line && [self.line count] > 0) {
        NSMutableArray* playerNames = [[NSMutableArray alloc] init];
        for (Player* player in self.line) {
            [playerNames addObject:player.name];
        }
        [dict setValue: playerNames forKey:kLineKey];
    }
    if (self.summary) {
        [dict setValue: [self.summary asDictionary] forKey:kSummaryProperty];
    }
    return dict;
}

@end
