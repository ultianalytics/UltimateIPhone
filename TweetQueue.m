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

#define kSendIntervalSeconds 5.0
#define kTimerIntervalSeconds 5.0

NSTimer* timer;
NSMutableArray* queue;  // queue of Tweets to post
NSMutableArray* recentTweets;  // log of recent Tweets sent
double lastTweetSecondsSinceEpoch;

static TweetQueue* current = nil;

@implementation TweetQueue

+(void)initialize {
    current = [[TweetQueue alloc] init];
    lastTweetSecondsSinceEpoch = [NSDate timeIntervalSinceReferenceDate];
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

-(void)start {
    if (!timer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:kTimerIntervalSeconds target:self selector:@selector(timePassed:) userInfo:nil repeats:YES];
    }
}

-(void)addTweet: (Tweet*) tweet {
    @synchronized(queue) {
        if (!(tweet.undoMessage && [self attemptUndoTweet: tweet.undoMessage])) {
            [queue addObject:tweet];
            NSLog(@"Tweet %@ added to queue", tweet.message);
            if (!timer) {
                [self start];
            }
        }
    }
}

-(NSArray*)getRecents {
    @synchronized(queue) {
        NSLog(@"queue is %d", [queue count]);
                NSLog(@"recentTweets is %d", [recentTweets count]);
        return [queue arrayByAddingObjectsFromArray:recentTweets];
    }
}


// PRIVATE 

-(BOOL)attemptUndoTweet: (NSString*) tweetMessage {
    if ([queue count] > 0) {
        Tweet* lastTweet = [queue lastObject];
        if ([lastTweet.message isEqualToString:tweetMessage]) {
            [queue removeLastObject];
            NSLog(@"Tweet %@ removed (undo) from queue",tweetMessage);
            return YES;
        }
    }
    return NO;
}

- (void)timePassed:(NSTimer*)theTimer {
    @synchronized(queue) {
        if (lastTweetSecondsSinceEpoch + kSendIntervalSeconds < [NSDate timeIntervalSinceReferenceDate]) {
            [self drainQueue];
            lastTweetSecondsSinceEpoch = [NSDate timeIntervalSinceReferenceDate];
        }
    }
}

-(void)drainQueue {
    NSString*  message = @"";
    @synchronized(queue) {    
        NSMutableArray* tweeted = [[NSMutableArray alloc] init];
        NSString* lastTweetType = nil;
        for (Tweet* tweet in queue) {
            NSString* newMessage = [NSString stringWithFormat:@"%@%@%@", message, [message isEqualToString:@""] ? @"" : @", ", tweet.message];
            if ([newMessage length] > 140) {
                break;
            } else if (lastTweetType != nil && ![lastTweetType isEqualToString:tweet.type]) {
                break;                
            } else {
                message = newMessage;
                [tweeted addObject:tweet];
            }
            lastTweetType = tweet.type;
        }
        [queue removeObjectsInArray:tweeted];
    }
    if (![message isEqualToString:@""]) {
        [self sendTweet: message];
    }
}

-(void)stopTimer {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

-(void)sendTweet: (NSString*) message toAccount: (ACAccount*) twitterAccount {
    NSLog(@"Sending tweet %@ to twitter", message);
    @try {
        // Build a twitter request
        TWRequest *postRequest = [[TWRequest alloc] initWithURL: [NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"] 
                                                     parameters:[NSDictionary dictionaryWithObject:message forKey:@"status"] requestMethod:TWRequestMethodPOST];
        
        // Post the request
        [postRequest setAccount:twitterAccount];
        
        // Block handler to manage the response
        [postRequest  performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) 
         {
             NSLog(@"Twitter response, HTTP response: %i", [urlResponse statusCode]);
             if ([urlResponse statusCode] == 200) {
                 [self logTweet: [[Tweet alloc] initMessage: message]];
             } else {
                 [self logTweet: [[Tweet alloc] initMessage: message failed: [NSString stringWithFormat:@"ERROR %d ", [urlResponse statusCode]]]];
             }
         }];
    }
    @catch (NSException *exception) {
        NSString* exceptionCaught = [NSString stringWithFormat:@"Exception: %@-%@", [exception name], [exception reason]];
        NSLog(@"Exception caught: %@", exceptionCaught);
        [self logTweet: [[Tweet alloc] initMessage: message failed: exceptionCaught]];
    }
}

-(void)logTweet: (Tweet*) tweet {
    if ([recentTweets count] >= 20) {
        [recentTweets removeObjectAtIndex:0];
    }
    [recentTweets addObject:tweet];
}

-(void)sendTweet: (NSString*) message {
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
                 NSString* accountName = [Tweeter getTwitterAccountName];
                 ACAccount* acct = nil;
                 for (ACAccount* twitAcct in arrayOfAccounts) {
                     if ([twitAcct.accountDescription isEqualToString:accountName]) {
                         acct = twitAcct;
                     }
                 }
                 
                 // if we are good to go, tweet
                 if (acct) 
                 {
                     [self sendTweet:message toAccount:acct];
                 }
             }
         }];
    }
}

@end
