//
//  Statistics.h
//  Ultimate
//
//  Created by Jim Geppert on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Game.h"
#import "Team.h"
#import "PlayerStat.h"
#import "StatsEventDetails.h"

@interface Statistics : NSObject

// public
+(NSDictionary*)pointsPlayedFactorPerPlayer: (Game*) game team: (Team*) team;
+(NSArray*)pointsPerPlayer: (Game*) game team: (Team*) team includeOffense: (BOOL) includeO includeDefense: (BOOL) includeD;
+(NSArray*)throwsPerPlayer: (Game*) game team: (Team*) team;
+(NSArray*)goalsPerPlayer: (Game*) game team: (Team*) team; 
+(NSArray*)assistsPerPlayer: (Game*) game team: (Team*) team;
+(NSArray*)dropsPerPlayer: (Game*) game team: (Team*) team;
+(NSArray*)throwawaysPerPlayer: (Game*) game team: (Team*) team;
+(NSArray*)pullsPerPlayer: (Game*) game team: (Team*) team;
+(NSArray*)dsPerPlayer: (Game*) game team: (Team*) team;

// private
+(NSArray*)sortedPlayerStats: (NSDictionary*) statPerPlayer game: (Game*) game team: (Team*) team statType: (StatNumericType) type;
+(NSArray*)descendingSortedStats:(NSArray*) unsortedStatsArray;;
+(PlayerStat*)getStatForPlayer: (Player*) player fromStats: (NSDictionary*) statPerPlayer statType:(StatNumericType) type;
+(NSDictionary*)pointsPerPlayer: (Game*) game includeOffense: (BOOL) includeO includeDefense: (BOOL) includeD;
+(NSDictionary*)accumulateStatsPerPlayer: (Game*) game accumulator: (void (^)(StatsEventDetails* statsEventDetails))accumulatorBlock;

@end
