//
//  LeaguevineConfiguration.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 3/6/16.
//  Copyright © 2016 Summit Hill Software. All rights reserved.
//

#import "LeaguevineConfiguration.h"
#import "Team.h"
#import "TeamDescription.h"

@implementation LeaguevineConfiguration

#define kLeaguevineSettingName @"leaguevine_preference"

+(void)configureSettings {
    BOOL hasLeaguevineTeams = NO;
    if (![self leaguevineEnabled]) {
        for (TeamDescription* teamDescription in Team.retrieveTeamDescriptions) {
            Team* team = [Team readTeam:teamDescription.teamId];
            if (team.isLeaguevineTeam) {
                hasLeaguevineTeams = YES;
                break;
            }
        }
        [[NSUserDefaults standardUserDefaults] setBool: hasLeaguevineTeams forKey:kLeaguevineSettingName];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+(BOOL)leaguevineEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kLeaguevineSettingName];
}

@end
