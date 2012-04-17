//
//  GameDescription.m
//  Ultimate
//
//  Created by Jim Geppert on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameDescription.h"
#import "Game.h"

#define kGameIdKey              @"gameId"
#define kOpponentNameKey        @"opponentName"
#define kTournamentNameKey      @"tournamentName"
#define kStartDateTimeKey       @"timestamp"
#define kJsonDateFormat         @"yyyy-MM-dd HH:mm"

@implementation GameDescription
@synthesize gameId,formattedStartDate,startDate,opponent,formattedScore, tournamentName, score;

+(GameDescription*) fromDictionary:(NSDictionary*) dict; {
    GameDescription* game = [[GameDescription alloc] init];
    game.gameId = [dict objectForKey:kGameIdKey];
    game.opponent = [dict objectForKey:kOpponentNameKey];
    game.tournamentName = [dict objectForKey:kTournamentNameKey];
    NSString* startDateAsString = [dict objectForKey:kStartDateTimeKey];
    if (startDateAsString) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:kJsonDateFormat];
        game.startDate = [dateFormat dateFromString:startDateAsString];
    }    
    return game;
}

@end
