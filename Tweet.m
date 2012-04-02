//
//  Tweet.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tweet.h"


@implementation Tweet

@synthesize message,type,status,undoMessage,error;

-(id) initMessage: (NSString*) aMessage {
    self = [super init];
    if (self) {
        message = aMessage;
        type = @"";
        status = TweetQueued;
    }
    return self;
}

-(id) initMessage: (NSString*) aMessage type: (NSString*) aType {
    self = [super init];
    if (self) {
        message = aMessage;
        type = aType;
        status = TweetQueued;
    }
    return self;
}

-(id) initMessage: (NSString*) aMessage status: (TweetStatus) aStatus {
    self = [super init];
    if (self) {
        message = aMessage;
        type = @"";
        status = aStatus;
    }
    return self;
}

-(id) initMessage: (NSString*) aMessage failed: (NSString*)errorDescription {
    self = [super init];
    if (self) {
        message = aMessage;
        type = @"";
        status = TweetFailed;
        error = errorDescription;
    }
    return self;
}


@end
