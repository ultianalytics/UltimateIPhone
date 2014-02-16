//
//  GameActionButton.m
//  UltimateIPhone
//
//  Created by james on 2/15/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "GameActionButton.h"
#import "ColorMaster.h"
#import "ImageMaster.h"

@implementation GameActionButton

-(void)awakeFromNib {
    [self setBackgroundImage:[ImageMaster stretchableWhite100Radius3] forState:UIControlStateNormal];
    [self setBackgroundImage:[ImageMaster stretchableWhite200Radius3] forState:UIControlStateSelected];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    self.backgroundColor = [UIColor whiteColor];
}


@end
