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
@class UPoint;
@class ACAccount;
@class Tweet;
typedef enum {
    NoAutoTweet = 0,
    TweetGoals,
    TweetGoalsAndTurns
} AutoTweetLevel;

@interface Tweeter : NSObject

+(Tweeter*)getCurrent;

-(void)tweet:(Tweet*) tweet;    
-(void)tweetFirstEventOfPoint:(Event*) event forGame: (Game*) game point: (UPoint*) point isUndo: (BOOL) isUndo;
-(void)tweetEvent:(Event*) event forGame: (Game*) game point: (UPoint*) point isUndo: (BOOL) isUndo;
-(void)tweetGameOver:(Game*) game;
-(NSArray*)getRecentTweetActivity;
-(NSArray*)getTwitterAccounts;
-(ACAccount*)getTwitterAccount;
-(NSString*)getTwitterAccountName;
-(NSArray*)getTwitterAccountsNames;
-(void)setPreferredTwitterAccount: (NSString*) accountName;
-(BOOL)isTweetingEvents;
-(AutoTweetLevel)getAutoTweetLevel;
-(void)setAutoTweetLevel:(AutoTweetLevel) level;
-(NSString*)getGameScoreDescription: (Game*) game;

@end
