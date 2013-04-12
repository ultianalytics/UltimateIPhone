//
//  UILabel+Utilities.m
//  UltimateIPhone
//
//  Created by james on 4/12/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "UILabel+Utilities.h"

@implementation UILabel (Utilities)

-(void)styleAsWhiteShadowedLabelWithSize: (CGFloat) size {
    self.font = [UIFont boldSystemFontOfSize:size];
    self.textColor = [UIColor whiteColor];
    self.shadowColor = [UIColor blackColor];
    self.shadowOffset = CGSizeMake(0, 1);
}

@end
