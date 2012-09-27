//
//  LeaguevineTournament.m
//  UltimateIPhone
//
//  Created by james on 9/25/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeaguevineTournament.h"
#import "NSDictionary+JSON.h"

#define kLeaguevineTournamentStartDate @"start_date"
#define kLeaguevineTournamentEndDate @"end_date"

@implementation LeaguevineTournament

+(LeaguevineTournament*)fromJson:(NSDictionary*) dict {
    if (dict) {
        LeaguevineTournament* tournament = [[LeaguevineTournament alloc] init];
        [tournament populateFromJson:dict];
        return tournament;
    } else {
        return nil;
    }
}

-(void)populateFromJson:(NSDictionary*) dict {
    if (dict) {
        [super populateFromJson:dict];
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        self.startDate = [dict dateForJsonProperty:kLeaguevineTournamentStartDate usingFormatter: dateFormatter defaultDate: nil];
        self.endDate = [dict dateForJsonProperty:kLeaguevineTournamentEndDate usingFormatter: dateFormatter defaultDate: nil];
    }
}

@end
