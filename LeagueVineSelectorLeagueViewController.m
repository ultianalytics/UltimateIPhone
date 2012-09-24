//
//  LeagueVineSelectorLeagueViewController.m
//  UltimateIPhone
//
//  Created by james on 9/16/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeagueVineSelectorLeagueViewController.h"
#import "ColorMaster.h"
#import "LeaguevineLeague.h"
#import "LeaguevineClient.h"

@interface LeagueVineSelectorLeagueViewController ()

@end

@implementation LeagueVineSelectorLeagueViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title =  @"Leaguevine League";
    }
    return self;
}

#pragma mark Client interaction

-(void)refreshItems {
    [self.leaguevineClient retrieveLeagues:^(LeaguevineInvokeStatus status, id result) {
        [self refreshItems:status result:result];
    }];
}

@end
