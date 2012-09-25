//
//  LeagueVineTeamViewController.h
//  UltimateIPhone
//
//  Created by james on 9/16/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Team;
@class LeaguevineTeam;

@interface LeagueVineTeamViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) Team* team;
@property (strong, nonatomic) void (^selectedBlock)(LeaguevineTeam* item);

@end
