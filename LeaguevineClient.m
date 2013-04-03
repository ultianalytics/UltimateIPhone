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
#import "LeaguevineEvent.h"
#import "LeaguevineScore.h"
#import "Team.h"
#import "Preferences.h"
#import "NSDictionary+JSON.h"

#define BASE_API_URL @"https://api.leaguevine.com/v1/"

@interface LeaguevineClient()

@property (strong, nonatomic) NSOperationQueue* queue;
@property (strong, nonatomic) LeaguevineResponseParser* responseParser;

@end

@implementation LeaguevineClient

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

-(void)retrievePlayersForTeam: (int) teamId completion: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock {
    NSString* teams = [[NSString stringWithFormat: @"[%d]", teamId] urlEncoded];
    NSString* url = [self fullUrl:[NSString stringWithFormat:@"team_players/?team_ids=%@", teams]];
    [self retrieveObjects:finishedBlock type: LeaguevineResultTypePlayers url:url results:nil];
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

-(LeaguevineInvokeStatus)postGameScore: (LeaguevineScore*) leaguevineScore {
    LeaguevineTeam* lvTeam = [Team getCurrentTeam].leaguevineTeam;
    if (!lvTeam) {
        NSLog(@"Error posting LV game score: our team isn't a LV team anymore");
        return LeaguevineInvokeInvalidGame;
    }
    
    NSString* leaguevineToken = [Preferences getCurrentPreferences].leaguevineToken;
    if (![leaguevineToken isNotEmpty]) {
        return LeaguevineInvokeCredentialsRejected;
    }
    
    NSString* url = [self fullUrl:@"game_scores/"];
    NSString* requestBody = [NSString stringWithFormat: @"{\"game_id\": \"%d\",\"team_1_score\": \"%d\",\"team_2_score\": \"%d\",\"is_final\":\"%@\"}",
                             leaguevineScore.gameId, leaguevineScore.team1Score, leaguevineScore.team2Score, leaguevineScore.final ? @"true" : @"false"];
    
    NSMutableURLRequest* request = [self createUrlRequest:url httpMethod:@"POST"];
    NSData* jsonData = [requestBody dataUsingEncoding: NSUTF8StringEncoding];
    request.HTTPBody = jsonData;
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:[NSString stringWithFormat:@"bearer %@", leaguevineToken] forHTTPHeaderField:@"Authorization"];
    
    NSLog(@"Posting score to leaguevine\nURL: %@%@", url, jsonData ? [NSString stringWithFormat:@"\nDATA: %@", [NSString stringFromData:jsonData]] : @"");
    NSURLResponse* response;
    NSError* sendError;
    NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&sendError];
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse *)response;
    if (sendError != nil || httpResponse.statusCode < 200) {
        NSLog(@"Request to %@ failed with http response %d error %@", request.URL, httpResponse.statusCode, sendError);
        return LeaguevineInvokeNetworkError;
    } else if (sendError == nil && (httpResponse.statusCode == 200 || httpResponse.statusCode == 201)) {
        return LeaguevineInvokeOK;
    } else {
        NSLog(@"Request to %@ failed with http response %d error %@ \nresponse:\n%@", url, httpResponse.statusCode, sendError, [NSString stringFromData:responseData]);
        return httpResponse.statusCode == 401 ? LeaguevineInvokeCredentialsRejected : LeaguevineInvokeInvalidResponse;
    }
}


-(LeaguevineInvokeStatus)postEvent: (LeaguevineEvent*) leaguevineEvent {
    if (![self isValidLeaguevineEvent:leaguevineEvent]) {
        NSLog(@"skipping post of leaguevine event %@ because it is not valid", leaguevineEvent);
        return LeaguevineInvokeOK; // bad but what else can we do?
    } 
        
    NSString* url = [self fullUrl:@"events/"];
    NSMutableURLRequest* request;
    if (leaguevineEvent.crud == CRUDUpdate) {
        url = [NSString stringWithFormat:@"%@%d/", url, leaguevineEvent.leaguevineEventId];
        request = [self createUrlRequest:url httpMethod:@"PUT"];
    } else if (leaguevineEvent.crud == CRUDDelete) {
        url = [NSString stringWithFormat:@"%@%d/", url, leaguevineEvent.leaguevineEventId];
        request = [self createUrlRequest:url httpMethod:@"DELETE"];
    } else {
        request = [self createUrlRequest:url httpMethod:@"POST"];
    }
    
    NSData* jsonData;
    NSError *error = nil;
    
    if (![leaguevineEvent isDelete]) {
        NSString* eventTime = [self formatAsISO8601Timestamp:leaguevineEvent.iUltimateTimestamp];
        NSMutableDictionary* requestDict = [NSMutableDictionary dictionary];
        [requestDict setObject:eventTime forKey:@"time"];
        [self addNonZeroProperty:@"game_id" value:leaguevineEvent.leaguevineGameId toDictionary:requestDict];
        [self addNonZeroProperty:@"type" value:leaguevineEvent.leaguevineEventType toDictionary:requestDict];
        [self addNonZeroProperty:@"player_1_id" value:leaguevineEvent.leaguevinePlayer1Id toDictionary:requestDict];
        [self addNonZeroProperty:@"player_2_id" value:leaguevineEvent.leaguevinePlayer2Id toDictionary:requestDict];
        [self addNonZeroProperty:@"player_3_id" value:leaguevineEvent.leaguevinePlayer3Id toDictionary:requestDict];
        [self addNonZeroProperty:@"player_1_team_id" value:leaguevineEvent.leaguevinePlayer1TeamId toDictionary:requestDict];
        [self addNonZeroProperty:@"player_2_team_id" value:leaguevineEvent.leaguevinePlayer2TeamId toDictionary:requestDict];
        [self addNonZeroProperty:@"player_3_team_id" value:leaguevineEvent.leaguevinePlayer3TeamId toDictionary:requestDict];
        jsonData = [NSJSONSerialization dataWithJSONObject:requestDict options:0 error:&error];
    }
    if (error) {
        NSLog(@"Error creating JSON for event posting: %@", error);
        return LeaguevineInvokeOK; // bad but what else can we do?
    } else {
        request.HTTPBody = jsonData;
        NSLog(@"Posting %@ event (%@) to leaguevine\nURL: %@%@", leaguevineEvent.crud == CRUDUpdate ? @"UPDATE" : leaguevineEvent.crud == CRUDDelete ? @"DELETE" : @"ADD", leaguevineEvent.eventDescription, url, jsonData ? [NSString stringWithFormat:@"\nDATA: %@", [NSString stringFromData: jsonData]] : @"");
        return [self postEventRequest:request forEvent:leaguevineEvent];
    }
}

-(void)addNonZeroProperty: (NSString*)property value: (int)value toDictionary: (NSMutableDictionary*) requestDict {
    if (value) {
        [requestDict setObject:[NSNumber numberWithInt:value] forKey:property];
    }
}

#pragma mark private Post methods

-(LeaguevineInvokeStatus)postEventRequest: (NSMutableURLRequest*) request forEvent: (LeaguevineEvent*) leaguevineEvent {
    NSString* leaguevineToken = [Preferences getCurrentPreferences].leaguevineToken;
    if (![leaguevineToken isNotEmpty]) {
        return LeaguevineInvokeCredentialsRejected;
    }
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:[NSString stringWithFormat:@"bearer %@", leaguevineToken] forHTTPHeaderField:@"Authorization"];
    
    NSURLResponse* response;
    NSError* sendError;
    NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&sendError];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (sendError != nil || httpResponse.statusCode < 200) {
        NSLog(@"Request to %@ failed with http response %d error %@", request.URL, httpResponse.statusCode, sendError);
        return LeaguevineInvokeNetworkError;
    } else if ([leaguevineEvent isDelete] && (httpResponse.statusCode == 200 || httpResponse.statusCode == 204 || httpResponse.statusCode == 410)) {
        if ( httpResponse.statusCode == 410) {
            NSLog(@"league rejected delete of event: already deleted");
        }
        return LeaguevineInvokeOK;
    } else if ([leaguevineEvent isUpdate] && (httpResponse.statusCode == 200 || httpResponse.statusCode == 202)) {
        return LeaguevineInvokeOK;
    } else if ([leaguevineEvent isAdd] && (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) && responseData) {
        NSError* parseError;
        NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&parseError];
        if (!parseError) {
            int eventId = [responseDict intForJsonProperty:@"id" defaultValue:0];
            if (eventId) {
                leaguevineEvent.leaguevineEventId = eventId;
                return LeaguevineInvokeOK;
            } else {
                NSLog(@"Unable to find event ID from leaguevine response when adding event"); 
            }
        } else {
            NSLog(@"Unable to parse leaguevine response when adding event: %@", parseError);
        }
        return LeaguevineInvokeInvalidResponse;
    } else {
        NSLog(@"Request to %@ failed with http response %d error %@ \nresponse:\n%@",request.URL, httpResponse.statusCode, sendError, [NSString stringFromData:responseData]);
        return httpResponse.statusCode == 401 ? LeaguevineInvokeCredentialsRejected : LeaguevineInvokeInvalidResponse;
    }
}

-(void)postGameScore: (int) gameId team1Score: (int) team1Score team2Score: (int)team2Score isFinal: (BOOL) final completion: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock {
    
    NSString* leaguevineToken = [Preferences getCurrentPreferences].leaguevineToken;
    if (![leaguevineToken isNotEmpty]) {
        finishedBlock(LeaguevineInvokeCredentialsRejected, nil);
        return;
    }
    
    NSString* url = [self fullUrl:@"game_scores/"];
    
    NSString* requestBody = [NSString stringWithFormat: @"{\"game_id\": \"%d\",\"team_1_score\": \"%d\",\"team_2_score\": \"%d\",\"is_final\":\"%@\"}",
                             gameId, team1Score, team2Score, final ? @"True" : @"False"];
    
    NSMutableURLRequest* request = [self createUrlRequest:url httpMethod:@"POST"];
    NSData* jsonData = [requestBody dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = jsonData;
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:[NSString stringWithFormat:@"bearer %@", leaguevineToken] forHTTPHeaderField:@"Authorization"];
    
    NSLog(@"Posting score to leaguevine\nURL: %@%@", url, jsonData ? [NSString stringWithFormat:@"\nDATA: %@", [NSString stringFromData:jsonData]] : @"");
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


#pragma mark private Retrieve methods

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

#pragma mark Custom accesors

-(NSOperationQueue*)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}

-(LeaguevineResponseParser*)responseParser {
    if (!_responseParser) {
        _responseParser = [[LeaguevineResponseParser alloc] init];
    }
    return _responseParser;
}

#pragma mark Misc.

-(NSString*)formatAsISO8601Timestamp: (NSTimeInterval)eventTimestamp {
    NSDate* now = [NSDate dateWithTimeIntervalSinceReferenceDate:eventTimestamp];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    NSString* dateFormatted = [dateFormatter stringFromDate:now];
    return dateFormatted;
}

-(BOOL)isValidLeaguevineEvent: (LeaguevineEvent*) leaguevineEvent {
    if (leaguevineEvent.iUltimateTimestamp && leaguevineEvent.leaguevineGameId && leaguevineEvent.leaguevineEventType) {
        if (leaguevineEvent.leaguevinePlayer1Id || leaguevineEvent.leaguevinePlayer1TeamId || leaguevineEvent.leaguevinePlayer3Id || leaguevineEvent.leaguevinePlayer3TeamId) {
            return YES;
        }
    }
    return NO;
}

@end
