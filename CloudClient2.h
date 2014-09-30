//
//  CloudClient2.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 9/29/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloudRequestStatus.h"
@class Team;
@class Game;

@interface CloudClient2 : NSObject

+(BOOL) isSignedOn;
+(void) signOff;
+(NSString*) getBaseUrl;
+(NSString*) getBaseWebUrl;
+(BOOL)isConnected;

// Important: completion block may not be on main thread.  It is caller's duty to make sure the block
// does UI work on main thread
+(void) downloadTeamsAtCompletion:  (void (^)(CloudRequestStatus* status, NSArray* teams)) completion;
+(void) downloadTeam: (NSString*) cloudId atCompletion:  (void (^)(CloudRequestStatus* status, NSString* teamId)) completion;
+(void) downloadGameDescriptionsForTeam: (NSString*) teamCloudId atCompletion:  (void (^)(CloudRequestStatus* requestStatus, NSArray* gameDescriptions)) completion;
+(void) downloadGame: (NSString*) gameId forTeam: (NSString*) teamCloudId atCompletion: (void (^)(CloudRequestStatus* requestStatus)) completion;

@end
