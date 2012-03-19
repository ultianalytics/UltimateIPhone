//
//  Statistics.m
//  Ultimate
//
//  Created by Jim Geppert on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Statistics.h"
#import "UPoint.h"
#import "Player.h"
#import "Game.h"
#import "Team.h"
#import "StatsEventDetails.h"
#import "OffenseEvent.h"
#import "DefenseEvent.h"

@implementation Statistics

// Answers a "factor" (float between 0 and 1) which reflects a player's played points vs. the rest of the team.
// Answered as a dictionary (key=player id, value=NSNumber with float)
+(NSDictionary*)pointsPlayedFactorPerPlayer: (Game*) game team: (Team*) team {
    NSDictionary* pointsPerPlayer = [self pointsPerPlayer:game includeOffense: YES includeDefense: YES];
    NSMutableDictionary* pointFactorPerPlayer = [[NSMutableDictionary alloc] initWithCapacity:[pointsPerPlayer count]];
    int playersMaxPoint = 0;
    for (PlayerStat* pointsPlayedStat in [pointsPerPlayer allValues]) {
        playersMaxPoint = MAX(playersMaxPoint, [pointsPlayedStat.number intValue]);
    }
    for (Player* player in team.players) {
        PlayerStat* pointsPlayedStat = [pointsPerPlayer objectForKey:[player getId]];
        int pointsPlayed = pointsPlayedStat == nil ? 0 : pointsPlayedStat.number.intValue;
        float factor = playersMaxPoint == 0 ? 0 : (float)pointsPlayed / (float)playersMaxPoint;
        [pointFactorPerPlayer setObject:[NSNumber numberWithFloat:factor] forKey:[player getId]];
    }
    return pointFactorPerPlayer;
}

+(NSArray*)throwsPerPlayer: (Game*) game team: (Team*) team {
    void (^statsAccumulator)(StatsEventDetails* statsEventDetails) = ^(StatsEventDetails* eventDetails) {
        if (eventDetails.event.action == Catch || eventDetails.event.action == Drop) {
            OffenseEvent* event = (OffenseEvent*)eventDetails.event;
            PlayerStat* playerStat = [Statistics getStatForPlayer:event.passer fromStats:eventDetails.accumulatedStats statType:IntStat];            
            playerStat.number = [NSNumber numberWithInt:[playerStat.number intValue] + 1];
        }
    };
    NSDictionary* statPerPlayer = [Statistics accumulateStatsPerPlayer: game accumulator: statsAccumulator];
    return [Statistics sortedPlayerStats: statPerPlayer game: game team: team statType: IntStat];
}

+(NSArray*)goalsPerPlayer: (Game*) game team: (Team*) team {
    void (^statsAccumulator)(StatsEventDetails* statsEventDetails) = ^(StatsEventDetails* eventDetails) {
        if (eventDetails.event.action == Goal &&  [eventDetails.event isOffense]) {
            OffenseEvent* event = (OffenseEvent*)eventDetails.event;
            PlayerStat* playerStat = [Statistics getStatForPlayer:event.receiver fromStats:eventDetails.accumulatedStats statType:IntStat];            
            playerStat.number = [NSNumber numberWithInt:[playerStat.number intValue] + 1];
        }
    };
    NSDictionary* statPerPlayer = [Statistics accumulateStatsPerPlayer: game accumulator: statsAccumulator];
    return [Statistics sortedPlayerStats: statPerPlayer game: game team: team statType: IntStat];
}

+(NSArray*)assistsPerPlayer: (Game*) game team: (Team*) team {
    void (^statsAccumulator)(StatsEventDetails* statsEventDetails) = ^(StatsEventDetails* eventDetails) {
        if (eventDetails.event.action == Goal &&  [eventDetails.event isOffense]) {
            OffenseEvent* event = (OffenseEvent*)eventDetails.event;
            PlayerStat* playerStat = [Statistics getStatForPlayer:event.passer fromStats:eventDetails.accumulatedStats statType:IntStat];            
            playerStat.number = [NSNumber numberWithInt:[playerStat.number intValue] + 1];
        }
    };
    NSDictionary* statPerPlayer = [Statistics accumulateStatsPerPlayer: game accumulator: statsAccumulator];
    return [Statistics sortedPlayerStats: statPerPlayer game: game team: team statType: IntStat];
}

+(NSArray*)dropsPerPlayer: (Game*) game team: (Team*) team {
    void (^statsAccumulator)(StatsEventDetails* statsEventDetails) = ^(StatsEventDetails* eventDetails) {
        if (eventDetails.event.action == Drop) {
            OffenseEvent* event = (OffenseEvent*)eventDetails.event;
            PlayerStat* playerStat = [Statistics getStatForPlayer:event.receiver fromStats:eventDetails.accumulatedStats statType:IntStat];            
            playerStat.number = [NSNumber numberWithInt:[playerStat.number intValue] + 1];
        }
    };
    NSDictionary* statPerPlayer = [Statistics accumulateStatsPerPlayer: game accumulator: statsAccumulator];
    return [Statistics sortedPlayerStats: statPerPlayer game: game team: team statType: IntStat];
}

+(NSArray*)throwawaysPerPlayer: (Game*) game team: (Team*) team {
    void (^statsAccumulator)(StatsEventDetails* statsEventDetails) = ^(StatsEventDetails* eventDetails) {
        if (eventDetails.event.action == Throwaway) {
            OffenseEvent* event = (OffenseEvent*)eventDetails.event;
            PlayerStat* playerStat = [Statistics getStatForPlayer:event.passer fromStats:eventDetails.accumulatedStats statType:IntStat];            
            playerStat.number = [NSNumber numberWithInt:[playerStat.number intValue] + 1];
        }
    };
    NSDictionary* statPerPlayer = [Statistics accumulateStatsPerPlayer: game accumulator: statsAccumulator];
    return [Statistics sortedPlayerStats: statPerPlayer game: game team: team statType: IntStat];
}

+(NSArray*)pullsPerPlayer: (Game*) game team: (Team*) team {
    void (^statsAccumulator)(StatsEventDetails* statsEventDetails) = ^(StatsEventDetails* eventDetails) {
        if (eventDetails.event.action == Pull) {
            DefenseEvent* event = (DefenseEvent*)eventDetails.event;
            PlayerStat* playerStat = [Statistics getStatForPlayer:event.defender fromStats:eventDetails.accumulatedStats statType:IntStat];            
            playerStat.number = [NSNumber numberWithInt:[playerStat.number intValue] + 1];
        }
    };
    NSDictionary* statPerPlayer = [Statistics accumulateStatsPerPlayer: game accumulator: statsAccumulator];
    return [Statistics sortedPlayerStats: statPerPlayer game: game team: team statType: IntStat];
}

+(NSArray*)dsPerPlayer: (Game*) game team: (Team*) team {
    void (^statsAccumulator)(StatsEventDetails* statsEventDetails) = ^(StatsEventDetails* eventDetails) {
        if (eventDetails.event.action == De) {
            DefenseEvent* event = (DefenseEvent*)eventDetails.event;
            PlayerStat* playerStat = [Statistics getStatForPlayer:event.defender fromStats:eventDetails.accumulatedStats statType:IntStat];            
            playerStat.number = [NSNumber numberWithInt:[playerStat.number intValue] + 1];
        }
    };
    NSDictionary* statPerPlayer = [Statistics accumulateStatsPerPlayer: game accumulator: statsAccumulator];
    return [Statistics sortedPlayerStats: statPerPlayer game: game team: team statType: IntStat];
}

/*** PRIVATE METHODS ***/
    
+(NSArray*)sortedPlayerStats: (NSDictionary*) statPerPlayer game: (Game*) game team: (Team*) team statType: (StatNumericType) type {
    NSArray* players = [game getPlayers];
    NSMutableArray* playerStats = [[NSMutableArray alloc] init];
    
    for (Player* player in players) {
        PlayerStat* playerStat = [statPerPlayer valueForKey:player.getId];
        if (playerStat == nil) {
            NSNumber* number = type == IntStat ? [[NSNumber alloc] initWithInt:0] : [[NSNumber alloc] initWithFloat: 0];
            playerStat = [[PlayerStat alloc] initPlayer: player stat: number type: type];
        }
        [playerStats addObject: playerStat];
    }
    return [self descendingSortedStats:playerStats];
}

+(PlayerStat*)getStatForPlayer: (Player*) player fromStats: (NSDictionary*) statPerPlayer statType:(StatNumericType) type {
    PlayerStat* playerStat = [statPerPlayer objectForKey:[player getId]];
    if (playerStat == nil) {
        NSNumber* number = type == IntStat ? [[NSNumber alloc] initWithInt:0] : [[NSNumber alloc] initWithFloat: 0];
        playerStat = [[PlayerStat alloc] initPlayer:player stat:number type:IntStat]; 
        [statPerPlayer setValue:playerStat forKey:[player getId]];
    }
    return playerStat;
}


// Answer a dictionary (key=player id, value=NSNumber with int) of all of the players' points in the game
+(NSDictionary*)pointsPerPlayer: (Game*) game includeOffense: (BOOL) includeO includeDefense: (BOOL) includeD {
    NSMutableDictionary* pointsPerPlayer = [[NSMutableDictionary alloc] init];
    for (UPoint* point in [game points]) {
        BOOL isOLine = [game isPointOline:point];
        if ((isOLine && includeO)  || (! isOLine && includeD)) {
            for (Player* player in point.line) {
                PlayerStat* playerStat = [pointsPerPlayer objectForKey:[player getId]];
                if (playerStat == nil) {
                    NSNumber* number = [[NSNumber alloc] initWithInt:1];
                    playerStat = [[PlayerStat alloc] initPlayer: player stat: number type: IntStat];
                    [pointsPerPlayer setObject:playerStat forKey:[player getId]];
                } else {
                    playerStat.number = [NSNumber numberWithInt:[playerStat.number intValue] + 1];
                }
            }
        }
    }
    return pointsPerPlayer;
}


+(NSArray*)descendingSortedStats:(NSArray*) unsortedStatsArray {
    NSArray* sortedPlayerStats = [unsortedStatsArray sortedArrayUsingComparator:^(id a, id b) {
        NSNumber* first = ((PlayerStat*)a).number;
        NSNumber* second = ((PlayerStat*)b).number;
        return [first compare:second];
    }];
    // descending
    return[[sortedPlayerStats reverseObjectEnumerator] allObjects];
}


// Answer a dictionary (key = player id, value = PlayerStat.  The accumulatorBlock is called for each event.
+(NSDictionary*)accumulateStatsPerPlayer: (Game*) game accumulator: (void (^)(StatsEventDetails* statsEventDetails))accumulatorBlock {
    NSMutableDictionary* statsPerPlayer = [[NSMutableDictionary alloc] init];
    StatsEventDetails* eventDetails = [[StatsEventDetails alloc] init];  // reuse this instance to avoid object creations
    for (UPoint* point in [game points]) {
        for (Event* event in point.getEvents) {
            eventDetails.accumulatedStats = statsPerPlayer;
            eventDetails.game = game;
            eventDetails.point = point;
            eventDetails.event = event;
            accumulatorBlock(eventDetails);
        }
    }
    return statsPerPlayer;
}

+(NSArray*)pointsPerPlayer: (Game*) game team: (Team*) team includeOffense: (BOOL) includeO includeDefense: (BOOL) includeD {
    NSDictionary* pointsPerPlayer = [Statistics pointsPerPlayer:game includeOffense: includeO includeDefense: (BOOL) includeD];
    return [Statistics sortedPlayerStats: pointsPerPlayer game: game team: team statType: IntStat];
}

@end


