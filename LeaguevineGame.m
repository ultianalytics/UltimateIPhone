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
#import "LeaguevineTournament.h"

#define kLeaguevineGameStartTime @"start_time"
#define kLeaguevineGameTeam1Id @"team_1_id"
#define kLeaguevineGameTeam2Id @"team_2_id"
#define kLeaguevineGameTeam1 @"team_1"
#define kLeaguevineGameTeam2 @"team_2"
#define kLeaguevineGameTeamName @"name"
#define kLeaguevineGameTeam1Name @"team1Name"
#define kLeaguevineGameTeam2Name @"team2Name"
#define kLeaguevineGameTournament @"tournament"
#define kLeaguevineGameTimezone @"timezone"
#define kLeaguevineGameTimezoneOffsetMinutes @"timezoneOffset"

@interface LeaguevineGame()

@property (nonatomic, strong) NSDateFormatter* dateFormatterISO8601;

@end

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
        NSDictionary* tournmantDict = [dict objectForJsonProperty:kLeaguevineGameTournament];
        if (tournmantDict) {
            self.tournament = [LeaguevineTournament fromJson:tournmantDict];
        }
        NSString* startTimeAsISO8601String = [dict stringForJsonProperty:kLeaguevineGameStartTime];
        if (startTimeAsISO8601String) {
            self.startTime = [self startTimeFromString:startTimeAsISO8601String];
        }
        self.timezoneOffsetMinutes = [self calcTimezoneOffsetMinutes:startTimeAsISO8601String];
        self.timezone = [dict stringForJsonProperty:kLeaguevineGameTimezone];
        self.team1Id = [dict intForJsonProperty:kLeaguevineGameTeam1Id defaultValue:-1];
        self.team2Id = [dict intForJsonProperty:kLeaguevineGameTeam2Id defaultValue:-1];
        NSDictionary* team1Dict = [dict objectForJsonProperty:kLeaguevineGameTeam1];
        if (team1Dict) {
            self.team1Name = [team1Dict stringForJsonProperty:kLeaguevineGameTeamName];
        }
        NSDictionary* team2Dict = [dict objectForJsonProperty:kLeaguevineGameTeam2];
        if (team2Dict) {
            self.team2Name = [team2Dict stringForJsonProperty:kLeaguevineGameTeamName];
        }

    }
}

-(NSDate*)startTimeFromString: (NSString*) dateAsISO8601String {
    /*
     Leaguevine Doc:
     
     Our API reads ISO 8601 formatted times. This format looks like YYYY-MM-DDTHH:MM:SS-hh:mm where each part is defined as follows:
     
     YYYY-MM-DD - The date, denoted by the year, month, and day. For example, 2012-02-08
     T - The letter 'T' is a separator that is placed between the date and the time. 
     HH:MM:SS - The time using the 24-hour notation including seconds. For example, 14:12:00 represents 2:12pm.
     ±hh:mm - The timezone offset from UTC. This can start with a + or a -. For example, -06:00 represents Central Standard Time
   */
    
    // Add "GMT" before timezone offset to make NSDateFormatter happy
    NSString* withGMTInserted = [NSString stringWithFormat: @"%@GMT%@",
                                 [dateAsISO8601String substringToIndex:19], [dateAsISO8601String substringFromIndex:19]];
    return [self.dateFormatterISO8601 dateFromString:withGMTInserted];
}

-(NSDateFormatter*)dateFormatterISO8601 {
    if (!_dateFormatterISO8601) {
        _dateFormatterISO8601 = [[NSDateFormatter alloc] init];
        [_dateFormatterISO8601 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
    }
    return _dateFormatterISO8601;
}

-(int)calcTimezoneOffsetMinutes: (NSString*) dateAsISO8601String {
    NSString* offsetSign = [dateAsISO8601String substringWithRange: NSMakeRange(19, 1)];
    NSString* offsetHoursString = [dateAsISO8601String substringWithRange: NSMakeRange(20, 2)];
    NSString* offsetMinutesString = [dateAsISO8601String substringWithRange: NSMakeRange(23, 2)];
    int offsetMinutes = ([offsetHoursString intValue] * 60) + [offsetMinutesString intValue];
    return [offsetSign isEqualToString: @"-"] ? offsetMinutes * -1 : offsetMinutes;
}

-(NSTimeZone*)getStartTimezone {
    return [NSTimeZone timeZoneForSecondsFromGMT: self.timezoneOffsetMinutes * 60];
}

-(NSString*)listDescription {
    return [NSString stringWithFormat: @"v. %@", [self opponentDescription]];
}

-(NSString*)opponentDescription {
    return self.team1Id == [Team getCurrentTeam].leaguevineTeam.itemId ? self.team2Name : self.team1Name;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        self.tournament = [decoder decodeObjectForKey:kLeaguevineGameTournament];
        self.startTime = [decoder decodeObjectForKey:kLeaguevineGameStartTime];
        self.timezoneOffsetMinutes = [decoder decodeIntForKey:kLeaguevineGameTimezoneOffsetMinutes];
        self.timezone = [decoder decodeObjectForKey:kLeaguevineGameTimezone];
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
    [encoder encodeInt:self.timezoneOffsetMinutes forKey:kLeaguevineGameTimezoneOffsetMinutes];
    [encoder encodeObject:self.timezone forKey:kLeaguevineGameTimezone];
    [encoder encodeInt:self.team1Id forKey:kLeaguevineGameTeam1Id];
    [encoder encodeInt:self.team2Id forKey:kLeaguevineGameTeam2Id];
    [encoder encodeObject:self.team1Name forKey:kLeaguevineGameTeam1Name];
    [encoder encodeObject:self.team2Name forKey:kLeaguevineGameTeam2Name];
}

-(NSString*)description {
    return [NSString stringWithFormat:@"LeaguevineGame: %d at %@.  %@ vs. %@", self.itemId, self.startTime, self.team1Name, self.team2Name];
}

@end