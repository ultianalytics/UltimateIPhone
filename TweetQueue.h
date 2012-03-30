//
//  TweetQueue.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
@class Tweet;
@class ACAccount;

@interface TweetQueue : NSObject

// public
+(TweetQueue*)getCurrent;
-(void)start;
-(void)addTweet: (Tweet*) tweet;

// private
-(void)timePassed:(NSTimer*)theTimer;
-(void)sendTweet: (NSString*) message toAccount: (ACAccount*) twitterAccount;
-(void)sendTweet: (NSString*) message;
-(void)drainQueue;
-(void)stopTimer;

@end
