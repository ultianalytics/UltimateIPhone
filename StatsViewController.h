//
//  StatsViewController.h
//  Ultimate
//
//  Created by Jim Geppert on 2/25/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UltimateViewController.h"
@class UltimateSegmentedControl;
@class Game;

@interface StatsViewController : UltimateViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView* statTypeTableView;
@property (nonatomic, strong) IBOutlet UITableView* playerStatsTableView;
@property (strong, nonatomic) IBOutlet UltimateSegmentedControl *statsScopeSegmentedControl;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSArray* statTypes;
@property (nonatomic, strong) NSArray* playerStats;
@property (nonatomic, strong) Game* game;
@property (nonatomic, strong) NSString* currentStat;

- (IBAction)statsScopeChanged:(id)sender;

-(void)initalizeStatTypes;
-(void)updatePlayerStats;

@end
