//
//  Event.h
//  Ultimate
//
//  Created by james on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Player;
typedef enum {
    Catch,
    Drop,
    Goal,
    Throwaway,
    Pull,
    De,
    Callahan
} Action;
#define kActionKey              @"action"
#define kEventTypeProperty      @"type"


@interface Event : NSObject <NSCoding>

@property Action action;
@property BOOL isHalftimeCause;

+ (Event*) fromDictionary:(NSDictionary*) dict;

- (NSString*)getDescription;
- (NSString*)getDescription: (NSString*) teamName opponent: (NSString*) opponentName;
- (BOOL) isOffense;
- (BOOL) isGoal;
- (BOOL) isOurGoal;
- (BOOL) isTurnover;
- (BOOL) isDrop;
- (BOOL) isD;
- (BOOL) isThrowaway;
- (BOOL) isOffenseThrowaway;
- (BOOL) isFinalEventOfPoint;
- (BOOL) causesDirectionChange;
- (BOOL) causesLineChange;
- (BOOL) isNextEventOffense;
- (NSArray*) getPlayers;
- (void)useSharedPlayers;
- (NSMutableDictionary*) asDictionaryWithScrubbing: (BOOL) shouldScrub;
- (BOOL)isAnonymous;

@end
