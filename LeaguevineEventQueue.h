//
//  LeaguevineEventQueue.h
//  UltimateIPhone
//
//  Created by james on 3/29/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Event, Game;

@interface LeaguevineEventQueue : NSObject

+ (LeaguevineEventQueue*)sharedQueue;

-(void)submitNewEvent: (Event*)event forGame: (Game*)game;
-(void)submitChangedEvent: (Event*)event forGame: (Game*)game;
-(void)submitDeletedEvent: (Event*)event forGame: (Game*)game;
-(void)triggerImmediateSubmit;

-(void)triggerDelayedSubmit;
-(NSArray*)filesInQueueFolder;
-(void)removeEvent: (NSString*)filePath;

@end
