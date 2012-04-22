//
//  PlayerStat.h
//  Ultimate
//
//  Created by Jim Geppert on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Player;
typedef enum {
    FloatStat,
    IntStat
} StatNumericType;

@interface PlayerStat : NSObject
@property (nonatomic, strong) Player* player;
@property (nonatomic, strong) NSNumber* number;
@property (nonatomic) StatNumericType type;

-(id) initPlayer: (Player*)aPlayer stat: (NSNumber*)aNumber type: (StatNumericType) aType;

@end
