//
//  GameDescription.h
//  Ultimate
//
//  Created by Jim Geppert on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "Game.h"


@interface GameDescription : NSObject

@property (nonatomic, strong) NSString* gameId;
@property (nonatomic, strong) NSString* formattedStartDate;
@property (nonatomic, strong) NSDate* startDate;
@property (nonatomic, strong) NSString* opponent;
@property (nonatomic) Score score;
@property (nonatomic, strong) NSString* formattedScore;
@property (nonatomic, strong) NSString* tournamentName;

+(GameDescription*) fromDictionary:(NSDictionary*) dict;

@end
