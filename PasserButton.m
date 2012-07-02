//
//  PasserButton.m
//
//  Created by james on 8/22/11.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "PasserButton.h"
#import <QuartzCore/QuartzCore.h>
#import "ColorMaster.h"

@implementation PasserButton

- (void)initCharacteristics {
    [super initCharacteristics];
    [self setSelected: YES];
    self.titleLabel.font = [UIFont boldSystemFontOfSize: 16];
}

- (void) setSelected: (BOOL) shouldBeSelected {
    if (!self.isLabelStyle) {
        if (shouldBeSelected) {
            self.highColor = [ColorMaster getPasserButtonSelectedHighColor];  
            self.lowColor = [ColorMaster getPasserButtonSelectedLowColor];
        } else {
            self.highColor = [ColorMaster getPasserButtonHighColor];
            self.lowColor = [ColorMaster getPasserButtonLowColor];
        }
        self.borderColor = self.highColor;
    }
    [super setSelected:shouldBeSelected];
    [self setNeedsDisplay];
}

- (NSString* )description {
    return [NSString stringWithFormat:@"PasserButton for player %@", self.titleLabel];
}

@end
