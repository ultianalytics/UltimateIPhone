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
//    game = [[Game alloc] init];
    player1 = [[Player alloc] initName:@"Jim"];
//    player2 = [[Player alloc] initName:@"Kyle"];
}

- (void)testAddEvent {       
//    event = [[OffenseEvent alloc] initPasser:player1 action:Goal receiver:player2];
//    [game addEvent:event];
//    GHAssertTrue([game hasEvents], nil);
}

- (void)testString {       
    NSString *string1 = @"a string";
    GHTestLog(@"I can log to the GHUnit test console: %@", string1);
    
    // Assert string1 is not NULL, with no custom error description
    GHAssertNotNil(string1, @"");
    
    // Assert equal objects, add custom error description
    NSString *string2 = @"a string";
    GHAssertEqualObjects(string1, string2, @"A custom error message. string1 should be equal to: %@.", string2);
}

@end
