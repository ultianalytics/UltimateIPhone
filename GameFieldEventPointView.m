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
#import "GameFieldEventTextView.h"
#import "NSString+manipulations.h"

#define kNonEmphasizedPositionInset 4
#define kEmphasizedPositionInnerCircleInset 8
#define kTextLabelTwoLineHeight 34
#define kTextLabelOneLineHeight 18
#define kTextLabelWidth 66

@interface GameFieldEventPointView()

@property (strong, nonatomic) GameFieldEventTextView* textView;
@property (nonatomic, strong) IBOutlet UILabel* outOfBoundLabel;

@end

@implementation GameFieldEventPointView

#pragma mark - Initialization

-(void)commonInit {
    [self addTapRecognizer];
    self.discColor = [UIColor whiteColor]; // default disc color
    self.backgroundColor = [UIColor clearColor];
    [self createTextView];
    [self createOutOfBoundsLabel];
}

-(void)createTextView {
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([GameFieldEventTextView class]) owner:nil options:nil];
    self.textView = (GameFieldEventTextView *)nibViews[0];
    self.textView.frame = CGRectMake(0, 0, kTextLabelWidth, kTextLabelTwoLineHeight);
    [self addSubview: self.textView];
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
    [super layoutSubviews];
  
    // layout text
    CGFloat textViewHeight = [self.textView.pointDescription contains:@"\n"] ? kTextLabelTwoLineHeight : kTextLabelOneLineHeight;
    self.textView.frameHeight = textViewHeight;    
    CGFloat textViewCenterOffset = self.boundsHeight / 2 + textViewHeight / 2;
    CGFloat textViewY = CGRectGetMidY(self.bounds) + ([self isBelowMidField] ? (-1 * textViewCenterOffset) : textViewCenterOffset);
    self.textView.center = CGPointMake(CGRectGetMidX(self.bounds), textViewY);
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
    
    // if emphasized draw an inner dot (represents the disc)
    if (self.isEmphasizedEvent && !self.discHidden) {
        CGFloat origin = (self.boundsWidth - self.discDiameter) / 2;
        CGFloat diameter = self.discDiameter;
        CGContextSetFillColorWithColor(context, self.discColor.CGColor);
        CGContextAddEllipseInRect(context, CGRectMake(origin,origin, diameter, diameter));
        CGContextFillPath(context);
    }
    
    CGContextRestoreGState(context);
}

#pragma mark - Out of Bounds message

-(void)createOutOfBoundsLabel {
    self.outOfBoundLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, kTextLabelWidth, kTextLabelTwoLineHeight)];
    self.outOfBoundLabel.numberOfLines = 2;
    self.outOfBoundLabel.textAlignment = NSTextAlignmentCenter;
    self.outOfBoundLabel.textColor = [UIColor whiteColor];
    self.outOfBoundLabel.font = [UIFont boldSystemFontOfSize:12];
    self.outOfBoundLabel.hidden = YES;
    self.outOfBoundLabel.text = @"Out of\nBounds";
    [self addSubview: self.outOfBoundLabel];
}

- (void)flashOutOfBoundsMessage {
    if (![self.event isPositionalBegin]) {
        CGFloat obLabelCenterOffset = self.boundsHeight / 2 + self.outOfBoundLabel.frameHeight / 2;
        CGFloat obLabelY = CGRectGetMidY(self.bounds) + ([self isBelowMidField] ? (-1 * obLabelCenterOffset) : obLabelCenterOffset);
        self.outOfBoundLabel.center = CGPointMake(CGRectGetMidX(self.bounds), obLabelY);
        
        self.textView.hidden = YES;
        self.outOfBoundLabel.hidden = NO;
        [self performSelector:@selector(animateHideOfBoundsLabel) withObject:self afterDelay:1];
    }
}

- (void)animateHideOfBoundsLabel {
    self.textView.alpha = 0;
    self.textView.hidden = NO;
    [UIView animateWithDuration:.5 animations:^{
        self.outOfBoundLabel.alpha = 0;
        self.textView.alpha = 1;
    } completion:^(BOOL finished) {
        self.outOfBoundLabel.hidden = YES;
        self.outOfBoundLabel.alpha = 1;
    }];
}

#pragma mark - Misc

-(void)setIsOurEvent:(BOOL)isOurEvent {
    _isOurEvent = isOurEvent;
    self.textView.textColor = [self dotColor];
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

-(void)setDiscHidden:(BOOL)discHidden {
    _discHidden = discHidden;
    [self setNeedsDisplay];
}

-(void)updateText {
    self.textView.pointDescription = [self.event positionalDescription];
    [self setNeedsLayout];
}

-(UIColor*)dotColor {
    return self.isOurEvent ? [ColorMaster applicationTintColor] : [UIColor redColor];
}

-(BOOL)isBelowMidField {
    return self.frameY > CGRectGetMidY(self.superview.bounds);
}

-(BOOL)isRightOfMidField {
    return self.frameX > CGRectGetMidX(self.superview.bounds);
}



@end
