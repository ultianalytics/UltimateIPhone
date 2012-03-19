//
//  Wind.m
//  Ultimate
//
//  Created by Jim Geppert on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Wind.h"
#define kMphKey                     @"mph"
#define kDirectionDegreesKey        @"degrees"
#define kIsFirstLeftToRightKey      @"leftToRight"

@implementation Wind
@synthesize mph,directionDegrees,isFirstPullLeftToRight;

-(id) init  {
    self = [super init];
    if (self) {
        self.mph = 0;
        self.directionDegrees = -1;
        self.isFirstPullLeftToRight = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder { 
    if (self = [super init]) { 
        self.mph = [decoder decodeIntForKey:kMphKey]; 
        self.directionDegrees = [decoder decodeIntForKey:kDirectionDegreesKey]; 
        self.isFirstPullLeftToRight = [decoder decodeBoolForKey:kIsFirstLeftToRightKey]; 
    } 
    return self; 
} 

- (void)encodeWithCoder:(NSCoder *)encoder { 
    [encoder encodeInt:self.mph forKey:kMphKey]; 
    [encoder encodeInt:self.directionDegrees forKey:kDirectionDegreesKey]; 
    [encoder encodeBool:self.isFirstPullLeftToRight forKey:kIsFirstLeftToRightKey]; 
} 

-(BOOL)isSpecified {
    return self.mph != 0 && self.directionDegrees > -1;
}

@end
