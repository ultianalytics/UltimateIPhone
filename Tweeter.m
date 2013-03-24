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
#import "DefenseEvent.h"
#import "Game.h"
#import "Preferences.h"
#import "Team.h"
#import "TweetQueue.h"
#import "Tweet.h"
#import "Wind.h"
#import "Player.h"
#import "UPoint.h"

#pragma mark - Private Method Category

@interface Tweeter() 

-(void)tweetFirstEventOfGameIfNecessary:(Event*) event forGame: (Game*) game point: (UPoint*) point isUndo: (BOOL) isUndo;
-(void)updateGameTweeted:(Game*) game event: (Event*) event undo: (BOOL) isUndo;
-(BOOL)hasGameBeenTweeted:(Game*) game;
-(NSString*)gameBeginTweetMessage:(Event*) event forGame: (Game*) game isUndo: (BOOL) isUndo;
-(NSString*)pointBeginTweetMessage:(Event*) event forGame: (Game*) game point: (UPoint*) point isUndo: (BOOL) isUndo;
-(NSString*)goalTweetMessage:(Event*) event forGame: (Game*) game isUndo: (BOOL) isUndo;
-(NSString*)turnoverTweetMessage:(Event*) event forGame: (Game*) game isUndo: (BOOL) isUndo;
-(NSString*)halftimeTweetMessageIsUndo: (BOOL) isUndo;
-(NSString*)gameOverTweetMessageForGame: (Game*) game;
-(NSString*)getTime;

@end

#pragma mark - Implementation

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

-(void)tweetEvent:(Event*) event forGame: (Game*) game point: (UPoint*) point isUndo: (BOOL) isUndo {
    if ([self isTweetingEvents]) {
        [self tweetFirstEventOfGameIfNecessary:event forGame:game point:point isUndo:isUndo];
        if ([event isGoal]) {
            NSString* message = [self goalTweetMessage:event forGame:game isUndo:isUndo]; 
            Tweet* tweet = [[Tweet alloc] initMessage:[NSString stringWithFormat:@"%@  %@", message, [self getTime]] type:@"Event"];
            tweet.isUndo = isUndo;
            tweet.associatedEvent = event;
            [self tweet: tweet];
            if ([game isNextEventImmediatelyAfterHalftime]) {
                NSString* halftimeMessage = [self halftimeTweetMessageIsUndo: isUndo]; 
                Tweet* tweet = [[Tweet alloc] initMessage:[NSString stringWithFormat:@"%@  %@", halftimeMessage, [self getTime]] type:@"Halftime"];
                tweet.isUndo = isUndo;
                tweet.associatedEvent = event;
                [self tweet: tweet];
            }
            [self updateGameTweeted:game event: event undo: isUndo];
        } else if ([event isTurnover] && [self getAutoTweetLevel] == TweetGoalsAndTurns) {
            NSString* message = [self turnoverTweetMessage:event forGame:game isUndo:isUndo]; 
            Tweet* tweet = [[Tweet alloc] initMessage:[NSString stringWithFormat:@"%@  %@", message, [self getTime]] type:@"Event"];
            tweet.isUndo = isUndo;
            tweet.associatedEvent = event;
            tweet.isOptional = YES;
            [self tweet: tweet]; 
            [self updateGameTweeted:game event: event undo: isUndo];
        }
    }
}

-(void)tweetHalftimeWithoutEvent {
    NSString* halftimeMessage = [self halftimeTweetMessageIsUndo:NO]; 
    Tweet* tweet = [[Tweet alloc] initMessage:[NSString stringWithFormat:@"%@  %@", halftimeMessage, [self getTime]] type:@"Halftime"];
    tweet.isUndo = NO;
    [self tweet: tweet];
}

-(void)tweetFirstEventOfPoint:(Event*) event forGame: (Game*) game point: (UPoint*) point isUndo: (BOOL) isUndo {
    if ([self isTweetingEvents]) {
        [self tweetFirstEventOfGameIfNecessary:event forGame:game point:point isUndo:isUndo];
        NSString* message = [self pointBeginTweetMessage:event forGame: game point: point isUndo: isUndo];
        Tweet* tweet = [[Tweet alloc] initMessage:[NSString stringWithFormat:@"%@  %@", message, [self getTime]] type:@"NewPoint"];
        tweet.isUndo = isUndo;
        tweet.associatedEvent = event;
        tweet.isOptional = YES;
        [self tweet: tweet]; 
        if ([event isGoal] || [event isTurnover]) {
            [self tweetEvent:event forGame:game point:point isUndo:isUndo];
        }
        [self updateGameTweeted:game event: event undo: isUndo];
    }
}

-(void)tweetGameOver:(Game*) game {
    if ([self isTweetingEvents]) {
        NSString* message = [self gameOverTweetMessageForGame:game];
        Tweet* tweet = [[Tweet alloc] initMessage:[NSString stringWithFormat:@"%@  %@", message, [self getTime]] type:@"GameOver"];
        [self tweet: tweet]; 
    }
}

-(void)tweetFirstEventOfGameIfNecessary:(Event*) event forGame: (Game*) game point: (UPoint*) point isUndo: (BOOL) isUndo {
    if (![self hasGameBeenTweeted:game] || (isUndo && [game.firstEventTweeted isEqual:event])) {
        if ([game isFirstPoint:point]) {
            NSString* message = [self gameBeginTweetMessage:event forGame: game isUndo: isUndo];
            Tweet* tweet = [[Tweet alloc] initMessage:[NSString stringWithFormat:@"%@  %@", message, [self getTime]] type:@"NewGame"];
            tweet.isUndo = isUndo;
            tweet.associatedEvent = event;
            [self tweet: tweet]; 
        } else {
            NSString* message = [self gameBeginInProgressTweetMessage:event forGame: game isUndo: isUndo];
            Tweet* tweet = [[Tweet alloc] initMessage:[NSString stringWithFormat:@"%@  %@", message, [self getTime]] type:@"NewInProgressGame"];
            tweet.isUndo = isUndo;
            tweet.associatedEvent = event;
            [self tweet: tweet]; 
        }
        [self updateGameTweeted:game event: event undo: isUndo];
    }
}

-(void)tweet:(Tweet*) tweet { 
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

-(BOOL)hasGameBeenTweeted:(Game*) game {
    return game.firstEventTweeted != nil;
}

-(void)updateGameTweeted:(Game*) game event: (Event*) event undo: (BOOL) isUndo {
    if (isUndo) {
        if ([event isEqual:game.firstEventTweeted]) {
            game.firstEventTweeted = nil;
        }
    }
    else if (!game.firstEventTweeted) {
        game.firstEventTweeted = event;
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

-(BOOL)doesTwitterAccountExist {
    return [[self getTwitterAccounts] count] > 0;
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

-(NSString*)gameBeginInProgressTweetMessage:(Event*) event forGame: (Game*) game isUndo: (BOOL) isUndo {
    NSString* message = nil;
    if (isUndo) {
        message = [NSString stringWithFormat: @"New game in progress was a boo-boo...never mind."];
    } else {
        NSString* windDescription = game.wind && game.wind.mph ? [NSString stringWithFormat: @" Wind: %dmph.", game.wind.mph] : @"";
        message = [NSString stringWithFormat:@"New game in progress vs. %@.  Game point: %d.%@ Current score: %@.", game.opponentName, game.gamePoint, windDescription, [self getGameScoreDescription:game]];
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
    NSString* message;
    
    if ([event isCallahan]) {
        message = [NSString stringWithFormat: @"Callahan %@", ourTeam];
    } else {
        message = [NSString stringWithFormat: @"Goal %@", [event isOurGoal] ? ourTeam : game.opponentName];
    }
    
    if (isUndo) {
        message = [NSString stringWithFormat: @"\"%@\" was a boo-boo...never mind", message];
    } else {
        if ([event isOurGoal]) {
            if ([event isCallahan]) {
                message = [NSString stringWithFormat: @"%@!!! %@. %@.", message, ((DefenseEvent*)event).defender.name, [self getGameScoreDescription:game]];
            } else {
                message = [NSString stringWithFormat: @"%@!!! %@ to %@. %@.", message, ((OffenseEvent*)event).passer.name, ((OffenseEvent*)event).receiver.name, [self getGameScoreDescription:game]];
            }
        } else {
            message = [NSString stringWithFormat: @"%@. %@.", message, [self getGameScoreDescription:game]];
        }
    }

    return message;
}

-(NSString*)turnoverTweetMessage:(Event*) event forGame: (Game*) game isUndo: (BOOL) isUndo {
    NSString* ourTeam = [Team getCurrentTeam].name;
    NSString* message = [NSString stringWithFormat: @"%@ %@ the disc", ourTeam, event.action == De ? @"steal" : @"lose"];
    NSString* cause;
    switch (event.action) {
        case Drop:
            cause = @"drop";
            break;
        case Throwaway:
            cause = @"throwaway";
            break;
        case Stall:
            cause = @"stall";
            break;
        case MiscPenalty:
            cause = @"penalty";
            break;
        default:
            cause = @"not sure why";
            break;
    }
    message = isUndo ?
        [NSString stringWithFormat: @"\"%@\" was a boo-boo...never mind.", message] : 
        event.action == De ?
        [NSString stringWithFormat: @"%@!!! (%@).", message, [event getDescription]]:
        [NSString stringWithFormat: @"%@ (%@).", message, cause];
    return message;
}

-(NSString*)halftimeTweetMessageIsUndo: (BOOL) isUndo {
    return isUndo ? @"\"Halftime\" was a boo-boo...never mind." : @"Halftime.";
}

-(NSString*)gameOverTweetMessageForGame: (Game*) game{
    return [NSString stringWithFormat: @"Game over. %@.", [self getGameScoreDescription:game]];
}

-(NSString*) getTime {
    return [[timeFormatter stringFromDate:[NSDate date]] lowercaseString];
}

@end
