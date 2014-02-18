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
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.backgroundColor = [UIColor whiteColor];
    [self.layer setCornerRadius:3.0f];
}


@end
