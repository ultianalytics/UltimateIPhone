//
//  LeagueVineSelectorTeamViewController.m
//  UltimateIPhone
//
//  Created by james on 9/16/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeagueVineSelectorTeamViewController.h"
#import "ColorMaster.h"
#import "LeaguevineSeason.h"
#import "LeaguevineClient.h"

@interface LeagueVineSelectorTeamViewController ()

@end

@implementation LeagueVineSelectorTeamViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title =  @"Leaguevine League";
    }
    return self;
}

#pragma mark Client interaction

-(void)refreshItems {
    [self.leaguevineClient retrieveTeamsForSeason:self.season.itemId completion:^(LeaguevineInvokeStatus status, id result) {
        [self refreshItems:status result:result];
    }];
}

@end
