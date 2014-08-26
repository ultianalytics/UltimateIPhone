//
//  BeginEvent.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/25/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "Event.h"

#define kPlayerKey        @"player"

@interface BeginEvent : Event

@property (nonatomic, strong) Player* player;

+(BeginEvent*) eventWithAction: (Action)anAction andPlayer: (Player*)player;

@end
