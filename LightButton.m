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

- (void)initCharacteristics {
    self.highColor = [UIColor whiteColor];
    self.lowColor = [UIColor whiteColor];
    self.borderColor = self.lowColor;
    self.borderDisabledColor = self.lowDisabledColor;
    self.buttonStyleNormalTextColor = [UIColor blackColor];
    self.buttonStyleHighlightTextColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize: 16];
}

-(NSArray*)getGradientLocations {
    return [NSArray arrayWithObjects: [NSNumber numberWithFloat: .1], [NSNumber numberWithFloat: .5], nil];
}

@end
