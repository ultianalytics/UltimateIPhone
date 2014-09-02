//
//  CessationEvent.m
//  UltimateIPhone
//
//  Created by james on 4/16/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "CessationEvent.h"

#define kNextPeriodStartOLine @"nextPeriodStartO"

@implementation CessationEvent

+(CessationEvent*) eventWithAction: (Action)anAction {
    CessationEvent* evt = [[CessationEvent alloc] init];
    evt.action = anAction;
    NSAssert(anAction == EndOfFirstQuarter || anAction == EndOfThirdQuarter || anAction == Halftime || anAction == GameOver || anAction == EndOfFourthQuarter || anAction == EndOfOvertime, @"Invalid action for cessation event");
    return evt;
}

+(CessationEvent*) endOfFourthQuarterWithOlineStartNextPeriod: (BOOL)startOline {
    CessationEvent* evt = [[CessationEvent alloc] init];
    evt.action = EndOfFourthQuarter;
    [evt.details setObject:[NSNumber numberWithBool:startOline] forKey:kNextPeriodStartOLine];
    return evt;
}

+(CessationEvent*) endOfOvertimeWithOlineStartNextPeriod: (BOOL)startOline {
    CessationEvent* evt = [[CessationEvent alloc] init];
    evt.action = EndOfOvertime;
    [evt.details setObject:[NSNumber numberWithBool:startOline] forKey:kNextPeriodStartOLine];    
    return evt;
}

-(BOOL) isNextOvertimePeriodStartingOline {
    NSAssert(self.action == EndOfFourthQuarter || self.action == EndOfOvertime, @"only overtime related periods know if next period starts O-line");
    NSNumber* isOlineAsNumber = [self.details objectForKey:kNextPeriodStartOLine];
    BOOL answer = isOlineAsNumber ? isOlineAsNumber.boolValue : NO;
    return answer;
}

- (BOOL) isCessationEvent {
    return YES;
}

- (BOOL) isTimeout {
    return self.action == Timeout;
}

- (BOOL) isEndOfFirstQuarter {
    return self.action == EndOfFirstQuarter;
}

- (BOOL) isEndOfThirdQuarter {
    return self.action == EndOfThirdQuarter;
}

- (BOOL) isHalftime {
    return self.action == Halftime;
}

- (BOOL) isPreHalftime {
    return self.action == EndOfFirstQuarter;
}

- (BOOL) isGameOver {
    return self.action == GameOver;
}

- (BOOL) isEndOfFourthQuarter {
    return self.action == EndOfFourthQuarter;
}

- (BOOL) isEndOfOvertime {
    return self.action == EndOfOvertime;
}

- (BOOL) isPeriodEnd {
    return ![self isTimeout];
}

- (BOOL) isFinalEventOfPoint {
    return [self isPeriodEnd];
}

-(BOOL)isHalftimeCause {
    return self.action == Halftime;
}

- (BOOL) causesOffenseDefenseChange {
    return YES;
}

- (BOOL) causesLineChange {
    return YES;
}

- (BOOL) isTurnover {
    return NO;
}

- (BOOL) isNextEventOffense {
    return NO;
}

- (NSDictionary*) asDictionaryWithScrubbing: (BOOL) shouldScrub {
    NSMutableDictionary* dict = [super asDictionaryWithScrubbing: shouldScrub];
    [dict setValue: @"Cessation" forKey:kEventTypeProperty];
    
    switch (self.action) {
        case EndOfFirstQuarter: {
            [dict setValue: @"EndOfFirstQuarter" forKey:kActionKey];
            break;
        }
        case EndOfThirdQuarter: {
            [dict setValue: @"EndOfThirdQuarter" forKey:kActionKey];
            break;
        }
        case Halftime: {
            [dict setValue: @"Halftime" forKey:kActionKey];
            break;
        }
        case GameOver: {
            [dict setValue: @"GameOver" forKey:kActionKey];
            break;
        }
        case EndOfFourthQuarter: {
            [dict setValue: @"EndOfFourthQuarter" forKey:kActionKey];
            break;
        }
        case EndOfOvertime: {
            [dict setValue: @"EndOfOvertime" forKey:kActionKey];
            break;
        }
        case Timeout: {
            [dict setValue: @"Timeout" forKey:kActionKey];
            break;
        }
        default: {
        }
    }
    
    return dict;
}

+(CessationEvent*)eventFromDictionary:(NSDictionary*) dict {
    NSString* dictAction = [dict valueForKey:kActionKey];
    
    Action action;
    if ([dictAction isEqualToString: @"EndOfFirstQuarter"]) {
        action = EndOfFirstQuarter;
    } else if ([dictAction isEqualToString: @"EndOfThirdQuarter"]) {
        action = EndOfThirdQuarter;
    } else if ([dictAction isEqualToString: @"Halftime"]) {
        action = Halftime;
    } else if ([dictAction isEqualToString: @"GameOver"]) {
        action = GameOver;
    } else if ([dictAction isEqualToString: @"EndOfFourthQuarter"]) {
        action = EndOfFourthQuarter;
    } else if ([dictAction isEqualToString: @"EndOfOvertime"]) {
        action = EndOfOvertime;
    } else  {
        action = Timeout;
    }
    
    return [CessationEvent eventWithAction: action];
}

-(void)useSharedPlayers {
    // no-op...not application to cessation
}

- (NSArray*) getPlayers {
    return @[];
}

- (NSString*)getDescription: (NSString*) teamName opponent: (NSString*) opponentName {
    switch (self.action) {
        case EndOfFirstQuarter:
            return @"End of 1st Qtr";
        case EndOfThirdQuarter:
            return @"End of 3rd Qtr";
        case Halftime:
            return @"Halftime";
        case GameOver:
            return @"Game Over";
        case EndOfFourthQuarter:
            return @"End of 4th Qtr";
        case EndOfOvertime:
            return @"End of an overtime";
        default:
            return @"";
    }
}

@end
