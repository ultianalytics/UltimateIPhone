//
//  UltimateSwitch.m
//  UltimateIPhone
//
//  Created by james on 10/4/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "UltimateSwitch.h"
#import "ColorMaster.h"

@implementation UltimateSwitch

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self commonInit];
    return self;
}

-(void)awakeFromNib {
    [self commonInit];
}

-(void)commonInit {
    self.onTintColor = [ColorMaster getSegmentControlDarkTintColor];
}

@end
