//
//  StandardButton.m
//  Ultimate
//
//  Created by Jim Geppert on 2/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StandardButton.h"
#import "ColorMaster.h"

@implementation StandardButton

- (void)initCharacteristics {
    [self setSelected: NO];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    self.titleLabel.font = [UIFont boldSystemFontOfSize: 16];
}

- (void) setSelected: (BOOL) shouldBeSelected {
    if (shouldBeSelected) {
        self.highColor = [ColorMaster getPasserButtonSelectedHighColor];  
        self.lowColor = [ColorMaster getPasserButtonSelectedLowColor];
    } else {
        self.highColor = [ColorMaster getPasserButtonHighColor];
        self.lowColor = [ColorMaster getPasserButtonLowColor];
    }
    self.borderColor = self.highColor;
    [self setNeedsDisplay];
}

- (NSString* )description {
    return [NSString stringWithFormat:@"StandardButton: %@", self.titleLabel];
}

@end
