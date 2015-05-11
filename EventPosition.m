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
#define kEventPositionInverted      @"inverted"
#define kEventPositionArea          @"area"

@implementation EventPosition


+(EventPosition*)positionInArea: (EventPositionArea) area x: (CGFloat)x y: (CGFloat)y inverted: (BOOL)isInverted {
    EventPosition* position = [[EventPosition alloc] init];
    position.x = x;
    position.y = y;
    position.area = area;
    position.inverted = isInverted;
    return position;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.x = [decoder decodeFloatForKey:kEventPositionX];
        self.y = [decoder decodeFloatForKey:kEventPositionY];
        self.inverted = [decoder decodeBoolForKey:kEventPositionInverted];
        self.area = [decoder decodeIntForKey:kEventPositionArea];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeFloat:self.x forKey:kEventPositionX];
    [encoder encodeFloat:self.y forKey:kEventPositionY];
    [encoder encodeBool:self.inverted forKey:kEventPositionInverted];
    [encoder encodeInt:self.area forKey:kEventPositionArea];
}

+(EventPosition*)fromDictionary:(NSDictionary*) dict {
    EventPosition* position = [[EventPosition alloc] init];
    NSNumber* x = [dict objectForKey:kEventPositionX];
    if (x) {
        position.x = [x floatValue];
    }
    NSNumber* y = [dict objectForKey:kEventPositionY];
    if (y) {
        position.y = [y floatValue];
    }
    NSNumber* inverted = [dict objectForKey:kEventPositionInverted];
    if (inverted) {
        position.inverted = [inverted boolValue];
    }
    NSString* area = [dict objectForKey:kEventPositionArea];
    if (area) {
        position.area = [self areaFromString:area];
    }
    return position;
}

-(NSDictionary*) asDictionary {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setValue: [NSNumber numberWithFloat:self.x ] forKey:kEventPositionX];
    [dict setValue: [NSNumber numberWithFloat:self.y ] forKey:kEventPositionY];
    [dict setValue: [NSNumber numberWithBool:self.inverted] forKey:kEventPositionInverted];
    [dict setValue: [self areaAsString] forKey:kEventPositionArea];
    return dict;
}

-(NSString*)areaAsString {
    switch (self.area) {
        case EventPositionAreaField:
            return @"field";
            break;
        case EventPositionArea0Endzone:
            return @"0endzone";
            break;
        case EventPositionArea100Endzone:
            return @"100endzone";
            break;
         default:
            return @"field";
            break;
    }
}

+(EventPositionArea)areaFromString: (NSString*) areaAsString {
    if ([areaAsString isEqualToString:@"field"]) {
        return EventPositionAreaField;
    } else if ([areaAsString isEqualToString:@"0endzone"]) {
        return EventPositionArea0Endzone;
    } else if ([areaAsString isEqualToString:@"100endzone"]) {
        return EventPositionArea100Endzone;
    } else {
        return EventPositionAreaField;
    }
}

-(BOOL)isCloserToEndzoneZero {
    switch (self.area) {
        case EventPositionArea0Endzone:
            return YES;
        case EventPositionArea100Endzone:
            return NO;
        default:
            return self.x < .5;
    }
}

-(NSString*)description {
    return [NSString stringWithFormat:@"EventPosition in area: %@, x: %f, y: %f, inverted=%@", [self areaAsString], self.x, self.y, NSStringFromBOOL(self.inverted)];
}

@end
