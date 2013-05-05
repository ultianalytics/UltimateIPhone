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
#define kEventId @"leaguevine_id"
#define kEventType @"type"
#define kTimestamp @"time"
#define kLeaguevineTimestamp @"leaguevineTimne"
#define kGameId @"game_id"
#define kPlayer1Id @"player_1_id"
#define kPlayer2Id @"player_2_id"
#define kPlayer3Id @"player_3_id"
#define kPlayer1TeamId @"player_1_team_id"
#define kPlayer2TeamId @"player_2_team_id"
#define kPlayer3TeamId @"player_3_team_id"
#define kLineChange @"line_change"
#define kDescription @"description"


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
    
    NSError* error;
    [data writeToFile:filePath options:NSDataWritingAtomic error:&error];
    if(error != nil) {
        NSLog(@"Failed trying to save leaguevine event: %@", error);
    }
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.leaguevineGameId = [decoder decodeIntForKey:kGameId];
        self.leaguevineEventId = [decoder decodeIntForKey:kEventId];
        self.leaguevineEventType = [decoder decodeIntForKey:kEventType];
        self.leaguevinePlayer1Id = [decoder decodeIntForKey:kPlayer1Id];
        self.leaguevinePlayer2Id = [decoder decodeIntForKey:kPlayer2Id];
        self.leaguevinePlayer3Id = [decoder decodeIntForKey:kPlayer3Id];
        self.leaguevinePlayer1TeamId = [decoder decodeIntForKey:kPlayer1TeamId];
        self.leaguevinePlayer2TeamId = [decoder decodeIntForKey:kPlayer2TeamId];
        self.leaguevinePlayer3TeamId = [decoder decodeIntForKey:kPlayer3TeamId];
        self.iUltimateTimestamp = [decoder decodeDoubleForKey:kTimestamp];
        self.leaguevineTimestamp = [decoder decodeDoubleForKey:kLeaguevineTimestamp];
        self.eventDescription = [decoder decodeObjectForKey:kDescription];
        self.latestLine = [decoder decodeObjectForKey:kLineChange];
        self.crud = [decoder decodeIntForKey:kCrud];
   }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self.leaguevineGameId forKey:kGameId];
    [encoder encodeInt:self.leaguevineEventId forKey:kEventId];
    [encoder encodeInt:self.leaguevineEventType forKey:kEventType];
    [encoder encodeInt:self.leaguevinePlayer1Id forKey:kPlayer1Id];
    [encoder encodeInt:self.leaguevinePlayer2Id forKey:kPlayer2Id];
    [encoder encodeInt:self.leaguevinePlayer3Id forKey:kPlayer3Id];
    [encoder encodeInt:self.leaguevinePlayer1TeamId forKey:kPlayer1TeamId];
    [encoder encodeInt:self.leaguevinePlayer2TeamId forKey:kPlayer2TeamId];
    [encoder encodeInt:self.leaguevinePlayer3TeamId forKey:kPlayer3TeamId];
    [encoder encodeObject:self.latestLine forKey:kLineChange];
    [encoder encodeDouble:self.iUltimateTimestamp forKey:kTimestamp];
    [encoder encodeDouble:self.leaguevineTimestamp forKey:kLeaguevineTimestamp];    
    [encoder encodeObject:self.eventDescription forKey:kDescription];
    [encoder encodeInt:self.crud forKey:kCrud];
}

-(NSString*)description {
    return [NSString stringWithFormat: @"LeaguevineEvent \"%@\" type=%d iUltimateTimestamp=%f, leaguevineEventId=%d, leaguevineGameId=%d, leaguevinePlayer1Id=%d, leaguevinePlayer2Id=%d, leaguevinePlayer3Id=%d, leaguevinePlayer1TeamId=%d, leaguevinePlayer2TeamId=%d, leaguevinePlayer3TeamId=%d, latestLine=%@", self.eventDescription, self.leaguevineEventType, self.iUltimateTimestamp, self.leaguevineEventId, self.leaguevineGameId, self.leaguevinePlayer1Id, self.leaguevinePlayer2Id, self.leaguevinePlayer3Id, self.leaguevinePlayer1TeamId, self.leaguevinePlayer2TeamId, self.leaguevinePlayer3TeamId, self.latestLine];
}

-(BOOL)isAdd {
    return self.crud == CRUDAdd;
}

-(BOOL)isUpdate {
    return self.crud == CRUDUpdate;
}

-(BOOL)isDelete {
    return self.crud == CRUDDelete;
}

-(NSString*)crudDescription {
    switch (self.crud) {
        case CRUDAdd:
            return @"Add";
        case CRUDUpdate:
            return @"Update";
        case CRUDDelete:
            return @"Delete";
        default:
            return @"";
    }
}

-(BOOL)isUpdateOrDelete {
    return self.crud == CRUDDelete || self.crud == CRUDUpdate;
}

-(BOOL)isLineChange {
    return self.leaguevineEventType == kLineChangeEventType;
}

-(BOOL)isPeriodEnd {
    return self.leaguevineEventType >= 94 && self.leaguevineEventType <= 98;
}

-(NSTimeInterval)leaguevineTimestamp {
    if (_leaguevineTimestamp) {
        return _leaguevineTimestamp;
    }
    return self.iUltimateTimestamp;
}

@end
