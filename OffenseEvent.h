//
//  OffenseEvent.h
//  Ultimate
//
//  Created by james on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
@class Player;

#define kPasserKey        @"passer"
#define kReceiverKey        @"receiver"

@interface OffenseEvent : Event

@property (nonatomic, strong) Player* passer;
@property (nonatomic, strong) Player* receiver;

+(OffenseEvent*)eventFromDictionary:(NSDictionary*) dict;

-(id) initPasser: (Player*)aPasser action: (Action)anAction;
-(id) initPasser: (Player*)aPasser action: (Action)anAction receiver: (Player*)aReceiver;
-(id) initPickupDiscWithPlayer: (Player*)aPasser;
-(id) initPullBegin;
-(BOOL)isPasserAnonymous;
-(BOOL)isReceiverAnonymous;

@end
