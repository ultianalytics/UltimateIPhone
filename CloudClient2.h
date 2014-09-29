//
//  CloudClient2.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 9/29/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Team;
@class Game;

typedef enum {
    CloudRequestStatusOk,
    CloudRequestStatusUnauthorized,
    CloudRequestStatusNotConnectedToInternet,
    CloudRequestStatusMarshallingError,
    CloudRequestStatusUnacceptableAppVersion,
    CloudRequestStatusUnknownError
} CloudRequestStatus;

@interface CloudClient2 : NSObject

+(BOOL) isSignedOn;
+(void) signOff;
+(NSString*) getBaseUrl;
+(NSString*) getBaseWebUrl;
+(BOOL)isConnected;

// Important: completion block may not be on main thread.  It is caller's duty to make sure the block
// does UI work on main thread
+(void) downloadTeamsAtCompletion:  (void (^)(CloudRequestStatus status, NSArray* teams)) completion;

@end
