//
//  Scrubber.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 5/23/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "Scrubber.h"
#import "Team.h"
#import "Game.h"
#import "Player.h"
#import "UPoint.h"
#import "Event.h"
#import "OffenseEvent.h"
#import "DefenseEvent.h"

@interface Scrubber()



@property (nonatomic, strong) NSMutableArray *maleTeamNames;
@property (nonatomic, strong) NSMutableArray *femaleTeamNames;
@property (nonatomic, strong) NSMutableArray *opponentNames;
@property (nonatomic, strong) NSMutableArray *tournamentNames;

@property (nonatomic, strong) NSMutableDictionary *playerNameLookup;
@property (nonatomic, strong) NSMutableSet *usedPlayerNames;

@property (nonatomic, strong) NSMutableDictionary *tournamentNameLookup;
@property (nonatomic, strong) NSMutableSet *usedTournamentNames;

@property (nonatomic, strong) NSMutableDictionary *opponentNameLookup;
@property (nonatomic, strong) NSMutableSet *usedOpponentNames;

@end

@implementation Scrubber

+ (Scrubber*)currentScrubber {
    static dispatch_once_t once;
    static Scrubber *sharedScrubber;
    dispatch_once(&once, ^ { sharedScrubber = [[self alloc] init]; });
    return sharedScrubber;
}

-(void)setIsOn:(BOOL)shouldBeOn {
    _isOn = shouldBeOn;
    if (_isOn) {
        [self setup];
    } else {
        self.maleTeamNames = nil;
        self.femaleTeamNames = nil;
        self.tournamentNames = nil;
        self.opponentNames = nil;
        self.tournamentNameLookup = nil;
        self.usedTournamentNames = nil;
        self.playerNameLookup = nil;
        self.usedPlayerNames = nil;
        self.opponentNameLookup = nil;
        self.usedOpponentNames = nil;
    }
}

-(NSString*)substitutePlayerName: (NSString*) originalName isMale: (BOOL) isMale {
    if (!originalName) {
        return originalName;
    }
    if ([self.usedPlayerNames containsObject:originalName]) {
        return originalName;
    }
    NSString *subName = [self.playerNameLookup objectForKey:originalName];
    if (subName == nil) {
        if (isMale) {
            subName = [ self.maleTeamNames lastObject];
            [ self.maleTeamNames removeLastObject];
        } else {
            subName = [ self.femaleTeamNames lastObject];
            [ self.femaleTeamNames removeLastObject]; 
        }
        [self.playerNameLookup setValue:subName forKey:originalName];
        [self.usedPlayerNames addObject:subName];
    }
    NSLog(@"Player name substitution.  old=%@, new=%@",originalName, subName);
    return subName;
}

-(NSString*)substituteTournamentName: (NSString*) originalName {
    if (!originalName) {
        return originalName;
    }
    if ([self.usedTournamentNames containsObject:originalName]) {
        return originalName;
    }
    NSString *subName = [self.tournamentNameLookup objectForKey:originalName];
    if (subName == nil) {
        subName = [ self.tournamentNames lastObject];
        [self.tournamentNames removeLastObject];
        [self.tournamentNameLookup setValue:subName forKey:originalName];
        [self.usedTournamentNames addObject:subName];
    }
    NSLog(@"Tournament name substitution.  old=%@, new=%@",originalName, subName);
    return subName;
}

-(NSString*)substituteOpponentName: (NSString*) originalName {
    if (!originalName) {
        return originalName;
    }
    if ([self.usedOpponentNames containsObject:originalName]) {
        return originalName;
    }
    NSString *subName = [self.opponentNameLookup objectForKey:originalName];
    if (subName == nil) {
        subName = [ self.opponentNames lastObject];
        [self.opponentNames removeLastObject];
        [self.opponentNameLookup setValue:subName forKey:originalName];
        [self.usedOpponentNames addObject:subName];
    }
    NSLog(@"Opponent name substitution.  old=%@, new=%@",originalName, subName);
    return subName;
}

-(NSDate*)scrubGameDate: (NSDate*) gameDate {
    if (gameDate) {
        return  [gameDate dateByAddingTimeInterval:  -1 * (356 * 24 * 60 * 60)];  // last yearish
    } else {
        return gameDate;
    }
}

-(void)setup {
    self.maleTeamNames = [NSMutableArray arrayWithObjects:@"Tom", @"Gonzo", @"Albert", @"Tobias", @"Cal", @"Rooster", @"Catman", @"Sleepy",@"Tupe" ,@"Gasman", @"Phinny",@"Shark", @"Robbie", @"Danny", @"Giga", @"Phil", @"Bikerman", @"Dolt", @"Priest",@"Famer" ,@"Steve", @"Jim",@"Flipper", @"Uki", @"Wadupp", @"Flatfoot", @"Archer", @"Lame", @"Gripper", @"Hondo",@"Bird" ,@"Trippy", @"Master",@"Gordy", @"Placard", @"Skyman", @"DDer", @"Sam", @"Collin", @"Pete", @"Fish",@"Walker" ,@"Axman", @"Yve",@"Norten", @"Tippy", @"Bubba", @"Fasta", @"Kip", @"Tim", @"Fryman", @"Ortho",@"Doc" ,@"Bret", @"Loren",@"Arty", @"Finster", @"Mr D", @"Slim", @"Rockstar", @"Jack", @"Spidy",@"Alex",@"Gordon", @"Chatterbox",@"Lowslinger", @"Jester", @"Amby", @"Greg", @"Forest", @"Trippy", @"Goliath", @"Tracker",@"Xman" ,@"Laser", @"Phineas",nil];
    
    self.femaleTeamNames = [NSMutableArray arrayWithObjects:@"Sue", @"Bambi", @"Tabatha", @"Samantha", @"Anne", @"Powergrrl", @"Cindy", @"Lori",@"Bitty" ,@"Ginger" @"MsTrouble",@"GadGirl", @"Michelle", @"Sara", @"Breaker", @"Huckgirl", @"Uma", @"Tami", @"Sally",nil];
    
    self.tournamentNames = [NSMutableArray arrayWithObjects:@"Trouble in Tupelo", @"Minnetourney", @"Disc Fest", @"Fast Times", @"Hammer Bowl", @"Almost Everybody Tourney", @"Disc Mania", @"Eleventh Hour", @"Sectionals", nil];
    
    self.opponentNames = [NSMutableArray arrayWithObjects:@"Fastidians", @"Fire Hose", @"Top Flight", @"Glam",@"Hucksters",@"Busta", @"Darwinians",@"Spark", @"Aliens", @"Gamma Rays", @"Hot House", @"Rooters",@"Ultimites", @"Fab7", @"Hammers", @"Red Hots", @"Skyboys", @"Tramway", @"Gavel", @"Crash Dummies", @"Rockstars", @"Northern Lights", @"City Boys", @"Bay Boys", @"Discites", @"Johnny Quest", @"Bad Boys", @"Beaux Bros", @"Sifters" ,@"Trappers",@"Fastidians", @"Fire Hose", @"Top Flight", @"Glam",@"Hucksters",@"Busta", @"Darwinians",@"Spark", @"Aliens", @"Gamma Rays", @"Hot House", @"Rooters",@"Ultimites", @"Fab7", @"Hammers", @"Red Hots", @"Skyboys", @"Tramway", @"Gavel", @"Crash Dummies", @"Rockstars", @"Northern Lights", @"City Boys", @"Bay Boys", @"Discites", @"Johnny Quest", @"Bad Boys", @"Beaux Bros", @"Sifters" ,@"Trappers", nil];

    self.tournamentNameLookup = [[NSMutableDictionary alloc] init];
    self.usedTournamentNames = [[NSMutableSet alloc] init];
    
    self.playerNameLookup = [[NSMutableDictionary alloc] init];
    self.usedPlayerNames = [[NSMutableSet alloc] init];
    
    self.opponentNameLookup = [[NSMutableDictionary alloc] init];
    self.usedOpponentNames = [[NSMutableSet alloc] init];
}


@end
