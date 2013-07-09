//
//  LeagueVineSelectorGameViewController.h
//  UltimateIPhone
//
//  Created by james on 9/16/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeaguevineSelectorAbstractViewController.h"
@class LeaguevineSeason;
@class LeaguevineTournament;
@class LeaguevineTeam;

@interface LeagueVineSelectorGameViewController : LeaguevineSelectorAbstractViewController

@property (nonatomic, strong) LeaguevineSeason* season; // required
@property (nonatomic, strong) LeaguevineTeam* myTeam; // required
@property (nonatomic, strong) LeaguevineTournament* tournament; // optional
@end

