//
//  StatsEventDetails.h
//  Ultimate
//
//  Created by Jim Geppert on 2/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Game.h"
#import "Event.h"
#import "UPoint.h"
#import "PlayerStat.h"

@interface StatsEventDetails : NSObject

@property (nonatomic, strong) Game* game;
@property (nonatomic, strong) UPoint* point;
@property (nonatomic, strong) Event* event;
@property (nonatomic, strong) NSDictionary* accumulatedStats;

@end
