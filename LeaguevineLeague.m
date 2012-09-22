//
//  LeaguevineLeague.m
//  UltimateIPhone
//
//  Created by james on 9/21/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeaguevineLeague.h"
#import "NSDictionary+JSON.h"

#define kLeaguevineResponseLeagueId @"id"
#define kLeaguevineResponseLeagueName @"name"
#define kLeaguevineResponseLeagueGender @"gender"

@implementation LeaguevineLeague

+(LeaguevineLeague*)fromJson:(NSDictionary*) dict {
    if (dict) {
        LeaguevineLeague* league = [[LeaguevineLeague alloc] init];
        league.leagueId = [dict intForJsonProperty:kLeaguevineResponseLeagueId defaultValue:0];
        league.name = [dict stringForJsonProperty:kLeaguevineResponseLeagueName];
        league.gender = [dict stringForJsonProperty:kLeaguevineResponseLeagueGender];
        return league;
    } else {
        return nil;
    }
}

@end
