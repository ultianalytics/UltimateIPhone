//
//  DefenseEvent.m
//  Ultimate
//
//  Created by james on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DefenseEvent.h"
#import "Team.h"
#import "Player.h"

@implementation DefenseEvent
@synthesize defender;

-(id) initDefender: (Player*)aDefender action: (Action)anAction {
    self = [super init];
    if (self) {
        self.defender = aDefender;
        self.action = anAction;
    }
    return self;
}

-(id) initAction: (Action)anAction {
    self = [super init];
    if (self) {
       self.action = anAction;
    }
    return self;
}

-(void)useSharedPlayers {
    self.defender = [Player replaceWithSharedPlayer: self.defender];
}

- (void)encodeWithCoder:(NSCoder *)encoder { 
    [super encodeWithCoder: encoder];
    [encoder encodeObject: self.defender forKey:kDefenderKey]; 
} 

- (id)initWithCoder:(NSCoder *)decoder { 
    self = [super initWithCoder:decoder];
    self.defender = [decoder decodeObjectForKey:kDefenderKey];
    return self; 
} 

+(DefenseEvent*)eventFromDictionary:(NSDictionary*) dict {
    NSString* dictAction = [dict valueForKey:kActionKey];
    Action action = [dictAction isEqualToString: @"D"] ? De :  [dictAction isEqualToString: @"Pull"] ? Pull : [dictAction isEqualToString: @"Goal"] ? Goal : [dictAction isEqualToString: @"Throwaway"] ? Throwaway : Callahan;
    return [[DefenseEvent alloc] 
            initDefender: [Team getPlayerNamed:[dict valueForKey:kDefenderKey]]
            action: action];
}

-(NSDictionary*) asDictionary {
    NSMutableDictionary* dict = [super asDictionary];
    [dict setValue: @"Defense" forKey:kEventTypeProperty];
    [dict setValue: self.action == De ? @"D" :  self.action == Pull ? @"Pull" : self.action == Goal ? @"Goal" : self.action == Throwaway ? @"Throwaway" : @"Calahan" forKey:kActionKey];
    [dict setValue: self.defender.name forKey:kDefenderKey];
    return dict;
}

- (BOOL) isOurGoal {
    return self.action == Callahan;
}

- (BOOL) isGoal {
    return self.action == Goal || self.action == Callahan;
}

- (BOOL) isTurnover {
    return self.action == De;
}

- (BOOL) isFinalEventOfPoint {
    return self.action == Callahan || self.action == Goal;
}

- (NSString*)getDescription: (NSString*) teamName opponent: (NSString*) opponentName {
    switch(self.action) {
        case Pull: {
            if (self.isAnonymous) {
                return [NSString stringWithFormat:@"%@ pull", (teamName == nil ? @"Our" : teamName)];
            } else {
                return [NSString stringWithFormat:@"Pull from %@", self.defender.name];
            }
        }
        case Goal: {
            return opponentName == nil ? @"Opponent goal" : [NSString stringWithFormat:@"%@ Goal", opponentName];
        }
        case Throwaway:{
            return opponentName == nil ? @"Opponent throwaway" : [NSString stringWithFormat:@"%@ throwaway", opponentName];
        }
        case De: {
            return self.isAnonymous ? [NSString stringWithFormat:@"%@ D", (teamName == nil ? @"Our" : teamName)] :[NSString stringWithFormat:@"D by %@", self.defender.name];    
        }
        default:
            return @"";
    }
}

- (BOOL) isNextEventOffense {
    return self.action != Pull;
}

- (NSArray*) getPlayers {
    return [[NSMutableArray alloc] initWithObjects: self.defender, nil];
}

- (BOOL)isAnonymous {
    return (defender == nil || defender.isAnonymous);
}

@end
