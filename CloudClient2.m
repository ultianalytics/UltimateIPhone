//
//  CloudClient2.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 9/29/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "CloudClient2.h"
#import "CloudRequestStatus.h"
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

+(void) downloadTeamsAtCompletion:  (void (^)(CloudRequestStatus* requestStatus, NSArray* teams)) completion {
    [self getObjectsFromUrl:@"/rest/mobile/teams" completion:^(CloudRequestStatus* getObjectsStatus, NSArray* arrayOfDictionaries) {
        if (getObjectsStatus.ok) {
            NSMutableArray* teams = [NSMutableArray array];
            for (NSDictionary* teamAsDictionary in arrayOfDictionaries) {
                Team* team = [Team fromDictionary:teamAsDictionary];
                [teams addObject:team];
            }
            completion(getObjectsStatus, teams);
        } else {
            completion(getObjectsStatus,  nil);
        }
    }];
}

// return teamId
+(void) downloadTeam: (NSString*) cloudId atCompletion:  (void (^)(CloudRequestStatus* requestStatus, NSString* teamId)) completion {
    [self getObjectFromUrl:[NSString stringWithFormat: @"/rest/mobile/team/%@?players=true", cloudId] completion:^(CloudRequestStatus* getObjectStatus, NSDictionary* objectAsDictionary) {
        if (getObjectStatus.ok) {
            Team* team = [Team fromDictionary:objectAsDictionary];
            NSString* existingTeamId = [Team getTeamIdForCloudId:cloudId];
            if (existingTeamId) {
                team.teamId = existingTeamId;
            }
            [team save];
            [Team setCurrentTeam: team.teamId];
            completion(getObjectStatus, team.teamId);
        } else {
            completion(getObjectStatus,  nil);
        }
    }];
}

+(void) downloadGameDescriptionsForTeam: (NSString*) teamCloudId atCompletion:  (void (^)(CloudRequestStatus* requestStatus, NSArray* gameDescriptions)) completion {
    [self getObjectsFromUrl:[NSString stringWithFormat:@"/rest/mobile/team/%@/games", teamCloudId] completion:^(CloudRequestStatus* getObjectsStatus, NSArray* arrayOfDictionaries) {
        if (getObjectsStatus.ok) {
            NSMutableArray* games = [NSMutableArray array];
            for (NSDictionary* gameAsDictionary in arrayOfDictionaries) {
                GameDescription* game = [GameDescription fromDictionary:gameAsDictionary];
                [games addObject:game];
            }
            completion(getObjectsStatus, games);
        } else {
            completion(getObjectsStatus,  nil);
        }
    }];
}

+(void) downloadGame: (NSString*) gameId forTeam: (NSString*) teamCloudId atCompletion: (void (^)(CloudRequestStatus* requestStatus)) completion {
    [self getObjectFromUrl:[NSString stringWithFormat: @"/rest/mobile/team/%@/game/%@", teamCloudId, gameId] completion:^(CloudRequestStatus* getObjectStatus, NSDictionary* objectAsDictionary) {
        if (getObjectStatus.ok) {
            Game* game = [Game fromDictionary:objectAsDictionary];
            [game save];
            [UploadDownloadTracker updateLastUploadOrDownloadTime:game.lastSaveGMT forGameId:game.gameId inTeamId:[Team getCurrentTeam].teamId];
            completion(getObjectStatus);
        } else {
            completion(getObjectStatus);
        }
    }];
}

+(void) downloadCloudMetaDataAtCompletion:  (void (^)(CloudRequestStatus* status, CloudMetaInfo* metaInfo)) completion {
    // endpoint needs current app version
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    appVersion = [appVersion stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    NSString* metaDataRelativeUrl = [NSString stringWithFormat:@"/rest/mobile/meta/%@", appVersion];
    
    [self getObjectFromUrl:metaDataRelativeUrl completion:^(CloudRequestStatus* status, NSDictionary* objectAsDictionary) {
        if (status == CloudRequestStatusCodeOk) {
            completion(status, [CloudMetaInfo fromDictionary:objectAsDictionary]);
        } else {
            completion(status,  nil);
        }
    }];
}

+(void) getObjectFromUrl: (NSString*) relativeUrl completion:  (void (^)(CloudRequestStatus* requestStatus, NSDictionary* objectAsDictionary)) completion {
    [self getDataFromUrl:relativeUrl completion:^(CloudRequestStatus* getDataStatus, NSData *responseData) {
        if (getDataStatus.ok) {
            NSError* unmarshallingError = nil;
            if (responseData) {
                NSDictionary* responseJsonAsDict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&unmarshallingError];
                if (unmarshallingError) {
                    completion([CloudRequestStatus status: CloudRequestStatusCodeMarshallingError], nil);
                } else {
                    completion([CloudRequestStatus status: CloudRequestStatusCodeOk], responseJsonAsDict);
                }
            }
        } else {
            completion(getDataStatus,  nil);
        }
    }];
}

+(void) getObjectsFromUrl: (NSString*) relativeUrl completion:  (void (^)(CloudRequestStatus* requestStatus, NSArray* arrayOfDictionaries)) completion {
    [self getDataFromUrl:relativeUrl completion:^(CloudRequestStatus* getDataStatus, NSData *responseData) {
        if (getDataStatus.ok) {
            NSError* unmarshallingError = nil;
            if (responseData) {
                NSArray* responseAsArrayOfDict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&unmarshallingError];
                if (unmarshallingError) {
                    completion([CloudRequestStatus status: CloudRequestStatusCodeMarshallingError], nil);
                } else {
                    completion([CloudRequestStatus status: CloudRequestStatusCodeOk], responseAsArrayOfDict);
                }
            }
        } else {
            completion(getDataStatus,  nil);
        }
    }];
}

+(void) verifyAppVersionAndThenGetDataFromUrl: (NSString*) relativeUrl completion:  (void (^)(CloudRequestStatus* requestStatus, NSData* responseData)) completion {
    [self verifyAppVersionAtCompletion:^(CloudRequestStatus *verifyStatus) {
        if (verifyStatus.ok) {
            [self getDataFromUrl:relativeUrl completion:^(CloudRequestStatus *getDataStatus, NSData *responseData) {
                completion(getDataStatus, responseData);
            }];
        } else {
            completion(verifyStatus, nil);
        }
    }];
}

+(void) verifyAppVersionAtCompletion:  (void (^)(CloudRequestStatus* status)) completion {
    [self downloadCloudMetaDataAtCompletion:^(CloudRequestStatus *status, CloudMetaInfo *metaInfo) {
        if (status.ok && !metaInfo.isAppVersionAcceptable) {
            CloudRequestStatus* unacceptableAppStatus = [CloudRequestStatus status: CloudRequestStatusCodeUnacceptableAppVersion];
            status.explanation = metaInfo.messageToUser;
            SHSLog(@"App at unacceptable version: %@", metaInfo.messageToUser);
            completion(unacceptableAppStatus);
        } else {
            completion(status);
        }
    }];
}

+(void) getDataFromUrl: (NSString*) relativeUrl completion:  (void (^)(CloudRequestStatus* requestStatus, NSData* responseData)) completion {
    NSAssert(completion, @"completion block required");
    if ([self isConnected]) {
        if ([[GoogleOAuth2Authenticator sharedAuthenticator] hasBeenAuthenticated]) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",  [self getBaseUrl], relativeUrl]];
            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPMethod:@"GET"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setCachePolicy: NSURLRequestReloadIgnoringLocalAndRemoteCacheData]; // cache buster
            [[GoogleOAuth2Authenticator sharedAuthenticator] authorizeRequest:request completionHandler:^(AuthenticationStatus authStatus) {
                if (authStatus == AuthenticationStatusOk) {
                    NSURLSession *session = [NSURLSession sharedSession];
                    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *sendError) {
                        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                        if (sendError == nil && response != nil && [httpResponse statusCode] == 200) {
                            SHSLog(@"http GET successful");
                            completion(CloudRequestStatusCodeOk, data);
                        } else {
                            CloudRequestStatusCode errorStatus = [self errorCodeFromResponse:httpResponse error:sendError];
                            NSString* httpStatus = response == nil ? @"Unknown" :  [NSString stringWithFormat:@"%ld", (long)httpResponse.statusCode];
                            SHSLog(@"Failed http GET request. Cloud status code = %@. Server returned HTTP status code %@. More Info = %@", [self statusCodeDescripton:errorStatus], httpStatus, sendError);
                            completion([CloudRequestStatus status: errorStatus], nil);
                        }
                    }] resume];
                } else {
                    completion([CloudRequestStatus status: CloudRequestStatusCodeUnauthorized],  nil);
                }
            }];
        } else {
            completion([CloudRequestStatus status: CloudRequestStatusCodeUnauthorized],  nil);
        }
    } else {
        completion([CloudRequestStatus status: CloudRequestStatusCodeNotConnectedToInternet],  nil);
    }
}

+(CloudRequestStatusCode) errorCodeFromResponse: (NSHTTPURLResponse*) httpResponse error: (NSError*) sendError {
    if (httpResponse.statusCode == 401) {
        return CloudRequestStatusCodeUnauthorized;
    } else if (sendError && sendError.code == NSURLErrorUserCancelledAuthentication) {
        // 401's aren't handled correctly in synch http requests...this is the workaround...
        return CloudRequestStatusCodeUnauthorized;
    }
    return CloudRequestStatusCodeUnknownError;
}

+(NSString*) statusCodeDescripton: (CloudRequestStatusCode) status {
    switch (status) {
        case CloudRequestStatusCodeOk:
            return @"OK";
            break;
        case CloudRequestStatusCodeUnauthorized:
            return @"Unauthorized";
            break;
        case CloudRequestStatusCodeNotConnectedToInternet:
            return @"NotConnectedToInternet";
            break;
        case CloudRequestStatusCodeMarshallingError:
            return @"MarshallingError";
            break;
        case CloudRequestStatusCodeUnacceptableAppVersion:
            return @"UnacceptableAppVersion";
            break;
        case CloudRequestStatusCodeUnknownError:
            return @"UnknownError";
            break;
        default:
            return @"UNKNOWN STATUS";
            break;
    }
}

@end




