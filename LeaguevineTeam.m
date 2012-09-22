//
//  LeaguevineTeam.m
//  UltimateIPhone
//
//  Created by james on 9/21/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeaguevineTeam.h"
#import "NSDictionary+JSON.h"

#define kLeaguevineResponseTeamId @"id"
#define kLeaguevineResponseTeamName @"name"

@implementation LeaguevineTeam

+(LeaguevineTeam*)fromJson:(NSDictionary*) dict {
    if (dict) {
        LeaguevineTeam* team = [[LeaguevineTeam alloc] init];
        team.teamId = [dict intForJsonProperty:kLeaguevineResponseTeamId defaultValue:0];
        team.name = [dict stringForJsonProperty:kLeaguevineResponseTeamName];
        return team;
    } else {
        return nil;
    }
}

@end
