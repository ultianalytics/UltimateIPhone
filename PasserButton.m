//
//  PasserButton.m
//
//  Created by james on 8/22/11.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "PasserButton.h"

@implementation PasserButton

-(void)setIsLabelStyle:(BOOL)shouldBeLabelStyle {
    _isLabelStyle = shouldBeLabelStyle;
    [self setNeedsLayout];
}

-(void)setIsCurrentPasser:(BOOL)isCurrentPasser {
    _isCurrentPasser = isCurrentPasser;
   [self setNeedsLayout];
}

-(void)layoutSubviews {
    [super layoutSubviews];
// displaying as a label always
//    if (self.isLabelStyle) {
        self.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = self.isCurrentPasser ? uirgb(134, 134, 134) : [UIColor blackColor];
//    }
}

- (NSString* )description {
    return [NSString stringWithFormat:@"PasserButton for player %@", self.titleLabel];
}

@end
