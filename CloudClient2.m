//
//  CloudClient2.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 9/29/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "CloudClient2.h"
#import "CloudRequestStatus.h"
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

#define kTeamIdKey          @"teamId"
#define kCloudIdKey         @"cloudId"

@implementation CloudClient2

#pragma mark - Public - Miscelleanous

+(NSString*) getBaseUrl {
    return kHostHame;
}

+(NSString*) getBaseWebUrl {
    return kWebHostHame;
}

+(BOOL)isConnected {
    Reachability* reachability = [Reachability reachabilityForInternetConnection];
    return !([reachability currentReachabilityStatus] == NotReachable);
}

+(void) signOff {
    [self setAccessToken:nil];
    [Preferences getCurrentPreferences].userid = nil;
    [[Preferences getCurrentPreferences] save];
}

+(BOOL) isSignedOn {
    return [Preferences getCurrentPreferences].accessToken != nil;
}

+(void) setAccessToken: (NSString*) accessToken {
    [Preferences getCurrentPreferences].accessToken = accessToken;
    [[Preferences getCurrentPreferences] save];
}

+(NSString*) getWebsiteURL: (Team*) team {
    if (team.cloudId != nil && ![team.cloudId isEqualToString: @""]) {
        return [NSString stringWithFormat:@"%@/team/%@/main", [self getBaseWebUrl], team.cloudId];
    }
    return nil;
}

#pragma mark - Public - Downloading

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

#pragma mark - Public - Uploading

+(void)uploadTeam:(Team*) team completion: (void (^)(CloudRequestStatus* requestStatus)) completion {
    NSDictionary* teamAsDict = [team asDictionaryWithScrubbing:[Scrubber currentScrubber].isOn];
    [self postObject:teamAsDict toUrl:@"/rest/mobile/team" completion:^(CloudRequestStatus *requestStatus, NSDictionary *responseObjectAsDictionary) {
        if (requestStatus.ok) {
            [Team getCurrentTeam].cloudId = [responseObjectAsDictionary objectForKey:kCloudIdKey];
            [[Team getCurrentTeam] save];
        }
        completion(requestStatus);
    }];
}

+(void)uploadTeam:(Team*) team withGames: (NSArray*) gameIds completion: (void (^)(CloudRequestStatus* requestStatus)) completion {
    [self uploadTeam:team completion:^(CloudRequestStatus *teamUploadStatus) {
        if (teamUploadStatus.ok) {
            [self uploadNextGameForTeam:team withGames:gameIds completion:completion];
        } else {
            completion(teamUploadStatus);
        }
    }];
}

+(void)uploadNextGameForTeam:(Team*) team withGames: (NSArray*) gameIds completion: (void (^)(CloudRequestStatus* requestStatus)) allGamesCompleteCompletion {
    // all games uploaded?  invoke the original completion block
    if ([gameIds count] == 0) {
        allGamesCompleteCompletion([CloudRequestStatus status: CloudRequestStatusCodeOk]);
    // otherwise, upload the next game
    } else {
        NSMutableArray* remainingGames = [gameIds mutableCopy];
        NSString* nextGameId = [remainingGames lastObject];
        [remainingGames removeLastObject];
        [self uploadGame:nextGameId forTeam:team.teamId completion:^(CloudRequestStatus *uploadStatus) {
            if (uploadStatus.ok) {
                [self uploadNextGameForTeam:team withGames:remainingGames completion:allGamesCompleteCompletion];
            } else {
                allGamesCompleteCompletion(uploadStatus);
            }
        }];
    }
}

+(void)uploadGame: (NSString*)gameId forTeam: (NSString*)teamId completion: (void (^)(CloudRequestStatus* requestStatus)) completion {
    Team* team = [Team readTeam:teamId];
    if (!team) {
        SHSLog(@"Unable to read team for upload of game");
        completion([CloudRequestStatus status: CloudRequestStatusCodeUnknownError]);
    } else {
        Game* game = [Game readGame:gameId forTeam:teamId mergePlayersWithCurrentTeam:NO];
        if (!game) {
            SHSLog(@"Unable to read game for upload of game");
            completion([CloudRequestStatus status: CloudRequestStatusCodeUnknownError]);
        } else {
            NSDictionary* gameAsDict = [game asDictionaryWithScrubbing:[Scrubber currentScrubber].isOn];
            [gameAsDict setValue:team.cloudId forKey:kTeamIdKey];
            [self postObject:gameAsDict toUrl:@"/rest/mobile/game" completion:^(CloudRequestStatus *postStatus, NSDictionary *responseObjectAsDictionary) {
                if (postStatus.ok) {
                    [UploadDownloadTracker updateLastUploadOrDownloadTime:game.lastSaveGMT forGameId:game.gameId inTeamId:team.teamId];
                }
                completion(postStatus);
            }];
        }
    }
}


#pragma mark - Private - Uploading

+(void) postObject: (NSDictionary*) objectAsDictionary toUrl: (NSString*) relativeUrl completion: (void (^)(CloudRequestStatus* requestStatus, NSDictionary* responseObjectAsDictionary)) completion {
    NSError* marshallError = nil;
    NSData* objectAsJson = [NSJSONSerialization dataWithJSONObject:objectAsDictionary options:0 error:&marshallError];
    if (marshallError) {
        SHSLog(@"Error attempting to marshall object %@ to JSON for upload: %@", objectAsDictionary, marshallError);
        completion([CloudRequestStatus status: CloudRequestStatusCodeMarshallingError], nil);
    } else {
        [self postData:objectAsJson toUrl:relativeUrl completion:^(CloudRequestStatus *requestStatus, NSData *responseData) {
            if (requestStatus.ok) {
                if (responseData != nil && responseData.length > 0) {
                    NSError* unmarshallingError = nil;
                    NSDictionary* responseJsonAsDict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&unmarshallingError];
                    if (unmarshallingError) {
                        SHSLog(@"Error attempting to unmarshall upload response data: %@", unmarshallingError);
                        completion([CloudRequestStatus status: CloudRequestStatusCodeMarshallingError], nil);
                    } else {
                        completion([CloudRequestStatus status: CloudRequestStatusCodeOk], responseJsonAsDict);
                    }
                } else {
                    completion([CloudRequestStatus status: CloudRequestStatusCodeOk], nil);
                }
            } else {
                completion(requestStatus, nil);
            }
        }];
    }
}

+(void) verifyAppVersionAndPostData: (NSData*) data toUrl: (NSString*) relativeUrl completion: (void (^)(CloudRequestStatus* requestStatus, NSData* responseData)) completion {
    [self verifyAppVersionAtCompletion:^(CloudRequestStatus *verifyStatus) {
        if (verifyStatus.ok) {
            [self postData:data toUrl:relativeUrl completion:completion];
        } else {
            completion(verifyStatus, nil);
        }
    }];
}

+(void) postData: (NSData*) data toUrl: (NSString*) relativeUrl completion: (void (^)(CloudRequestStatus* requestStatus, NSData* responseData)) completion {
    NSAssert(completion, @"completion block required");
    if ([self isConnected]) {
        NSString* accessToken = [Preferences getCurrentPreferences].accessToken;
        if (accessToken) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",  [self getBaseUrl], relativeUrl]];
            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setCachePolicy: NSURLRequestReloadIgnoringLocalAndRemoteCacheData]; // cache buster
            [request setValue:[NSString stringWithFormat:@"Bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
            [self postData:data inRequest:request completion:completion];
        } else {
            SHSLog(@"http POST not attempted: no authentication was done previously");
            completion([CloudRequestStatus status: CloudRequestStatusCodeUnauthorized],  nil);
        }
    } else {
        SHSLog(@"http POST not attempted: device is not connected to net");
        completion([CloudRequestStatus status: CloudRequestStatusCodeNotConnectedToInternet],  nil);
    }
}

+(void) postData: (NSData*) data inRequest: (NSURLRequest*) request completion: (void (^)(CloudRequestStatus* requestStatus, NSData* responseData)) completion {
    [[[NSURLSession sharedSession] uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *sendError) {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        if (sendError == nil && [httpResponse statusCode] == 200) {
            SHSLog(@"http POST successful.  URL is %@", request.URL.absoluteString);
            completion([CloudRequestStatus status: CloudRequestStatusCodeOk], data);
        } else {
            CloudRequestStatusCode errorStatus = [self errorCodeFromResponse:httpResponse error:sendError];
            NSString* httpStatus = response == nil ? @"Unknown" :  [NSString stringWithFormat:@"%ld", (long)httpResponse.statusCode];
            SHSLog(@"Failed http POST request. Cloud status code = %@. Server returned HTTP status code %@. More Info = %@", [CloudRequestStatus statusCodeDescripton:errorStatus], httpStatus, sendError);
            completion([CloudRequestStatus status: errorStatus], nil);
        }
    }] resume];
}

#pragma mark - Private - Downloading

+(void) getObjectFromUrl: (NSString*) relativeUrl completion:  (void (^)(CloudRequestStatus* requestStatus, NSDictionary* objectAsDictionary)) completion {
    [self verifyAppVersionAndGetDataFromUrl:relativeUrl completion:^(CloudRequestStatus *verifyAndGetStatus, NSData *responseData) {
        if (verifyAndGetStatus.ok) {
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
            completion(verifyAndGetStatus,  nil);
        }
    }];
}

+(void) getObjectsFromUrl: (NSString*) relativeUrl completion:  (void (^)(CloudRequestStatus* requestStatus, NSArray* arrayOfDictionaries)) completion {
    [self verifyAppVersionAndGetDataFromUrl:relativeUrl completion:^(CloudRequestStatus *verifyAndGetStatus, NSData *responseData) {
        if (verifyAndGetStatus.ok) {
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
            completion(verifyAndGetStatus,  nil);
        }
    }];
}

+(void) verifyAppVersionAndGetDataFromUrl: (NSString*) relativeUrl completion:  (void (^)(CloudRequestStatus* requestStatus, NSData* responseData)) completion {
    [self verifyAppVersionAtCompletion:^(CloudRequestStatus *verifyStatus) {
        if (verifyStatus.ok) {
            [self getDataFromUrl:relativeUrl completion:completion];
        } else {
            completion(verifyStatus, nil);
        }
    }];
}

+(void) getDataFromUrl: (NSString*) relativeUrl completion:  (void (^)(CloudRequestStatus* requestStatus, NSData* responseData)) completion {
    NSAssert(completion, @"completion block required");
    if ([self isConnected]) {
        NSString* accessToken = [Preferences getCurrentPreferences].accessToken;
        if (accessToken) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",  [self getBaseUrl], relativeUrl]];
            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPMethod:@"GET"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setCachePolicy: NSURLRequestReloadIgnoringLocalAndRemoteCacheData]; // cache buster
            [request setValue:[NSString stringWithFormat:@"Bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
            [self getDataFromRequest:request completion:completion];
        } else {
            SHSLog(@"http GET not attempted: no authentication was done previously");
            completion([CloudRequestStatus status: CloudRequestStatusCodeUnauthorized],  nil);
        }
    } else {
        SHSLog(@"http GET not attempted: device is not connected to net");
        completion([CloudRequestStatus status: CloudRequestStatusCodeNotConnectedToInternet],  nil);
    }
}

+(void) getDataFromRequest: (NSURLRequest*) request completion:  (void (^)(CloudRequestStatus* requestStatus, NSData* responseData)) completion {
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *sendError) {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        if (sendError == nil && response != nil && [httpResponse statusCode] == 200) {
            SHSLog(@"http GET successful.  URL is %@", request.URL.absoluteString);
            completion([CloudRequestStatus status: CloudRequestStatusCodeOk], data);
        } else {
            CloudRequestStatusCode errorStatus = [self errorCodeFromResponse:httpResponse error:sendError];
            NSString* httpStatus = response == nil ? @"Unknown" :  [NSString stringWithFormat:@"%ld", (long)httpResponse.statusCode];
            SHSLog(@"Failed http GET request. Cloud status code = %@. Server returned HTTP status code %@. More Info = %@.  URL is %@", [CloudRequestStatus statusCodeDescripton:errorStatus], httpStatus, sendError, request.URL.absoluteString);
            completion([CloudRequestStatus status: errorStatus], nil);
        }
    }] resume];
}

#pragma mark - Private - Verify App Version

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

+(void) downloadCloudMetaDataAtCompletion:  (void (^)(CloudRequestStatus* status, CloudMetaInfo* metaInfo)) completion {
    // add app version to URL
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    appVersion = [appVersion stringByReplacingOccurrencesOfString:@"." withString:@"_"];  // make the version URL safe
    NSString* metaDataRelativeUrl = [NSString stringWithFormat:@"/rest/mobile/meta/%@", appVersion];
    
    [self getDataFromUrl:metaDataRelativeUrl completion:^(CloudRequestStatus* getDataStatus, NSData *responseData) {
        if (getDataStatus.ok) {
            NSError* unmarshallingError = nil;
            if (responseData) {
                NSDictionary* responseJsonAsDict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&unmarshallingError];
                if (unmarshallingError) {
                    SHSLog(@"error unmarshalling meta data from sever");
                    completion([CloudRequestStatus status: CloudRequestStatusCodeMarshallingError], nil);
                } else {
                    completion([CloudRequestStatus status: CloudRequestStatusCodeOk], [CloudMetaInfo fromDictionary:responseJsonAsDict]);
                }
            } else {
                SHSLog(@"meta data endpoint did not return a response");
                completion([CloudRequestStatus status: CloudRequestStatusCodeUnknownError], nil);
            }
        } else {
            completion(getDataStatus,  nil);
        }
    }];
}

#pragma mark - Private - Miscellaneous


+(CloudRequestStatusCode) errorCodeFromResponse: (NSHTTPURLResponse*) httpResponse error: (NSError*) sendError {
    if (httpResponse.statusCode == 401) {
        return CloudRequestStatusCodeUnauthorized;
    } else if (sendError && sendError.code == NSURLErrorUserCancelledAuthentication) {
        // 401's aren't handled correctly in synch http requests...this is the workaround...
        return CloudRequestStatusCodeUnauthorized;
    }
    return CloudRequestStatusCodeUnknownError;
}

+(BOOL)isLocalTestMode {
    NSString* host = kHostHame;
    return [host contains:@"local"];
}

@end




