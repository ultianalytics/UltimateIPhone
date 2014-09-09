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
#import "Scrubber.h"

#define kHangtimeKey  @"hangtime"

@implementation DefenseEvent
@dynamic pullHangtimeMilliseconds;

+(NSString*)formatHangtime: (int)hangtimeMilliseconds {
    double hangtimeSeconds = (double)hangtimeMilliseconds / 1000.f;
    return [NSString stringWithFormat:@"%.1f", hangtimeSeconds];
}

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

-(id) initPickupDisc {
    self = [super init];
    if (self) {
        self.action = PickupDisc;
    }
    return self;
}

-(id) initPullBegin: (Player*)puller {
    self = [super init];
    if (self) {
        self.defender = puller;
        self.action = PullBegin;
    }
    return self;
}

-(id) initOpponentCatch {
    self = [super init];
    if (self) {
        self.action = OpponentCatch;
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
    [self ensureValid];
    return self; 
} 

+(DefenseEvent*)eventFromDictionary:(NSDictionary*) dict {
    NSString* dictAction = [dict valueForKey:kActionKey];
    Action action = [dictAction isEqualToString: @"D"] ? De :  [dictAction isEqualToString: @"Pull"] ? Pull : [dictAction isEqualToString: @"Goal"] ? Goal : [dictAction isEqualToString: @"Throwaway"] ? Throwaway : [dictAction isEqualToString: @"PullOb"] ? PullOb : [dictAction isEqualToString: @"PickupDisc"] ? PickupDisc : [dictAction isEqualToString: @"OpponentCatch"] ? OpponentCatch : Callahan ;
    return [[DefenseEvent alloc] 
            initDefender: [Team getPlayerNamed:[dict valueForKey:kDefenderKey]]
            action: action];
}

- (NSDictionary*) asDictionaryWithScrubbing: (BOOL) shouldScrub  {
    NSMutableDictionary* dict = [super asDictionaryWithScrubbing: shouldScrub];
    [dict setValue: @"Defense" forKey:kEventTypeProperty];
    [dict setValue: self.action == De ? @"D" :  self.action == Pull ? @"Pull" : self.action == Goal ? @"Goal" : self.action == Throwaway ? @"Throwaway" : self.action == PullOb ? @"PullOb" : self.action == PickupDisc ? @"PickupDisc" : self.action == OpponentCatch ? @"OpponentCatch" : @"Callahan" forKey:kActionKey];
    NSString *defenderName = shouldScrub ? [[Scrubber currentScrubber] substitutePlayerName:self.defender.name isMale:self.defender.isMale] : self.defender.name;
    [dict setValue: defenderName forKey:kDefenderKey];
    return dict;
}

- (id)copyWithZone:(NSZone *)zone {
    DefenseEvent* evt = [super copyWithZone:nil];
    evt.defender = self.defender;
    return evt;
}

- (BOOL) isDefense {
    return YES;
}

- (BOOL) isOurGoal {
    return self.action == Callahan;
}

- (BOOL) isGoal {
    return self.action == Goal || self.action == Callahan;
}

- (BOOL) isTurnover {
    return self.action == De || self.action == Throwaway || self.action == Callahan;
}

- (BOOL) isCallahan {
    return self.action == Callahan;
}

- (BOOL) isTheirGoal {
    return self.action == Goal;
}

- (BOOL) isFinalEventOfPoint {
    return self.action == Callahan || self.action == Goal;
}

- (BOOL) isPlayEvent {
    return YES;
}

- (Event*) asBeginEvent {
    Event* beginEvent;
    if (self.beginPosition) {
        if ([self isPull]) {
            beginEvent = [[DefenseEvent alloc] initPullBegin:self.defender];
        } else {
            beginEvent = [[DefenseEvent alloc] initPickupDisc];  
        }
        beginEvent.position = self.beginPosition;
    }
    return beginEvent;
}

-(Player*)playerOne {
    return self.defender;
}

- (NSString*)getDescription: (NSString*) teamName opponent: (NSString*) opponentName {
    switch(self.action) {
        case Pull: {
            NSString* hangtime = self.pullHangtimeMilliseconds > 0 ?
                [NSString stringWithFormat: @" (%@ sec)", [DefenseEvent formatHangtime:self.pullHangtimeMilliseconds]] :
                @"";
            if (self.isAnonymous) {
                return [NSString stringWithFormat:@"%@ pull%@", (teamName == nil ? @"Our" : teamName), hangtime];
            } else {
                return [NSString stringWithFormat:@"Pull from %@%@", self.defender.name, hangtime];
            }
        }
        case PullOb: {
            if (self.isAnonymous) {
                return [NSString stringWithFormat:@"%@ OB pull", (teamName == nil ? @"Our" : teamName)];
            } else {
                return [NSString stringWithFormat:@"OB Pull from %@", self.defender.name];
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
        case Callahan: {
            return self.isAnonymous ? [NSString stringWithFormat:@"%@ Callahan", (teamName == nil ? @"Our" : teamName)] :[NSString stringWithFormat:@"Callahan by %@", self.defender.name];
        }
        case PickupDisc:{
            return opponentName == nil ? @"Opponent pick up" : [NSString stringWithFormat:@"%@ pick up", opponentName];
        }
        case PullBegin:{
            return self.isAnonymous ? [NSString stringWithFormat:@"%@ Pull", (teamName == nil ? @"Our" : teamName)] :[NSString stringWithFormat:@"Pull by %@", self.defender.name];    
        }
        case OpponentCatch:{
            return opponentName == nil ? @"Opponent catch" : [NSString stringWithFormat:@"%@ catch", opponentName];
        }
        default:
            return @"";
    }
}

-(NSString*)positionalDescription {
    
    switch(self.action) {
        case Pull: {
            return self.isAnonymous ? @"PULL LAND" : [NSString stringWithFormat:@"PULL LAND\n%@", self.defender.name];
        }
        case PullOb: {
            return self.isAnonymous ? @"PULL OB" : [NSString stringWithFormat:@"PULL OB\n%@", self.defender.name];
        }
        case Goal: {
            return [NSString stringWithFormat:@"THEIR GOAL"];
        }
        case Throwaway:{
            return [NSString stringWithFormat:@"THROWAWAY"];
        }
        case De: {
            return self.isAnonymous ? @"D" : [NSString stringWithFormat:@"D\n%@", self.defender.name];
        }
        case Callahan: {
            return self.isAnonymous ? @"CALLAHAN" : [NSString stringWithFormat:@"CALLAHAN\n%@", self.defender.name];
        }
        case PickupDisc:{
            return [NSString stringWithFormat:@"PICK UP"];
        }
        case PullBegin:{
            return self.isAnonymous ? @"PULL BEGIN" : [NSString stringWithFormat:@"PULL BY\n%@", self.defender.name];
        }
        case OpponentCatch:{
            return [NSString stringWithFormat:@"CATCH"];
        }
        default:
            return @"";
    }
}

- (BOOL) isNextEventOffense {
    return ![self isCallahan] && ([self isTurnover] || [self isGoal]);
}

- (NSArray*) getPlayers {
    return [[NSMutableArray alloc] initWithObjects: self.defender, nil];
}

- (BOOL)isAnonymous {
    return (self.defender == nil || self.defender.isAnonymous);
}

-(void)ensureValid {
    if (self.defender == nil) {
        self.defender = [Player getAnonymous];
    }
}

-(void)setDefender:(Player *)defender {
    _defender = defender ? defender : [Player getAnonymous];
}

#pragma mark Detail properties

-(void)setPullHangtimeMilliseconds: (int)hangtimeMs {
    [self setDetailIntValue:hangtimeMs forKey:kHangtimeKey];
}

-(int)pullHangtimeMilliseconds {
    return [self intDetailValueForKey:kHangtimeKey default:0];
}

@end
