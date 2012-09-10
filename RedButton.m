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
    self.buttonStyleNormalTextColor = [UIColor whiteColor];
    self.buttonStyleHighlightTextColor = [UIColor blackColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize: 16];
}

@end
