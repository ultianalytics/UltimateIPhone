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
#import "CloudClient.h"

@implementation LeaguevinePostOperation

-(void)main {
    NSArray* filesInQueueFolder = [[LeaguevineEventQueue sharedQueue] filesInQueueFolder];
    if ([filesInQueueFolder count] > 0) {
        if ([CloudClient isConnected]) {
            // post all of the events
            LeaguevineClient* lvClient = [[LeaguevineClient alloc] init];
            for (NSString* filePath in filesInQueueFolder) {
                if ([[LeaguevineEventQueue sharedQueue] isEvent:filePath]) {
                    if (![self postEvent: filePath usingClient:lvClient]) {
                        break;
                    }
                } else {
                    if (![self postScore: filePath usingClient:lvClient]) {
                        break;
                    }
                }
            }
        } else {
            // not connected...try again in awhile
            [[LeaguevineEventQueue sharedQueue] triggerDelayedSubmit];
        }
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
        if ([event isUpdateOrDelete]) {
            event.leaguevineEventId = [[LeaguevineEventQueue sharedQueue] leaguevineEventIdForTimestamp:event.iUltimateTimestamp];
            if (!event.leaguevineEventId) {
                NSLog(@"Posting an event for %@ but the previous add event was not found in log.  Skipping %@", [event isDelete] ? @"delete" : @"update", event);
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
            return NO;
        } else if (status == LeaguevineInvokeInvalidResponse) {
            NSLog(@"Posting an event for %@ but leaguvine returned an invalid response.  Skipping %@", [event isDelete] ? @"delete" : @"update", event);
            [[LeaguevineEventQueue sharedQueue] removeEvent:filePath];
            return YES;
        } else if (status == LeaguevineInvokeInvalidGame) {
            NSLog(@"Posting an event for %@ but leaguvine rejected it as invalid game.  Skipping %@", [event isDelete] ? @"delete" : @"update", event);
            [[LeaguevineEventQueue sharedQueue] removeEvent:filePath];
            return YES;
        } else {
            [[LeaguevineEventQueue sharedQueue] removeEvent:filePath];
            return YES;
        }
    } else {
        NSLog(@"bad data...dumping the event");
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
            NSLog(@"Posting a score for %@ but leaguvine failed due to network error.", lvScore);
            return NO;
        } else if (status == LeaguevineInvokeCredentialsRejected) {
            NSLog(@"Posting a score for %@ but leaguvine failed response due to invalid credentials.", lvScore);
            return NO;
        } else if (status == LeaguevineInvokeInvalidResponse) {
            NSLog(@"Posting a score for %@ but leaguvine returned an invalid response.  Skipping.", lvScore);
            [[LeaguevineEventQueue sharedQueue] removeEvent:filePath];
            return YES;
        } else if (status == LeaguevineInvokeInvalidGame) {
            NSLog(@"Posting an event for %@ but leaguvine rejected it as invalid game.  Skipping.", lvScore);
            [[LeaguevineEventQueue sharedQueue] removeEvent:filePath];
            return YES;
        } else {
            [[LeaguevineEventQueue sharedQueue] removeEvent:filePath];
            return YES;
        }
    } else {
        NSLog(@"bad data...dumping the score");
        [[LeaguevineEventQueue sharedQueue] removeEvent:filePath];
        return YES;
    }
}


@end
