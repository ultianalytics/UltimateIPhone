//
//  PlayerDetailsViewController.h
//  Ultimate
//
//  Created by james on 1/21/12.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UltimateViewController.h"

@class Player;
@class UltimateSegmentedControl;

@interface PlayerDetailsViewController : UltimateViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    NSArray* cells;
}

@property (nonatomic, strong) Player* player;
@property (strong, nonatomic) void (^playerChangedBlock)(Player* player);
@property (nonatomic) BOOL isModalAddMode;

@end
