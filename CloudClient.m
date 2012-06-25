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
#import "TestFlight.h"
#import "Reachability.h"

// send nslog output to testflight
#define NSLog(__FORMAT__, ...) TFLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

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
+(NSString*) getBaseUrl;

@end

@implementation CloudClient

#pragma mark - Upload Team and Games

+(void) uploadTeam: (Team*) team error:(NSError**) uploadError {
    NSError* error = nil;
    NSData* responseJSON = [CloudClient upload: [team asDictionary] relativeUrl: @"/rest/mobile/team" error: &error];
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
    NSMutableDictionary* gameAsDict = [game asDictionary];
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
    NSLog(@"URL response: %@",[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    BOOL isSignedOn = response != nil && [response statusCode] == 200;
    NSLog(@"Http response status code = %d",[response statusCode]);
    NSLog(@"Is Signed On ? %@",isSignedOn ? @"YES" : @"NO");
    return isSignedOn;
}


+(void) signOff {
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:[CloudClient getBaseUrl]]];
    for (NSHTTPCookie* cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie: cookie];
    }
    [Preferences getCurrentPreferences].userid = nil;
    [[Preferences getCurrentPreferences] save];
}

+(BOOL) signOnWithID: userid password: password {
    
    // see http://stackoverflow.com/questions/471898/google-app-engine-with-clientlogin-interface-for-objective-c
    
    //create request
    NSString* content = [NSString stringWithFormat:@"accountType=HOSTED_OR_GOOGLE&Email=%@&Passwd=%@&service=ah&source=ultimate-team", userid, password];
    NSURL* authUrl = [NSURL URLWithString:@"https://www.google.com/accounts/ClientLogin"];
    NSMutableURLRequest* authRequest = [[NSMutableURLRequest alloc] initWithURL:authUrl];
    [authRequest setHTTPMethod:@"POST"];
    [authRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    [authRequest setHTTPBody:[content dataUsingEncoding:NSASCIIStringEncoding]];
    
    NSHTTPURLResponse* authResponse;
    NSError* authError;
    NSData * authData = [NSURLConnection sendSynchronousRequest:authRequest returningResponse:&authResponse error:&authError];      
    NSString *authResponseBody = [[NSString alloc] initWithData:authData encoding:NSASCIIStringEncoding];
    
    //loop through response body which is key=value pairs, seperated by \n. The code below is not optimal and certainly error prone. 
    NSArray *lines = [authResponseBody componentsSeparatedByString:@"\n"];
    NSMutableDictionary* token = [NSMutableDictionary dictionary];
    for (NSString* s in lines) {
        NSArray* kvpair = [s componentsSeparatedByString:@"="];
        if ([kvpair count]>1) {
            [token setObject:[kvpair objectAtIndex:1] forKey:[kvpair objectAtIndex:0]];
        }
    }
    //if google returned an error in the body [google returns Error=Bad Authentication in the body. which is weird, not sure if they use status codes]
    if (authError || [token objectForKey:@"Error"]) {
        //handle error
        NSLog(@"Error while authenticating");
        return NO;
    } else {
        NSLog(@"Auth Successful");
    }
    
    // do a get so that google will set the auth cookie (all subsequent calls will contain the cookie returned)
    
    NSURL* cookieUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/_ah/login?continue=%@/&auth=%@", [CloudClient getBaseUrl], [CloudClient getBaseUrl], [token objectForKey:@"Auth"]]];
    // NSLog([cookieUrl description]);
    NSHTTPURLResponse* cookieResponse;
    NSError* cookieError;
    NSMutableURLRequest *cookieRequest = [[NSMutableURLRequest alloc] initWithURL:cookieUrl];
    
    [cookieRequest setHTTPMethod:@"GET"];
    
    NSData* cookieData = [NSURLConnection sendSynchronousRequest:cookieRequest returningResponse:&cookieResponse error:&cookieError];
    // NSLog([cookieData description]);
    if (cookieError) {
        //handle error
        NSLog(@"Error getting cookie: %@ %@", [cookieError description], [cookieData description]);
        return NO;
    } 
    
    BOOL isSignedOn = [CloudClient isSignedOn];
    if(isSignedOn) {
        [Preferences getCurrentPreferences].userid = userid;
        [[Preferences getCurrentPreferences] save];
    }
    return isSignedOn;

    
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
                NSLog(@"http GET successful");
            } else {
                *getError = [NSError errorWithDomain:[CloudClient getBaseUrl] code: [CloudClient errorCodeFromResponse: response error: sendError] userInfo:nil];
                NSLog(@"Failed http GET request.  Returning error %@.  The HTTP status code was = %d, More Info = %@", *getError, response == nil ? 0 :  [response statusCode], sendError);
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
                NSLog(@"Unable to marshall to JSON: %@", marshallError);
                *uploadError = [NSError errorWithDomain:[CloudClient getBaseUrl] code: Marshalling userInfo:nil];
            } else {
                //NSLog(@"Object as JSON = %@",[[NSString alloc] initWithData:objectAsJson encoding:NSASCIIStringEncoding]);
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",  [CloudClient getBaseUrl], relativeUrl]];
                NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
                [request setHTTPMethod:@"POST"];
                [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                [request setHTTPBody:objectAsJson];
                
                responseJSON = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&sendError];
                if (sendError == nil && response != nil && [response statusCode] == 200) {
                    NSLog(@"Object upload successful");
                } else {
                    *uploadError = [NSError errorWithDomain:[CloudClient getBaseUrl] code: [CloudClient errorCodeFromResponse: response error: sendError] userInfo:nil];
                    NSLog(@"Failed to send.  Returning error %@.  The HTTP status code was = %d, More Info = %@", *uploadError, response == nil ? 0 :  [response statusCode], sendError);
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

+(void) verifyConnection: (NSError**) error {
    Reachability* reachability = [Reachability reachabilityForInternetConnection]; 
    if ([reachability currentReachabilityStatus] == NotReachable) {
        *error = [NSError errorWithDomain:[CloudClient getBaseUrl] code: NotConnectedToInternet userInfo:nil];
        NSLog(@"Internet connection not available");
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
                    NSLog(@"App at unacceptable version: %@", metaInfo.messageToUser);
                }
            } else {
                *error = unmarshallingError;
            }
        } else {
            *error = [NSError errorWithDomain:[CloudClient getBaseUrl] code: [CloudClient errorCodeFromResponse: response error: sendError] userInfo:nil];
            NSLog(@"Failed http GET request.  Returning error %@.  The HTTP status code was = %d, More Info = %@", *error, response == nil ? 0 :  [response statusCode], sendError);
        }
    }
}

+(NSString*) getWebsiteURL: (Team*) team {
    if (team.cloudId != nil && team.cloudId != @"") {
        return [NSString stringWithFormat:@"%@/team/%@/main", [CloudClient getBaseUrl], team.cloudId];
    }
    return nil;
}

@end
