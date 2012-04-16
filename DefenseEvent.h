//
//  DefenseEvent.h
//  Ultimate
//
//  Created by james on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "Player.h"
#define kDefenderKey        @"defender"

@interface DefenseEvent : Event
@property (nonatomic, strong) Player* defender;

+(DefenseEvent*)eventFromDictionary:(NSDictionary*) dict;

-(id) initAction: (Action)anAction;
-(id) initDefender: (Player*)aDefender action: (Action)anAction;


@end
