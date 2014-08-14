//
//  GameUploadPickerTableViewCell.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/14/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameUploadPickerTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView* checkedImageView;
@property (strong, nonatomic) IBOutlet UILabel* opponentLabel;
@property (strong, nonatomic) IBOutlet UILabel* otherInfoLabel;

@end
