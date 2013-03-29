//
//  LeaguevineEventQueue.m
//  UltimateIPhone
//
//  Created by james on 3/29/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "LeaguevineEventQueue.h"

@implementation LeaguevineEventQueue

+ (LeaguevineEventQueue*)sharedQueue {
    
    static LeaguevineEventQueue *sharedLeaguevineEventQueue;
    
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^ {
        sharedLeaguevineEventQueue = [[self alloc] init];
    });
    return sharedLeaguevineEventQueue;
}

-(void)submitNewEvent: (Event*)event forGame: (Game*)game {
    
}

-(void)submitChangedEvent: (Event*)event forGame: (Game*)game {
    
}

-(void)submitDeletedEvent: (Event*)event forGame: (Game*)game {
    
}

@end
