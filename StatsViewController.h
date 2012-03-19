//
//  StatsViewController.h
//  Ultimate
//
//  Created by Jim Geppert on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerStat.h"
#import "Game.h"

@interface StatsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView* statTypeTableView;
@property (nonatomic, strong) IBOutlet UITableView* playerStatsTableView;
@property (nonatomic, strong) NSArray* statTypes;
@property (nonatomic, strong) NSArray* playerStats;
@property (nonatomic, strong) Game* game;
@property (nonatomic, strong) NSString* currentStat;


-(void)initalizeStatTypes;
-(void)updatePlayerStats;

@end
