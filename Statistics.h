//
//  Statistics.h
//  Ultimate
//
//  Created by Jim Geppert on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@class Game;
@class Team;
@class Player;

@interface Statistics : NSObject


+(NSDictionary*)pointsPlayedFactorPerPlayer: (Game*) game team: (Team*) team;
+(NSArray*)pointsPerPlayer: (Game*) game team: (Team*) team includeOffense: (BOOL) includeO includeDefense: (BOOL) includeD;
+(NSArray*)throwsPerPlayer: (Game*) game team: (Team*) team;
+(NSArray*)goalsPerPlayer: (Game*) game team: (Team*) team; 
+(NSArray*)assistsPerPlayer: (Game*) game team: (Team*) team;
+(NSArray*)dropsPerPlayer: (Game*) game team: (Team*) team;
+(NSArray*)throwawaysPerPlayer: (Game*) game team: (Team*) team;
+(NSArray*)pullsPerPlayer: (Game*) game team: (Team*) team;
+(NSArray*)dsPerPlayer: (Game*) game team: (Team*) team;
+(NSDictionary*)pointsPerPlayer: (Game*) game includeOffense: (BOOL) includeO includeDefense: (BOOL) includeD;

@end
