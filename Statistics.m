//
//  Statistics.m
//  Ultimate
//
//  Created by Jim Geppert on 2/4/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "Game.h"
#import "Team.h"
#import "PlayerStat.h"
#import "StatsEventDetails.h"
#import "Statistics.h"
#import "UPoint.h"
#import "Player.h"
#import "StatsEventDetails.h"
#import "OffenseEvent.h"
#import "DefenseEvent.h"
#import "NSString+manipulations.h"

// private methods
@interface Statistics()

@end


@implementation Statistics

// Answers a "factor" (float between 0 and 1) which reflects a player's played points vs. the rest of the team.
// Answered as a dictionary (key=player id, value=NSNumber with float)
+(NSDictionary*)pointsPlayedFactorPerPlayer: (Game*) game {
    NSDictionary* pointsPerPlayer = [self pointsPerPlayer:game includeOffense: YES includeDefense: YES];
    NSMutableDictionary* pointFactorPerPlayer = [[NSMutableDictionary alloc] initWithCapacity:[pointsPerPlayer count]];
    int playersMaxPoint = 0;
    for (PlayerStat* pointsPlayedStat in [pointsPerPlayer allValues]) {
        playersMaxPoint = MAX(playersMaxPoint, [pointsPlayedStat.number intValue]);
    }
    NSArray* players = [game getPlayers];
    for (Player* player in players) {
        PlayerStat* pointsPlayedStat = [pointsPerPlayer objectForKey:[player getId]];
        int pointsPlayed = pointsPlayedStat == nil ? 0 : pointsPlayedStat.number.intValue;
        float factor = playersMaxPoint == 0 ? 0 : (float)pointsPlayed / (float)playersMaxPoint;
        [pointFactorPerPlayer setObject:[NSNumber numberWithFloat:factor] forKey:[player getId]];
    }
    return pointFactorPerPlayer;
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

#pragma mark - Stats Accumulator methods

+(NSArray*)pointsPerPlayer: (Game*) game includeOffense: (BOOL) includeO includeDefense: (BOOL) includeD includeTournament: (BOOL) includeTournament {
    void (^statsAccumulator)(StatsEventDetails* statsEventDetails) = ^(StatsEventDetails* eventDetails) {
        if (eventDetails.isFirstEventOfPoint) {
            if ((eventDetails.isOlinePoint && includeO)  || (! eventDetails.isOlinePoint && includeD)) {
                for (Player* player in eventDetails.line) {
                    PlayerStat* playerStat = [Statistics getStatForPlayer:player fromStats:eventDetails.accumulatedStats statType:IntStat];
                    playerStat.number = [NSNumber numberWithInt:[playerStat.number intValue] + 1];
                }
            }
        }
    };
    return [self accumulateStatsPerPlayer: game includeTournament: includeTournament statsAccumulator: statsAccumulator];
}

+(NSArray*)throwsPerPlayer: (Game*) game includeTournament: (BOOL) includeTournament {
    void (^statsAccumulator)(StatsEventDetails* statsEventDetails) = ^(StatsEventDetails* eventDetails) {
        if ([eventDetails.event isOffense] && (eventDetails.event.action == Catch || eventDetails.event.action == Drop || eventDetails.event.action == Throwaway)) {
            OffenseEvent* event = (OffenseEvent*)eventDetails.event;
            PlayerStat* playerStat = [Statistics getStatForPlayer:event.passer fromStats:eventDetails.accumulatedStats statType:IntStat];
            playerStat.number = [NSNumber numberWithInt:[playerStat.number intValue] + 1];
        }
    };
    return [self accumulateStatsPerPlayer: game includeTournament: includeTournament statsAccumulator: statsAccumulator];
}

+(NSArray*)goalsPerPlayer: (Game*) game includeTournament: (BOOL) includeTournament {
    void (^statsAccumulator)(StatsEventDetails* statsEventDetails) = ^(StatsEventDetails* eventDetails) {
        if (eventDetails.event.action == Goal &&  [eventDetails.event isOffense]) {
            OffenseEvent* event = (OffenseEvent*)eventDetails.event;
            PlayerStat* playerStat = [Statistics getStatForPlayer:event.receiver fromStats:eventDetails.accumulatedStats statType:IntStat];
            playerStat.number = [NSNumber numberWithInt:[playerStat.number intValue] + 1];
        }
    };
    return [self accumulateStatsPerPlayer: game includeTournament: includeTournament statsAccumulator: statsAccumulator];
}

+(NSArray*)assistsPerPlayer: (Game*) game includeTournament: (BOOL) includeTournament {
    void (^statsAccumulator)(StatsEventDetails* statsEventDetails) = ^(StatsEventDetails* eventDetails) {
        if (eventDetails.event.action == Goal &&  [eventDetails.event isOffense]) {
            OffenseEvent* event = (OffenseEvent*)eventDetails.event;
            PlayerStat* playerStat = [Statistics getStatForPlayer:event.passer fromStats:eventDetails.accumulatedStats statType:IntStat];
            playerStat.number = [NSNumber numberWithInt:[playerStat.number intValue] + 1];
        }
    };
    return [self accumulateStatsPerPlayer: game includeTournament: includeTournament statsAccumulator: statsAccumulator];
}

+(NSArray*)dropsPerPlayer: (Game*) game includeTournament: (BOOL) includeTournament {
    void (^statsAccumulator)(StatsEventDetails* statsEventDetails) = ^(StatsEventDetails* eventDetails) {
        if (eventDetails.event.action == Drop) {
            OffenseEvent* event = (OffenseEvent*)eventDetails.event;
            PlayerStat* playerStat = [Statistics getStatForPlayer:event.receiver fromStats:eventDetails.accumulatedStats statType:IntStat];
            playerStat.number = [NSNumber numberWithInt:[playerStat.number intValue] + 1];
        }
    };
    return [self accumulateStatsPerPlayer: game includeTournament: includeTournament statsAccumulator: statsAccumulator];
}

+(NSArray*)throwawaysPerPlayer: (Game*) game includeTournament: (BOOL) includeTournament {
    void (^statsAccumulator)(StatsEventDetails* statsEventDetails) = ^(StatsEventDetails* eventDetails) {
        if ([eventDetails.event isOffense] && eventDetails.event.action == Throwaway) {
            OffenseEvent* event = (OffenseEvent*)eventDetails.event;
            PlayerStat* playerStat = [Statistics getStatForPlayer:event.passer fromStats:eventDetails.accumulatedStats statType:IntStat];
            playerStat.number = [NSNumber numberWithInt:[playerStat.number intValue] + 1];
        }
    };
    return [self accumulateStatsPerPlayer: game includeTournament: includeTournament statsAccumulator: statsAccumulator];
}

+(NSArray*)pullsPerPlayer: (Game*) game includeTournament: (BOOL) includeTournament {
    void (^statsAccumulator)(StatsEventDetails* statsEventDetails) = ^(StatsEventDetails* eventDetails) {
        if (eventDetails.event.action == Pull) {
            DefenseEvent* event = (DefenseEvent*)eventDetails.event;
            PlayerStat* playerStat = [Statistics getStatForPlayer:event.defender fromStats:eventDetails.accumulatedStats statType:IntStat];
            playerStat.number = [NSNumber numberWithInt:[playerStat.number intValue] + 1];
        }
    };
    return [self accumulateStatsPerPlayer: game includeTournament: includeTournament statsAccumulator: statsAccumulator];
}

+(NSArray*)dsPerPlayer: (Game*) game includeTournament: (BOOL) includeTournament {
    void (^statsAccumulator)(StatsEventDetails* statsEventDetails) = ^(StatsEventDetails* eventDetails) {
        if (eventDetails.event.action == De) {
            DefenseEvent* event = (DefenseEvent*)eventDetails.event;
            PlayerStat* playerStat = [Statistics getStatForPlayer:event.defender fromStats:eventDetails.accumulatedStats statType:IntStat];
            playerStat.number = [NSNumber numberWithInt:[playerStat.number intValue] + 1];
        }
    };
    return [self accumulateStatsPerPlayer: game includeTournament: includeTournament statsAccumulator: statsAccumulator];
}

+(NSArray*)plusMinusCountPerPlayer: (Game*) game includeTournament: (BOOL) includeTournament {
    /*
     +/- counters/stats for individual players over the course of a game and a
     tournament (assists and goals count as +1, drops and throwaways count as -1).
     D's are a +1.
     */
    void (^statsAccumulator)(StatsEventDetails* statsEventDetails) = ^(StatsEventDetails* eventDetails) {
        if ([eventDetails.event isOffense]) {
            OffenseEvent* event = (OffenseEvent*)eventDetails.event;
            if ([event isDrop] || [event isThrowaway]) {
                Player *player = [event isDrop] ? event.receiver : event.passer;
                PlayerStat* playerStat = [Statistics getStatForPlayer:player fromStats:eventDetails.accumulatedStats statType:IntStat];
                playerStat.number = [NSNumber numberWithInt:[playerStat.number intValue] - 1];
            } else if ([event isGoal]) {
                PlayerStat* playerStat = [Statistics getStatForPlayer:event.passer fromStats:eventDetails.accumulatedStats statType:IntStat];
                playerStat.number = [NSNumber numberWithInt:[playerStat.number intValue] + 1];
                playerStat = [Statistics getStatForPlayer:event.receiver fromStats:eventDetails.accumulatedStats statType:IntStat];
                playerStat.number = [NSNumber numberWithInt:[playerStat.number intValue] + 1];
            }
        } else if ([eventDetails.event isD]) {
            DefenseEvent* event = (DefenseEvent*)eventDetails.event;
            PlayerStat* playerStat = [Statistics getStatForPlayer:event.defender fromStats:eventDetails.accumulatedStats statType:IntStat];
            playerStat.number = [NSNumber numberWithInt:[playerStat.number intValue] + 1];
        }
    };
    
    return [self accumulateStatsPerPlayer: game includeTournament: includeTournament statsAccumulator: statsAccumulator];
}

#pragma mark - PRIVATE

+(NSArray*)accumulateStatsPerPlayer: (Game*) game includeTournament: (BOOL) includeTournament statsAccumulator: (void (^)(StatsEventDetails* statsEventDetails))statsAccumulator {
    NSMutableDictionary* statPerPlayer = [[NSMutableDictionary alloc] init];
    if (includeTournament && [game.tournamentName isNotEmpty]) {
        NSString* currentTeamId = [Team getCurrentTeam].teamId;
        NSArray* gameFilesForCurrentTeam = [Game getAllGameFileNames:currentTeamId];
        NSString* tournamentName = game.tournamentName;
        for (NSString* gameFileId in gameFilesForCurrentTeam) {
            Game* aGame = [Game readGame: gameFileId forTeam: currentTeamId];
            if ([aGame.tournamentName isEqualToString:tournamentName]) {
                [Statistics accumulateStatsPerPlayer: aGame inDictionary:statPerPlayer accumulator: statsAccumulator];
            }
        }
    } else {
        [Statistics accumulateStatsPerPlayer: game inDictionary:statPerPlayer accumulator: statsAccumulator];
    }
    return [Statistics sortedPlayerStats: statPerPlayer game: game statType: IntStat];
}


+(NSArray*)sortedPlayerStats: (NSDictionary*) statPerPlayer game: (Game*) game statType: (StatNumericType) type {
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
        NSLog(@"player is %@", player);
        [statPerPlayer setValue:playerStat forKey:[player getId]];
    }
    return playerStat;
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
    [self accumulateStatsPerPlayer:game inDictionary:statsPerPlayer accumulator:accumulatorBlock];
    return statsPerPlayer;
}

// Accumulate stats in a dictionary (key = player id, value = PlayerStat).  The accumulatorBlock is called for each event.
+(void)accumulateStatsPerPlayer: (Game*) game inDictionary: (NSMutableDictionary*) statsPerPlayer accumulator: (void (^)(StatsEventDetails* statsEventDetails))accumulatorBlock {
    StatsEventDetails* eventDetails = [[StatsEventDetails alloc] init];  // reuse this instance to avoid object creations
    for (UPoint* point in [game points]) {
        BOOL firstEvent = YES;
        BOOL isOLine = [game isPointOline:point];
        for (Event* event in point.getEvents) {
            eventDetails.accumulatedStats = statsPerPlayer;
            eventDetails.game = game;
            eventDetails.point = point;
            eventDetails.event = event;
            eventDetails.isFirstEventOfPoint = firstEvent;
            eventDetails.isOlinePoint = isOLine;
            eventDetails.line = point.line;
            accumulatorBlock(eventDetails);
            firstEvent = NO;
        }
    }
}



@end


