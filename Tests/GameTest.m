//
//  GameTest.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 4/22/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h> 
#import "Game.h"
#import "Event.h"
#import "OffenseEvent.h"
#import "DefenseEvent.h"
#import "Player.h"

@interface GameTest : GHTestCase {
    Game* game;
    Event* event;
    Player* player1;
    Player* player2;
}

@end

@implementation GameTest

- (void)setUp {
    game = [[Game alloc] init];
    player1 = [[Player alloc] initName:@"Jim"];
    player2 = [[Player alloc] initName:@"Kyle"];
}

- (void)testAddEvent {       
    // add one
    event = [[OffenseEvent alloc] initPasser:player1 action:Catch receiver:player2];
    [game addEvent:event];
    
    // assert    
    GHAssertTrue([game hasEvents], nil);
    GHAssertEquals(event, [game getLastEvent], nil);
    GHAssertTrue([game.points count] == 1, nil);
    
    // add another (should be in same point)
    event = [[OffenseEvent alloc] initPasser:player1 action:Goal receiver:player2];
    [game addEvent:event];
    
    // assert    
    GHAssertTrue([game hasEvents], nil);
    GHAssertEquals(event, [game getLastEvent], nil); 
    GHAssertTrue([game.points count] == 1, nil);
    
    // add another (should be in new point)
    event = [[OffenseEvent alloc] initPasser:player1 action:Catch receiver:player2];
    [game addEvent:event];
    
    // assert    
    GHAssertTrue([game hasEvents], nil);
    GHAssertEquals(event, [game getLastEvent], nil);  
    GHAssertTrue([game.points count] == 2, nil);
}


@end
