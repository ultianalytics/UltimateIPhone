//
//  CloudClient.m
//  Ultimate
//
//  Created by Jim Geppert on 3/7/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "CloudClient.h"
#import "Team.h"
#import "Game.h"
#import "GameDescription.h"
#import "Preferences.h"
#import "CloudMetaInfo.h"
#import "Scrubber.h"
#import "TestFlight.h"
#import "Reachability.h"

#define kHostHame @"www.ultimate-numbers.com"
//#define kHostHame @"local.appspot.com:8888"
//#define kHostHame @"local.appspot.com:8890" // tcp monitor
//#define [CloudClient getBaseUrl] @"http://www.ultimate-numbers.com"
//#define [CloudClient getBaseUrl] @"http://local.appspot.com:8888"

// private methods
@interface CloudClient() 

+(NSData*) upload: (NSDictionary*) objectAsDictionary relativeUrl: (NSString*) relativeUrl error:(NSError**) uploadError;
+(void) uploadGame: (Game*) game ofTeam: (Team*) team error:(NSError**) uploadError;
+(CloudError) errorCodeFromResponse: (NSHTTPURLResponse*) httpResponse error: (NSError*) sendError;
+(void) saveTeamCloudId:(NSData *)responseJSON;
+(NSData*) get: (NSString*) relativeUrl error: (NSError**) getError; 
+(void) verifyConnection: (NSError**) uploadError;

@end

@implementation CloudClient

#pragma mark - Upload Team and Games

+(void) uploadTeam: (Team*) team error:(NSError**) uploadError {
    NSError* error = nil;
    NSData* responseJSON = [CloudClient upload: [team asDictionaryWithScrubbing: [Scrubber currentScrubber].isOn] relativeUrl: @"/rest/mobile/team" error: &error];
    if (responseJSON) {
        [self saveTeamCloudId:responseJSON];
    }
    *uploadError = error;
}

+(void) uploadTeam: (Team*) team withGames: (NSArray*) gameIds error:(NSError**) uploadError {
    NSError* error = nil;
    [CloudClient uploadTeam:team error:&error];
    if (!error) {
        for (NSString* gameId in gameIds) {
            Game* game = [Game readGame:gameId];
            [CloudClient uploadGame:game ofTeam: team error:&error]; 
            if (error) {
                break;
            }
        }
    }
    *uploadError = error;
}

+(void) uploadGame: (Game*) game ofTeam: (Team*) team error:(NSError**) uploadError {
    NSError* error = nil;
    NSMutableDictionary* gameAsDict = [game asDictionaryWithScrubbing:[Scrubber currentScrubber].isOn];
    [gameAsDict setValue:team.cloudId forKey:kTeamIdKey];
    [CloudClient upload: gameAsDict relativeUrl: @"/rest/mobile/game" error: &error];
    *uploadError = error;
}

+ (void)saveTeamCloudId:(NSData *)responseJSON {
    NSError* unmarshallingError = nil;
    NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:responseJSON options:0 error:&unmarshallingError];
    if (unmarshallingError == nil) { 
        [Team getCurrentTeam].cloudId = [responseDict objectForKey:kCloudIdKey]; 
        [[Team getCurrentTeam] save];
    }
}

#pragma mark - Download Team

+(NSArray*) getTeams: (NSError**) getError {
    NSError* sendError = nil;
    NSData* responseJson = [CloudClient get: @"/rest/mobile/teams" error: &sendError];
    NSMutableArray* teams = [[NSMutableArray alloc] init];
    NSError* unmarshallingError = nil;
    if (responseJson) {
        NSArray* responseArray = [NSJSONSerialization JSONObjectWithData:responseJson options:0 error:&unmarshallingError]; 
        for (NSDictionary* teamAsDictionary in responseArray) {
            Team* team = [Team fromDictionary:teamAsDictionary];
            [teams addObject:team];
        }
    }
    *getError = sendError == nil ? unmarshallingError : sendError;
    return teams;
}

// return teamId
+(NSString*) downloadTeam: (NSString*) cloudId error: (NSError**) getError {
    NSError* sendError = nil;
    NSData* responseJson = [CloudClient get: [NSString stringWithFormat: @"/rest/mobile/team/%@?players=true", cloudId ] error: &sendError];
    Team* team = nil;
    NSError* unmarshallingError = nil;
    if (responseJson) {
        NSDictionary* teamAsDictionary = [NSJSONSerialization JSONObjectWithData:responseJson options:0 error:&unmarshallingError];
        if (!unmarshallingError) {
            team = [Team fromDictionary:teamAsDictionary];
        }
    }
    *getError = sendError == nil ? unmarshallingError : sendError;
    if(!unmarshallingError && !sendError) {
        NSString* existingTeamId = [Team getTeamIdForCloudId:cloudId];
        if (existingTeamId) {
            team.teamId = existingTeamId;
        }
        [team save];
        [Team setCurrentTeam: team.teamId];
    }
    return team.teamId;
}


#pragma mark - Download game

+(NSArray*) getGameDescriptions: (NSString*) teamCloudId error: (NSError**) getError {
    NSError* sendError = nil;
    NSString* url = [NSString stringWithFormat:@"/rest/mobile/team/%@/games", teamCloudId];
    NSData* responseJson = [CloudClient get: url error: &sendError];
    NSMutableArray* games = [[NSMutableArray alloc] init];
    NSError* unmarshallingError = nil;
    if (responseJson) {
        NSArray* responseArray = [NSJSONSerialization JSONObjectWithData:responseJson options:0 error:&unmarshallingError]; 
        for (NSDictionary* gameAsDictionary in responseArray) {
            GameDescription* game = [GameDescription fromDictionary:gameAsDictionary];
            [games addObject:game];
        }
    }
    *getError = sendError == nil ? unmarshallingError : sendError;
    return games;
}

+(void) downloadGame: (NSString*) gameId forTeam: (NSString*) teamCloudId error: (NSError**) getError {
    NSError* sendError = nil;
    NSData* responseJson = [CloudClient get: [NSString stringWithFormat: @"/rest/mobile/team/%@/game/%@", teamCloudId, gameId ] error: &sendError];
    Game* game = nil;
    NSError* unmarshallingError = nil;
    if (responseJson) {
        NSDictionary* gameAsDictionary = [NSJSONSerialization JSONObjectWithData:responseJson options:0 error:&unmarshallingError];
        if (!unmarshallingError) {
            game = [Game fromDictionary:gameAsDictionary];
        }
    }
    *getError = sendError == nil ? unmarshallingError : sendError;
    if(!unmarshallingError && !sendError) {
        [game save];
    }
}

#pragma mark - Signon/Signoff

+(BOOL) isSignedOn { 
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",  [CloudClient getBaseUrl], @"/rest/mobile/test"]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setCachePolicy: NSURLRequestReloadIgnoringLocalAndRemoteCacheData]; // cache buster
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSHTTPURLResponse* response = nil;
    NSError* sendError = nil;
    
    NSData* data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&sendError];
    SHSLog(@"URL response: %@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    BOOL isSignedOn = response != nil && [response statusCode] == 200;
    SHSLog(@"Http response status code = %d",[response statusCode]);
    SHSLog(@"Is Signed On ? %@",isSignedOn ? @"YES" : @"NO");
    return isSignedOn;
}


+(void) signOff {
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie* cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie: cookie];
    }
    [Preferences getCurrentPreferences].userid = nil;
    [[Preferences getCurrentPreferences] save];
}

#pragma mark - Get Cloud Meta Information

+(CloudMetaInfo*) getCloudMetaInfo: (NSError**) getError {
    NSError* sendError = nil;
    NSData* responseJson = [CloudClient get: @"/rest/mobile/meta" error: &sendError];
    CloudMetaInfo* metaInfo = nil;
    NSError* unmarshallingError = nil;
    if (responseJson) {
        NSDictionary* metaInfoAsDictionary = [NSJSONSerialization JSONObjectWithData:responseJson options:0 error:&unmarshallingError];
        if (!unmarshallingError) {
            metaInfo = [CloudMetaInfo fromDictionary:metaInfoAsDictionary];
        }
    }
    *getError = sendError == nil ? unmarshallingError : sendError;
    return metaInfo;
}

#pragma mark - Miscellaneous

+(NSData*) get: (NSString*) relativeUrl error: (NSError**) getError {
    NSData* responseJSON = nil;
    if ([Preferences getCurrentPreferences].userid == nil) {
        // don't bother making a request if we don't know the user
        *getError = [NSError errorWithDomain:[CloudClient getBaseUrl] code: Unauthorized userInfo:nil];
    } else {
        NSHTTPURLResponse* response = nil;
        NSError* sendError = nil;
        [CloudClient verifyConnection:&sendError];
        if (!sendError) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",  [CloudClient getBaseUrl], relativeUrl]];
            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPMethod:@"GET"];
            
            responseJSON = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&sendError];
            if (sendError == nil && response != nil && [response statusCode] == 200) {
                SHSLog(@"http GET successful");
            } else {
                *getError = [NSError errorWithDomain:[CloudClient getBaseUrl] code: [CloudClient errorCodeFromResponse: response error: sendError] userInfo:nil];
                SHSLog(@"Failed http GET request.  Returning error %@.  The HTTP status code was = %d, More Info = %@", *getError, response == nil ? 0 :  [response statusCode], sendError);
            }
        } else {
            *getError = sendError;
        }
    }
    return responseJSON;
}

// upload the object (passed as a ditionary).  answer the resonse json
+(NSData*) upload: (NSDictionary*) objectAsDictionary relativeUrl: (NSString*) relativeUrl error:(NSError**) uploadError {
    NSData* responseJSON = nil;
    if ([Preferences getCurrentPreferences].userid == nil) {
        // don't bother making a request if we don't know the user
        *uploadError = [NSError errorWithDomain:[CloudClient getBaseUrl] code: Unauthorized userInfo:nil];
    } else {
        NSHTTPURLResponse* response = nil;
        NSError* marshallError = nil;
        NSError* sendError = nil;
        [CloudClient verifyConnection:&sendError];
        if (!sendError) {
            NSData* objectAsJson = [NSJSONSerialization dataWithJSONObject:objectAsDictionary options:0 error:&marshallError];
            if (marshallError) {
                SHSLog(@"Unable to marshall to JSON: %@", marshallError);
                *uploadError = [NSError errorWithDomain:[CloudClient getBaseUrl] code: Marshalling userInfo:nil];
            } else {
                //SHSLog(@"Object as JSON = %@",[[NSString alloc] initWithData:objectAsJson encoding:NSASCIIStringEncoding]);
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",  [CloudClient getBaseUrl], relativeUrl]];
                NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
                [request setHTTPMethod:@"POST"];
                [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                [request setHTTPBody:objectAsJson];
                
                responseJSON = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&sendError];
                if (sendError == nil && response != nil && [response statusCode] == 200) {
                    SHSLog(@"Object upload successful");
                } else {
                    *uploadError = [NSError errorWithDomain:[CloudClient getBaseUrl] code: [CloudClient errorCodeFromResponse: response error: sendError] userInfo:nil];
                    SHSLog(@"Failed to send.  Returning error %@.  The HTTP status code was = %d, More Info = %@", *uploadError, response == nil ? 0 :  [response statusCode], sendError);
                } 
            }
        } else {
            *uploadError = sendError;
        }
    }
    return responseJSON;
}

+(CloudError) errorCodeFromResponse: (NSHTTPURLResponse*) httpResponse error: (NSError*) sendError {
    // 401's aren't handled correctly in synch http requests...this is the workaround...
    if (sendError && sendError.code == NSURLErrorUserCancelledAuthentication) {
        return Unauthorized;
    }
    return Unknown;
}

+(NSString*) getBaseUrl {
    return [NSString stringWithFormat:@"http://%@", kHostHame];
}

+(BOOL)isConnected {
    Reachability* reachability = [Reachability reachabilityForInternetConnection]; 
    return ![reachability currentReachabilityStatus] == NotReachable;
}

+(void) verifyConnection: (NSError**) error {
    if (![self isConnected]) {
        *error = [NSError errorWithDomain:[CloudClient getBaseUrl] code: NotConnectedToInternet userInfo:nil];
        SHSLog(@"Internet connection not available");
    } else {
        // check the app version to make sure OK with server
        NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        appVersion = [appVersion stringByReplacingOccurrencesOfString:@"." withString:@"_"];
        
        NSHTTPURLResponse* response = nil;
        NSError* sendError = nil;
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/rest/mobile/meta/%@",  [CloudClient getBaseUrl], appVersion]];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        NSData*  responseJSON = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&sendError];
        if (sendError == nil && response != nil && [response statusCode] == 200) {
            NSError* unmarshallingError = nil;
            NSDictionary* metaInfoAsDictionary = [NSJSONSerialization JSONObjectWithData:responseJSON options:0 error:&unmarshallingError];
            if (!unmarshallingError) {
                CloudMetaInfo *metaInfo = [CloudMetaInfo fromDictionary:metaInfoAsDictionary];
                if (!metaInfo.isAppVersionAcceptable) {
                    *error = [NSError errorWithDomain:[CloudClient getBaseUrl] code: UnacceptableAppVersion userInfo:[NSDictionary dictionaryWithObject:metaInfo.messageToUser forKey:kCloudErrorExplanationKey]];
                    SHSLog(@"App at unacceptable version: %@", metaInfo.messageToUser);
                }
            } else {
                *error = unmarshallingError;
            }
        } else {
            *error = [NSError errorWithDomain:[CloudClient getBaseUrl] code: [CloudClient errorCodeFromResponse: response error: sendError] userInfo:nil];
            SHSLog(@"Failed http GET request.  Returning error %@.  The HTTP status code was = %d, More Info = %@", *error, response == nil ? 0 :  [response statusCode], sendError);
        }
    }
}

+(NSString*) getWebsiteURL: (Team*) team {
    if (team.cloudId != nil && ![team.cloudId isEqualToString: @""]) {
        return [NSString stringWithFormat:@"%@/team/%@/main", [CloudClient getBaseUrl], team.cloudId];
    }
    return nil;
}

@end
