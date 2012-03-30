//
//  Tweeter.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Event;
@class Game;
@class ACAccount;
@class Tweet;

@interface Tweeter : NSObject

+(NSString*)getGameScoreDescription: (Game*) game;
+(void)tweet:(Tweet*) message;
+(void)tweetMessage:(NSString*) message;
+(void)tweetEvent:(Event*) event forGame: (Game*) game isUndo: (BOOL) isUndo;
+(NSArray*)getTwitterAccounts;
+(ACAccount*)getTwitterAccount;
+(NSString*)getTwitterAccountName;
+(NSArray*)getTwitterAccountsNames;
+(void)setPreferredTwitterAccount: (NSString*) accountName;
+(BOOL)isTweetingEvents;

@end
