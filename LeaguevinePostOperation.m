//
//  LeaguevinePostOperation.m
//  UltimateIPhone
//
//  Created by james on 3/30/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "LeaguevinePostOperation.h"
#import "LeaguevineEventQueue.h"
#import "LeaguevinePostingLog.h"
#import "LeaguevineEvent.h"
#import "LeaguevineScore.h"
#import "LeaguevineClient.h"
#import "Reachability.h"

#define kMinimumRemainingBackgroundTimeToContinue 120  

@implementation LeaguevinePostOperation

-(void)main {
    NSArray* filesInQueueFolder = [[LeaguevineEventQueue sharedQueue] filesInQueueFolder];
    if ([filesInQueueFolder count] > 0) {
        Reachability* reachability = [Reachability reachabilityForInternetConnection];
        if (![reachability currentReachabilityStatus] == NotReachable) {
            // post all of the events
            [self postEvents:filesInQueueFolder];
        } else {
            // not connected...try again in awhile
            [[LeaguevineEventQueue sharedQueue] triggerDelayedSubmit];
        }
    }
}

-(void)postEvents: (NSArray*)eventFilePaths {
    UIBackgroundTaskIdentifier backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    LeaguevineClient* lvClient = [[LeaguevineClient alloc] init];
    for (NSString* filePath in eventFilePaths) {
        if ([UIApplication sharedApplication].backgroundTimeRemaining > kMinimumRemainingBackgroundTimeToContinue) {
            if ([[LeaguevineEventQueue sharedQueue] isEvent:filePath]) {
                if (![self postEvent: filePath usingClient:lvClient]) {
                    break;
                }
            } else {
                if (![self postScore: filePath usingClient:lvClient]) {
                    break;
                }
            }
        } else {
            break;
        }
    }
    if (backgroundTaskId != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
    }
}

-(NSArray*)getEventsToSubmit {
    NSArray*  files = [[LeaguevineEventQueue sharedQueue] filesInQueueFolder];
    NSMutableArray* events = [NSMutableArray array];
    for (NSString* filePath in files) {
        LeaguevineEvent* lvEvent = [LeaguevineEvent restoreFrom:filePath];
        [events addObject:lvEvent];
    }
    return events;
}

-(BOOL)postEvent: (NSString*)filePath usingClient: (LeaguevineClient*)client {
    LeaguevineEvent* event = [LeaguevineEvent restoreFrom:filePath];
    if (event) {    
        if ([event isLineChange]) {
            return [self postLineChangeEvent:filePath usingClient:client];
        } else {
            if ([event isUpdateOrDelete]) {
                event.leaguevineEventId = [[LeaguevineEventQueue sharedQueue].postingLog leaguevineEventIdForTimestamp:event.iUltimateTimestamp  eventType: event.leaguevineEventType];
                if (!event.leaguevineEventId) {
                    SHSLog(@"Posting an event for %@ but the previous add event was not found in log.  Skipping %@", [event isDelete] ? @"delete" : @"update", event);
                    [[LeaguevineEventQueue sharedQueue] removeEvent:filePath];
                    return YES;
                }
            }
            LeaguevineInvokeStatus status = [client postEvent:event];
            if (status == LeaguevineInvokeOK) {
                [[LeaguevineEventQueue sharedQueue].postingLog logLeaguevineEvent:event];
                [[LeaguevineEventQueue sharedQueue] removeEvent:filePath];
                return YES;
            } else if (status == LeaguevineInvokeNetworkError) {
                [[LeaguevineEventQueue sharedQueue] triggerDelayedSubmit];
                return NO;
            } else if (status == LeaguevineInvokeCredentialsRejected) {
                [self writeInvalidCredentialsError];
                return NO;
            } else if (status == LeaguevineInvokeInvalidResponse) {
                [self writeInvalidRequestError];
                SHSLog(@"Posting an event for %@ but leaguvine returned an invalid response.  Skipping %@", [event isDelete] ? @"delete" : @"update", event);
                [[LeaguevineEventQueue sharedQueue] removeEvent:filePath];
                return YES;
            } else if (status == LeaguevineInvokeInvalidGame) {
                [self writeInvalidRequestError];
                SHSLog(@"Posting an event for %@ but leaguvine rejected it as invalid game.  Skipping %@", [event isDelete] ? @"delete" : @"update", event);
                [[LeaguevineEventQueue sharedQueue] removeEvent:filePath];
                return YES;
            } else {
                [[LeaguevineEventQueue sharedQueue] removeEvent:filePath];
                return YES;
            }
        }
    } else {
        SHSLog(@"bad data...dumping the event");
        [[LeaguevineEventQueue sharedQueue] removeEvent:filePath];
        return YES;
    }
}

-(BOOL)postScore: (NSString*)filePath usingClient: (LeaguevineClient*)client {
    LeaguevineScore* lvScore = [LeaguevineScore restoreFrom:filePath];
    if (lvScore) {
        LeaguevineInvokeStatus status = [client postGameScore:lvScore];
        if (status == LeaguevineInvokeOK) {
            [[LeaguevineEventQueue sharedQueue] removeEvent:filePath];
            return YES;
        } else if (status == LeaguevineInvokeNetworkError) {
            [[LeaguevineEventQueue sharedQueue] triggerDelayedSubmit];
            SHSLog(@"Posting a score for %@ but leaguvine failed due to network error.", lvScore);
            return NO;
        } else if (status == LeaguevineInvokeCredentialsRejected) {
            [self writeInvalidCredentialsError];
            SHSLog(@"Posting a score for %@ but leaguvine failed response due to invalid credentials.", lvScore);
            return NO;
        } else if (status == LeaguevineInvokeInvalidResponse) {
            [self writeInvalidRequestError];
            SHSLog(@"Posting a score for %@ but leaguvine returned an invalid response.  Skipping.", lvScore);
            [[LeaguevineEventQueue sharedQueue] removeEvent:filePath];
            return YES;
        } else if (status == LeaguevineInvokeInvalidGame) {
            [self writeInvalidRequestError];
            SHSLog(@"Posting an event for %@ but leaguvine rejected it as invalid game.  Skipping.", lvScore);
            [[LeaguevineEventQueue sharedQueue] removeEvent:filePath];
            return YES;
        } else {
            [self writeInvalidRequestError];
            [[LeaguevineEventQueue sharedQueue] removeEvent:filePath];
            return YES;
        }
    } else {
        SHSLog(@"bad data...dumping the score");
        [[LeaguevineEventQueue sharedQueue] removeEvent:filePath];
        return YES;
    }
}

#pragma Line Changes

-(BOOL)postLineChangeEvent: (NSString*)filePath usingClient: (LeaguevineClient*)client {
    LeaguevineEvent* lineChangeEvent = [LeaguevineEvent restoreFrom:filePath];
    // create a list of events to sub out old and sub in new
    NSArray* newLine = lineChangeEvent.latestLine;
    NSArray* oldLine = [[LeaguevineEventQueue sharedQueue].postingLog lastLinePostedForGameId:lineChangeEvent.leaguevineGameId];
    NSMutableArray* events = [self subOutEventsFor:lineChangeEvent.leaguevineGameId oldLine:oldLine newLine:newLine];
    [events addObjectsFromArray:[self subInEventsFor:lineChangeEvent.leaguevineGameId oldLine:oldLine newLine:newLine]];

    if ([events count] > 0) {    
        BOOL ok = YES;
        for (LeaguevineEvent* substitutionEvent in events) {
            substitutionEvent.iUltimateTimestamp = lineChangeEvent.iUltimateTimestamp;
            LeaguevineInvokeStatus status = [client postEvent:substitutionEvent];
            if (status != LeaguevineInvokeOK) {
               if (status == LeaguevineInvokeNetworkError) {
                    [[LeaguevineEventQueue sharedQueue] triggerDelayedSubmit];
                    ok = NO;
                } else if (status == LeaguevineInvokeCredentialsRejected) {
                    [self writeInvalidCredentialsError];
                    ok = NO;
                } else if (status == LeaguevineInvokeInvalidResponse) {
                    [self writeInvalidRequestError];
                    SHSLog(@"Posting a line change event but leaguvine returned an invalid response.  Skipping subsitution event %@", substitutionEvent);
                } else if (status == LeaguevineInvokeInvalidGame) {
                    [self writeInvalidRequestError];
                    SHSLog(@"Posting a line change event but leaguvine rejected it as invalid game.  Skipping subsitution event %@", substitutionEvent);
                }
            }
            if (!ok) {
                return NO;
            }
        }
    } else {
        SHSLog(@"Posting line change but no personnel changed.  Didn't posted to leaguevine");
    }
    [[LeaguevineEventQueue sharedQueue].postingLog logLeaguevineEvent:lineChangeEvent];
    [[LeaguevineEventQueue sharedQueue] removeEvent:filePath];
    return YES;
}

-(NSMutableArray*)subOutEventsFor: (NSUInteger)gameId oldLine: (NSArray*)oldLine newLine:(NSArray*)newLine {
    NSMutableSet* subOutEvents = oldLine ? [NSMutableSet setWithArray:oldLine] : [NSMutableSet set];
    [subOutEvents minusSet: newLine ? [NSMutableSet setWithArray:newLine] : [NSMutableSet set]];
    return [self subEventsForGame:gameId withPlayerIds:subOutEvents isOut: YES];
}

-(NSMutableArray*)subInEventsFor: (NSUInteger)gameId oldLine: (NSArray*)oldLine newLine:(NSArray*)newLine {
    NSMutableSet* subInEvents = newLine ? [NSMutableSet setWithArray:newLine] : [NSMutableSet set];
    [subInEvents minusSet: oldLine ? [NSMutableSet setWithArray:oldLine] : [NSMutableSet set]];
    return [self subEventsForGame:gameId withPlayerIds:subInEvents isOut: NO];
}

-(NSMutableArray*)subEventsForGame: (NSUInteger)gameId withPlayerIds: (NSSet*)playerIds isOut: (BOOL)subOut {
    NSUInteger eventType = subOut ? 81 : 80;
    NSMutableArray* events = [NSMutableArray array];
    for (NSNumber* playerId in playerIds) {
        LeaguevineEvent* lvEvent = [LeaguevineEvent leaguevineEventWithCrud:CRUDAdd];
        lvEvent.leaguevineGameId = gameId;
        lvEvent.eventDescription = [NSString stringWithFormat: @"substitution %@", subOut ? @"out" : @"in"];
        lvEvent.leaguevinePlayer1Id = playerId.intValue;
        lvEvent.leaguevineEventType = eventType;
        [events addObject:lvEvent];
    }
    return events;
}

-(void)writeInvalidRequestError {
    [[LeaguevineEventQueue sharedQueue].postingLog writeErrorMessage:@"Errors attempting to publish events to leaguevine (usually caused by changes in the leaguevine team, game, or players since the game began).  Data has been skipped." overwrite:NO];
}

-(void)writeInvalidCredentialsError {
    [[LeaguevineEventQueue sharedQueue].postingLog writeErrorMessage:@"Leaguevine is not accepting the event data that iUltimate is attempting to publish because it does not accept your credentials.  Try switching the game to private and back to \"stats\" to get authenticated." overwrite:NO];
}

@end
