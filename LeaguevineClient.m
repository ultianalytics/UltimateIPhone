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

#define BASE_API_URL @"https://api.leaguevine.com/"

@interface LeaguevineClient()

@property (strong, nonatomic) NSOperationQueue* queue;
@property (strong, nonatomic) LeaguevineResponseParser* responseParser;
@property (strong, nonatomic) NSString* token;

@end

@implementation LeaguevineClient

-(id) init: (NSString*) authToken  {
    self = [super init];
    if (self) {
        self.queue = [[NSOperationQueue alloc] init];
        self.responseParser = [[LeaguevineResponseParser alloc] init];
        self.token = authToken;
    }
    return self;
}

#pragma mark Public methods

-(void)retrieveLeagues: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock {
    NSString* url = [self fullUrl:[NSString stringWithFormat:@"leagues?sport=ultimate&order_by=%@", [@"[name]" urlEncoded]]];
    [self retrieveObjects:finishedBlock type: LeaguevineResultTypeLeagues url:url results:nil];
}

-(void)retrieveSeasons: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock leagueId: (int) leagueId {
    NSString* url = [self fullUrl:[NSString stringWithFormat:@"seasons?league_id=%d&order_by=%@", leagueId, [@"[name]" urlEncoded]]];
    [self retrieveObjects:finishedBlock type: LeaguevineResultTypeSeasons url:url results:nil];
}

-(void)retrieveTeams: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock seasonId: (int) seasonId {
    NSString* url = [self fullUrl:[NSString stringWithFormat:@"teams?season_id=%d&order_by=%@", seasonId, [@"[name]" urlEncoded]]];
    [self retrieveObjects:finishedBlock type: LeaguevineResultTypeTeams url:url results:nil];
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
            finishedBlock(LeaguevineInvokeOK, results);
        }
    }];
}

-(void)doGet: (NSString*) url errorBlock: (void (^)(LeaguevineInvokeStatus, id result)) finishedBlock okBlock: (void (^)(NSDictionary* responseDict)) responseOKBlock  {
    NSMutableURLRequest* request = [self createUrlRequest:url httpMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:^(NSURLResponse* response, NSData* data, NSError* sendError) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (sendError == nil && httpResponse.statusCode == 200 && data) {
            NSError* unmarshallingError = nil;
            NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&unmarshallingError];
            if (unmarshallingError) {
                [self invokeFailedTo:url withUnMarshallingError:unmarshallingError finishedBlock:finishedBlock];
            } else {
                if ([self.responseParser hasMeta:responseDict]) {
                    responseOKBlock(responseDict);
                } else {
                    [self invokeFailedTo:url withMissingMetaPropertyInResponse:data finishedBlock:finishedBlock];
                }
            }
        } else {
            [self invokeFailedTo:url withHttpFailure:sendError httpResponse: httpResponse finishedBlock:finishedBlock];
        }
    }];
}

#pragma mark Error handler methods

-(void)invokeFailedTo: (NSString*) url withUnMarshallingError: (NSError*) error finishedBlock: (void (^)(LeaguevineInvokeStatus, NSArray* leagues)) finishedBlock {
    NSLog(@"Request to %@ failed with unmarshalling error %@", url, error);
    finishedBlock(LeaguevineInvokeInvalidResponse, nil);
}

-(void)invokeFailedTo: (NSString*) url withHttpFailure: (NSError*) error httpResponse: (NSHTTPURLResponse*) httpResponse finishedBlock: (void (^)(LeaguevineInvokeStatus, NSArray* leagues)) finishedBlock {
    NSLog(@"Request to %@ failed with http response %d error %@", url, httpResponse.statusCode, error);
    finishedBlock(LeaguevineInvokeInvalidResponse, nil);
}

-(void)invokeFailedTo: (NSString*) url withMissingMetaPropertyInResponse: (NSData*) responseData finishedBlock: (void (^)(LeaguevineInvokeStatus, NSArray* leagues)) finishedBlock {
    NSLog(@"Request to %@ failed. Response is missing meta property.  Response: %@", url, [NSString stringFromData: responseData]);
    finishedBlock(LeaguevineInvokeInvalidResponse, nil);
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
