//
//  LeaguevineEventQueue.m
//  UltimateIPhone
//
//  Created by james on 3/29/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "LeaguevineEventQueue.h"
#import "LeaguevineEvent.h"
#import "Game.h"
#import "LeaguevineGame.h"
#import "Event.h"
#import "LeaguevinePostOperation.h"
#import "LeaguevinePostingLog.h"
#import "LeaguevineEventConverter.h"

#define kTriggerDelaySeconds 15

@interface LeaguevineEventQueue()

@property (nonatomic, strong) NSOperationQueue* triggerQueue;
@property (nonatomic, strong) NSString* queueFolderPath;
@property (nonatomic) int lastQueueId;
@property (nonatomic, strong) NSTimer* delayedTriggerTimer;
@property (nonatomic) long lastEventTimeIntervalSinceReferenceDateSeconds;
@property (nonatomic, strong) LeaguevineEventConverter* eventConverter;

@end

@implementation LeaguevineEventQueue

+ (LeaguevineEventQueue*)sharedQueue {
    
    static LeaguevineEventQueue *sharedLeaguevineEventQueue;
    
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^ {
        sharedLeaguevineEventQueue = [[self alloc] init];
    });
    return sharedLeaguevineEventQueue;
}

- (id)init {
    self = [super init];
    if (self) {
        self.lastQueueId = -1;
        [self initQueueFolderPath];
        self.triggerQueue = [[NSOperationQueue alloc] init];
        self.triggerQueue.maxConcurrentOperationCount = 1;
        self.postingLog = [[LeaguevinePostingLog alloc] init];
    }
    return self;
}

-(void)submitNewEvent: (Event*)event forGame: (Game*)game {
    [self submitEvent:[self createLeaguevineEventFor: event inGame: game crud:CRUDAdd]];
}

-(void)submitChangedEvent: (Event*)event forGame: (Game*)game {
    [self submitEvent:[self createLeaguevineEventFor: event inGame: game crud:CRUDUpdate]];
}

-(void)submitDeletedEvent: (Event*)event forGame: (Game*)game {
    [self submitEvent:[self createLeaguevineEventFor: event inGame: game crud:CRUDDelete]];
}

-(void)submitEvent: (LeaguevineEvent*) leaguevineEvent {
    if (leaguevineEvent) {
        [self addEventToQueue:leaguevineEvent];
        [self triggerImmediateSubmit];
    }
}

#pragma mark - Trigger queue

-(void)triggerImmediateSubmit {
    LeaguevinePostOperation* operation = [[LeaguevinePostOperation alloc] init];
    [self.triggerQueue addOperation:operation];
}

-(void)triggerDelayedSubmit {
    [self.delayedTriggerTimer invalidate];
    self.delayedTriggerTimer = [NSTimer scheduledTimerWithTimeInterval:kTriggerDelaySeconds target:self selector:@selector(triggerImmediateSubmit) userInfo:nil repeats:NO];
}

#pragma mark - Queue Folder

// returns files names in descending name order
-(NSArray*)filesInQueueFolder {
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.queueFolderPath error:NULL];
    if (files && [files count] > 0) {
        NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(localizedCompare:)];
        return [files sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    } else {
        return [NSArray array];
    }
}

-(void)removeEvent: (NSString*)filePath {
    NSError *error;
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])	{
		if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]) {
			NSLog(@"Delete file error: %@", error);
		}
	}
}

-(void)addEventToQueue: (LeaguevineEvent*) leaguevineEvent {
    NSString* filePath = [self nextQueueId];
    [leaguevineEvent save:filePath];
}

-(NSString*)nextQueueId {
    if (self.lastQueueId < 0) {
        NSArray*  files = [self filesInQueueFolder];
        if ([files count] > 0) {
            NSString* mostRecentFile = [files objectAtIndex:0];
            self.lastQueueId = [NSNumber numberWithInteger:[mostRecentFile integerValue]].intValue;
        } else {
            self.lastQueueId = 0;
        }
    }
    self.lastQueueId++;
    return [NSString stringWithFormat:@"%09d", self.lastQueueId];  // pad to 9 with leading "0"
}

-(void)initQueueFolderPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDir = [paths objectAtIndex:0];
    self.queueFolderPath = [cacheDir stringByAppendingPathComponent:  @"LeaguevineSubmitQueue"];
}

-(LeaguevineEvent*)createLeaguevineEventFor: (Event*) event inGame: (Game*)game crud: (CRUD)crud {
    LeaguevineEvent* leaguevineEvent = [LeaguevineEvent leaguevineEventWithCrud:crud];
    if (crud != CRUDAdd) {
        leaguevineEvent.leaguevineEventId = [self.postingLog leaguevineEventIdForTimestamp:event.timestamp];
        if (!leaguevineEvent.leaguevineEventId) {
            return nil;
        }
    }
    leaguevineEvent.leaguevineGameId = game.leaguevineGame.itemId;
    leaguevineEvent.iUltimateTimestamp = event.timestamp;
    BOOL isConverted = [self.eventConverter populateLeaguevineEvent:leaguevineEvent withEvent:event fromGame:game];
    return isConverted ? leaguevineEvent : nil;
}

@end
