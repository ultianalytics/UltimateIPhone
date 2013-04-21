//
//  CessationEvent.m
//  UltimateIPhone
//
//  Created by james on 4/16/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "CessationEvent.h"

@implementation CessationEvent

+(CessationEvent*) eventWithAction: (Action)anAction {
    CessationEvent* evt = [[CessationEvent alloc] init];
    evt.action = anAction;
    NSAssert(anAction == EndOfFirstQuarter || anAction == EndOfThirdQuarter || anAction == Halftime || anAction == GameOver, @"Invalid action for cessation event");
    return evt;
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

- (BOOL) isGameOver {
    return self.action == GameOver;
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

- (BOOL) causesDirectionChange {
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
        default:
            return @"";
    }
}

@end
