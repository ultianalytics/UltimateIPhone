//
//  LeaguevineTeam.h
//  UltimateIPhone
//
//  Created by james on 9/21/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeaguevineItem.h"
@class LeaguevineSeason;
@class LeaguevineLeague;

@interface LeaguevineTeam : LeaguevineItem

@property (nonatomic, strong) LeaguevineSeason* season;

+(LeaguevineTeam*)fromJson:(NSDictionary*) dict;
-(LeaguevineLeague*)league;

@end
