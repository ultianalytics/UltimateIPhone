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

-(NSString*)description {
    return [NSString stringWithFormat:@"LeaguevineTeam: %d %@", self.itemId, self.name];
}




@end
