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
#import "OffenseEvent.h"
#import "Game.h"
#import "Preferences.h"
#import "Team.h"
#import "TweetQueue.h"
#import "Tweet.h"

static Tweeter* current = nil;

@implementation Tweeter

NSDateFormatter* timeFormatter;

+(void)initialize {
    current = [[Tweeter alloc] init];
}

+(Tweeter*)getCurrent {
    return current;
}

-(id) init  {
    self = [super init];
    if (self) {
        timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateFormat:@"h:mma"];
    }
    return self;
}

-(BOOL)isTweetingEvents {
    return [Preferences getCurrentPreferences].autoTweetLevel != NoAutoTweet;
}

-(AutoTweetLevel)getAutoTweetLevel {
    return [Preferences getCurrentPreferences].autoTweetLevel;
}

-(void)setAutoTweetLevel:(AutoTweetLevel) level {
    [Preferences getCurrentPreferences].autoTweetLevel = level;
    [[Preferences getCurrentPreferences] save];
}

-(NSString*)getGameScoreDescription: (Game*) game {
    Score score = [[Game getCurrentGame] getScore];
    return [NSString stringWithFormat: @"%d-%d %@", score.ours, score.theirs, score.ours == score.theirs ? @"" : score.ours > score.theirs ?
            [Team getCurrentTeam].name : [Game getCurrentGame].opponentName];
}

-(void)tweetEvent:(Event*) event forGame: (Game*) game isUndo: (BOOL) isUndo { 
    if ([self isTweetingEvents]) {
        if ([event isGoal]) {
            NSString* message = [self goalTweetMessage:event forGame:game isUndo:isUndo]; 
            Tweet* tweet = [[Tweet alloc] initMessage:[NSString stringWithFormat:@"%@  %@", message, [self getTime]] type:@"Event"];
            tweet.isUndo = isUndo;
            tweet.associatedEvent = event;
            [self tweet: tweet];
            if ([game isNextEventImmediatelyAfterHalftime]) {
                NSString* halftimeMessage = [self halftimeTweetMessage:event forGame:game isUndo:isUndo]; 
                Tweet* tweet = [[Tweet alloc] initMessage:[NSString stringWithFormat:@"%@  %@", halftimeMessage, [self getTime]] type:@"Halftime"];
                tweet.isUndo = isUndo;
                tweet.associatedEvent = event;
                [self tweet: tweet];
            }
        } else if ([event isTurnover] && [self getAutoTweetLevel] == TweetGoalsAndTurns) {
            NSString* message = [self turnoverTweetMessage:event forGame:game isUndo:isUndo]; 
            Tweet* tweet = [[Tweet alloc] initMessage:[NSString stringWithFormat:@"%@  %@", message, [self getTime]] type:@"Event"];
            tweet.isUndo = isUndo;
            tweet.associatedEvent = event;
            tweet.isOptional = YES;
            [self tweet: tweet]; 
        }
    }
}

-(void)tweetFirstEventOfPoint:(Event*) event forGame: (Game*) game point: (UPoint*) point isUndo: (BOOL) isUndo {
    if ([self isTweetingEvents]) {
        if ([game isFirstPoint:point]) {
            NSString* message = [self gameBeginTweetMessage:event forGame: game isUndo: isUndo];
            Tweet* tweet = [[Tweet alloc] initMessage:[NSString stringWithFormat:@"%@  %@", message, [self getTime]] type:@"NewGame"];
            tweet.isUndo = isUndo;
            tweet.associatedEvent = event;
            [self tweet: tweet]; 
        }
        NSString* message = [self pointBeginTweetMessage:event forGame: game point: point isUndo: isUndo];
        Tweet* tweet = [[Tweet alloc] initMessage:[NSString stringWithFormat:@"%@  %@", message, [self getTime]] type:@"NewPoint"];
        tweet.isUndo = isUndo;
        tweet.associatedEvent = event;
        [self tweet: tweet]; 
        if ([event isGoal] || [event isTurnover]) {
            [self tweetEvent:event forGame:game isUndo:isUndo];
        }
    }
}

-(void)tweetGameOver:(Game*) game {
    if ([self isTweetingEvents]) {
        NSString* message = [self gameOverTweetMessageForGame:game];
        Tweet* tweet = [[Tweet alloc] initMessage:[NSString stringWithFormat:@"%@  %@", message, [self getTime]] type:@"GameOver"];
        [self tweet: tweet]; 
    }
}

-(void)tweet:(Tweet*) tweet { 
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

-(NSArray*)getRecentTweetActivity {
    return [[TweetQueue getCurrent] getRecents];
}

-(NSArray*)getTwitterAccounts {
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

-(ACAccount*)getTwitterAccount { 
    NSArray* twitterAccounts = [self getTwitterAccounts];
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

-(NSString*)getTwitterAccountName {
    ACAccount* acct = [self getTwitterAccount];
    return acct == nil ? nil : acct.accountDescription;
}

-(NSArray*)getTwitterAccountsNames { 
    NSArray* twitterAccounts = [self getTwitterAccounts];
    NSMutableArray* accountNames = [[NSMutableArray alloc] init];
    for (ACAccount* account in twitterAccounts) {
        [accountNames addObject:account.accountDescription];
    }
    return accountNames;
}

-(void)setPreferredTwitterAccount: (NSString*) accountName { 
    [Preferences getCurrentPreferences].twitterAccountDescription = accountName;
    [[Preferences getCurrentPreferences] save];
}

-(NSString*)gameBeginTweetMessage:(Event*) event forGame: (Game*) game isUndo: (BOOL) isUndo {
    NSString* message = nil;
    if (isUndo) {
        message = [NSString stringWithFormat: @"New game was a boo-boo...never mind."];
    } else {
        NSString* windDescription = game.wind && game.wind.mph ? [NSString stringWithFormat: @" Wind: %dmph.", game.wind.mph] : @"";
        message = [NSString stringWithFormat:@"New game vs. %@.  Game point: %d. %@", game.opponentName, game.gamePoint, windDescription];
    }
    return message;
}

-(NSString*)pointBeginTweetMessage:(Event*) event forGame: (Game*) game point: (UPoint*) point isUndo: (BOOL) isUndo {
    NSString* message = nil;
    if (isUndo) {
        message = [NSString stringWithFormat: @"New point was a boo-boo...never mind."];
    } else {
        NSString* windDescription = game.wind && game.wind.mph ? @"" : @"";
        NSMutableArray* names = [[NSMutableArray alloc] init];
        for (Player* player in point.line) {
            [names addObject:player.name];
        }
        message = [NSString stringWithFormat:@"Pull. %@ on %@%@. Line: %@.", [Team getCurrentTeam].name, [game isPointOline:point] ? @"Offense" : @"Defense", windDescription, [names componentsJoinedByString:@", "]];
    }
    return message;
}

-(NSString*)goalTweetMessage:(Event*) event forGame: (Game*) game isUndo: (BOOL) isUndo {
    NSString* ourTeam = [Team getCurrentTeam].name;
    NSString* message = [NSString stringWithFormat: @"Goal %@", [event isOurGoal] ? ourTeam : game.opponentName];
    message = 
            isUndo ? 
                [NSString stringWithFormat: @"\"%@\" was a boo-boo...never mind", message] : 
            [event isOurGoal] ?
                [NSString stringWithFormat: @"%@!!! %@ to %@. %@.", message, ((OffenseEvent*)event).passer.name, ((OffenseEvent*)event).receiver.name, [self getGameScoreDescription:game]]:
                [NSString stringWithFormat: @"%@. %@.", message, [self getGameScoreDescription:game]];
    return message;
}

-(NSString*)turnoverTweetMessage:(Event*) event forGame: (Game*) game isUndo: (BOOL) isUndo {
    NSString* ourTeam = [Team getCurrentTeam].name;
    NSString* message = [NSString stringWithFormat: @"%@ %@ the disc", ourTeam, event.action == De ? @"steal" : @"lose"];
        message = 
        isUndo ? 
        [NSString stringWithFormat: @"\"%@\" was a boo-boo...never mind.", message] : 
        event.action == De ?
        [NSString stringWithFormat: @"%@!!! (%@).", message, [event getDescription]]:
        [NSString stringWithFormat: @"%@ (%@).", message, event.action == Drop ? @"drop" : @"throwaway"];
    return message;
}

-(NSString*)halftimeTweetMessage:(Event*) event forGame: (Game*) game isUndo: (BOOL) isUndo {
    return isUndo ? @"\"Halftime\" was a boo-boo...never mind." : @"Halftime.";
}

-(NSString*)gameOverTweetMessageForGame: (Game*) game{
    return [NSString stringWithFormat: @"Game over. %@.", [self getGameScoreDescription:game]];
}

-(NSString*) getTime {
    return [[timeFormatter stringFromDate:[NSDate date]] lowercaseString];
}

@end
