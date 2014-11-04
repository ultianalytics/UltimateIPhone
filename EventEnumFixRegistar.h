//
//  EventEnumFixRegistar.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 11/3/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventEnumFixRegistar : NSObject

@property (nonatomic) BOOL shouldFixEventEnums;

+ (EventEnumFixRegistar *)sharedRegister;

@end
