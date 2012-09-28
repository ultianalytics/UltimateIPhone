//
//  LeagueVineSelectorGameViewController.m
//  UltimateIPhone
//
//  Created by james on 9/16/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeagueVineSelectorGameViewController.h"
#import "ColorMaster.h"
#import "LeaguevineSeason.h"
#import "LeaguevineTournament.h"
#import "LeaguevineTeam.h"
#import "LeaguevineClient.h"

@interface LeagueVineSelectorGameViewController ()

@end

@implementation LeagueVineSelectorGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title =  @"Leaguevine Game";
    }
    return self;
}

#pragma mark Client interaction

-(void)refreshItems {
    if (self.tournament) {
        [self.leaguevineClient retrieveGamesForTeam:self.myTeam.itemId andTournament:self.tournament.itemId completion:^(LeaguevineInvokeStatus status, id result) {
            [self refreshItems:status result:result];
        }];
    } else {
        [self.leaguevineClient retrieveGamesForTeam:self.myTeam.itemId completion:^(LeaguevineInvokeStatus status, id result) {
            [self refreshItems:status result:result];
        }];
    }
}

-(NSString*)getNoResultsText {
    return @"No games found";
}

@end
