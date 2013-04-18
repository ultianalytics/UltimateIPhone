//
//  Event.h
//  Ultimate
//
//  Created by Jim Geppert
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
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
    Callahan,
    PullOb,
    Stall,
    MiscPenalty,
    
    EndOfFirstQuarter,
    Halftime,
    EndOfThirdQuarter,
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

+ (Event*) fromDictionary:(NSDictionary*) dict;

- (NSString*)getDescription;
- (NSString*)getDescription: (NSString*) teamName opponent: (NSString*) opponentName;
- (BOOL) isCessationEvent;
- (BOOL) isPlayEvent;
- (BOOL) isOffense;
- (BOOL) isGoal;
- (BOOL) isOurGoal;
- (BOOL) isTheirGoal;
- (BOOL) isTurnover;
- (BOOL) isDrop;
- (BOOL) isD;
- (BOOL) isPull;
- (BOOL) isPullOb;
- (BOOL) isCallahan;
- (BOOL) isThrowaway;
- (BOOL) isOffenseThrowaway;
- (BOOL) isDefenseThrowaway;
- (BOOL) isFinalEventOfPoint;
- (BOOL) isPeriodEnd;
- (BOOL) causesDirectionChange;
- (BOOL) causesLineChange;
- (BOOL) isNextEventOffense;
- (NSArray*) getPlayers;
- (Player*)playerOne;
- (Player*)playerTwo;
- (void)useSharedPlayers;
- (NSMutableDictionary*) asDictionaryWithScrubbing: (BOOL) shouldScrub;
- (BOOL)isAnonymous;

// subclass support
-(void)setDetailIntValue:(int)value forKey:(NSString *)key;
-(int)intDetailValueForKey: (NSString *)key default: (int)defaultValue;

@end
