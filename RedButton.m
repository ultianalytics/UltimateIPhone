//
//  ColorButton.m
//  Numbers
//
//  Created by james on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RedButton.h"
#import "ColorMaster.h"


@implementation RedButton

- (void)initCharacteristics {
    self.highColor = [ColorMaster getAlarmingButtonHighColor];
    self.lowColor = [ColorMaster getAlarmingButtonLowColor];
    self.borderColor = self.highColor;
    self.borderDisabledColor = self.lowDisabledColor;
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    self.titleLabel.font = [UIFont boldSystemFontOfSize: 20];
}

@end
