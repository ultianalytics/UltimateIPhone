//
//  LeaguevineGame.m
//  UltimateIPhone
//
//  Created by james on 9/26/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeaguevineGame.h"
#import "NSDictionary+JSON.h"
#import "Team.h"
#import "LeaguevineTeam.h"

#define kLeaguevineGameStartTime @"start_date"
#define kLeaguevineGameTeam1Id @"team_1_id"
#define kLeaguevineGameTeam2Id @"team_2_id"
#define kLeaguevineGameTeam1 @"team_1"
#define kLeaguevineGameTeam2 @"team_2"
#define kLeaguevineGameTeamName @"name"
#define kLeaguevineGameTeam1Name @"team1Name"
#define kLeaguevineGameTeam2Name @"team2Name"
#define kLeaguevineGameTournament @"tournament"

@implementation LeaguevineGame

+(LeaguevineGame*)fromJson:(NSDictionary*) dict {
    if (dict) {
        LeaguevineGame* game = [[LeaguevineGame alloc] init];
        [game populateFromJson:dict];
        return game;
    } else {
        return nil;
    }
}

-(void)populateFromJson:(NSDictionary*) dict {
    if (dict) {
        [super populateFromJson:dict];
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-ddEHH:mm:ssZ"];
        self.startTime = [dict dateForJsonProperty:kLeaguevineGameStartTime usingFormatter: dateFormatter defaultDate: nil];
        self.team1Id = [dict intForJsonProperty:kLeaguevineGameTeam1Id defaultValue:-1];
        self.team2Id = [dict intForJsonProperty:kLeaguevineGameTeam2Id defaultValue:-1];
        NSDictionary* team1 = [dict objectForJsonProperty:kLeaguevineGameTeam1];
        if (team1) {
            self.team1Name = [team1 stringForJsonProperty:kLeaguevineGameTeamName];
        }
        NSDictionary* team2 = [dict objectForJsonProperty:kLeaguevineGameTeam2];
        if (team2) {
            self.team2Name = [dict stringForJsonProperty:kLeaguevineGameTeamName];
        }
    }
}

-(NSString*)listDescription {
    NSString* teamName = self.itemId == [Team getCurrentTeam].leaguevineTeam.itemId ? self.team2Name : self.team1Name;
    return [NSString stringWithFormat: @"v. %@", teamName];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        self.tournament = [decoder decodeObjectForKey:kLeaguevineGameTournament];
        self.startTime = [decoder decodeObjectForKey:kLeaguevineGameStartTime];
        self.team1Id = [decoder decodeIntForKey:kLeaguevineGameTeam1Id];
        self.team2Id = [decoder decodeIntForKey:kLeaguevineGameTeam2Id];
        self.team1Name = [decoder decodeObjectForKey:kLeaguevineGameTeam1Name];
        self.team2Name = [decoder decodeObjectForKey:kLeaguevineGameTeam2Name];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:self.tournament forKey:kLeaguevineGameTournament];
        [encoder encodeObject:self.startTime forKey:kLeaguevineGameStartTime];
        [encoder encodeInt:self.team1Id forKey:kLeaguevineGameTeam1Id];
        [encoder encodeInt:self.team2Id forKey:kLeaguevineGameTeam2Id];
        [encoder encodeObject:self.team1Name forKey:kLeaguevineGameTeam1Name];
        [encoder encodeObject:self.team2Name forKey:kLeaguevineGameTeam2Name];
}

-(NSString*)description {
    return [NSString stringWithFormat:@"LeaguevineTeam: %d %@", self.itemId, self.name];
}

@end