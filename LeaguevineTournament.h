//
//  LeaguevineTournament.h
//  UltimateIPhone
//
//  Created by james on 9/25/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeaguevineItem.h"

@interface LeaguevineTournament : LeaguevineItem

@property (nonatomic, strong) NSDate* startDate;
@property (nonatomic, strong) NSDate* endDate;

+(LeaguevineTournament*)fromJson:(NSDictionary*) dict;

@end
