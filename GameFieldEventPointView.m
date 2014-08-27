//
//  GameFieldEventPointView.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/23/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "GameFieldEventPointView.h"
#import "UIView+Convenience.h"
#import "ColorMaster.h"

#define kNonEmphasizedPositionInset 4
#define kEmphasizedPositionInnerCircleInset 8

@interface GameFieldEventPointView()

@end

@implementation GameFieldEventPointView

#pragma mark - Initialization

-(void)commonInit {
    [self addTapRecognizer];
    self.backgroundColor = [UIColor clearColor];
}

-(void)addTapRecognizer {
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self addGestureRecognizer: tapRecognizer];
}

#pragma mark - Touch handling

- (void)viewTapped:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint tapPoint = [gestureRecognizer locationInView:self];
    // taps are not managed by event view...forward to the parent
    if (self.tappedBlock) {
        self.tappedBlock(tapPoint, self);
    }
}

#pragma mark - UIView overrides

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void)awakeFromNib {
    [self commonInit];
}


- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // draw the dot
    CGFloat origin = self.isEmphasizedEvent ? 0 : kNonEmphasizedPositionInset;
    CGFloat diameter = self.isEmphasizedEvent ? self.boundsWidth : self.boundsWidth - kNonEmphasizedPositionInset * 2;
    CGContextSetFillColorWithColor(context, [self dotColor].CGColor);
    CGContextAddEllipseInRect(context, CGRectMake(origin,origin, diameter, diameter));
    CGContextFillPath(context);
    
    // if emphasized draw an inner dot
    if (self.isEmphasizedEvent) {
        CGFloat origin = kEmphasizedPositionInnerCircleInset;
        CGFloat diameter = self.boundsWidth - kEmphasizedPositionInnerCircleInset * 2;
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextAddEllipseInRect(context, CGRectMake(origin,origin, diameter, diameter));
        CGContextFillPath(context);
    }
    
    CGContextRestoreGState(context);
}

#pragma mark - Misc

-(void)setIsOurEvent:(BOOL)isOurEvent {
    _isOurEvent = isOurEvent;
    [self setNeedsDisplay];
}

-(void)setIsEmphasizedEvent:(BOOL)isEmphasizedEvent {
    _isEmphasizedEvent = isEmphasizedEvent;
    [self setNeedsDisplay];
}

-(UIColor*)dotColor {
    return self.isOurEvent ? [ColorMaster applicationTintColor] : [UIColor redColor];
}



@end
