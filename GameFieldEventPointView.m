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
#define kTextLabelHeight 34

@interface GameFieldEventPointView()

@property (strong, nonatomic) UILabel* textLabel;

@end

@implementation GameFieldEventPointView

#pragma mark - Initialization

-(void)commonInit {
    [self addTapRecognizer];
    self.backgroundColor = [UIColor clearColor];
    [self createLabel];
}

-(void)createLabel {
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, kTextLabelHeight)];
    [self addSubview: self.textLabel];
    self.textLabel.font = [UIFont systemFontOfSize:12];
    self.textLabel.numberOfLines = 0;
    self.textLabel.textAlignment = NSTextAlignmentCenter;
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

-(void)layoutSubviews {
    CGFloat verticalCenter = self.boundsHeight + kTextLabelHeight / 2;
    CGFloat horizontalCenter = self.boundsWidth / 2;
    self.textLabel.center = CGPointMake(horizontalCenter, verticalCenter);
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
    self.textLabel.textColor = [self dotColor];
    [self setNeedsDisplay];
}

-(void)setIsEmphasizedEvent:(BOOL)isEmphasizedEvent {
    _isEmphasizedEvent = isEmphasizedEvent;
    [self setNeedsDisplay];
}

-(void)setEvent:(Event *)event {
    _event = event;
    [self updateText];
}

-(void)updateText {
    self.textLabel.text = [self.event positionalDescription];
}

-(UIColor*)dotColor {
    return self.isOurEvent ? [ColorMaster applicationTintColor] : [UIColor redColor];
}



@end
