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
#import "CloudClient.h"

#define kAutoLoaderFileName     @"autoloader.dat"
#define kAutoLoaderKey          @"autoloader"
#define kGameIdKey              @"gameId"
#define kTeamIdKey              @"teamId"
#define kGameLastUpdateKey      @"gameLastUpdate"
#define kLastUploadTimeKey      @"lastUpdloadTime"
#define kNextGameToUploadKey    @"nextGame"

#define kUploadIntervalSeconds 60

@interface GameUpload : NSObject

@property (nonatomic, strong) NSString* gameId;
@property (nonatomic, strong) NSString* teamId;
@property (nonatomic) NSTimeInterval gameLastUpdateGMT;

@end

@interface GameAutoUploader ()

@property (nonatomic, strong) GameUpload* nextGameToUpload;
@property (nonatomic) NSTimeInterval lastUploadTime;
@property (nonatomic) BOOL isNextUploadScheduled;  // transient...default is false

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

-(void)submitGameForUpload: (Game*) game ofTeam:(Team*)team {
    @synchronized (self) {
        // OK to be on the main thread...just pulls the data from the game and queues the request for the next update cycle
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

#pragma mark - Async Uploading

-(void)sendUploadToServer: (GameUpload*) gameUpload {
    self.lastUploadTime = [NSDate timeIntervalSinceReferenceDate];
    if (gameUpload) {
        // this should be run on background background thread
        NSError* uploadError = nil;
        [CloudClient uploadGame:gameUpload.gameId forTeam:gameUpload.teamId error:&uploadError];
        if (uploadError) {
            [self uploadFinished:nil];
            // log error
            // too many errors in a row?  turn off auto uploading
            // send a notification of error
            
        } else {
            [self uploadFinished:gameUpload];
        }
    }
}

-(void)uploadFinished: (GameUpload*) gameUpload {
    @synchronized (self) {
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
        if (!self.isNextUploadScheduled && self.nextGameToUpload) {
            NSTimeInterval secondsSinceLastUpdate = MAX(0, [NSDate timeIntervalSinceReferenceDate] - self.lastUploadTime);
            NSTimeInterval delay = MAX(0, kUploadIntervalSeconds - secondsSinceLastUpdate);
            self.isNextUploadScheduled = YES;
           [self performSelector:@selector(performScheduledUpload) withObject:nil afterDelay:delay];
        }
    }
}

-(void)performScheduledUpload {
    @synchronized (self) {
        self.isNextUploadScheduled = NO;
        [self upload];
    }
}

-(void)upload {
    @synchronized (self) {
        GameUpload* nextUpload = self.nextGameToUpload;
        if (nextUpload) {
            __typeof(self) __weak weakSelf = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                @autoreleasepool {
                    [weakSelf sendUploadToServer:nextUpload];
                }
            });
        }
    }
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



