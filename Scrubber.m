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

-(void)setup;
-(NSString*)substituteName: (NSString*) originalName isMale: (BOOL) isMale;
-(void)scrubGame:(Game *)game;
-(NSString*)substituteTournament: (NSString*) originalName;
-(NSString*)substituteOpponentName;

@end


@implementation Scrubber

-(void)createScrubbedVersionOfActiveTeam {
    [self setup];
    Team *team = [Team getCurrentTeam];
    NSString* oldTeamId = team.teamId;
    NSMutableArray *gameIds = [NSMutableArray arrayWithArray: [Game getAllGameFileNames:team.teamId]];
    NSString* newTeamId = [Team generateUniqueFileName];
    team.teamId = newTeamId;
    team.name = @"SCRUBBED";
    team.cloudId = nil;
    [team.players removeAllObjects];
    [team save];
    [Team setCurrentTeam:team.teamId];
    Game *lastGame = nil;
    for (NSString *gameId in gameIds) {
        Game *game = [Game readGame:gameId forTeam:oldTeamId];
        [self scrubGame:game];
        [game save];
        lastGame = game;
    }
    // clear the players and read a game to populate the team players
    [team.players removeAllObjects];
    //[Game readGame:lastGame.gameId forTeam:oldTeamId];
    [team save];
    
    Team *scrubbedTeam = [Team readTeam:newTeamId];
    NSLog(@"Scrubbing Complete.  New team has ID %@", scrubbedTeam.teamId);
    
}

- (void)scrubGame:(Game *)game {
    game.gameId = [Game generateUniqueFileName];
    game.opponentName = [self substituteOpponentName];
    game.tournamentName = [self substituteTournament:game.tournamentName];
    game.startDateTime = [game.startDateTime dateByAddingTimeInterval:  -1 * (356 * 24 * 60 * 60)];  // last yearish
    for (UPoint *point in game.points) {
        for (Event *event in point.events) {
            if ([event isOffense]) {
                OffenseEvent *oEvent = (OffenseEvent *)event;
                oEvent.passer.name = [self substituteName:oEvent.passer.name isMale: YES];
                if (oEvent.receiver) {
                    oEvent.receiver.name = [self substituteName:oEvent.receiver.name isMale: YES];     
                }
            } else {
                DefenseEvent *dEvent = (DefenseEvent *)event;
                if (dEvent.defender) {
                    dEvent.defender.name = [self substituteName:dEvent.defender.name isMale: YES];
                }
            }
        }
        for (Player *player in game.currentLine) {
            player.name = [self substituteName:player.name isMale: YES];    
        }
        for (Player *player in game.lastOLine) {
            player.name = [self substituteName:player.name isMale: YES];    
        }
        for (Player *player in game.lastDLine) {
            player.name = [self substituteName:player.name isMale: YES];    
        }
    }
}

-(NSString*)substituteName: (NSString*) originalName isMale: (BOOL) isMale {
    if ([usedPlayerNames containsObject:originalName]) {
        return originalName;
    }
    NSString *subName = [playerNameLookup objectForKey:originalName];
    if (subName == nil) {
        if (isMale) {
            subName = [maleTeamNames lastObject];
            [maleTeamNames removeLastObject];
        } else {
            subName = [femaleTeamNames lastObject];
            [femaleTeamNames removeLastObject]; 
        }
        [playerNameLookup setValue:subName forKey:originalName];
        [usedPlayerNames addObject:subName];
    }
    NSLog(@"Player name substitution.  old=%@, new=%@",originalName, subName);
    return subName;
}

-(NSString*)substituteTournament: (NSString*) originalName {
    NSString *subName = [tournamenLookup objectForKey:originalName];
    if (subName == nil) {
        subName = [tournamentNames lastObject];
        [tournamentNames removeLastObject]; 
        [tournamenLookup setValue:subName forKey:originalName];
    }
    return subName;
}

-(NSString*)substituteOpponentName {
    NSString *subName = [oppponentNames lastObject];
    [oppponentNames removeLastObject]; 
    return subName;
}

-(void)setup {
    maleTeamNames = [NSMutableArray arrayWithObjects:@"Tom", @"Gonzo", @"Al", @"Tobias", @"Cal", @"Rooster", @"Catman", @"Sleepy",@"Tupe" ,@"Gasman", @"Phinny",@"Shark", @"Robbie", @"Danny", @"Giga", @"Phil", @"Bikerman", @"Dolt", @"Priest",@"Famer" ,@"Steve" @"Jim",@"Flipper", @"Uki", @"Wadupp", @"Flatfoot", @"Archer", @"Lame", @"Gripper", @"Hondo",@"Bird" ,@"Trippy", @"Master",@"Gordy", @"Placard", @"Skyman", @"DDer", @"Sam", @"Collin", @"Pete", @"Fish",@"Walker" ,@"Aman", @"Yve",@"Norten", @"Tippy", @"Bubba", @"Fasta", @"Kip", @"Tim", @"Fryman", @"Ortho",@"Doc" ,@"Bret", @"Loren",nil];
    
    femaleTeamNames = [NSMutableArray arrayWithObjects:@"Sue", @"Bambi", @"Tabatha", @"Samantha", @"Anne", @"Powergrrl", @"Cindy", @"Lori",@"Bitty" ,@"Ginger" @"MsTrouble",@"GadGirl", @"Michelle", @"Sara", @"Breaker", @"Huckgirl", @"Uma", @"Tami", @"Sally",nil];
    
    tournamentNames = [NSMutableArray arrayWithObjects:@"Trouble in Tupelo", @"Minnetourney", @"Disc Fest", @"Fast Times", @"Hammer Bowl", nil];
    
    oppponentNames = [NSMutableArray arrayWithObjects:@"Discites", @"Johnny Quest", @"Bad Boys", @"Beaux Bros", @"Fastidians", @"Fire Hose", @"Top Flight", @"Glam",@"Hucksters" ,@"Busta" @"Darwinians",@"Spark", @"Aliens", @"Gamma Rays", @"Hot House", @"Rooters",@"Discites", @"Johnny Quest", @"Bad Boys", @"Beaux Bros", @"Fastidians", @"Fire Hose", @"Top Flight", @"Glam",@"Hucksters" ,@"Busta" @"Darwinians",@"Spark", @"Aliens", @"Gamma Rays", @"Hot House", @"Rooters", nil];

    tournamenLookup = [[NSMutableDictionary alloc] init];
    playerNameLookup = [[NSMutableDictionary alloc] init];
    usedPlayerNames = [[NSMutableSet alloc] init];
}


@end
