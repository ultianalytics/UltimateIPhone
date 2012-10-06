//
//  LeaguevineTeam.m
//  UltimateIPhone
//
//  Created by james on 9/21/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeaguevineTeam.h"
#import "LeaguevineSeason.h"

#define kLeaguevineTeamSeason @"season"

@implementation LeaguevineTeam

+(LeaguevineTeam*)fromJson:(NSDictionary*) dict {
    if (dict) {
        LeaguevineTeam* team = [[LeaguevineTeam alloc] init];
        [team populateFromJson:dict];
        return team;
    } else {
        return nil;
    }
}


-(LeaguevineLeague*)league {
    return self.season ?  self.season.league : nil;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        self.season = [decoder decodeObjectForKey:kLeaguevineTeamSeason];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:self.season forKey:kLeaguevineTeamSeason];
}

-(NSMutableDictionary*)asDictionary {
    NSMutableDictionary* dict = [super asDictionary];
    [dict setValue: self.season forKey:kLeaguevineTeamSeason];
    return dict;
}

+(LeaguevineTeam*)fromDictionary:(NSDictionary*) dict {
    LeaguevineTeam* team = [[LeaguevineTeam alloc] init];
    [team populateFromDictionary:dict];
    return team;
}

-(void)populateFromDictionary:(NSDictionary*) dict {
    [super populateFromDictionary:dict];
    self.season = [LeaguevineSeason fromDictionary:[dict objectForKey:kLeaguevineTeamSeason]];
}

-(NSString*)description {
    return [NSString stringWithFormat:@"LeaguevineTeam: %d %@", self.itemId, self.name];
}




@end
