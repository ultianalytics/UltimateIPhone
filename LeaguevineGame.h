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

@property (nonatomic, strong) NSDate* startTime;  // GMT...transient
@property (nonatomic) int timezoneOffsetMinutes;    // local timezone offset for game...persistent
@property (nonatomic, strong) NSString* timezone;  // for display (e.g., US/Central)...not reliable enough for use as offset?  ...persistent
@property (nonatomic) int team1Id;  // persistent
@property (nonatomic) int team2Id;  // persistent
@property (nonatomic, strong) NSString* team1Name; // persistent
@property (nonatomic, strong) NSString* team2Name; // persistent
@property (nonatomic, strong) LeaguevineTournament* tournament;  // persistent

+(LeaguevineGame*)fromJson:(NSDictionary*) dict;
+(LeaguevineGame*)fromDictionary:(NSDictionary*) dict;
-(NSString*)opponentDescription;
-(NSString*)shortDescription;
-(NSTimeZone*)getStartTimezone;

@end

