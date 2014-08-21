//
//  EventPosition.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/21/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "EventPosition.h"

#define kEventPositionX             @"x"
#define kEventPositionY             @"y"
#define kEventPositionOrientation   @"orientation"

@implementation EventPosition

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.x = [decoder decodeFloatForKey:kEventPositionX];
        self.y = [decoder decodeFloatForKey:kEventPositionY];
        self.orientation = [decoder decodeIntForKey:kEventPositionOrientation];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeFloat:self.x forKey:kEventPositionX];
    [encoder encodeFloat:self.y forKey:kEventPositionY];
    [encoder encodeInt:self.orientation forKey:kEventPositionOrientation];
}

+(EventPosition*)fromDictionary:(NSDictionary*) dict {
    EventPosition* position = [[EventPosition alloc] init];
    NSNumber* x = [dict objectForKey:kEventPositionX];
    if (x) {
        position.x = [x floatValue];
    }
    NSNumber* y = [dict objectForKey:kEventPositionX];
    if (y) {
        position.y = [y floatValue];
    }
    NSNumber* orientation = [dict objectForKey:kEventPositionOrientation];
    if (orientation) {
        position.orientation = [orientation intValue];
    }
    return position;
}

-(NSDictionary*) asDictionary {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setValue: [NSNumber numberWithFloat:self.x ] forKey:kEventPositionX];
    [dict setValue: [NSNumber numberWithFloat:self.y ] forKey:kEventPositionY];
    [dict setValue: [NSNumber numberWithInt:self.orientation ] forKey:kEventPositionOrientation];
    return dict;
}


@end
