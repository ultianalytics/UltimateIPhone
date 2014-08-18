//
//  GameHistoryTableViewCell.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/18/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "GameHistoryTableViewCell.h"

@implementation GameHistoryTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [self.contentView bringSubviewToFront: self.undoButton];
}

- (IBAction)undoButtonTapped:(id)sender {
    [self.delegate undoButtonTapped];
}

@end
