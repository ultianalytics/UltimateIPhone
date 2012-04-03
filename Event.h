//
//  Event.h
//  Ultimate
//
//  Created by james on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
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

- (NSString*)getDescription;
- (NSString*)getDescription: (NSString*) teamName opponent: (NSString*) opponentName;
- (BOOL) isOffense;
- (BOOL) isGoal;
- (BOOL) isOurGoal;
- (BOOL) isTurnover;
- (BOOL) isFinalEventOfPoint;
- (BOOL) causesDirectionChange;
- (BOOL) causesLineChange;
- (BOOL) isNextEventOffense;
- (NSArray*) getPlayers;
- (void)useSharedPlayers;
- (NSDictionary*) asDictionary;

@end
