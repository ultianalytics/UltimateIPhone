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

@interface TweetQueue : NSObject {
    @private
    NSMutableArray* queue;  // queue of Tweets to post
    NSMutableArray* recentTweets;  // log of recent Tweets sent
}

// public
+(TweetQueue*)getCurrent;
-(void)addTweet: (Tweet*) tweet;
-(NSArray*)getRecents;



@end
