//
//  Tweet.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tweet.h"


@implementation Tweet

@synthesize message, type;

-(id) initMessage: (NSString*) aMessage type: aType  {
    self = [super init];
    if (self) {
        message = aMessage;
        type = aType;
    }
    return self;
}

@end
