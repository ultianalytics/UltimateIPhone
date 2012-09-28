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

#define BASE_API_URL @"https://api.leaguevine.com/v1/"

@interface LeaguevineClient()

@property (strong, nonatomic) NSOperationQueue* queue;
@property (strong, nonatomic) LeaguevineResponseParser* responseParser;
@property (strong, nonatomic) NSString* token;

@end

@implementation LeaguevineClient

-(id) init: (NSString*) authToken  {
    self = [self init];
    if (self) {
        self.token = authToken;
    }
    return self;
}

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
    NSString* url = [self fullUrl:[NSString stringWithFormat:@"tournaments/?season_id=%d&order_by=%@", seasonId, [@"[start_date,name]" urlEncoded]]];
    [self retrieveObjects:finishedBlock type: LeaguevineResultTypeTournaments url:url results:nil];
}

-(void)retrieveGamesForSeason: (int) seasonId completion: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock {
    NSString* url = [self fullUrl:[NSString stringWithFormat:@"games/?season_id=%d&order_by=%@", seasonId, [@"[name]" urlEncoded]]];
    [self retrieveObjects:finishedBlock type: LeaguevineResultTypeGames url:url results:nil];
}

-(void)retrieveGamesForTournament: (int) tournamentId completion: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock {
    NSString* url = [self fullUrl:[NSString stringWithFormat:@"games/?tournament_id=%d&order_by=%@", tournamentId, [@"[name]" urlEncoded]]];
    [self retrieveObjects:finishedBlock type: LeaguevineResultTypeGames url:url results:nil];
}

-(void)retrieveGamesForTeam: (int) teamId completion: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock {
    NSString* url = [self fullUrl:[NSString stringWithFormat:@"games/?team_id=[%d]&order_by=%@", teamId, [@"[name]" urlEncoded]]];
    [self retrieveObjects:finishedBlock type: LeaguevineResultTypeGames url:url results:nil];
}

-(void)retrieveGamesForTeam: (int) teamId andTournament: (int) tournamentId completion: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock {
    NSString* url = [self fullUrl:[NSString stringWithFormat:@"games/?team_id=[%d]&tournament_id=%d&order_by=%@", teamId, tournamentId, [@"[name]" urlEncoded]]];
    [self retrieveObjects:finishedBlock type: LeaguevineResultTypeGames url:url results:nil];
}

#pragma mark Retrieve methods

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
            [self returnFailedResponse:url withHttpFailure:sendError httpResponse: httpResponse finishedBlock:finishedBlock];
        }
    }];
}

#pragma mark Return handler methods

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

-(void)returnFailedResponse: (NSString*) url withHttpFailure: (NSError*) error httpResponse: (NSHTTPURLResponse*) httpResponse finishedBlock: (void (^)(LeaguevineInvokeStatus, NSArray* leagues)) finishedBlock {
    NSLog(@"Request to %@ failed with http response %d error %@", url, httpResponse.statusCode, error);
    dispatch_async(dispatch_get_main_queue(), ^{
        finishedBlock(LeaguevineInvokeInvalidResponse, nil);
    });
}

-(void)returnFailedResponse: (NSString*) url withMissingMetaPropertyInResponse: (NSData*) responseData finishedBlock: (void (^)(LeaguevineInvokeStatus, NSArray* leagues)) finishedBlock {
    NSLog(@"Request to %@ failed. Response is missing meta property.  Response: %@", url, [NSString stringFromData: responseData]);
    dispatch_async(dispatch_get_main_queue(), ^{
        finishedBlock(LeaguevineInvokeInvalidResponse, nil);
    });
}

#pragma mark Helper methods

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
