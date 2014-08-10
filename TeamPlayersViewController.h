//
//  TeamPlayersViewController.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 4/5/12.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UltimateViewController.h"
#import "PlayerDetailsViewController.h"

@interface TeamPlayersViewController : UltimateViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) PlayerDetailsViewController* detailController; // only used in iPad

-(void)goToAddItem;

@end


