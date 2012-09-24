//
//  LeaguevineSeason.m
//  UltimateIPhone
//
//  Created by james on 9/21/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeaguevineSeason.h"

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

@end
