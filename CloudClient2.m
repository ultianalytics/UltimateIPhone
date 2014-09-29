//
//  CloudClient2.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 9/29/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "CloudClient2.h"
#import "GoogleOAuth2Authenticator.h"
#import "Team.h"
#import "Game.h"
#import "GameDescription.h"
#import "Preferences.h"
#import "CloudMetaInfo.h"
#import "Scrubber.h"
#import "Reachability.h"
#import "UploadDownloadTracker.h"


#define kHostHame @"https://ultimate-team.appspot.com"
#define kWebHostHame @"http://www.ultianalytics.com"
//#define kHostHame @"http://local.appspot.com:8888"
//#define kHostHame @"http://local.appspot.com:8890" // tcp monitor

@implementation CloudClient2

+(NSString*) getBaseUrl {
    return kHostHame;
}

+(NSString*) getBaseWebUrl {
    return kWebHostHame;
}

+(BOOL)isConnected {
    Reachability* reachability = [Reachability reachabilityForInternetConnection];
    return ![reachability currentReachabilityStatus] == NotReachable;
}

+(void) signOff {
    [[GoogleOAuth2Authenticator sharedAuthenticator] signOut];
}

+(BOOL) isSignedOn {
    return [[GoogleOAuth2Authenticator sharedAuthenticator] hasBeenAuthenticated];
}

+(void) downloadTeamsAtCompletion:  (void (^)(CloudRequestStatus status, NSArray* teams)) completion {
    [self get:@"/rest/mobile/teams" completion:^(CloudRequestStatus status, NSData *responseData) {
        if (status == CloudRequestStatusOk) {
            NSError* unmarshallingError = nil;
            if (responseData) {
                NSArray* responseArray = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&unmarshallingError];
                if (unmarshallingError) {
                    completion(CloudRequestStatusMarshallingError, nil);
                } else {
                    NSMutableArray* teams = [NSMutableArray array];
                    for (NSDictionary* teamAsDictionary in responseArray) {
                        Team* team = [Team fromDictionary:teamAsDictionary];
                        [teams addObject:team];
                    }
                    completion(status, teams);
                }
            }
        } else {
            completion(status,  nil);
        }
    }];
}

+(void) get: (NSString*) relativeUrl completion:  (void (^)(CloudRequestStatus status, NSData* responseData)) completion {
    NSAssert(completion, @"completion block required");
    if ([self isConnected]) {
        if ([[GoogleOAuth2Authenticator sharedAuthenticator] hasBeenAuthenticated]) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",  [self getBaseUrl], relativeUrl]];
            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPMethod:@"GET"];
            [[GoogleOAuth2Authenticator sharedAuthenticator] authorizeRequest:request completionHandler:^(AuthenticationStatus status) {
                if (status == AuthenticationStatusOk) {
                    NSURLSession *session = [NSURLSession sharedSession];
                    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *sendError) {
                        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                        if (sendError == nil && response != nil && [httpResponse statusCode] == 200) {
                            SHSLog(@"http GET successful");
                            completion(CloudRequestStatusOk, data);
                        } else {
                            CloudRequestStatus errorStatus = [self errorCodeFromResponse:httpResponse error:sendError];
                            NSString* httpStatus = response == nil ? @"Unknown" :  [NSString stringWithFormat:@"%ld", (long)httpResponse.statusCode];
                            SHSLog(@"Failed http GET request. Cloud status code = %@. Server returned HTTP status code %@. More Info = %@", [self statusCodeDescripton:errorStatus], httpStatus, sendError);
                            completion(errorStatus, nil);
                        }
                    }] resume];
                } else {
                    completion(CloudRequestStatusUnauthorized,  nil);
                }
            }];
        } else {
            completion(CloudRequestStatusUnauthorized,  nil);
        }
    } else {
        completion(CloudRequestStatusNotConnectedToInternet,  nil);
    }
}


+(CloudRequestStatus) errorCodeFromResponse: (NSHTTPURLResponse*) httpResponse error: (NSError*) sendError {
    if (httpResponse.statusCode == 401) {
        return CloudRequestStatusUnauthorized;
    } else if (sendError && sendError.code == NSURLErrorUserCancelledAuthentication) {
        // 401's aren't handled correctly in synch http requests...this is the workaround...
        return CloudRequestStatusUnauthorized;
    }
    return CloudRequestStatusUnknownError;
}

+(NSString*) statusCodeDescripton: (CloudRequestStatus) status {
    switch (status) {
        case CloudRequestStatusOk:
            return @"OK";
            break;
        case CloudRequestStatusUnauthorized:
            return @"Unauthorized";
            break;
        case CloudRequestStatusNotConnectedToInternet:
            return @"NotConnectedToInternet";
            break;
        case CloudRequestStatusMarshallingError:
            return @"MarshallingError";
            break;
        case CloudRequestStatusUnacceptableAppVersion:
            return @"UnacceptableAppVersion";
            break;
        case CloudRequestStatusUnknownError:
            return @"UnknownError";
            break;
        default:
            return @"UNKNOWN STATUS";
            break;
    }
}

@end




