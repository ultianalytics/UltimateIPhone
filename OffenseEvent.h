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
#define kPointStartPositionKey     @"pointStartPosition"

@interface OffenseEvent : Event

@property (nonatomic, strong) Player* passer;
@property (nonatomic, strong) Player* receiver;
@property (nonatomic, strong) EventPosition* pointStartPosition; // only on first event of point when receiving

+(OffenseEvent*)eventFromDictionary:(NSDictionary*) dict;

-(id) initPasser: (Player*)aPasser action: (Action)anAction;
-(id) initPasser: (Player*)aPasser action: (Action)anAction receiver: (Player*)aReceiver;
-(BOOL)isPasserAnonymous;
-(BOOL)isReceiverAnonymous;

@end
