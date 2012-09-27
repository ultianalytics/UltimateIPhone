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

@interface LeagueVineSelectorGameViewController : LeaguevineSelectorAbstractViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) LeaguevineSeason* season; // required
@property (nonatomic, strong) LeaguevineTournament* tournament; // optional

@end
