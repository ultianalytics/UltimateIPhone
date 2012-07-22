//
//  CloudClient.h
//  Ultimate
//
//  Created by Jim Geppert on 3/7/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Team;
@class Game;

typedef enum {
    Unauthorized,
    NotConnectedToInternet,
    Marshalling,
    UnacceptableAppVersion,
    Unknown
} CloudError;

#define kCloudErrorExplanationKey @"CloudErrorExplanation"

@interface CloudClient : NSObject

+(BOOL) isSignedOn;
+(void) signOff;
+(void) uploadTeam: (Team*) team error:(NSError**) error;
+(void) uploadTeam: (Team*) team withGames: (NSArray*) gameIds error:(NSError**) error;
+(NSString*) getWebsiteURL: (Team*) team;
+(NSArray*) getTeams: (NSError**) error; 
+(NSString*) downloadTeam: (NSString*) cloudId error: (NSError**) error; 
+(NSArray*) getGameDescriptions: (NSString*) teamcloudId error: (NSError**) error; 
+(void) downloadGame: (NSString*) gameId forTeam: (NSString*) teamCloudId error: (NSError**) error;
+(NSString*) getBaseUrl;
+(BOOL)isConnected;

@end
