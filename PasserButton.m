//
//  PasserButton.m
//
//  Created by james on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PasserButton.h"
#import <QuartzCore/QuartzCore.h>
#import "ColorMaster.h"

@implementation PasserButton

- (void)initCharacteristics {
    [self setSelected: YES];
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
    return [NSString stringWithFormat:@"PasserButton for player %@", self.titleLabel];
}

@end
