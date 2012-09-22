//
//  LeaguevineSeason.m
//  UltimateIPhone
//
//  Created by james on 9/21/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeaguevineSeason.h"
#import "NSDictionary+JSON.h"

#define kLeaguevineResponseSeasonId @"id"
#define kLeaguevineResponseSeasonName @"name"

@implementation LeaguevineSeason

+(LeaguevineSeason*)fromJson:(NSDictionary*) dict {
    if (dict) {
        LeaguevineSeason* season = [[LeaguevineSeason alloc] init];
        season.seasonId = [dict intForJsonProperty:kLeaguevineResponseSeasonId defaultValue:0];
        season.name = [dict stringForJsonProperty:kLeaguevineResponseSeasonName];
        return season;
    } else {
        return nil;
    }
}

-(NSString*)description {
    return [NSString stringWithFormat:@"LeaguevineSeason: %d %@", self.seasonId, self.name];
}

@end
