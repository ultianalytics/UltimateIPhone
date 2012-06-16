//
//  LeaguevineGame.h
//  UltimateIPhone
//
//  Created by james on 9/26/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeaguevineItem.h"
@class LeaguevineTournament;

@interface LeaguevineGame : LeaguevineItem

@property (nonatomic, strong) NSDate* startTime;  // GMT
@property (nonatomic) int timezoneOffsetMinutes;    // local timezone offset for game
@property (nonatomic, strong) NSString* timezone;  // for display (e.g., US/Central)...not reliable enough for use as offset?
@property (nonatomic) int team1Id;
@property (nonatomic) int team2Id;
@property (nonatomic, strong) NSString* team1Name;
@property (nonatomic, strong) NSString* team2Name;
@property (nonatomic, strong) LeaguevineTournament* tournament;

+(LeaguevineGame*)fromJson:(NSDictionary*) dict;
-(NSString*)opponentDescription;
-(NSTimeZone*)getStartTimezone;

@end
