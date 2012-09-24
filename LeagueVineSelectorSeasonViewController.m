//
//  LeagueVineSelectorSeasonViewController.m
//  UltimateIPhone
//
//  Created by james on 9/16/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "LeagueVineSelectorSeasonViewController.h"
#import "ColorMaster.h"
#import "LeaguevineLeague.h"
#import "LeaguevineClient.h"

@interface LeagueVineSelectorSeasonViewController ()

@end

@implementation LeagueVineSelectorSeasonViewController

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
    [self.leaguevineClient retrieveSeasonsForLeague:self.league.itemId completion:^(LeaguevineInvokeStatus status, id result)  {
        [self refreshItems:status result:result];
    }];
}

-(NSString*)getNoResultsText {
    return @"No seasons found for this league";
}

@end
