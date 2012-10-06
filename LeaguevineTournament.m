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

@interface  LeaguevineTournament()

@property (nonatomic, strong) NSString* startDateString;
@property (nonatomic, strong) NSString* endDateString;

@end

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
        self.startDateString = [dict objectForJsonProperty:kLeaguevineTournamentStartDate];
        self.endDateString = [dict objectForJsonProperty:kLeaguevineTournamentEndDate];
    }
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        self.startDate = [decoder decodeObjectForKey:kLeaguevineTournamentStartDate];
        self.endDate = [decoder decodeObjectForKey:kLeaguevineTournamentEndDate];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:self.startDate forKey:kLeaguevineTournamentStartDate];
    [encoder encodeObject:self.endDate forKey:kLeaguevineTournamentEndDate];
}

-(NSMutableDictionary*)asDictionary {
    NSMutableDictionary* dict = [super asDictionary];
    [dict setValue: self.startDateString forKey:kLeaguevineTournamentStartDate];
    [dict setValue: self.endDateString forKey:kLeaguevineTournamentEndDate];
    return dict;
}

+(LeaguevineTournament*)fromDictionary:(NSDictionary*) dict {
    LeaguevineTournament* tournament = [[LeaguevineTournament alloc] init];
    [tournament populateFromDictionary:dict];
    return tournament;
}

-(void)populateFromDictionary:(NSDictionary*) dict {
    [super populateFromDictionary:dict];
    self.startDateString = [dict objectForKey:kLeaguevineTournamentStartDate];
    self.endDateString = [dict objectForKey:kLeaguevineTournamentEndDate];
}

-(NSDate*)startDate {
    if (!_startDate && [self.startDateString isNotEmpty]) {
        _startDate = [self.dateFormatter dateFromString:self.startDateString];
    }
    return _startDate;
}

-(NSDate*)endDate {
    if (!_endDate && [self.endDateString isNotEmpty]) {
        _endDate= [self.dateFormatter dateFromString:self.endDateString];
    }
    return _endDate;
}

-(NSDateFormatter*)dateFormatter {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return dateFormatter;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"LeaguevineTournament: %d %@", self.itemId, self.name];
}

@end
