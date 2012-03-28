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


@implementation Tweeter


+(NSString*)getGameScoreDescription: (Game*) game {
    Score score = [[Game getCurrentGame] getScore];
    return [NSString stringWithFormat: @"current score: %d-%d %@", score.ours, score.theirs, score.ours > score.theirs ?
            [Team getCurrentTeam].name : [Game getCurrentGame].opponentName];
}

+(void)tweetEvent:(Event*) event forGame: (Game*) game isUndo: (BOOL) isUndo { 
    if ([Preferences getCurrentPreferences].isTweetingEvents && [TWTweetComposeViewController canSendTweet]) {
        NSString* tweet = isUndo ? 
            [NSString stringWithFormat: @"\"%@\" was a boo-boo...never mind", event] :
            [NSString stringWithFormat: @"%@ (%@)", [event getDescription], [Tweeter getGameScoreDescription:game]];
        
        if ([TWTweetComposeViewController canSendTweet]) 
        {
            // Create account store, followed by a twitter account identifier
            // At this point, twitter is the only account type available
            ACAccountStore *account = [[ACAccountStore alloc] init];
            ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            
            // Request access from the user to access their Twitter account
            [account requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) 
             {
                 // Did user allow us access?
                 if (granted == YES)
                 {
                     // Populate array with all available Twitter accounts
                     NSArray* arrayOfAccounts = [account accountsWithAccountType:accountType];
                     NSString* accountName = [Tweeter getTwitterAccountName];
                     ACAccount* acct = nil;
                     for (ACAccount* twitAcct in arrayOfAccounts) {
                         if ([twitAcct.accountDescription isEqualToString:accountName]) {
                             acct = twitAcct;
                         }
                     }

                     if (acct) 
                     {
                       
                         // Build a twitter request
                         TWRequest *postRequest = [[TWRequest alloc] initWithURL:
                                                   [NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"] 
                                                                      parameters:[NSDictionary dictionaryWithObject:tweet
                                                                                                             forKey:@"status"] requestMethod:TWRequestMethodPOST];
                         
                         // Post the request
                         [postRequest setAccount:acct];
                         
                         // Block handler to manage the response
                         [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) 
                          {
                              NSLog(@"Twitter response, HTTP response: %i", [urlResponse statusCode]);
                          }];
                     }
                 }
             }];
        }
    }
}



+(void)XXXtweetEvent:(Event*) event forGame: (Game*) game isUndo: (BOOL) isUndo { 
    if ([Preferences getCurrentPreferences].isTweetingEvents && [TWTweetComposeViewController canSendTweet]) {
        // Get permission from user to access their Twitter account
        ACAccountStore* accountStore = [[ACAccountStore alloc] init];
        ACAccountType* accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
            // Did user allow us access?
            if (granted == YES) {
                
                // do the tweet
                ACAccount* acct = [Tweeter getTwitterAccount];      
                if (acct) {
                    NSString* tweet = [NSString stringWithFormat: @"%@%@", (isUndo ? @"Whoops...never mind " : [Tweeter getGameScoreDescription:game]), [event getDescription]];
                    
                    // Build a twitter request
                    TWRequest* postRequest = [[TWRequest alloc] initWithURL: [NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"] 
                                                                 parameters:[NSDictionary dictionaryWithObject:tweet forKey:@"status"] requestMethod:TWRequestMethodPOST];
                    [postRequest setAccount:acct];
                    
                    // Post with block handler to manage the response
                    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        NSLog(@"Twitter response, HTTP response: %i", [urlResponse statusCode]);
                    }];
                } else {
                    NSLog(@"No twitter account found"); 
                }
            } else {
                NSLog(@"User denied access to account twitter store");
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
