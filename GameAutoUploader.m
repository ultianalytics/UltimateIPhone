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

@interface GameUpload : NSObject

@property (nonatomic, strong) NSMutableDictionary* gameJson;
@property (nonatomic, strong) NSString* gameId;
@property (nonatomic, strong) NSString* teamId;
@property (nonatomic, strong) NSString* teamCloudId;
@property (nonatomic) NSTimeInterval gameLastSaveGMT;

@end

@implementation GameUpload


@end

@interface GameAutoUploader ()

@property (nonatomic, strong) GameUpload* nextGameToUpload;

@end

@implementation GameAutoUploader

#pragma mark - Public

+ (GameAutoUploader*)sharedUploader {
    
    static GameAutoUploader *sharedGameAutoUploader;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^ {
        sharedGameAutoUploader = [[self alloc] init];
    });
    return sharedGameAutoUploader;
}

-(void)submitGameForUpload: (Game*) game ofTeam:(Team*)team {
    // OK to be on the main thread...just pulls the data from the game and queues the request for the next update cycle
    GameUpload* gameUpload = [[GameUpload alloc] init];
    gameUpload.gameJson = [game asDictionaryWithScrubbing:NO];
    gameUpload.gameId = game.gameId;
    gameUpload.teamId = team.teamId;
    gameUpload.teamCloudId = team.cloudId;
    gameUpload.gameLastSaveGMT = game.lastSaveGMT;
    NSAssert(gameUpload.gameJson != nil, @"game data required");
    NSAssert(gameUpload.teamId != nil, @"game data required");
    NSAssert(gameUpload.teamCloudId != nil, @"game data required");
    NSAssert(gameUpload.gameId != nil, @"game data required");
    self.nextGameToUpload = gameUpload;
    // todo check for the upload task waiter
}

#pragma mark - Send to server

-(void)sendUploadToServer: (GameUpload*) gameUpload {
    // shoud be on background thread
    NSError* uploadError = nil;
    [CloudClient uploadGameId:gameUpload.gameId withGameJson:gameUpload.gameJson forTeamId:gameUpload.teamId withCloudId:gameUpload.teamCloudId lastSaveGmt:gameUpload.gameLastSaveGMT error:&uploadError];
    // todo...check for error...
    // log error
    // too many errors in a row?  turn off auto uploading
    // send a notification if error
}

@end
