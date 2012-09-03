//
//  Statistics.h
//  Ultimate
//
//  Created by Jim Geppert on 2/4/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

@class Game;
@class Team;
@class Player;

@interface Statistics : NSObject


+(NSDictionary*)pointsPlayedFactorPerPlayer: (Game*) game team: (Team*) team;
+(NSDictionary*)pointsPerPlayer: (Game*) game includeOffense: (BOOL) includeO includeDefense: (BOOL) includeD;


+(NSArray*)pointsPerPlayer: (Game*) game team: (Team*) team includeOffense: (BOOL) includeO includeDefense: (BOOL) includeD includeTournament: (BOOL) includeTournament;
+(NSArray*)throwsPerPlayer: (Game*) game team: (Team*) team includeTournament: (BOOL) includeTournament;
+(NSArray*)goalsPerPlayer: (Game*) game team: (Team*) team includeTournament: (BOOL) includeTournament; 
+(NSArray*)assistsPerPlayer: (Game*) game team: (Team*) team includeTournament: (BOOL) includeTournament;
+(NSArray*)dropsPerPlayer: (Game*) game team: (Team*) team includeTournament: (BOOL) includeTournament;
+(NSArray*)throwawaysPerPlayer: (Game*) game team: (Team*) team includeTournament: (BOOL) includeTournament;
+(NSArray*)pullsPerPlayer: (Game*) game team: (Team*) team includeTournament: (BOOL) includeTournament;
+(NSArray*)dsPerPlayer: (Game*) game team: (Team*) team includeTournament: (BOOL) includeTournament;
+(NSArray*)plusMinusCountPerPlayer: (Game*) game team: (Team*) team includeTournament: (BOOL) includeTournament;

@end
