//
//  LeaguevinePlayer.m
//  UltimateIPhone
//
//  Created by james on 3/26/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "LeaguevinePlayer.h"
#import "NSDictionary+JSON.h"
#import "Player.h"

#define kLeaguevineJsonNumber      @"number"
#define kLeaguevineJsonPlayer      @"player"
#define kLeaguevineJsonPlayerId      @"id"
#define kLeaguevineJsonFirstName      @"first_name"
#define kLeaguevineJsonLastName      @"last_name"
#define kLeaguevineJsonNickname      @"nickname"

@implementation LeaguevinePlayer


+(LeaguevinePlayer*)fromJson:(NSDictionary*) dict {
    if (dict) {
        LeaguevinePlayer* player = [[LeaguevinePlayer alloc] init];
        [player populateFromDictionary:dict];
        return player;
    } else {
        return nil;
    }
}

-(NSMutableDictionary*)asDictionary {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue: [NSNumber numberWithInt: self.number] forKey:kLeaguevineJsonNumber];
    NSMutableDictionary* playerDetailsDict = [NSMutableDictionary dictionary];
    [dict setValue: playerDetailsDict forKey:kLeaguevineJsonPlayer];
    [playerDetailsDict setValue: [NSNumber numberWithInt:self.playerId] forKey:kLeaguevineJsonPlayerId];
    [playerDetailsDict setValue: self.firstName forKey:kLeaguevineJsonFirstName];
    [playerDetailsDict setValue: self.lastName forKey:kLeaguevineJsonLastName];
    [playerDetailsDict setValue: self.nickname forKey:kLeaguevineJsonNickname];
    return dict;
}

+(LeaguevinePlayer*)fromDictionary:(NSDictionary*) dict {
    LeaguevinePlayer* team = [[LeaguevinePlayer alloc] init];
    [team populateFromDictionary:dict];
    return team;
}


-(void)populateFromDictionary:(NSDictionary*) dict {
    self.number = [dict intForJsonProperty:kLeaguevineJsonNumber defaultValue:0];
    NSDictionary* playerDetails = [dict objectForJsonProperty:kLeaguevineJsonPlayer defaultValue:[NSDictionary dictionary]];
    self.playerId = [playerDetails intForJsonProperty:kLeaguevineJsonPlayerId defaultValue:0];
    self.firstName = [playerDetails stringForJsonProperty:kLeaguevineJsonFirstName];
    self.lastName = [playerDetails stringForJsonProperty:kLeaguevineJsonLastName];
    self.nickname = [playerDetails stringForJsonProperty:kLeaguevineJsonNickname];
}


- (id)initWithCoder:(NSCoder *)decoder {
    self.playerId = [decoder decodeIntForKey:kLeaguevineJsonPlayerId];
    self.number = [decoder decodeIntForKey:kLeaguevineJsonNumber];
    self.firstName = [decoder decodeObjectForKey: kLeaguevineJsonFirstName];
    self.lastName = [decoder decodeObjectForKey: kLeaguevineJsonLastName];
    self.nickname = [decoder decodeObjectForKey: kLeaguevineJsonNickname];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt: self.playerId forKey:kLeaguevineJsonPlayerId];
    [encoder encodeInt: self.number forKey:kLeaguevineJsonNumber];
    [encoder encodeObject:self.firstName forKey:kLeaguevineJsonFirstName];
    [encoder encodeObject:self.lastName forKey:kLeaguevineJsonLastName];
    [encoder encodeObject:self.nickname forKey:kLeaguevineJsonNickname];
}

-(NSString*)description {
    return [NSString stringWithFormat:@"LeaguevinePlayer: %d %@ %@ nickname=%@", self.playerId, self.firstName, self.lastName, self.nickname];
}

-(Player*)asPlayer {
    Player* player = [[Player alloc] init];
    player.name = [NSString stringWithFormat: @"%@ %@", self.firstName, self.lastName];
    if (self.number) {
        player.number = [NSString stringWithFormat: @"%d", self.number];
    }
    player.position = Any;
    player.isMale = YES;
    
    player.leaguevinePlayer = self;
    
    return player;
}

+(NSArray*)playersFromLeaguevinePlayers: (NSArray*)leaguevinePlayers {
    NSMutableArray* players = [NSMutableArray array];
    for (LeaguevinePlayer* leaguevinePlayer in leaguevinePlayers) {
        Player* player = [leaguevinePlayer asPlayer];
        [players addObject:player];
    }
    return players;
}

@end

