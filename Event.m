//
//  Event.m
//  Ultimate
//
//  Created by james on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Event.h"

@implementation Event
@synthesize action;

- (void)encodeWithCoder:(NSCoder *)encoder { 
    [encoder encodeInt: self.action forKey:kActionKey]; 
} 

- (id)initWithCoder:(NSCoder *)decoder { 
    if (self = [super init]) { 
        self.action = [decoder decodeIntForKey:kActionKey];
    } 
    return self; 
} 

-(void)useSharedPlayers {
    [NSException raise:@"Method must be implemented in subclass" format:@"should be implemented in subclass"];
}

- (BOOL) isGoal {
    return NO;
}

- (BOOL) isOurGoal {
    return NO;
}

- (BOOL) isTurnover {
   [NSException raise:@"Method must be implemented in subclass" format:@"should be implemented in subclass"];
    return NO;
}

- (BOOL) isFinalEventOfPoint {
    return NO;
}

- (NSString*)description {
    return [self getDescription];
}

- (NSString*)getDescription: (NSString*) teamName opponent: (NSString*) opponentName {
    [NSException raise:@"Method must be implemented in subclass" format:@"should be implemented in subclass"];
    return nil;
}

- (NSDictionary*) asDictionary {
    [NSException raise:@"Method must be implemented in subclass" format:@"should be implemented in subclass"];
    return nil;
}

- (NSString*)getDescription {
    return [self getDescription:nil opponent:nil];
}

- (BOOL) isOffense {
    return NO;
}

- (BOOL) causesDirectionChange {
    return !(action == Catch || action == Pull);
}

- (BOOL) causesLineChange {
    return action == Goal;
}

- (BOOL) isNextEventOffense {
    [NSException raise:@"Method must be implemented in subclass" format:@"should be implemented in subclass"];
    return NO;
}

- (NSArray*) getPlayers {
    [NSException raise:@"Method must be implemented in subclass" format:@"should be implemented in subclass"];
    return nil;
}

@end
