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

+(CessationEvent*) eventFromDictionary:(NSDictionary*) dict; 

- (BOOL) isTimeout;
- (BOOL) isEndOfFirstQuarter;
- (BOOL) isEndOfThirdQuarter;
- (BOOL) isHalftime;
- (BOOL) isGameOver;
- (BOOL) isPeriodEnd;

@end
