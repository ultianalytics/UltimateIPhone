//
//  GameAutoUploader.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 9/4/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "GameAutoUploader.h"
#import "Game.h"
#import "Team.h"
#import "CloudClient2.h"
#import "Preferences.h"

#define kAutoLoaderFileName     @"autoloader.dat"
#define kAutoLoaderKey          @"autoloader"
#define kGameIdKey              @"gameId"
#define kTeamIdKey              @"teamId"
#define kGameLastUpdateKey      @"gameLastUpdate"
#define kLastUploadTimeKey      @"lastUpdloadTime"
#define kNextGameToUploadKey    @"nextGame"

#define kUploadIntervalSeconds 30

@interface GameUpload : NSObject

@property (nonatomic, strong) NSString* gameId;
@property (nonatomic, strong) NSString* teamId;
@property (nonatomic) NSTimeInterval gameLastUpdateGMT;

@end

@interface GameAutoUploader ()

@property (nonatomic, strong) GameUpload* nextGameToUpload;
@property (nonatomic) NSTimeInterval lastUploadTime;
@property (nonatomic) BOOL isNextUploadScheduledOrInProgress;  // transient...default is false
@property (nonatomic) UIBackgroundTaskIdentifier backgroundUploadTaskIdentifier;
@property (nonatomic) CloudRequestStatus* lastUploadStatus;

@end

@implementation GameAutoUploader

#pragma mark - Public

+ (GameAutoUploader*)sharedUploader {
    
    static GameAutoUploader *sharedGameAutoUploader;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^ {
        sharedGameAutoUploader = [self readAutoLoader];
        if (!sharedGameAutoUploader) {
            sharedGameAutoUploader = [[self alloc] init];
        }
    });
    return sharedGameAutoUploader;
}

// OK to call this on the main thread: this method just pulls the meta info from the game and queues the real work for the next update cycle which happens on a background thread
-(void)submitGameForUpload: (Game*) game ofTeam:(Team*)team {
    @synchronized (self) {
        if ([self isAutoUploading]) {
            GameUpload* gameUpload = [[GameUpload alloc] init];
            gameUpload.gameId = game.gameId;
            gameUpload.teamId = team.teamId;
            gameUpload.gameLastUpdateGMT = game.lastSaveGMT;
            NSAssert(gameUpload.teamId != nil, @"team id required");
            NSAssert(gameUpload.gameId != nil, @"game data required");
            NSAssert(gameUpload.gameLastUpdateGMT != 0, @"game last update time needed for auto game upload");
            self.nextGameToUpload = gameUpload;
            [self save];
            [self scheduleNextUpload];
        }
    }
}

-(void)flush {
    @synchronized (self) {
        if ([self isAutoUploading]) {
            [[self class] cancelPreviousPerformRequestsWithTarget:self selector: @selector(upload) object:nil];
            self.lastUploadTime = 0;
            self.isNextUploadScheduledOrInProgress = NO;
            [self scheduleNextUpload];
        }
    }
}

-(BOOL)isAutoUploading {
    return [Preferences getCurrentPreferences].gameAutoUpload;
}

-(void)resetErrorsOnLastUpload {
    self.lastUploadStatus = nil;
}

-(BOOL)errorOnLastUpload {
    return self.lastUploadStatus && !self.lastUploadStatus.ok;
}

#pragma mark - Async Uploading

-(void)sendUploadToServer: (GameUpload*) gameUpload {
    self.lastUploadTime = [NSDate timeIntervalSinceReferenceDate];
    if (gameUpload) {
        [CloudClient2 uploadGame:gameUpload.gameId forTeam:gameUpload.teamId completion:^(CloudRequestStatus *requestStatus) {
            GameUpload* finishedGameUpload = requestStatus.ok ? gameUpload : nil;
            self.lastUploadStatus = requestStatus;
            [self uploadFinished:finishedGameUpload];
        }];
    }

}

-(void)uploadFinished: (GameUpload*) gameUpload {
    @synchronized (self) {
        self.isNextUploadScheduledOrInProgress = NO;
        self.lastUploadTime = [NSDate timeIntervalSinceReferenceDate];
        // if this game version was the last submitted upload then stop
        if ([self.nextGameToUpload isEqual:gameUpload]) {
            self.nextGameToUpload = nil;
            [self save];
        } else {
            [self scheduleNextUpload];
        }
    }
}

-(void)scheduleNextUpload {
    @synchronized (self) {
        // only schedule the next round if we haven't alredy done so AND there is a game to upload
        if (!self.isNextUploadScheduledOrInProgress && self.nextGameToUpload) {
            NSTimeInterval secondsSinceLastUpdate = MAX(0, [NSDate timeIntervalSinceReferenceDate] - self.lastUploadTime);
            NSTimeInterval delay = MAX(0, kUploadIntervalSeconds - secondsSinceLastUpdate);
            self.isNextUploadScheduledOrInProgress = YES;
           [self performSelector:@selector(upload) withObject:nil afterDelay:delay];
        }
    }
}

-(void)upload {
    @synchronized (self) {
        GameUpload* nextUpload = self.nextGameToUpload;
        if (nextUpload) {
            [self beginBackgroundUploadTask];
            [self sendUploadToServer:nextUpload];
            [self endBackgroundUploadTask];
        }
    }
}

- (void) beginBackgroundUploadTask {
    __typeof(self) __weak weakSelf = self;
    self.backgroundUploadTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [weakSelf endBackgroundUploadTask];
    }];
}

- (void) endBackgroundUploadTask {
    [[UIApplication sharedApplication] endBackgroundTask: self.backgroundUploadTaskIdentifier];
    self.backgroundUploadTaskIdentifier = UIBackgroundTaskInvalid;
}

#pragma mark - Persistence

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.nextGameToUpload forKey:kNextGameToUploadKey];
    [encoder encodeDouble:self.lastUploadTime forKey:kLastUploadTimeKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.nextGameToUpload = [decoder decodeObjectForKey:kNextGameToUploadKey];
        self.lastUploadTime = [decoder decodeDoubleForKey:kLastUploadTimeKey];
    }
    return self;
}

+(GameAutoUploader*)readAutoLoader {
    NSData *data = [[NSData alloc] initWithContentsOfFile: [self getFilePath]];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]
                                     initForReadingWithData:data];
    return [unarchiver decodeObjectForKey:kAutoLoaderKey];
}

-(void)save {
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]
                                 initForWritingWithMutableData:data];
    [archiver encodeObject: self forKey:kAutoLoaderKey];
    [archiver finishEncoding];
    BOOL success = [data writeToFile:[[self class] getFilePath] atomically:YES];
    if (!success) {
        [NSException raise:@"Failed trying to save auto loader state" format:@"failed auto loader state"];
    }
}

+ (NSString*)getFilePath {
    NSArray* paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kAutoLoaderFileName];
}

@end


#pragma mark - GameUpload object

/*
 
    GameUpload object (used for remembering state of an upload request) 
 
 */

@implementation GameUpload

- (BOOL)isEqual:(id)anObject {
    if (![anObject isKindOfClass:[self class]]) {
        return NO;
    }
    return [self.gameId isEqualToString:[anObject gameId]] &&
    [self.teamId isEqualToString:[anObject teamId]] &&
    self.gameLastUpdateGMT == [anObject gameLastUpdateGMT];
}

- (NSUInteger)hash {
    return [self.gameId hash];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.gameId forKey:kGameIdKey];
    [encoder encodeObject:self.teamId forKey:kTeamIdKey];
    [encoder encodeDouble:self.gameLastUpdateGMT forKey:kGameLastUpdateKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.gameId = [decoder decodeObjectForKey:kGameIdKey];
        self.teamId = [decoder decodeObjectForKey:kTeamIdKey];
        self.gameLastUpdateGMT = [decoder decodeDoubleForKey:kGameLastUpdateKey];
    }
    return self;
}

@end



