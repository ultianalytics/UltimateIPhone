//
//  GreyButton.m
//  Ultimate
//
//  Created by Jim Geppert on 2/26/12.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "GreyButton.h"
#import "ColorMaster.h"

@implementation GreyButton

-(void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.backgroundColor = uirgb(100,100,100);
}

@end
