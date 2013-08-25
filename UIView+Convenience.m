//
//  UIView+Convenience.m
//  UltimateIPhone
//
//  Created by james on 10/16/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "UIView+Convenience.h"

@implementation UIView (Convenience)
@dynamic frameX, frameY, frameHeight, frameWidth, visible;

-(void)setFrameX: (CGFloat) x {
    CGRect rect = self.frame;
    rect.origin.x = x;
    self.frame = rect;
}

-(CGFloat)frameX {
    return self.frame.origin.x;
}

-(void)setFrameY: (CGFloat) y {
    CGRect rect = self.frame;
    rect.origin.y = y;
    self.frame = rect;
}

-(CGFloat)frameY {
    return self.frame.origin.y;
}

-(void)setFrameWidth: (CGFloat) width {
    CGRect rect = self.frame;
    rect.size.width = width;
    self.frame = rect;
}

-(CGFloat)frameWidth {
    return self.frame.size.width;
}

-(void)setFrameHeight: (CGFloat) height {
    CGRect rect = self.frame;
    rect.size.height = height;
    self.frame = rect;
}

-(CGFloat)frameHeight {
    return self.frame.size.height;
}

-(BOOL)visible {
    return !self.hidden;
}

-(void)setVisible:(BOOL)visbile {
    self.hidden = !visbile;
}

@end
