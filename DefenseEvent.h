//
//  DefenseEvent.h
//  Ultimate
//
//  Created by james on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
@class Player;
#define kDefenderKey        @"defender"

@interface DefenseEvent : Event
@property (nonatomic, strong) Player* defender;
@property (nonatomic) int pullHangtimeMilliseconds;

+(DefenseEvent*)eventFromDictionary:(NSDictionary*) dict;
+(NSString*)formatHangtime: (int)hangtimeMilliseconds;

-(id) initAction: (Action)anAction;
-(id) initDefender: (Player*)aDefender action: (Action)anAction;
-(id) initPickupDisc;


@end
