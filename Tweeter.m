//
//  Tweeter.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "Tweeter.h"
#import "Event.h"
#import "Game.h"
#import "Preferences.h"
#import "Team.h"
#import "TweetQueue.h"
#import "Tweet.h"


@implementation Tweeter

+(BOOL)isTweetingEvents {
    return [Preferences getCurrentPreferences].isTweetingEvents;
}

+(NSString*)getGameScoreDescription: (Game*) game {
    Score score = [[Game getCurrentGame] getScore];
    return [NSString stringWithFormat: @"current score: %d-%d %@", score.ours, score.theirs, score.ours > score.theirs ?
            [Team getCurrentTeam].name : [Game getCurrentGame].opponentName];
}

+(void)tweetEvent:(Event*) event forGame: (Game*) game isUndo: (BOOL) isUndo { 
    if ([Tweeter isTweetingEvents]) {
        NSString* message = isUndo ? 
            [NSString stringWithFormat: @"\"%@\" was a boo-boo...never mind", event] :
        [NSString stringWithFormat: @"%@", [event getDescription: [Team getCurrentTeam].name opponent:[game opponentName]]];
        if ([event isGoal]) {
            message = [NSString stringWithFormat: @"%@ (%@)", message, [Tweeter getGameScoreDescription:game]];
        }
        [self tweet:message];
    }
}

+(void)tweet:(NSString*) message { 
    // start tweet queue (if not already started)
    [[TweetQueue getCurrent] start];
    
    // before we add it to the queue...make sure we have access
    if ([TWTweetComposeViewController canSendTweet]) {
        // Create account store, followed by a twitter account identifier
        ACAccountStore* accountStore = [[ACAccountStore alloc] init];
        ACAccountType* accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        // Request access from the user to access their Twitter account
        [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
             // Did user allow us access?
             if (granted == YES)
             {
                 // tweet
                 [[TweetQueue getCurrent] addTweet: [[Tweet alloc] initMessage:message]];
             }
         }];
    }
}

+(NSArray*)getTwitterAccounts { 
    if ([TWTweetComposeViewController canSendTweet]) {
        // Create account store and ask it for all of the twitter type accounts
        ACAccountStore* accountStore = [[ACAccountStore alloc] init];
        ACAccountType* accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        return [accountStore accountsWithAccountType:accountType];
        
    } else {
        return [[NSArray alloc] init];
    }
}

+(ACAccount*)getTwitterAccount { 
    NSArray* twitterAccounts = [Tweeter getTwitterAccounts];
    if ([twitterAccounts count] > 0) {
        NSString* preferredAccountName = [Preferences getCurrentPreferences].twitterAccountDescription;
        if (preferredAccountName == nil) {
            return [twitterAccounts objectAtIndex:0];
        } else {
            for (ACAccount* acct in twitterAccounts) {
                if ([acct.accountDescription isEqualToString:preferredAccountName]) {
                    return acct;
                }
            }
            ACAccount* acct = (ACAccount*)[twitterAccounts objectAtIndex:0];
            [Preferences getCurrentPreferences].twitterAccountDescription = acct.accountDescription;
            [[Preferences getCurrentPreferences] save];
            return acct;
        }
    }
    return nil;
}

+(NSString*)getTwitterAccountName {
    ACAccount* acct = [Tweeter getTwitterAccount];
    return acct == nil ? nil : acct.accountDescription;
}

+(NSArray*)getTwitterAccountsNames { 
    NSArray* twitterAccounts = [Tweeter getTwitterAccounts];
    NSMutableArray* accountNames = [[NSMutableArray alloc] init];
    for (ACAccount* account in twitterAccounts) {
        [accountNames addObject:account.accountDescription];
    }
    return accountNames;
}

+(void)setPreferredTwitterAccount: (NSString*) accountName { 
    [Preferences getCurrentPreferences].twitterAccountDescription = accountName;
    [[Preferences getCurrentPreferences] save];
}

@end
