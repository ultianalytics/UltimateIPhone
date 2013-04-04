//
//  LeagueVinePlayerNameTransformer.m
//  UltimateIPhone
//
//  Created by james on 4/4/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "LeagueVinePlayerNameTransformer.h"
#import "Player.h"
#import "LeaguevinePlayer.h"
#import "NSString+manipulations.h"

@interface LeagueVinePlayerNameTransformer()

@property (nonatomic, strong) NSMutableArray* players;
@property (nonatomic, strong) NSMutableDictionary* previousPlayersByLeaguevineId;
@property (nonatomic, strong) NSMutableDictionary* allLeaguevinePlayersByLeaguevineId;
@property (nonatomic, strong) NSMutableDictionary* usedNames;

@end

@implementation LeagueVinePlayerNameTransformer

+(LeagueVinePlayerNameTransformer*) transformer {
    LeagueVinePlayerNameTransformer* transformer = [[LeagueVinePlayerNameTransformer alloc] init];
    return transformer;
}

-(void)updatePlayers: (NSMutableArray*) currentPlayers playersFromLeaguevine: (NSArray*)leaguevinePlayers {
    [self initializeForUpdateUsingPlayerNames:currentPlayers playersFromLeaguevine:leaguevinePlayers];
    
    // remove deleted players
    [self removeOldPlayersNotIn: leaguevinePlayers];
    
    // change existing names if necessary
    for (Player* player in self.players) {
        LeaguevinePlayer* oldLvPlayer = player.leaguevinePlayer;
        LeaguevinePlayer* newLvPlayer = [self.allLeaguevinePlayersByLeaguevineId objectForKey: [NSNumber numberWithInt:player.leaguevinePlayer.playerId]];
        if (![[self nicknameFromFirstAndLast:newLvPlayer] isEqualToString:[self nicknameFromFirstAndLast:oldLvPlayer]]) {
            [self renamePlayer:player from:player.name to:[self preferredUniqueName:newLvPlayer]];
        }
    }
    
    // add new players with unique preferred names
    for (LeaguevinePlayer* lvPlayer in [self sortedLeaguevinePlayers:leaguevinePlayers]) {
        if (![self.previousPlayersByLeaguevineId objectForKey:[NSNumber numberWithInt:lvPlayer.playerId]]) {
            Player* newPlayer = [lvPlayer asPlayer];
            [self renamePlayer:newPlayer from:nil to:[self preferredUniqueName:lvPlayer]];
            [currentPlayers addObject:newPlayer];
        }
    }
}

-(void)renamePlayer: (Player*) player from: (NSString*)oldName to: (NSString*)newName {
    if (oldName) {
        [self.usedNames removeObjectForKey:player.name];
        player.name = @"";
    }
    if (newName) {
        player.name = newName;
        [self.usedNames setValue:player forKey:newName];
    }
}

-(void)initializeForUpdateUsingPlayerNames: (NSMutableArray*) players playersFromLeaguevine: (NSArray*)leaguevinePlayers {
    self.players = players;
    [self initializePreviousPlayersByLeaguevineId:players];
    [self initializeNewLeaguevinePlayersByLeaguevineId:leaguevinePlayers];
    [self initializeUsedNames:players];
    [self removeOldPlayersNotIn: leaguevinePlayers];
}

-(void)initializePreviousPlayersByLeaguevineId: (NSArray*) players {
    self.previousPlayersByLeaguevineId = [NSMutableDictionary dictionary];
    for (Player* player in players) {
        [self.previousPlayersByLeaguevineId setObject:player forKey:[NSNumber numberWithInt:player.leaguevinePlayer.playerId]];
    }
}

-(void)initializeNewLeaguevinePlayersByLeaguevineId: (NSArray*) leaguevinePlayers {
    self.allLeaguevinePlayersByLeaguevineId = [NSMutableDictionary dictionary];
    for (LeaguevinePlayer* lvPlayer in leaguevinePlayers) {
        [self.allLeaguevinePlayersByLeaguevineId setObject:lvPlayer forKey:[NSNumber numberWithInt:lvPlayer.playerId]];
    }
}

-(void)initializeUsedNames: (NSMutableArray*) players {
    self.usedNames = [NSMutableDictionary dictionary];
    for (Player* player in players) {
        [self.usedNames setObject:player forKey:player.name];
    }
}

// return sorted in leaguevine ID order
-(NSArray*)sortedLeaguevinePlayers: (NSArray*)leaguevinePlayers {
    return [leaguevinePlayers sortedArrayUsingComparator:^NSComparisonResult(id player1, id player2) {
        if ([player1 playerId] > [player2 playerId]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([player1 playerId] < [player2 playerId]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
}

-(NSString*)nicknameFromFirstAndLast: (LeaguevinePlayer*) leaguevinePlayer {
    return [self nicknameFromFirstAndLast:leaguevinePlayer numberOfLastNameChars:1];
}

-(NSString*)nicknameFromFirstAndLast: (LeaguevinePlayer*) leaguevinePlayer numberOfLastNameChars: (int) lastNameChars {
    if (![leaguevinePlayer.firstName isNotEmpty]) {
        return [leaguevinePlayer.lastName trim];
    }
    if (![leaguevinePlayer.lastName isNotEmpty]) {
        return [leaguevinePlayer.firstName trim];
    }
    NSString* lastInitial = [[leaguevinePlayer.lastName capitalizedString] substringToIndex:MIN(lastNameChars, [leaguevinePlayer.lastName length])];  
    return [NSString stringWithFormat:@"%@ %@", [[leaguevinePlayer.firstName trim] capitalizedString], lastInitial];
}

-(NSString*)preferredName: (LeaguevinePlayer*) leaguevinePlayer {
    if ([leaguevinePlayer.nickname isNotEmpty]) {
        return [[leaguevinePlayer.nickname trim] capitalizedString];
    } else {
        return [self nicknameFromFirstAndLast:leaguevinePlayer];
    }
}

-(NSString*)preferredUniqueName: (LeaguevinePlayer*) leaguevinePlayer {
    // start with the preferred name
    NSString* name = [self preferredName:leaguevinePlayer];
    if (![self isUsedName: name]) {
        return name;
    }
    
    // try a few more chars in last name
    for (int i = 1; i < 3; i++) {
        name = [self nicknameFromFirstAndLast:leaguevinePlayer numberOfLastNameChars:i];
        if (![self isUsedName: name]) {
            return name;
        }
    }
    
    // try appending player's number
    if (leaguevinePlayer.number) {
        name = [NSString stringWithFormat:@"%@-%d", name, leaguevinePlayer.number];
        if (![self isUsedName: name]) {
            return name;
        }
    }
    
    // brute force...just add a number until unique
    int suffix = 2;
    while ([self isUsedName: name]) {
        name = [NSString stringWithFormat:@"%@%d", name, suffix];
    }
    return name;
}

-(void)removeOldPlayersNotIn: (NSArray*)leaguevinePlayers {
    NSMutableSet* leaguevineIds = [NSMutableSet set];
    for (LeaguevinePlayer* lvPlayer in leaguevinePlayers) {
        [leaguevineIds addObject:[NSNumber numberWithInt:lvPlayer.playerId]];
    }
    for (Player* player in [self.players copy]) {
        if (![leaguevineIds containsObject:[NSNumber numberWithInt:player.leaguevinePlayer.playerId]]) {
            [self.players removeObject:player];
        }
    }
}
    
-(BOOL)isUsedName: (NSString*) name {
    return [[self usedNames] objectForKey:name] != nil;
}

@end
