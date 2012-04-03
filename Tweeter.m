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
    return [NSString stringWithFormat: @"%d-%d %@", score.ours, score.theirs, score.ours > score.theirs ?
            [Team getCurrentTeam].name : [Game getCurrentGame].opponentName];
}

+(void)tweetEvent:(Event*) event forGame: (Game*) game isUndo: (BOOL) isUndo { 
    if ([Tweeter isTweetingEvents]) {
        NSString* message = [NSString stringWithFormat: @"%@", [event getDescription: [Team getCurrentTeam].name opponent:[game opponentName]]];
        if ([event isGoal]) {
            message = [NSString stringWithFormat: @"%@ (%@)", message, [Tweeter getGameScoreDescription:game]];
        }
        Tweet* tweet = [[Tweet alloc] initMessage:message type:[NSString stringWithFormat:@"%d %@", event.action, isUndo ? @"@UNDO" : @""]];
        if (isUndo) {
            tweet.isUndo = YES;
            tweet.message = [NSString stringWithFormat: @"\"%@\" was a boo-boo...never mind", event];
        }
        tweet.associatedEvent = event;
        [self tweet: tweet];
    }
}

+(void)tweetFirstEventOfPoint:(Event*) event forGame: (Game*) game point: (UPoint*) point isUndo: (BOOL) isUndo {
    if ([Tweeter isTweetingEvents]) {
        NSString* message = [Tweeter pointBeginMessage:event forGame: game point: point isUndo: isUndo];
        Tweet* tweet = [[Tweet alloc] initMessage:message type:@"NewPoint"];
        tweet.associatedEvent = event;
        [self tweet: tweet]; 
    }
}

+(void)tweet:(Tweet*) tweet { 
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
                [[TweetQueue getCurrent] addTweet: tweet];
            }
        }];
    }
}

+(NSArray*)getRecentTweetActivity {
    return [[TweetQueue getCurrent] getRecents];
}

+(NSArray*)getTwitterAccounts {
    __block NSArray* accounts = nil;
    if ([TWTweetComposeViewController canSendTweet]) {
        // Create account store and ask it for all of the twitter type accounts
        ACAccountStore* accountStore = [[ACAccountStore alloc] init];
        ACAccountType* accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        // Request access from the user to access their Twitter account
        [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
            // Did user have access?
            if (granted == YES) {
                accounts = [accountStore accountsWithAccountType:accountType];
            }
        }];
        return [accountStore accountsWithAccountType:accountType];
        
    } 
    return accounts == nil ? [[NSArray alloc] init] : accounts;
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

+(NSString*)pointBeginMessage:(Event*) event forGame: (Game*) game point: (UPoint*) point isUndo: (BOOL) isUndo {
    NSString* message = nil;
    if (isUndo) {
        message = [NSString stringWithFormat: @"New point was a boo-boo...never mind"];
    } else {
        NSString* windDescription = game.wind && game.wind.mph ? @"" : @"";
        NSMutableArray* names = [[NSMutableArray alloc] init];
        for (Player* player in point.line) {
            [names addObject:player.name];
        }
        message = [NSString stringWithFormat:@"Point begins, %@ on %@%@, Line: %@", [Team getCurrentTeam].name, [game isPointOline:point] ? @"Offense" : @"Defense", windDescription, [names componentsJoinedByString:@", "]];
    }
    return message;
}

@end
