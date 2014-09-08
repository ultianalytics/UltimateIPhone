//
//  GameDiscView.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 9/8/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "GameDiscView.h"

@interface GameDiscView()

@end

@implementation GameDiscView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.discColor = [UIColor whiteColor];  // default disc color
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetFillColorWithColor(context, self.discColor.CGColor);
    CGContextAddEllipseInRect(context, self.bounds);
    CGContextFillPath(context);

    CGContextRestoreGState(context);
}

@end
