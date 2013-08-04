//
//  StandardButton.m
//  Ultimate
//
//  Created by Jim Geppert on 2/26/12.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "StandardButton.h"
#import "ColorMaster.h"

@implementation StandardButton

-(void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor blackColor];
}

@end
