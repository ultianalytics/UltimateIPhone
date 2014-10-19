//
//  DimensionView.m
//  InstrumentsTest
//
//  Created by Jim Geppert on 10/16/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "DimensionView.h"
#import "UIView+Convenience.h"

#define kButtonMargin 2.0f
#define kEndMarksMargin 2.0f

@interface DimensionView ()

@property (nonatomic, strong) UIButton* dimensionButton;
@property (nonatomic) CGPoint lineBeginPoint;
@property (nonatomic) CGPoint lineEndPoint;
@property (nonatomic, weak) id tapHandler;
@property (nonatomic) SEL tapHandlerSelector;


@end

@implementation DimensionView


- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    self.lineColor = [UIColor blackColor];
    self.changeEnabledTextColor = [UIColor blackColor];
    [self configureButton];
}

-(void)awakeFromNib {
    [self commonInit];
}

-(void)layoutSubviews {
    self.dimensionButton.backgroundColor = self.superview.backgroundColor;
    [self calculateLinePoints];
    [self layoutButton];
}

-(void)configureButton {
    self.dimensionButton = [[UIButton alloc] init];
    [self.dimensionButton setTitleColor:self.lineColor forState:UIControlStateNormal];
    self.dimensionButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.dimensionButton addTarget:self action:@selector(handleButtonTap) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.dimensionButton];
}

-(void)layoutButton {
    [self.dimensionButton sizeToFit];
    self.dimensionButton.frameWidth =  self.dimensionButton.frameWidth  + (kButtonMargin * 2);
    self.dimensionButton.center = self.boundsCenter;
    self.dimensionButton.frame = CGRectIntegral(self.dimensionButton.frame);
    [self.dimensionButton setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // line properties
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    CGContextSetFillColorWithColor(context, self.lineColor.CGColor);
    CGContextSetLineWidth(context, 1);
    
    // draw the line
    CGFloat dashAndSpaceLengths[] = {2,3};
    CGContextSetLineDash(context, 0, dashAndSpaceLengths, 2);
    CGContextMoveToPoint(context, self.lineBeginPoint.x, self.lineBeginPoint.y);
    CGContextAddLineToPoint(context, self.lineEndPoint.x, self.lineEndPoint.y);
    CGContextStrokePath(context);
    CGContextSetLineDash(context, 0, NULL, 0);
    
    // end marks
    if (self.includeEndMarks) {
        if (self.orientation == DimensionViewOrientationHorizontal) {
            CGContextMoveToPoint(context, self.boundsX, self.boundsY + kEndMarksMargin);
            CGContextAddLineToPoint(context, self.boundsX, self.boundsY + self.boundsHeight - (kEndMarksMargin * 2));
            CGContextStrokePath(context);
            
            CGContextMoveToPoint(context, self.boundsX + self.boundsWidth, self.boundsY + kEndMarksMargin);
            CGContextAddLineToPoint(context, self.boundsX  + self.boundsWidth, self.boundsY + self.boundsHeight - (kEndMarksMargin * 2));
            CGContextStrokePath(context);
        } else {
            CGContextMoveToPoint(context, self.boundsX + kEndMarksMargin, self.boundsY);
            CGContextAddLineToPoint(context, self.boundsX + self.boundsWidth - (kEndMarksMargin * 2), self.boundsY);
            CGContextStrokePath(context);
            
            CGContextMoveToPoint(context, self.boundsX + kEndMarksMargin, self.boundsY + self.boundsHeight);
            CGContextAddLineToPoint(context, self.boundsX + self.boundsWidth - (kEndMarksMargin * 2) , self.boundsY + self.boundsHeight);
            CGContextStrokePath(context);
        }
    }
    
    CGContextRestoreGState(context);
    
}

-(void)calculateLinePoints {
    if (self.orientation == DimensionViewOrientationHorizontal) {
        CGFloat y = roundf(self.boundsHeight / 2);
        self.lineBeginPoint = CGPointMake(self.boundsX, y);
        self.lineEndPoint = CGPointMake(self.boundsWidth, y);
    } else {
        CGFloat x = roundf(self.boundsWidth / 2);
        self.lineBeginPoint = CGPointMake(x, self.boundsY);
        self.lineEndPoint = CGPointMake(x, self.boundsHeight);
    }
}

-(void)setDistanceDescription:(NSString *)distanceDescription {
    _distanceDescription = distanceDescription;
    [self.dimensionButton setTitle:distanceDescription forState:UIControlStateNormal];
}

-(void)setTapHandler:(id) handler selector:(SEL) handlerSelector {
    self.tapHandler = handler;
    self.tapHandlerSelector = handlerSelector;
}

-(void)handleButtonTap {
    if (self.tapHandler && self.changedEnabled) {
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.tapHandler performSelector:self.tapHandlerSelector withObject:self];
    }
}

-(void)setChangedEnabled:(BOOL)changedEnabled {
    _changedEnabled = changedEnabled;
    UIColor* textColor = changedEnabled ? self.changeEnabledTextColor : self.lineColor;
    self.dimensionButton.titleLabel.font = changedEnabled ? [UIFont boldSystemFontOfSize:16] : [UIFont systemFontOfSize:16];
    [self.dimensionButton setTitleColor:textColor forState:UIControlStateNormal];
}


@end



