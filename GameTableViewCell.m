//
//  GameTableViewCell.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/13/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "GameTableViewCell.h"

@implementation GameTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
