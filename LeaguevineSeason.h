//
//  LeaguevineSeason.h
//  UltimateIPhone
//
//  Created by james on 9/21/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeaguevineItem.h"
@class LeaguevineLeague;

@interface LeaguevineSeason : LeaguevineItem

@property (nonatomic, strong) LeaguevineLeague* league;

+(LeaguevineSeason*)fromJson:(NSDictionary*) dict;

@end
