//
//  LeagueVineSelectorTournamentViewController.h
//  UltimateIPhone
//
//  Created by james on 9/16/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeaguevineSelectorAbstractViewController.h"
@class LeaguevineClient;
@class LeaguevineSeason;

@interface LeagueVineSelectorTournamentViewController : LeaguevineSelectorAbstractViewController

@property (nonatomic, strong) LeaguevineSeason* season; 

@end
