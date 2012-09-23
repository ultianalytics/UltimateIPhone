//
//  LeagueVineTeamViewController.h
//  UltimateIPhone
//
//  Created by james on 9/16/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeaguevineTeam.h"
#import "LeaguevineSeason.h"
#import "LeaguevineLeague.h"

@interface LeagueVineTeamViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray* teams;
@property (nonatomic, strong) LeaguevineTeam* team;

@end
