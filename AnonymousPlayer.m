//
//  AnonymousPlayer.m
//  Ultimate
//
//  Created by james on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AnonymousPlayer.h"

@implementation AnonymousPlayer

-(id) init {
    self = [super init];
    if (self) {
        self.name = @"Anonymous";
        self.position = Any;
        self.isMale = YES;
    }
    return self;
}

-(BOOL) isAnonymous {
    return true;
}

@end