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

-(void)retrieveLeagues: (void (^)(LeaguevineInvokeStatus, NSArray* leagues)) finishedBlock {
    NSString* url = [self fullUrl:[NSString stringWithFormat:@"leagues?access_token=%@&order_by=%@", self.token, [@"[name]" urlEncoded]]];
    [self doGet:url errorBlock:finishedBlock okBlock:^(NSDictionary* responseDict){
        
    }];
}

#pragma mark Generalized invokers

-(void)doGet: (NSString*) url errorBlock: (void (^)(LeaguevineInvokeStatus, NSArray* leagues)) finishedBlock okBlock: (void (^)(NSDictionary* responseDict)) responseOKBlock  {
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
