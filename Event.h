//
//  Event.h
//  Ultimate
//
//  Created by Jim Geppert
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Player, EventPosition;
typedef enum {
    None,
    
    Catch,
    Drop,
    Goal,
    Throwaway,
    Pull,
    De,
    Callahan,
    PullOb,
    Stall,
    MiscPenalty,
    
    // positional only
    OpponentPull,
    OpponentPullOb,
    OpponentCatch,
    PickupDisc,  // ephemeral
    PullBegin,   // ephemeral
    
    // cessation
    EndOfFirstQuarter,
    Halftime,
    EndOfThirdQuarter,
    EndOfFourthQuarter,
    EndOfOvertime,
    GameOver,
    Timeout
} Action;

#define kActionKey              @"action"
#define kDetailsKey             @"details"
#define kEventTypeProperty      @"type"


@interface Event : NSObject <NSCoding, NSCopying>

@property (nonatomic) Action action;
@property (nonatomic) NSTimeInterval timestamp;
@property (nonatomic, strong) NSMutableDictionary* details;
@property BOOL isHalftimeCause;
@property (nonatomic, strong) EventPosition* position;
@property (nonatomic, strong) EventPosition* beginPosition; // only for pull events or events occurring after pull or turnover

+ (Event*) fromDictionary:(NSDictionary*) dict;

- (NSString*)getDescription;
- (NSString*)positionalDescription;
- (NSString*)getDescription: (NSString*) teamName opponent: (NSString*) opponentName;
- (BOOL) isCessationEvent;
- (BOOL) isPlayEvent;
- (BOOL) isPickupDisc;
- (BOOL) isPullBegin;
- (BOOL) isOffense;
- (BOOL) isDefense;
- (BOOL) isGoal;
- (BOOL) isOurGoal;
- (BOOL) isTheirGoal;
- (BOOL) isTurnover;
- (BOOL) isDrop;
- (BOOL) isD;
- (BOOL) isPull;
- (BOOL) isPullIb;
- (BOOL) isPullOb;
- (BOOL) isOpponentPull;
- (BOOL) isOpponentPullIb ;
- (BOOL) isOpponentPullOb;
- (BOOL) isPullOrOpponentPull;
- (BOOL) isOpponentCatch;
- (BOOL) isCatchOrOpponentCatch;
- (BOOL) isCallahan;
- (BOOL) isThrowaway;
- (BOOL) isOffenseThrowaway;
- (BOOL) isDefenseThrowaway;
- (BOOL) isFinalEventOfPoint;
- (BOOL) isPeriodEnd;
- (BOOL) causesOffenseDefenseChange;
- (BOOL) causesLineChange;
- (BOOL) isNextEventOffense;
- (Event*) asBeginEvent;
- (NSArray*) getPlayers;
- (Player*)playerOne;
- (Player*)playerTwo;
- (void)useSharedPlayers;
- (NSMutableDictionary*) asDictionaryWithScrubbing: (BOOL) shouldScrub;
- (BOOL)isAnonymous;
- (BOOL)isPositionalOnly;

// subclass support
-(void)setDetailIntValue:(int)value forKey:(NSString *)key;
-(int)intDetailValueForKey: (NSString *)key default: (int)defaultValue;

@end
