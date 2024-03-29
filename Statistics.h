//
//  Statistics.h
//  Ultimate
//
//  Created by Jim Geppert on 2/4/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

@class Game;
@class Player;

@interface Statistics : NSObject


+(NSDictionary*)pointsPlayedFactorPerPlayer: (Game*) game;
+(NSDictionary*)pointsPerPlayer: (Game*) game includeOffense: (BOOL) includeO includeDefense: (BOOL) includeD;

+(NSArray*)pointsPerPlayer: (Game*) game includeOffense: (BOOL) includeO includeDefense: (BOOL) includeD includeTournament: (BOOL) includeTournament;
+(NSArray*)throwsPerPlayer: (Game*) game includeTournament: (BOOL) includeTournament;
+(NSArray*)goalsPerPlayer: (Game*) game includeTournament: (BOOL) includeTournament; 
+(NSArray*)assistsPerPlayer: (Game*) game includeTournament: (BOOL) includeTournament;
+(NSArray*)dropsPerPlayer: (Game*) game includeTournament: (BOOL) includeTournament;
+(NSArray*)throwawaysPerPlayer: (Game*) game includeTournament: (BOOL) includeTournament;
+(NSArray*)stallsPerPlayer: (Game*) game includeTournament: (BOOL) includeTournament;
+(NSArray*)miscPenaltiesPerPlayer: (Game*) game includeTournament: (BOOL) includeTournament;
+(NSArray*)pullsPerPlayer: (Game*) game includeTournament: (BOOL) includeTournament;
+(NSArray*)pullsObPerPlayer: (Game*) game includeTournament: (BOOL) includeTournament;
+(NSArray*)dsPerPlayer: (Game*) game includeTournament: (BOOL) includeTournament;
+(NSArray*)plusMinusCountPerPlayer: (Game*) game includeTournament: (BOOL) includeTournament;
+(NSArray*)callahansPerPlayer: (Game*) game includeTournament: (BOOL) includeTournament;
+(NSArray*)callahanedPerPlayer: (Game*) game includeTournament: (BOOL) includeTournament;

@end
