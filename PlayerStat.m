//
//  PlayerStat.m
//  Ultimate
//
//  Created by Jim Geppert on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayerStat.h"
#import "Player.h"

@implementation PlayerStat
@synthesize player,number,type;

-(id) initPlayer: (Player*)aPlayer stat: (NSNumber*)aNumber type: (StatNumericType) aType {
    self = [super init];
    if (self) {
        self.player = aPlayer;
        self.number = aNumber;
        self.type = aType;
    }
    return self;
}

@end
