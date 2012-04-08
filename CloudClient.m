//
//  CloudClient.m
//  Ultimate
//
//  Created by Jim Geppert on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CloudClient.h"
#import "Team.h"
#import "Game.h"
#import "Preferences.h"
#import "TestFlight.h"

// send nslog output to testflight
#define NSLog(__FORMAT__, ...) TFLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#define kBaseUrl @"http://ultimate-team.appspot.com"
//#define kBaseUrl @"http://local.appspot.com:8888"

@implementation CloudClient

+(NSString*) getWebsiteURL: (Team*) team {
    if (team.cloudId != nil && team.cloudId != @"") {
        return [NSString stringWithFormat:@"%@/team/%@/main", kBaseUrl, team.cloudId];
    }
    return nil;
}

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

+(void) downloadTeam: (NSString*) cloudId error: (NSError**) getError {
    NSError* sendError = nil;
    NSData* responseJson = [CloudClient get: [NSString stringWithFormat: @"/rest/mobile/team/%@", cloudId ] error: &sendError];
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
        [self saveDownloadedTeam: team];
    }
}

+(void) saveDownloadedTeam:(Team*)team {
    [team save];
    if ([Team isCurrentTeam:team.teamId]) {
        [Team setCurrentTeam:team.teamId];
    }
}

+(NSData*) get: (NSString*) relativeUrl error: (NSError**) getError {
    NSData* responseJSON = nil;
    if ([Preferences getCurrentPreferences].userid == nil) {
        // don't bother making a request if we don't know the user
        *getError = [NSError errorWithDomain:kBaseUrl code: Unauthorized userInfo:nil];
    } else {
        NSHTTPURLResponse* response = nil;
        NSError* sendError = nil;
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",  kBaseUrl, relativeUrl]];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"GET"];
        
        responseJSON = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&sendError];
        if (sendError == nil && response != nil && [response statusCode] == 200) {
            NSLog(@"http GET successful");
        } else {
            *getError = [NSError errorWithDomain:kBaseUrl code: [CloudClient errorCodeFromResponse: response error: sendError] userInfo:nil];
            NSLog(@"Failed http GET request.  Returning error %@.  The HTTP status code was = %d, More Info = %@", *getError, response == nil ? 0 :  [response statusCode], sendError);
        }
    }
    return responseJSON;
}

// upload the object (passed as a ditionary).  answer the resonse json
+(NSData*) upload: (NSDictionary*) objectAsDictionary relativeUrl: (NSString*) relativeUrl error:(NSError**) uploadError {
     NSData* responseJSON = nil;
    if ([Preferences getCurrentPreferences].userid == nil) {
        // don't bother making a request if we don't know the user
        *uploadError = [NSError errorWithDomain:kBaseUrl code: Unauthorized userInfo:nil];
    } else {
        NSHTTPURLResponse* response = nil;
        NSError* marshallError = nil;
        NSError* sendError = nil;
        NSData* objectAsJson = [NSJSONSerialization dataWithJSONObject:objectAsDictionary options:0 error:&marshallError];
        if (marshallError) {
            NSLog(@"Unable to marshall to JSON: %@", marshallError);
            *uploadError = [NSError errorWithDomain:kBaseUrl code: Marshalling userInfo:nil];
        } else {
            //NSLog(@"Object as JSON = %@",[[NSString alloc] initWithData:objectAsJson encoding:NSASCIIStringEncoding]);
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",  kBaseUrl, relativeUrl]];
            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPMethod:@"POST"];
            [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:objectAsJson];
            
            responseJSON = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&sendError];
            if (sendError == nil && response != nil && [response statusCode] == 200) {
                NSLog(@"Object upload successful");
            } else {
                *uploadError = [NSError errorWithDomain:kBaseUrl code: [CloudClient errorCodeFromResponse: response error: sendError] userInfo:nil];
                NSLog(@"Failed to send.  Returning error %@.  The HTTP status code was = %d, More Info = %@", *uploadError, response == nil ? 0 :  [response statusCode], sendError);
            } 
        }
    }
    return responseJSON;
}

+ (void)saveTeamCloudId:(NSData *)responseJSON {
    NSError* unmarshallingError = nil;
    NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:responseJSON options:0 error:&unmarshallingError];
    if (unmarshallingError == nil) { 
        [Team getCurrentTeam].cloudId = [responseDict objectForKey:kCloudIdKey]; 
        [[Team getCurrentTeam] save];
    }
}

+(BOOL) isSignedOn { 
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",  kBaseUrl, @"/rest/mobile/test"]];
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

+(CloudError) errorCodeFromResponse: (NSHTTPURLResponse*) httpResponse error: (NSError*) sendError {
    // 401's aren't handled correctly in synch http requests...this is the workaround...
    if (sendError && sendError.code == NSURLErrorUserCancelledAuthentication) {
        return Unauthorized;
    }
    return Unknown;
}

+(void) signOff {
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:kBaseUrl]];
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
    
    NSURL* cookieUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/_ah/login?continue=%@/&auth=%@", kBaseUrl, kBaseUrl, [token objectForKey:@"Auth"]]];
    // NSLog([cookieUrl description]);
    NSHTTPURLResponse* cookieResponse;
    NSError* cookieError;
    NSMutableURLRequest *cookieRequest = [[NSMutableURLRequest alloc] initWithURL:cookieUrl];
    
    [cookieRequest setHTTPMethod:@"GET"];
    
    NSData* cookieData = [NSURLConnection sendSynchronousRequest:cookieRequest returningResponse:&cookieResponse error:&cookieError];
    // NSLog([cookieData description]);
    if (cookieError) {
        //handle error
        NSLog(@"Error getting cookie: %@", [cookieError description]);
        NSLog(@"Error getting cookie: %@", [cookieData description]);
        return NO;
    } 
    
    BOOL isSignedOn = [CloudClient isSignedOn];
    if(isSignedOn) {
        [Preferences getCurrentPreferences].userid = userid;
        [[Preferences getCurrentPreferences] save];
    }
    return isSignedOn;

    
}

@end
