//
//  DarkButton.m
//  UltimateIPhone
//
//  Created by james on 10/15/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "DarkButton.h"
#import "ColorMaster.h"

@implementation DarkButton

- (void)initCharacteristics {
    self.highColor = [UIColor darkGrayColor];
    self.lowColor = [UIColor blackColor];
    self.borderColor = self.highColor;
    self.borderDisabledColor = self.lowDisabledColor;
    self.buttonStyleNormalTextColor = [UIColor whiteColor];
    self.buttonStyleHighlightTextColor = [UIColor blackColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize: 16];
}

-(NSArray*)getGradientLocations {
    return [NSArray arrayWithObjects: [NSNumber numberWithFloat: .1], [NSNumber numberWithFloat: .5], nil];
}

@end
