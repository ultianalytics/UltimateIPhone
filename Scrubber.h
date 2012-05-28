//
//  Scrubber.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 5/23/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Scrubber : NSObject {
    NSMutableArray *maleTeamNames;
    NSMutableArray *femaleTeamNames;
    NSMutableArray *oppponentNames;
    NSMutableArray *tournamentNames;
    NSMutableDictionary *playerNameLookup;
    NSMutableSet *usedPlayerNames;
    NSMutableDictionary *tournamenLookup;
}

-(void)createScrubbedVersionOfActiveTeam;


@end
