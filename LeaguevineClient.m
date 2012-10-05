//
//  LeaguevineClient.m
//  UltimateIPhone
//
//  Created by Jim on 9/19/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeaguevineClient.h"
#import "NSString+manipulations.h"
#import "LeaguevineResponseParser.h"
#import "NSString+manipulations.h"
#import "LeaguevineResponseMeta.h"
#import "LeaguevineTeam.h"
#import "LeaguevineGame.h"
#import "Team.h"
#import "Preferences.h"

#define BASE_API_URL @"https://api.leaguevine.com/v1/"

@interface LeaguevineClient()

@property (strong, nonatomic) NSOperationQueue* queue;
@property (strong, nonatomic) LeaguevineResponseParser* responseParser;

@end

@implementation LeaguevineClient


-(id) init  {
    self = [super init];
    if (self) {
        self.queue = [[NSOperationQueue alloc] init];
        self.responseParser = [[LeaguevineResponseParser alloc] init];
    }
    return self;
}

#pragma mark Public methods

-(void)retrieveLeagues: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock {
    NSString* url = [self fullUrl:[NSString stringWithFormat:@"leagues/?sport=ultimate&order_by=%@", [@"[name]" urlEncoded]]];
    [self retrieveObjects:finishedBlock type: LeaguevineResultTypeLeagues url:url results:nil];
}

-(void)retrieveSeasonsForLeague: (int) leagueId completion: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock {
    NSString* url = [self fullUrl:[NSString stringWithFormat:@"seasons/?league_id=%d&order_by=%@", leagueId, [@"[name]" urlEncoded]]];
    [self retrieveObjects:finishedBlock type: LeaguevineResultTypeSeasons url:url results:nil];
}

-(void)retrieveTeamsForSeason: (int) seasonId completion: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock {
    NSString* url = [self fullUrl:[NSString stringWithFormat:@"teams/?season_id=%d&order_by=%@", seasonId, [@"[name]" urlEncoded]]];
    [self retrieveObjects:finishedBlock type: LeaguevineResultTypeTeams url:url results:nil];
}

-(void)retrieveTouramentsForSeason: (int) seasonId completion: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock {
    NSString* url = [self fullUrl:[NSString stringWithFormat:@"tournaments/?season_id=%d&order_by=%@", seasonId, [@"[-start_date,name]" urlEncoded]]];
    [self retrieveObjects:finishedBlock type: LeaguevineResultTypeTournaments url:url results:nil];
}

-(void)retrieveGamesForSeason: (int) seasonId completion: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock {
    NSString* url = [self fullUrl:[NSString stringWithFormat:@"games/?season_id=%d&order_by=%@", seasonId, [@"[-start_time]" urlEncoded]]];
    [self retrieveObjects:finishedBlock type: LeaguevineResultTypeGames url:url results:nil];
}

-(void)retrieveGamesForTournament: (int) tournamentId completion: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock {
    NSString* url = [self fullUrl:[NSString stringWithFormat:@"games/?tournament_id=%d&order_by=%@", tournamentId, [@"[-start_time]" urlEncoded]]];
    [self retrieveObjects:finishedBlock type: LeaguevineResultTypeGames url:url results:nil];
}

-(void)retrieveGamesForTeam: (int) teamId completion: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock {
    NSString* teams = [[NSString stringWithFormat: @"[%d]", teamId] urlEncoded];
    NSString* url = [self fullUrl:[NSString stringWithFormat:@"games/?team_ids=%@&order_by=%@", teams, [@"[-start_time]" urlEncoded]]];
    [self retrieveObjects:finishedBlock type: LeaguevineResultTypeGames url:url results:nil];
}

-(void)retrieveGamesForTeam: (int) teamId andTournament: (int) tournamentId completion: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock {
    NSString* teams = [[NSString stringWithFormat: @"[%d]", teamId] urlEncoded];
    NSString* url = [self fullUrl:[NSString stringWithFormat:@"games/?team_ids=%@&tournament_id=%d&order_by=%@", teams, tournamentId, [@"[-start_time]" urlEncoded]]];
    [self retrieveObjects:finishedBlock type: LeaguevineResultTypeGames url:url results:nil];
}

-(void)postGameScore: (LeaguevineGame*) leaguevineGame score: (Score)score isFinal: (BOOL) final completion: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock {
    LeaguevineTeam* lvTeam = [Team getCurrentTeam].leaguevineTeam;
    if (!lvTeam) {
        NSLog(@"Error posting LV game score: our team isn't a LV team anymore");
        finishedBlock(LeaguevineInvokeInvalidGame, nil);
        return;
    }
    
    int team1Score, team2Score;
    if (leaguevineGame.team1Id == lvTeam.itemId) {
        team1Score = score.ours;
        team2Score = score.theirs;
    } else if (leaguevineGame.team2Id == lvTeam.itemId) {
        team2Score = score.ours;
        team1Score = score.theirs;
    } else {
        NSLog(@"Error posting LV game score: our team isn't one of the teams on the LV game");
        finishedBlock(LeaguevineInvokeInvalidGame, nil);
        return;
    }
   
    [self postGameScore:leaguevineGame.itemId team1Score:team1Score team2Score:team2Score isFinal:final completion:finishedBlock];
}

#pragma mark private Post methods

-(void)postGameScore: (int) gameId team1Score: (int) team1Score team2Score: (int)team2Score isFinal: (BOOL) final completion: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock {
    
    NSString* leaguevineToken = [Preferences getCurrentPreferences].leaguevineToken;
    if (![leaguevineToken isNotEmpty]) {
        finishedBlock(LeaguevineInvokeCredentialsRejected, nil);
        return;
    }
    
    NSString* url = [self fullUrl:@"game_scores/"];
    //NSString* url = [self fullUrl:[NSString stringWithFormat:@"game_scores/?access_token=%@", leaguevineToken]];
    
    NSString* requestBody = [NSString stringWithFormat: @"{\"game_id\": \"%d\",\"team_1_score\": \"%d\",\"team_2_score\": \"%d\",\"is_final\":\"%@\"}",
                             gameId, team1Score, team2Score, final ? @"True" : @"False"];
    
    NSMutableURLRequest* request = [self createUrlRequest:url httpMethod:@"POST"];
    request.HTTPBody = [requestBody dataUsingEncoding:NSUTF8StringEncoding];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    //[request addValue:[NSString stringWithFormat:@"bearer %@", leaguevineToken] forHTTPHeaderField:@"Authorization"];
    [request addValue: @"bearer 1bc95a9227" forHTTPHeaderField:@"Authorization"];

    [self postGameScore:request completion:finishedBlock];
    
}

-(void)postGameScore: (NSMutableURLRequest*) request completion: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock {
    
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:^(NSURLResponse* response, NSData* data, NSError* sendError) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (sendError != nil || httpResponse.statusCode < 200) {
            [self returnFailedResponse:request.URL.absoluteString withNetworkError:sendError httpResponse: httpResponse finishedBlock:finishedBlock];
        } else if (sendError == nil && (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) && data) {
            [self returnSuccessResponse:nil finishedBlock:finishedBlock];
        } else {
            [self returnFailedResponse:request.URL.absoluteString withHttpFailure:sendError httpResponse: httpResponse data: data finishedBlock:finishedBlock];
        }
    }];
}

#pragma mark pdrivate Retrieve methods

-(void)retrieveObjects: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock type: (LeaguevineResultType) type url: url results: (NSMutableArray*) previousResults {
    NSMutableArray* results = previousResults == nil ? [[NSMutableArray alloc] init] : previousResults;
    [self doGet:url errorBlock:finishedBlock okBlock:^(NSDictionary* responseDict){
        LeaguevineResponseMeta* meta = [self.responseParser parseMeta:responseDict];
        [results addObjectsFromArray:[self.responseParser parseResults:responseDict type:type]];
        if ([meta hasMoreResults]) {
            [self retrieveObjects:finishedBlock type: type url:meta.nextUrl results:results];
        } else {
            [self returnSuccessResponse:results finishedBlock:finishedBlock];
        }
    }];
}

-(void)doGet: (NSString*) url errorBlock: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock okBlock: (void (^)(NSDictionary* responseDict)) responseOKBlock  {
    NSMutableURLRequest* request = [self createUrlRequest:url httpMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:^(NSURLResponse* response, NSData* data, NSError* sendError) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (sendError != nil || httpResponse.statusCode < 200) {
            [self returnFailedResponse:url withNetworkError:sendError httpResponse: httpResponse finishedBlock:finishedBlock];
        } else if (sendError == nil && httpResponse.statusCode == 200 && data) {
            NSError* unmarshallingError = nil;
            NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&unmarshallingError];
            if (unmarshallingError) {
                [self returnFailedResponse:url withUnMarshallingError:unmarshallingError finishedBlock:finishedBlock];
            } else {
                if ([self.responseParser hasMeta:responseDict]) {
                    responseOKBlock(responseDict);
                } else {
                    [self returnFailedResponse:url withMissingMetaPropertyInResponse:data finishedBlock:finishedBlock];
                }
            }
        } else {
            [self returnFailedResponse:url withHttpFailure:sendError httpResponse: httpResponse data: data finishedBlock:finishedBlock];
        }
    }];
}

#pragma mark private Return handler methods

-(void)returnSuccessResponse: (id) results finishedBlock: (void (^)(LeaguevineInvokeStatus, NSArray* leagues)) finishedBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        finishedBlock(LeaguevineInvokeOK, results);
    });
}

-(void)returnFailedResponse: (NSString*) url withUnMarshallingError: (NSError*) error finishedBlock: (void (^)(LeaguevineInvokeStatus, NSArray* leagues)) finishedBlock {
    NSLog(@"Request to %@ failed with unmarshalling error %@", url, error);
    dispatch_async(dispatch_get_main_queue(), ^{
        finishedBlock(LeaguevineInvokeInvalidResponse, nil);
    });
}

-(void)returnFailedResponse: (NSString*) url withNetworkError: (NSError*) error httpResponse: (NSHTTPURLResponse*) httpResponse finishedBlock: (void (^)(LeaguevineInvokeStatus, NSArray* leagues)) finishedBlock {
    NSLog(@"Request to %@ failed with http response %d error %@", url, httpResponse.statusCode, error);
    dispatch_async(dispatch_get_main_queue(), ^{
        finishedBlock(LeaguevineInvokeNetworkError, nil);
    });
}

-(void)returnFailedResponse: (NSString*) url withHttpFailure: (NSError*) error httpResponse: (NSHTTPURLResponse*) httpResponse data: (NSData*) responseData finishedBlock: (void (^)(LeaguevineInvokeStatus, NSArray* leagues)) finishedBlock {
    NSLog(@"Request to %@ failed with http response %d error %@ \nresponse:\n%@", url, httpResponse.statusCode, error, [NSString stringFromData:responseData]);
    LeaguevineInvokeStatus invokeErrorStatus = httpResponse.statusCode == 401 ? LeaguevineInvokeCredentialsRejected : LeaguevineInvokeInvalidResponse;
    dispatch_async(dispatch_get_main_queue(), ^{
        finishedBlock(invokeErrorStatus, nil);
    });
}

-(void)returnFailedResponse: (NSString*) url withMissingMetaPropertyInResponse: (NSData*) responseData finishedBlock: (void (^)(LeaguevineInvokeStatus, NSArray* leagues)) finishedBlock {
    NSLog(@"Request to %@ failed. Response is missing meta property.  Response: %@", url, [NSString stringFromData: responseData]);
    dispatch_async(dispatch_get_main_queue(), ^{
        finishedBlock(LeaguevineInvokeInvalidResponse, nil);
    });
}

#pragma mark private Helper methods

-(NSString*)fullUrl:(NSString*) relativeUrl {
    return [NSString stringWithFormat:@"%@%@",  BASE_API_URL, relativeUrl];
}

-(NSMutableURLRequest*)createUrlRequest:(NSString*) fullUrl httpMethod: (NSString*) httpMethod {
    NSURL *url = [NSURL URLWithString:fullUrl];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:httpMethod];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    return request;
}



@end
