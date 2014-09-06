//
//  UIView+Convenience.m
//  UltimateIPhone
//
//  Created by james on 10/16/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "UIView+Convenience.h"

@implementation UIView (Convenience)
@dynamic frameX, frameY, frameHeight, frameWidth, boundsX, boundsY, boundsHeight, boundsWidth, visible;

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

- (CGFloat)frameRight {
	return self.frameX + self.frameWidth;
}

- (void)setFrameRight:(CGFloat)newRight {
	CGRect rect = self.frame;
	rect.origin.x = newRight - rect.size.width;
	self.frame = rect;
}

- (CGFloat)frameBottom {
	return self.frameY + self.frameHeight;
}

- (void)setFrameBottom:(CGFloat)newBottom {
	self.frameY = newBottom - self.frameHeight;
}

-(void)setBoundsX: (CGFloat) x {
    CGRect rect = self.bounds;
    rect.origin.x = x;
    self.bounds = rect;
}

-(CGFloat)boundsX {
    return self.bounds.origin.x;
}

-(void)setBoundsY: (CGFloat) y {
    CGRect rect = self.bounds;
    rect.origin.y = y;
    self.bounds = rect;
}

-(CGFloat)boundsY {
    return self.bounds.origin.y;
}

-(void)setBoundsWidth: (CGFloat) width {
    CGRect rect = self.bounds;
    rect.size.width = width;
    self.bounds = rect;
}

-(CGFloat)boundsWidth {
    return self.bounds.size.width;
}

-(void)setBoundsHeight: (CGFloat) height {
    CGRect rect = self.bounds;
    rect.size.height = height;
    self.bounds = rect;
}

-(CGFloat)boundsHeight {
    return self.bounds.size.height;
}

-(CGPoint)boundsCenter {
    return CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

-(BOOL)visible {
    return !self.hidden;
}

-(void)setVisible:(BOOL)visbile {
    self.hidden = !visbile;
}

-(CGFloat)distanceBetweenPoint: (CGPoint)p1 andPoint:(CGPoint)p2 {
    CGFloat xDistance = (p2.x - p1.x);
    CGFloat yDistance = (p2.y - p1.y);
    return sqrt((xDistance * xDistance) + (yDistance * yDistance));
}

@end
