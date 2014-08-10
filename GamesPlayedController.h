//
//  GamesPlayedController.h
//  Ultimate
//
//  Created by Jim Geppert on 2/10/12.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "UltimateViewController.h"
#import "GameDetailViewController.h"

@interface GamesPlayedController : UltimateViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) GameDetailViewController* detailController; // only used in iPad

@property (nonatomic, strong) NSArray* gameDescriptions;
@property (nonatomic, strong) IBOutlet UITableView* gamesTableView;

-(void)retrieveGameDescriptions;
-(void)goToAddGame;

@end
