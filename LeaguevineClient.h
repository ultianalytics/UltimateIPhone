//
//  LeaguevineClient.h
//  UltimateIPhone
//
//  Created by Jim on 9/19/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    LeaguevineInvokeOK,
    LeaguevineInvokeCredentialsRejected,
    LeaguevineInvokeNetworkError,
    LeaguevineInvokeInvalidResponse,
} LeaguevineInvokeStatus;

@interface LeaguevineClient : NSObject

-(void)retrieveLeagues:(void (^)(LeaguevineInvokeStatus, id result)) finishedBlock;
-(void)retrieveSeasons: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock leagueId: (int) leagueId;
-(void)retrieveTeams: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock seasonId: (int) seasonId;
-(void)retrieveSeasonsForLeague: (int) leagueId completion: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock;
-(void)retrieveTeamsForSeason: (int) seasonId completion: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock;

@end
