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

-(void)commonInit {
    [super commonInit];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.backgroundColor = [UIColor redColor];
}

@end
