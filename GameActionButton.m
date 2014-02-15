//
//  GameActionButton.m
//  UltimateIPhone
//
//  Created by james on 2/15/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "GameActionButton.h"
#import "ColorMaster.h"


@implementation GameActionButton

-(void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.backgroundColor = uirgb(51,51,51);
}


@end
