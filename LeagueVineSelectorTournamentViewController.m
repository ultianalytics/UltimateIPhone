//
//  LeagueVineSelectorTournamentViewController.m
//  UltimateIPhone
//
//  Created by james on 9/16/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeagueVineSelectorTournamentViewController.h"
#import "ColorMaster.h"
#import "LeaguevineSeason.h"
#import "LeaguevineClient.h"

@interface LeagueVineSelectorTournamentViewController ()

@end

@implementation LeagueVineSelectorTournamentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title =  @"Leaguevine Tournament";
    }
    return self;
}

#pragma mark Client interaction

-(void)refreshItems {
    [self.leaguevineClient retrieveTouramentsForSeason:self.season.itemId completion:^(LeaguevineInvokeStatus status, id result) {
        [self refreshItems:status result:result];
    }];
}

-(NSString*)getNoResultsText {
    return @"No tournaments found";
}

@end
