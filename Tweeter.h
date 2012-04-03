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

@interface Tweeter : NSObject

+(Tweeter*)getCurrent;

-(void)tweet:(Tweet*) tweet;    
-(void)tweetEvent:(Event*) event forGame: (Game*) game isUndo: (BOOL) isUndo;
-(void)tweetFirstEventOfPoint:(Event*) event forGame: (Game*) game point: (UPoint*) point isUndo: (BOOL) isUndo;
-(NSArray*)getRecentTweetActivity;
-(NSArray*)getTwitterAccounts;
-(ACAccount*)getTwitterAccount;
-(NSString*)getTwitterAccountName;
-(NSArray*)getTwitterAccountsNames;
-(void)setPreferredTwitterAccount: (NSString*) accountName;
-(BOOL)isTweetingEvents;

// private
-(NSString*)getGameScoreDescription: (Game*) game;
-(NSString*)pointBeginTweetMessage:(Event*) event forGame: (Game*) game point: (UPoint*) point isUndo: (BOOL) isUndo;
-(NSString*)eventTweetMessage:(Event*) event forGame: (Game*) game isUndo: (BOOL) isUndo;
-(NSString*) getTime;

@end
