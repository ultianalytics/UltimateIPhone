//
//  LeagueVinePlayerNameTransformer.h
//  UltimateIPhone
//
//  Created by james on 4/4/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LeagueVinePlayerNameTransformer : NSObject

+(LeagueVinePlayerNameTransformer*) transformer;

-(void)updatePlayers: (NSMutableArray*) oldPlayers playersFromLeaguevine: (NSArray*)leaguevinePlayers;

@end
