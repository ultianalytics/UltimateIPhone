//
//  LeaguevineSeason.h
//  UltimateIPhone
//
//  Created by james on 9/21/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LeaguevineSeason : NSObject

@property (nonatomic) int seasonId;
@property (nonatomic, strong) NSString* name;

+(LeaguevineSeason*)fromJson:(NSDictionary*) dict;

@end
