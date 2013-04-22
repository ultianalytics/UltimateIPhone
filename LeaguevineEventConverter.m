//
//  LeaguevineEventConverter.m
//  UltimateIPhone
//
//  Created by james on 3/31/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "LeaguevineEventConverter.h"
#import "LeaguevineEvent.h"
#import "Event.h"
#import "Team.h"
#import "LeaguevineTeam.h"
#import "Game.h"
#import "LeaguevineGame.h"
#import "Player.h"
#import "LeaguevinePlayer.h"

@implementation LeaguevineEventConverter

-(BOOL)populateLeaguevineEvent: (LeaguevineEvent*) leaguevineEvent withEvent: (Event*)event fromGame: (Game*)game {
    BOOL converted = YES;
    
    leaguevineEvent.leaguevineGameId = game.leaguevineGame.itemId;
    leaguevineEvent.iUltimateTimestamp = event.timestamp;
    leaguevineEvent.eventDescription = [event description];
    
    int ourLeaguevineTeamId = [Team getCurrentTeam].leaguevineTeam.itemId;
    int theirLeaguevineTeamId = game.leaguevineGame.team1Id == ourLeaguevineTeamId ? game.leaguevineGame.team2Id : game.leaguevineGame.team1Id;
    
    switch (event.action) {
        case Catch: {
            leaguevineEvent.leaguevineEventType = 21;
            [self populatePlayerOneInLVEvent: leaguevineEvent withEvent: event ourLeaguevineId: ourLeaguevineTeamId];
            [self populatePlayerTwoInLVEvent: leaguevineEvent withEvent: event ourLeaguevineId: ourLeaguevineTeamId];
            break;
        }
        case Goal: {
            leaguevineEvent.leaguevineEventType = 22;
            if ([event isOurGoal]) {
                [self populatePlayerOneInLVEvent: leaguevineEvent withEvent: event ourLeaguevineId: ourLeaguevineTeamId];
                [self populatePlayerTwoInLVEvent: leaguevineEvent withEvent: event ourLeaguevineId: ourLeaguevineTeamId];
            } else {
                leaguevineEvent.leaguevinePlayer1TeamId = theirLeaguevineTeamId;
                leaguevineEvent.leaguevinePlayer2TeamId = theirLeaguevineTeamId;
            }
            break;
        }
        case Drop: {
            leaguevineEvent.leaguevineEventType = 33;
            [self populatePlayerOneInLVEvent: leaguevineEvent withEvent: event ourLeaguevineId: ourLeaguevineTeamId];
            [self populatePlayerTwoInLVEvent: leaguevineEvent withEvent: event ourLeaguevineId: ourLeaguevineTeamId];
            break;
        }
        case Throwaway: {
            leaguevineEvent.leaguevineEventType = 32;
            if ([event isOffenseThrowaway]) {
                [self populatePlayerOneInLVEvent: leaguevineEvent withEvent: event ourLeaguevineId: ourLeaguevineTeamId];
            } else {
                leaguevineEvent.leaguevinePlayer1TeamId = theirLeaguevineTeamId;
            }
            break;
        }
        case Stall: {
            leaguevineEvent.leaguevineEventType = 51;
            [self populatePlayerOneInLVEvent: leaguevineEvent withEvent: event ourLeaguevineId: ourLeaguevineTeamId];            
            break;
        }
        case MiscPenalty: {
            leaguevineEvent.leaguevineEventType = 50;
            [self populatePlayerOneInLVEvent: leaguevineEvent withEvent: event ourLeaguevineId: ourLeaguevineTeamId];            
            break;
        }
        case Pull: {
            leaguevineEvent.leaguevineEventType = 2;
            [self populatePlayerOneInLVEvent: leaguevineEvent withEvent: event ourLeaguevineId: ourLeaguevineTeamId];            
            break;
        }
        case PullOb: {
            leaguevineEvent.leaguevineEventType = 5;
            [self populatePlayerOneInLVEvent: leaguevineEvent withEvent: event ourLeaguevineId: ourLeaguevineTeamId];
            break;
        }
        case De: {
            leaguevineEvent.leaguevineEventType = 34;
            [self populatePlayerThreeInLVEvent: leaguevineEvent withEvent: event ourLeaguevineId: ourLeaguevineTeamId];
            break;
        }
        case Callahan: {
            leaguevineEvent.leaguevineEventType = 38;
            leaguevineEvent.leaguevinePlayer1TeamId = theirLeaguevineTeamId;
            leaguevineEvent.leaguevinePlayer2TeamId = theirLeaguevineTeamId;
            [self populatePlayerThreeInLVEvent: leaguevineEvent withEvent: event ourLeaguevineId: ourLeaguevineTeamId];
            break;
        }
        case EndOfFirstQuarter: {
            leaguevineEvent.leaguevineEventType = 95;
            break;
        }
        case Halftime: {
            leaguevineEvent.leaguevineEventType = 96;
            break;
        }
        case EndOfThirdQuarter: {
            leaguevineEvent.leaguevineEventType = 97;
            break;
        }
        case EndOfFourthQuarter: {
            leaguevineEvent.leaguevineEventType = 94;
            break;
        }
        case EndOfOvertime: {
            leaguevineEvent.leaguevineEventType = 94;
            break;
        }
        case GameOver: {
            leaguevineEvent.leaguevineEventType = 98;
            break;
        }

        default: {
            converted = NO;
        }
    }
    
    return converted;
}

-(void)populatePlayerOneInLVEvent: (LeaguevineEvent*) leaguevineEvent withEvent: (Event*)event ourLeaguevineId: (NSUInteger)ourLeaguevineTeamId {
    if ([event playerOne] && ![[event playerOne] isAnonymous]) {
        leaguevineEvent.leaguevinePlayer1Id = [event playerOne].leaguevinePlayer.playerId;
    } else {
        leaguevineEvent.leaguevinePlayer1TeamId = ourLeaguevineTeamId;
    }
}

-(void)populatePlayerTwoInLVEvent: (LeaguevineEvent*) leaguevineEvent withEvent: (Event*)event ourLeaguevineId: (NSUInteger)ourLeaguevineTeamId {
    if ([event playerTwo] && ![[event playerTwo] isAnonymous]) {
        leaguevineEvent.leaguevinePlayer2Id = [event playerTwo].leaguevinePlayer.playerId;
    } else {
        leaguevineEvent.leaguevinePlayer2TeamId = ourLeaguevineTeamId;
    }
}

-(void)populatePlayerThreeInLVEvent: (LeaguevineEvent*) leaguevineEvent withEvent: (Event*)event ourLeaguevineId: (NSUInteger)ourLeaguevineTeamId {
    if ([event playerOne] && ![[event playerOne] isAnonymous]) {
        leaguevineEvent.leaguevinePlayer3Id = [event playerOne].leaguevinePlayer.playerId;
    } else {
        leaguevineEvent.leaguevinePlayer3TeamId = ourLeaguevineTeamId;
    }
}


@end
