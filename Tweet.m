//
//  Tweet.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

@synthesize message,type,status,error,time,associatedEvent,isUndo,isOptional;

-(id) initMessage: (NSString*) aMessage {
    return [self initMessage: aMessage type: (NSString*) @""];
}

-(id) initMessage: (NSString*) aMessage type: (NSString*) aType {
    self = [super init];
    if (self) {
        time = [NSDate timeIntervalSinceReferenceDate];
        message = aMessage;
        type = aType;
        status = TweetQueued;
    }
    return self;
}

-(id) initMessage: (NSString*) aMessage status: (TweetStatus) aStatus {
    self = [self initMessage: aMessage type: (NSString*) @""];
    if (self) {
        status = aStatus;
    }
    return self;
}

-(id) initMessage: (NSString*) aMessage failed: (NSString*)errorDescription {
    self = [self initMessage: aMessage type: (NSString*) @""];
    if (self) {
        status = TweetFailed;
        error = errorDescription;
    }
    return self;
}

-(BOOL)isAdHoc {
    return [kAdHocType isEqualToString:self.type];
}


@end
