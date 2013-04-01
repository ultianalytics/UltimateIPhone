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
#import "LeaguevineClient.h"
#import "CloudClient.h"

@implementation LeaguevinePostOperation

-(void)main {
    NSArray* eventsToPost = [[LeaguevineEventQueue sharedQueue] filesInQueueFolder];
    if ([eventsToPost count] > 0) {
        if ([CloudClient isConnected]) {
            // submit all of the events
            if (![self postEvents:eventsToPost]) {
                // failed...try again in awhile
                [[LeaguevineEventQueue sharedQueue] triggerDelayedSubmit];
            };
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

-(BOOL)postEvents: (NSArray*) filesInQueueFolder {
    LeaguevineClient* lvClient = [[LeaguevineClient alloc] init];
    for (NSString* filePath in filesInQueueFolder) {
        LeaguevineEvent* event = [LeaguevineEvent restoreFrom:filePath];
        if (event) {
            BOOL submitted = [self postEvent: event usingClient:lvClient];
            if (submitted) {
                [[LeaguevineEventQueue sharedQueue] removeEvent:filePath];
            } else {
                return NO;
            }
        } else {
            NSLog(@"bad data...dumping the event");
            [[LeaguevineEventQueue sharedQueue] removeEvent:filePath];
        }
    }
    return YES;
}

-(BOOL)postEvent: (LeaguevineEvent*)event usingClient: (LeaguevineClient*)client {
    LeaguevineInvokeStatus status = [client postEvent:event];
    if (status == LeaguevineInvokeOK) {
        [[LeaguevineEventQueue sharedQueue].postingLog logLeaguevineEvent:event];
        return YES;
    } else {
        return NO;
        /*
         What do we do with these?
         LeaguevineInvokeCredentialsRejected,
         LeaguevineInvokeNetworkError,
         LeaguevineInvokeInvalidResponse,
         LeaguevineInvokeInvalidGame,
         */
    }
}

@end
