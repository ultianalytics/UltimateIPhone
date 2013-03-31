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
    
    int ourLeaguevineTeamId = [Team getCurrentTeam].leaguevineTeam.itemId;
    int theirLeaguevineTeamId = game.leaguevineGame.team1Id == ourLeaguevineTeamId ? game.leaguevineGame.team2Id : game.leaguevineGame.team1Id;
    
    
    // Set the players. If the player(s) is anonymous then set the team Id instead.
    if ([event isTheirGoal] || [event isDefenseThrowaway]) {
       leaguevineEvent.leaguevinePlayer1TeamId = theirLeaguevineTeamId;
       if ([event isTheirGoal]) {
           leaguevineEvent.leaguevinePlayer2TeamId = theirLeaguevineTeamId;
       }
    } else if ([event isCallahan]) {
       leaguevineEvent.leaguevinePlayer1TeamId = theirLeaguevineTeamId;
       leaguevineEvent.leaguevinePlayer2TeamId = theirLeaguevineTeamId;
       // player 3 (used only for callahan)
       if ([event playerOne] && ![[event playerOne] isAnonymous]) {
           leaguevineEvent.leaguevinePlayer3Id = [event playerOne].leaguevinePlayer.playerId;
       } else {
           leaguevineEvent.leaguevinePlayer3TeamId = ourLeaguevineTeamId;
       }
    } else {
        // player 1
        if ([event playerOne] && ![[event playerOne] isAnonymous]) {
            leaguevineEvent.leaguevinePlayer1Id = [event playerOne].leaguevinePlayer.playerId;
        } else {
            leaguevineEvent.leaguevinePlayer1TeamId = ourLeaguevineTeamId;
        }

        // player 2 
        if ([event playerTwo] && ![[event playerTwo] isAnonymous]) {
            leaguevineEvent.leaguevinePlayer2Id = [event playerTwo].leaguevinePlayer.playerId;
        } else {
            leaguevineEvent.leaguevinePlayer2TeamId = ourLeaguevineTeamId;
        }
    }
    
    switch (event.action) {
        case Catch: {
            leaguevineEvent.leaguevineEventType = 21;
            break;
        }
        case Goal: {
            leaguevineEvent.leaguevineEventType = 22;
            break;
        }
        case Drop: {
            leaguevineEvent.leaguevineEventType = 33;
            break;
        }
        case Throwaway: {
            leaguevineEvent.leaguevineEventType = 32;
            break;
        }
        case Stall: {
            leaguevineEvent.leaguevineEventType = 52;
            break;
        }
        case MiscPenalty: {
            leaguevineEvent.leaguevineEventType = 50;
            break;
        }
        case Pull: {
            leaguevineEvent.leaguevineEventType = 2;
            break;
        }
        case PullOb: {
            leaguevineEvent.leaguevineEventType = 5;
            break;
        }
        case De: {
            leaguevineEvent.leaguevineEventType = 34;
            break;
        }
        case Callahan: {
            leaguevineEvent.leaguevineEventType = 38;
            break;
        }

        default: {
            converted = NO;
        }
    }
    
    return converted;
}

@end
