//
//  LightButton.m
//  UltimateIPhone
//
//  Created by james on 7/19/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "LightButton.h"
#import "ColorMaster.h"

@implementation LightButton

-(void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor blackColor];
}

@end
