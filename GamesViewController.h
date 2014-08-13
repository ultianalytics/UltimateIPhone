//
//  GamesViewController.h
//  Ultimate
//
//  Created by Jim Geppert on 2/10/12.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "UltimateViewController.h"
#import "GameDetailViewController.h"

@interface GamesViewController : UltimateViewController <UITableViewDelegate, UITableViewDataSource>

// only used in iPad
@property (nonatomic, weak) UIViewController* topViewController;
@property (nonatomic, strong) GameDetailViewController* detailController;
@property (nonatomic, strong) void (^gamesChangedBlock)(); 

-(void)reset;

@end
