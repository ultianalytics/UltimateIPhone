//
//  Tweet.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tweet.h"


@implementation Tweet

@synthesize message;

-(id) initMessage: (NSString*) aMessage  {
    self = [super init];
    if (self) {
        message = aMessage;
    }
    return self;
}

@end
