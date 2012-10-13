//
//  PlayerSelectionTableViewCell.h
//  UltimateIPhone
//
//  Created by james on 10/11/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Player;

@interface PlayerSelectionTableViewCell : UITableViewCell

@property (strong, nonatomic) Player* player;
@property (nonatomic) BOOL chosen;

@end
