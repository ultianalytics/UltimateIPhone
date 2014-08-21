//
//  GameTableViewCell.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/13/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameTableViewCell : UITableViewCell


@property (nonatomic, weak) IBOutlet UILabel* opponentLabel;
@property (nonatomic, weak) IBOutlet UILabel* gameInfoLabel;
@property (nonatomic, weak) IBOutlet UILabel* scoreLabel;

@end
