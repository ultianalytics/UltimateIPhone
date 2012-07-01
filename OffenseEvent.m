//
//  OffenseEvent.m
//  Ultimate
//
//  Created by james on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OffenseEvent.h"
#import "Team.h"
#import "Player.h"

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
    NSMutableDictionary* dict = [super asDictionary];
    [dict setValue: @"Offense" forKey:kEventTypeProperty];
    [dict setValue: self.action == Catch ? @"Catch" :  self.action == Drop ? @"Drop" : self.action == Goal ? @"Goal" : @"Throwaway" forKey:kActionKey];
    [dict setValue: self.passer.name forKey:kPasserKey];
    if (self.receiver) {
        [dict setValue: self.receiver.name forKey:kReceiverKey];
    }
    return dict;
}

+(OffenseEvent*)eventFromDictionary:(NSDictionary*) dict {
    NSString* dictAction = [dict valueForKey:kActionKey];
    Action action = [dictAction isEqualToString: @"Catch"] ? Catch :  [dictAction isEqualToString: @"Drop"] ? Drop : [dictAction isEqualToString: @"Goal"] ? Goal : Throwaway;
    return [[OffenseEvent alloc] 
        initPasser: [Team getPlayerNamed:[dict valueForKey:kPasserKey]]
        action: action 
        receiver: [Team getPlayerNamed:[dict valueForKey:kReceiverKey]]];
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

- (NSString*)getDescription: (NSString*) teamName opponent: (NSString*) opponentName {
    switch(self.action) {
        case Catch: {
            if (self.isAnonymous) {
                return [NSString stringWithFormat:@"%@ pass", (teamName == nil ? @"Our" : teamName)];
            } else if (self.isReceiverAnonymous) {
                return [NSString stringWithFormat:@"%@ pass", self.passer.name];
            } else if (self.isPasserAnonymous) {
                return [NSString stringWithFormat:@"Pass to %@", self.receiver.name];
            } else {
                return [NSString stringWithFormat:@"%@ to %@", self.passer.name, self.receiver.name];
            }
        }
        case Drop: {
            if (self.isAnonymous) {
                return [NSString stringWithFormat:@"%@ drop", (teamName == nil ? @"Our" : teamName)];
            } else if (self.isReceiverAnonymous) {
                return [NSString stringWithFormat:@"%@ pass dropped", self.passer.name];
            } else if (self.isPasserAnonymous) {
                return [NSString stringWithFormat:@"%@ dropped pass", self.receiver.name];
            } else {
               return [NSString stringWithFormat:@"%@ dropped from %@", self.receiver.name, self.passer.name];            
            }
        }
        case Throwaway:{
            return self.isAnonymous ?  [NSString stringWithFormat:@"%@ throwaway", (teamName == nil ? @"Our" : teamName)] : [NSString stringWithFormat:@"%@ throwaway", self.passer.name];     
        }
        case Goal: {
            if (self.isAnonymous) {
                return [NSString stringWithFormat:@"%@ goal", (teamName == nil ? @"Our" : teamName)]; 
            } else if (self.isReceiverAnonymous) {
                return [NSString stringWithFormat:@"%@ pass for goal", self.passer.name];
            } else if (self.isPasserAnonymous) {
                return [NSString stringWithFormat:@"%@ goal", self.receiver.name];
            } else {
                return [NSString stringWithFormat:@"%@ goal (%@ to %@)", (teamName == nil ? @"Our" : teamName), self.passer.name, self.receiver.name];            
            }
        }
        default:
            return @"";
    }
}

- (BOOL) isOffense {
    return YES;
}

- (BOOL) isTurnover {
    return self.action == Drop || self.action == Throwaway;
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

- (BOOL)isAnonymous {
    return (passer == nil || passer.isAnonymous) && (receiver ==  nil || receiver.isAnonymous);
}

- (BOOL)isPasserAnonymous {
    return (passer == nil || passer.isAnonymous);
}

- (BOOL)isReceiverAnonymous {
    return (receiver ==  nil || receiver.isAnonymous);
}

@end
