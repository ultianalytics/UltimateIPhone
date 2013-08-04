//
//  RedButton.m
//  Numbers
//
//  Created by james on 8/22/11.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "RedButton.h"
#import "ColorMaster.h"


@implementation RedButton

-(void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor redColor];
}

@end
