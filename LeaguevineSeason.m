//
//  LeaguevineSeason.m
//  UltimateIPhone
//
//  Created by james on 9/21/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeaguevineSeason.h"
#import "LeaguevineLeague.h"

#define kLeaguevineSeasonLeague @"league"

@implementation LeaguevineSeason

+(LeaguevineSeason*)fromJson:(NSDictionary*) dict {
    if (dict) {
        LeaguevineSeason* season = [[LeaguevineSeason alloc] init];
        [season populateFromJson:dict];
        return season;
    } else {
        return nil;
    }
}

-(NSString*)description {
    return [NSString stringWithFormat:@"LeaguevineSeason: %d %@", self.itemId, self.name];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        self.league = [decoder decodeObjectForKey:kLeaguevineSeasonLeague];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:self.league forKey:kLeaguevineSeasonLeague];
}

-(NSMutableDictionary*)asDictionary {
    NSMutableDictionary* dict = [super asDictionary];
    [dict setValue: self.league forKey:kLeaguevineSeasonLeague];
    return dict;
}

+(LeaguevineSeason*)fromDictionary:(NSDictionary*) dict {
    LeaguevineSeason* season = [[LeaguevineSeason alloc] init];
    [season populateFromDictionary:dict];
    return season;
}

-(void)populateFromDictionary:(NSDictionary*) dict {
    [super populateFromDictionary:dict];
    self.league = [LeaguevineLeague fromDictionary:[dict objectForKey:kLeaguevineSeasonLeague]];
}

@end
