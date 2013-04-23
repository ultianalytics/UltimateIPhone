//
//  CessationEvent.h
//  UltimateIPhone
//
//  Created by james on 4/16/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "Event.h"

@interface CessationEvent : Event

+(CessationEvent*) eventWithAction: (Action)anAction;
+(CessationEvent*) endOfFourthQuarterWithOlineStartNextPeriod: (BOOL)startOline;
+(CessationEvent*) endOfOvertimeWithOlineStartNextPeriod: (BOOL)startOline;

+(CessationEvent*) eventFromDictionary:(NSDictionary*) dict; 

- (BOOL) isTimeout;
- (BOOL) isEndOfFirstQuarter;
- (BOOL) isEndOfThirdQuarter;
- (BOOL) isEndOfFourthQuarter;
- (BOOL) isEndOfOvertime;
- (BOOL) isHalftime;
- (BOOL) isGameOver;
- (BOOL) isPeriodEnd;

@end
