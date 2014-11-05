//
//  EventEnumFixRegistar.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 11/3/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "EventEnumFixRegistar.h"

@implementation EventEnumFixRegistar

static EventEnumFixRegistar *sharedRegister = nil;

+ (EventEnumFixRegistar *)sharedRegister {
    if (nil != sharedRegister) {
        return sharedRegister;
    }
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedRegister = [[EventEnumFixRegistar alloc] init];
    });
    
    return sharedRegister;
}

@end
