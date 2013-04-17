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

-(BOOL)isHalftimeCause {
    return self.action == Halftime;
}

- (BOOL) causesDirectionChange {
    return YES;
}

- (BOOL) causesLineChange {
    return YES;
}


@end
