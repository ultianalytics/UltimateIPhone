//
//  LeaguevineLeague.m
//  UltimateIPhone
//
//  Created by james on 9/21/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeaguevineLeague.h"
#import "NSDictionary+JSON.h"

#define kLeaguevineResponseLeagueGender @"gender"

@implementation LeaguevineLeague

+(LeaguevineLeague*)fromJson:(NSDictionary*) dict {
    if (dict) {
        LeaguevineLeague* league = [[LeaguevineLeague alloc] init];
        [league populateFromJson:dict];
        league.gender = [dict stringForJsonProperty:kLeaguevineResponseLeagueGender];
        return league;
    } else {
        return nil;
    }
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        self.gender = [decoder decodeObjectForKey:kLeaguevineResponseLeagueGender];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:self.gender forKey:kLeaguevineResponseLeagueGender];
}

-(NSString*)description {
    return [NSString stringWithFormat:@"LeaguevineLeague: %d %@", self.itemId, self.name];
}

@end
