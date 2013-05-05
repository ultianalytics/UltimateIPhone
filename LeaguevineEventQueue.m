//
//  LeaguevineEventQueue.m
//  UltimateIPhone
//
//  Created by james on 3/29/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "Reachability.h"
#import "UniqueTimestampGenerator.h"
#import "LeaguevineEventQueue.h"
#import "LeaguevineEvent.h"
#import "LeaguevineScore.h"
#import "LeaguevineGame.h"
#import "LeaguevineTeam.h"
#import "LeaguevinePlayer.h"
#import "LeaguevinePostOperation.h"
#import "LeaguevinePostingLog.h"
#import "LeaguevineEventConverter.h"
#import "Game.h"
#import "UPoint.h"
#import "Event.h"
#import "Team.h"
#import "Player.h"

#define kTriggerDelaySeconds 15
#define kEventFileExtension @"event"
#define kScoreFileExtension @"score"

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
        self.eventConverter = [[LeaguevineEventConverter alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerImmediateSubmit) name:kReachabilityChangedNotification object:nil];
    }
    return self;
}

#pragma mark - Submitting

-(void)submitNewEvent: (Event*)event forGame: (Game*)game isFirstEventAfterPull: (BOOL)isFirstEventAfterPull {
    if (event.isOffense && isFirstEventAfterPull) {
        [self submitEvent:[self createDummyPullLeaguevineEventForFirstOlineEvent: event inGame: game crud:CRUDAdd] forEventDescription:[event description]];
    }
    LeaguevineEvent* lvEvt = [self createLeaguevineEventFor: event inGame: game crud:CRUDAdd];
    [self submitEvent:lvEvt forEventDescription:[event description]];
    if ([event isGoal]) {
        [self submitScoreForGame:game final:NO];
    }
}

-(void)submitChangedEvent: (Event*)event forGame: (Game*)game {
    [self submitEvent:[self createLeaguevineEventFor: event inGame: game crud:CRUDUpdate]  forEventDescription:[event description]];
}

-(void)submitDeletedEvent: (Event*)event forGame: (Game*)game {
    [self submitEvent:[self createLeaguevineEventFor: event inGame: game crud:CRUDDelete]  forEventDescription:[event description]];
    if ([event isGoal]) {
        [self submitScoreForGame:game final:NO];
    }
}

-(void)submitLineChangeForGame: (Game*)game {
    [self submitEvent:[self createLineChangeEventForGame:game] forEventDescription:@"line change"];
}

-(void)submitScoreForGame: (Game*)game final: (BOOL)final {
    LeaguevineScore* score = [self createLeaguevineScoreFor: game final:final];
    if (score) {
        [self addScoreToQueue:score];
        [self triggerImmediateSubmit];
        SHSLog(@"Submitted score");
    } else {
        SHSLog(@"Warning: submit score failed");
    }
}

-(void)submitEvent: (LeaguevineEvent*) leaguevineEvent forEventDescription: (NSString*)eventDescription {
    if (leaguevineEvent) {
        [self addEventToQueue:leaguevineEvent];
        [self triggerImmediateSubmit];
        SHSLog(@"Submitted event \"%@\"", eventDescription);
    } else {
        SHSLog(@"Warning: submit event  failed: %@", eventDescription);
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
        NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES selector:@selector(localizedCompare:)];
        NSArray* fileNames = [files sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        NSMutableArray* filePaths = [NSMutableArray array];
        for (NSString* fileName in fileNames) {
            NSString* extension = [fileName pathExtension];
            if ([extension isEqualToString:kEventFileExtension] || [extension isEqualToString:kScoreFileExtension]) {
                [filePaths addObject:[self.queueFolderPath stringByAppendingPathComponent:fileName]];
            }
        }
        return filePaths;
    } else {
        return [NSArray array];
    }
}

-(void)removeEvent: (NSString*)filePath {
    NSError *error;
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])	{
		if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]) {
			SHSLog(@"Delete file error: %@", error);
		}
	}
}

-(void)addEventToQueue: (LeaguevineEvent*) leaguevineEvent {
    NSString* filePath = [[self.queueFolderPath stringByAppendingPathComponent: [self nextQueueId]] stringByAppendingPathExtension:kEventFileExtension];
    [leaguevineEvent save:filePath];
}

-(void)addScoreToQueue: (LeaguevineScore*) leaguevineScore {
    NSString* filePath = [[self.queueFolderPath stringByAppendingPathComponent: [self nextQueueId]] stringByAppendingPathExtension:kScoreFileExtension];
    [leaguevineScore save:filePath];
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
    NSError *error;
	if (![[NSFileManager defaultManager] fileExistsAtPath:self.queueFolderPath]) {
		if (![[NSFileManager defaultManager] createDirectoryAtPath:self.queueFolderPath withIntermediateDirectories:NO attributes:nil error:&error]) {
			SHSLog(@"Error creating leaguevine event queue: %@", error);
		}
	}
}

-(LeaguevineEvent*)createLeaguevineEventFor: (Event*) event inGame: (Game*)game crud: (CRUD)crud {
    LeaguevineEvent* leaguevineEvent = [LeaguevineEvent leaguevineEventWithCrud:crud];

    BOOL isConverted = [self.eventConverter populateLeaguevineEvent:leaguevineEvent withEvent:event fromGame:game];
    return isConverted ? leaguevineEvent : nil;
}

-(LeaguevineEvent*)createDummyPullLeaguevineEventForFirstOlineEvent: (Event*) event inGame: (Game*)game crud: (CRUD)crud {
    LeaguevineEvent* leaguevineEvent = [LeaguevineEvent leaguevineEventWithCrud:crud];
    [self.eventConverter populateDummyOtherTeamPullLeaguevineEvent:leaguevineEvent usingFirstOlineEvent:event fromGame:game];
    return leaguevineEvent;
}

-(LeaguevineEvent*)createLineChangeEventForGame: (Game*)game {
    LeaguevineEvent* leaguevineEvent =[self createLineChangeEventForLeaguevineGameId:game.leaguevineGame.itemId withNewPlayers:game.currentLine];
    leaguevineEvent.iUltimateTimestamp = [[UniqueTimestampGenerator sharedGenerator] uniqueTimeIntervalSinceReferenceDateSeconds];
    return leaguevineEvent;
}

-(LeaguevineEvent*)createLineChangeEventForLeaguevineGameId: (NSUInteger)leaguevineGameId withNewPlayers: (NSArray*)players {
    LeaguevineEvent* leaguevineEvent = [LeaguevineEvent leaguevineEventWithCrud:CRUDUpdate];
    leaguevineEvent.leaguevineGameId = leaguevineGameId;
    leaguevineEvent.leaguevineEventType = kLineChangeEventType;
    
    NSMutableArray* leaguevinePlayerIds = [NSMutableArray array];
    for (Player* player in players) {
        NSUInteger playerId = player.leaguevinePlayer.playerId;
        if (playerId) {
            [leaguevinePlayerIds addObject:[NSNumber numberWithInt:playerId]];
        }
    }
    leaguevineEvent.latestLine = leaguevinePlayerIds;
    
    return leaguevineEvent;
}


-(LeaguevineScore*)createLeaguevineScoreFor: (Game*)game final: (BOOL)scoreIsFinal {
    LeaguevineGame* lvGame = game.leaguevineGame;
    if (!lvGame) {
        SHSLog(@"Error posting LV game score: game isn't a LV game anymore");
        return nil;
    }
    LeaguevineTeam* lvTeam = [Team getCurrentTeam].leaguevineTeam;
    if (!lvGame) {
        SHSLog(@"Error posting LV game score: game team isn't a LV team anymore");
        return nil;
    }
    LeaguevineScore* lvScore = [LeaguevineScore leaguevineScoreWithGameId:lvGame.itemId];
    
    if (lvGame.team1Id == lvTeam.itemId) {  // are we team 1?
        lvScore.team1Score = [game getScore].ours;
        lvScore.team2Score = [game getScore].theirs;
    } else if (lvGame.team2Id == lvTeam.itemId) { // or team 2?
        lvScore.team2Score = [game getScore].ours;
        lvScore.team1Score = [game getScore].theirs;
    } else {  // or nowhere to be found?
        SHSLog(@"Error posting LV game score: our team isn't one of the teams on the LV game");
        return nil;
    }
    lvScore.final = scoreIsFinal;
    
    return lvScore;

}

-(BOOL)isEvent: (NSString*)filePath  {
    return [[filePath pathExtension] isEqualToString:kEventFileExtension];
}

-(BOOL)isScore: (NSString*)filePath {
    return [[filePath pathExtension] isEqualToString:kScoreFileExtension];
}

-(void)submitAllGameStats: (Game*)game {
    if ([game hasEvents]) {
        Event* firstEvent = [[[[game points] objectAtIndex:0] events] objectAtIndex:0];
        NSTimeInterval lastEventTime = firstEvent.timestamp - 5;
        for (UPoint* point in game.points) {
            LeaguevineEvent* lineChangeEvent = [self createLineChangeEventForLeaguevineGameId: game.leaguevineGame.itemId withNewPlayers: point.line];
            lineChangeEvent.iUltimateTimestamp = lastEventTime + 1;
            [self submitEvent:lineChangeEvent forEventDescription:@"line change"];
            Event* lastEvent;
            for (Event* evt in [point getEvents]) {
                BOOL wasLastPointPull = point.summary.isOline ? lastEvent == nil : [lastEvent isPull];
                [self submitNewEvent:evt forGame:game isFirstEventAfterPull:wasLastPointPull];
                lastEvent = evt;
            }
        }
        [self submitScoreForGame:game final:YES];
    }
}

@end
