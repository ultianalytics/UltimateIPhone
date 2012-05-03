//
//  TweetQueue.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "TweetQueue.h"
#import "Tweet.h"
#import "Tweeter.h"

#define kSendWaitSeconds 10.0
#define kTimerIntervalSeconds 3.0
#define kRecentTweetExpireSeconds 1800
#define kMaxRecentsTweetsAllowed 20

static TweetQueue* current = nil;

@interface  TweetQueue()

// private
-(void)sendTweet: (Tweet*) tweet toAccount: (ACAccount*) twitterAccount;
-(void)sendTweetLimited: (Tweet*) tweet toAccount: (ACAccount*) twitterAccount;
-(void)sendTweet: (Tweet*) tweet;
-(void)sendReadyTweets: (BOOL)onlyReady;
-(void)logTweet: (Tweet*) tweet;
-(void)expireRecentTweets;

@end

@implementation TweetQueue

+(void)initialize {
    current = [[TweetQueue alloc] init];
}

+(TweetQueue*)getCurrent {
    return current;
}

-(id) init  {
    self = [super init];
    if (self) {
        queue = [[NSMutableArray alloc] init];
        recentTweets = [[NSMutableArray alloc] init];
    }
    return self;
}


-(void)addTweet: (Tweet*) tweet {
        [queue addObject:tweet];
        NSLog(@"Tweet %@ added to queue", tweet.message);
        [self sendReadyTweets: YES];
}

-(NSArray*)getRecents {
    @synchronized(queue) {
        return [[[queue reverseObjectEnumerator] allObjects] arrayByAddingObjectsFromArray: [[recentTweets reverseObjectEnumerator] allObjects]];
    }
}

// PRIVATE 

-(void)sendReadyTweets: (BOOL)onlyReady {
    NSArray* tweets = [queue copy];
    for (Tweet* tweet in tweets) {
        [self sendTweet: tweet];
    }
}

-(void)sendTweet: (Tweet*) tweet {
    if ([TWTweetComposeViewController canSendTweet]) {
        // Create account store, followed by a twitter account identifier
        // At this point, twitter is the only account type available
        ACAccountStore* accountStore = [[ACAccountStore alloc] init];
        ACAccountType* accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        // Request access from the user to access their Twitter account
        [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) 
         {
             // Did user allow us access?
             if (granted == YES)
             {
                 // Populate array with all available Twitter accounts
                 NSArray* arrayOfAccounts = [accountStore accountsWithAccountType:accountType];
                 NSString* accountName = [[Tweeter getCurrent] getTwitterAccountName];
                 ACAccount* acct = nil;
                 for (ACAccount* twitAcct in arrayOfAccounts) {
                     if ([twitAcct.accountDescription isEqualToString:accountName]) {
                         acct = twitAcct;
                     }
                 }
                 
                 // if we are good to go, tweet
                 if (acct) 
                 {
                     [self sendTweetLimited:tweet toAccount:acct];
                 }
             }
         }];
    }
}

-(void)sendTweetLimited: (Tweet*) tweet toAccount: (ACAccount*) twitterAccount {
    [self expireRecentTweets];
    if (tweet.isOptional && [recentTweets count] >= kMaxRecentsTweetsAllowed) {  // too many tweets per hour
        tweet.status = TweetSkipped;
        [self logTweet:tweet];
        [queue removeObject:tweet];
    } else {
        [self sendTweet: tweet toAccount: twitterAccount];
    }
}

-(void)sendTweet: (Tweet*) tweet toAccount: (ACAccount*) twitterAccount {
    NSLog(@"Sending tweet %@ to twitter", tweet.message);
    @try {
        // Build a twitter request
        TWRequest *postRequest = [[TWRequest alloc] initWithURL: [NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"] 
                                                     parameters:[NSDictionary dictionaryWithObject:tweet.message forKey:@"status"] requestMethod:TWRequestMethodPOST];
        
        // Post the request
        [postRequest setAccount:twitterAccount];
        
        // Block handler to manage the response
        [postRequest  performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) 
         {
             if ([urlResponse statusCode] == 200) {
                 tweet.status = TweetSent;
                 DebugLog(@"Tweet successful: %@", tweet.message);
             } else if ([urlResponse statusCode] == 403) {
                 tweet.status = TweetIgnored;
                 DebugLog(@"Tweet rejected by Twitter: %@", tweet.message);
             } else {
                 tweet.status = TweetFailed;
                 tweet.error = [NSString stringWithFormat:@"ERROR %d ", [urlResponse statusCode]];
                 DebugLog(@"Tweet error %@ when sending to Twitter: %@", tweet.error, tweet.message);
             }
         }];
    }
    @catch (NSException *exception) {
        NSString* exceptionCaught = [NSString stringWithFormat:@"Exception: %@-%@", [exception name], [exception reason]];
        NSLog(@"Exception caught: %@", exceptionCaught);
        tweet.status = TweetFailed;
        tweet.error = exceptionCaught;
    }
    [self logTweet: tweet];
    [queue removeObject:tweet];
}

-(void)logTweet: (Tweet*) tweet {
    [recentTweets addObject:tweet];
}

-(void)expireRecentTweets {
    double expiredTime = [NSDate timeIntervalSinceReferenceDate] - kRecentTweetExpireSeconds;
    NSMutableIndexSet* indicesToRemove = [[NSMutableIndexSet alloc] init];
    for (int i=0; i < [recentTweets count]; i++) {
        Tweet* tweet = [recentTweets objectAtIndex:i];
        if (tweet.time < expiredTime) {
            [indicesToRemove addIndex:i];
        }
    }
    [recentTweets removeObjectsAtIndexes:indicesToRemove];
}


@end
