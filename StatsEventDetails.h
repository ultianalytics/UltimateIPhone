//
//  StatsEventDetails.h
//  Ultimate
//
//  Created by Jim Geppert on 2/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Game;
@class Event;
@class UPoint;
@class PlayerStat;

@interface StatsEventDetails : NSObject

@property (nonatomic, strong) Game* game;
@property (nonatomic, strong) UPoint* point;
@property (nonatomic, strong) Event* event;
@property (nonatomic) BOOL isFirstEventOfPoint;
@property (nonatomic) BOOL isOlinePoint;
@property (nonatomic, strong) NSDictionary* accumulatedStats;
@property (nonatomic, strong) NSArray* line;

@end
