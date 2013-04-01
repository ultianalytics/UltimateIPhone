//
//  LeaguevineEvent.m
//  UltimateIPhone
//
//  Created by james on 3/29/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "LeaguevineEvent.h"
#import "Game.h"

#define kLeaguevineEvent @"LeaguevineEvent"
#define kCrud @"crud"
#define kEventType @"type"
#define kTimestamp @"time"
#define kGameId @"game_id"
#define kPlayer1Id @"player_1_id"
#define kPlayer2Id @"player_2_id"
#define kPlayer3Id @"player_3_id"
#define kPlayer1TeamId @"player_1_team_id"
#define kPlayer2TeamId @"player_2_team_id"
#define kPlayer3TeamId @"player_3_team_id"


@implementation LeaguevineEvent

+(LeaguevineEvent*)leaguevineEventWithCrud: (CRUD)crud  {
    LeaguevineEvent* event = [[LeaguevineEvent alloc] init];
    event.crud = crud;
    return event;
}

+(LeaguevineEvent*)restoreFrom: (NSString*)filePath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData *data = [[NSData alloc] initWithContentsOfFile: filePath];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        LeaguevineEvent* lvEvent = [unarchiver decodeObjectForKey:kLeaguevineEvent];
        return lvEvent;
    } else {
        return nil;
    }
}

-(void)save: (NSString*)filePath {
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]
                                 initForWritingWithMutableData:data];
    [archiver encodeObject: self forKey:kLeaguevineEvent];
    [archiver finishEncoding];
    BOOL success = [data writeToFile:filePath atomically:YES];
    if (!success) {
        NSLog(@"Failed trying to save leaguevine event");
    }
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.leaguevineGameId = [decoder decodeIntForKey:kGameId];
        self.leaguevineEventType = [decoder decodeIntForKey:kEventType];
        self.leaguevinePlayer1Id = [decoder decodeIntForKey:kPlayer1Id];
        self.leaguevinePlayer2Id = [decoder decodeIntForKey:kPlayer2Id];
        self.leaguevinePlayer3Id = [decoder decodeIntForKey:kPlayer3Id];
        self.leaguevinePlayer1TeamId = [decoder decodeIntForKey:kPlayer1TeamId];
        self.leaguevinePlayer2TeamId = [decoder decodeIntForKey:kPlayer2TeamId];
        self.leaguevinePlayer3TeamId = [decoder decodeIntForKey:kPlayer3TeamId];
        self.iUltimateTimestamp = [decoder decodeDoubleForKey:kTimestamp];
        self.crud = [decoder decodeIntForKey:kCrud];
   }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self.leaguevineGameId forKey:kGameId];
    [encoder encodeInt:self.leaguevineEventType forKey:kEventType];
    [encoder encodeInt:self.leaguevinePlayer1Id forKey:kPlayer1Id];
    [encoder encodeInt:self.leaguevinePlayer2Id forKey:kPlayer2Id];
    [encoder encodeInt:self.leaguevinePlayer3Id forKey:kPlayer3Id];
    [encoder encodeInt:self.leaguevinePlayer1TeamId forKey:kPlayer1TeamId];
    [encoder encodeInt:self.leaguevinePlayer2TeamId forKey:kPlayer2TeamId];
    [encoder encodeInt:self.leaguevinePlayer3TeamId forKey:kPlayer3TeamId];
    [encoder encodeDouble:self.iUltimateTimestamp forKey:kTimestamp];
    [encoder encodeInt:self.crud forKey:kCrud];
}


@end
