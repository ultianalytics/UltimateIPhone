//
//  LeaguevineClient.h
//  UltimateIPhone
//
//  Created by Jim on 9/19/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LeaguevineGame;

typedef enum {
    LeaguevineInvokeOK,
    LeaguevineInvokeCredentialsRejected,
    LeaguevineInvokeNetworkError,
    LeaguevineInvokeInvalidResponse,
    LeaguevineInvokeInvalidGame,
} LeaguevineInvokeStatus;

@interface LeaguevineClient : NSObject

-(void)retrieveLeagues:(void (^)(LeaguevineInvokeStatus, id result)) finishedBlock;
-(void)retrieveSeasonsForLeague: (int) leagueId completion: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock;
-(void)retrieveTeamsForSeason: (int) seasonId completion: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock;
-(void)retrieveTouramentsForSeason: (int) seasonId completion: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock;
-(void)retrieveGamesForSeason: (int) seasonId completion: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock;
-(void)retrieveGamesForTournament: (int) tournamentId completion: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock;
-(void)retrieveGamesForTeam: (int) teamId completion: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock;
-(void)retrieveGamesForTeam: (int) teamId andTournament: (int) tournamentId completion: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock;
-(void)postGameScore: (LeaguevineGame*) leaguevineGame score: (Score)score isFinal: (BOOL) final completion: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock;
@end
