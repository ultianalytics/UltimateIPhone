//
//  OffenseEvent.m
//  Ultimate
//
//  Created by james on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OffenseEvent.h"

@implementation OffenseEvent
@synthesize passer,receiver;

-(id) initPasser: (Player*)aPasser action: (Action)anAction {
    self = [super init];
    if (self) {
        self.passer = aPasser;
        self.action = anAction;
    }
    return self;
}

-(id) initPasser: (Player*)aPasser action: (Action)anAction receiver: (Player*)aReceiver {
    self = [super init];
    if (self) {
        self.passer = aPasser;
        self.action = anAction;
        self.receiver = aReceiver;
    }
    return self;
}

-(void)useSharedPlayers {
    self.passer = [Player replaceWithSharedPlayer: self.passer];
    self.receiver = [Player replaceWithSharedPlayer: self.receiver];
}

- (BOOL) isOurGoal {
    return self.action == Goal;
}

- (BOOL) isGoal {
    return self.action == Goal;
}

- (BOOL) isFinalEventOfPoint {
    return self.action == Goal;
}

-(NSDictionary*) asDictionary {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setValue: @"Offense" forKey:kEventTypeProperty];
    [dict setValue: self.action == Catch ? @"Catch" :  self.action == Drop ? @"Drop" : self.action == Goal ? @"Goal" : @"Throwaway" forKey:kActionKey];
    [dict setValue: self.passer.name forKey:kPasserKey];
    if (self.receiver) {
        [dict setValue: self.receiver.name forKey:kReceiverKey];
    }
    return dict;
}

- (void)encodeWithCoder:(NSCoder *)encoder { 
    [super encodeWithCoder: encoder];
    [encoder encodeObject: self.passer forKey:kPasserKey]; 
    [encoder encodeObject: self.receiver forKey:kReceiverKey]; 
} 

- (id)initWithCoder:(NSCoder *)decoder { 
    self = [super initWithCoder:decoder];
    self.passer = [decoder decodeObjectForKey:kPasserKey];
    self.receiver = [decoder decodeObjectForKey:kReceiverKey];
    return self; 
} 

- (NSString*)getDescription {
    switch(self.action) {
        case Catch:
            return [NSString stringWithFormat:@"%@ to %@", self.passer.name, self.receiver.name];
        case Drop:
            return [NSString stringWithFormat:@"%@ dropped from %@", self.receiver.name, self.passer.name];
        case Throwaway:
            return [NSString stringWithFormat:@"%@ throwaway", self.passer.name];            
        case Goal:
            return [NSString stringWithFormat:@"Our Goal (%@ to %@)", self.passer.name, self.receiver.name];
        default:
            return @"";
    }
}

- (BOOL) isOffense {
    return YES;
}

- (BOOL) isNextEventOffense {
    return self.action == Catch;
}

- (NSArray*) getPlayers {
    NSMutableArray* players = [[NSMutableArray alloc] initWithObjects: self.passer, nil];
    if (self.receiver != nil) {
        [players addObject:self.receiver];
    }
    return players;
}


@end
