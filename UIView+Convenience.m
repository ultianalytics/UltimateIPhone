//
//  UIView+Convenience.m
//  UltimateIPhone
//
//  Created by james on 10/16/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "UIView+Convenience.h"

@implementation UIView (Convenience)
@dynamic frameX;

-(void)setFrameX: (CGFloat) x {
    CGRect rect = self.frame;
    rect.origin.x = x;
    self.frame = rect;
}

-(CGFloat)frameX {
    return self.frame.origin.x;
}

@end
