//
//  CloudClient.h
//  Ultimate
//
//  Created by Jim Geppert on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Team;
@class Game;

typedef enum {
    Unauthorized,
    ConnectionFailure,
    Marshalling,
    Unknown
} CloudError;

@interface CloudClient : NSObject

+(BOOL) isSignedOn;
+(void) signOff;
+(BOOL) signOnWithID: userid password: password;
+(void) uploadTeam: (Team*) team error:(NSError**) error;
+(void) uploadTeam: (Team*) team withGames: (NSArray*) gameIds error:(NSError**) error;
+(NSString*) getWebsiteURL: (Team*) team;

// private

+(NSData*) upload: (NSDictionary*) objectAsDictionary relativeUrl: (NSString*) relativeUrl error:(NSError**) uploadError;
+(void) uploadGame: (Game*) game ofTeam: (Team*) team error:(NSError**) uploadError;
+(CloudError) errorCodeFromResponse: (NSHTTPURLResponse*) httpResponse error: (NSError*) sendError;
+(void) saveTeamCloudId:(NSData *)responseJSON;

@end
