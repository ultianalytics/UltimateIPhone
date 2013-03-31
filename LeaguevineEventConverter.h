//
//  LeaguevineEventConverter.h
//  UltimateIPhone
//
//  Created by james on 3/31/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Event, LeaguevineEvent, Game;

@interface LeaguevineEventConverter : NSObject

-(BOOL)populateLeaguevineEvent: (LeaguevineEvent*) leaguevineEvent withEvent: (Event*)event fromGame: (Game*)game;

@end
