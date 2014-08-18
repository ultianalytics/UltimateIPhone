//
//  GameHistoryTableViewCell.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/18/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GameHistoryTableViewCellDelegate;

@protocol GameHistoryTableViewCellDelegate <NSObject>

-(void)undoButtonTapped;

@end

@interface GameHistoryTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIButton *undoButton;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) id<GameHistoryTableViewCellDelegate> delegate;

@end
