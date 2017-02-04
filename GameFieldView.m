//
//  GameFieldView.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/22/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "GameFieldView.h"
#import "UIView+Convenience.h"
#import "EventPosition.h"
#import "GameFieldEventPointView.h"
#import "Event.h"
#import "Game.h"
#import "ColorMaster.h"
#import "FieldDimensions.h"

#define kBrickMarkRadius 3.0f

@interface GameFieldView ()

@property (nonatomic) CGRect totalFieldRect;
@property (nonatomic) CGRect fieldRect;
@property (nonatomic) CGRect endzone0Rect;
@property (nonatomic) CGRect endzone100Rect;
@property (nonatomic) CGRect brickMark0Rect;
@property (nonatomic) CGRect brickMark100Rect;

@property (nonatomic, strong) UILabel* messageLabel;

@end

@implementation GameFieldView

#pragma mark - Initialization

-(void)commonInit {
    [self initFieldDefaults];
    [self addMessageView];
    [self.layer setNeedsDisplay];
}

-(void)initFieldDefaults {
    self.endzonePercent = .15; // default endzone percent
    self.fieldBorderColor = [UIColor whiteColor];  // default border color
    self.endzone0BorderColor = [UIColor whiteColor];  // default endzone 0 border color
    self.endzone100BorderColor = [UIColor whiteColor];  // default endzone 100 border color
    self.discColor = [UIColor whiteColor]; // color of the frisbee
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
    [super awakeFromNib];
    [self commonInit];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self calculateFieldRectangles];
    if (self.message) {
        self.messageLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
    [self.layer setNeedsDisplay];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
    // draw the primary layer for the view
    [super drawLayer:layer inContext:context];
    CGFloat lineWidth = 2;
    
    CGContextSaveGState(context);
    
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetLineCap(context, kCGLineCapSquare);
    
    // draw endzone 0 line
    CGContextSetStrokeColorWithColor(context, self.endzone0BorderColor.CGColor);
    CGFloat x = CGRectGetMaxX(self.endzone0Rect);
    CGContextMoveToPoint(context, x, self.endzone0Rect.origin.y);
    CGContextAddLineToPoint(context, x, CGRectGetMaxY(self.endzone0Rect));
    CGContextStrokePath(context);
    
    // draw endzone 100 line
    CGContextSetStrokeColorWithColor(context, self.endzone100BorderColor.CGColor);
    x = self.endzone100Rect.origin.x;
    CGContextMoveToPoint(context, x, self.endzone100Rect.origin.y);
    CGContextAddLineToPoint(context, x, CGRectGetMaxY(self.endzone100Rect));
    CGContextStrokePath(context);
    
    // draw the total field boundaries
    CGContextSetStrokeColorWithColor(context, self.fieldBorderColor.CGColor);
    CGFloat borderLineInset = lineWidth - 1;  // stay inside the bounds
    CGRect rect = self.totalFieldRect;
    CGContextMoveToPoint(context, rect.origin.x + borderLineInset, rect.origin.y + borderLineInset);
    CGContextAddLineToPoint(context, rect.origin.x  + borderLineInset, rect.size.height - borderLineInset);
    CGContextAddLineToPoint(context, rect.size.width - borderLineInset, rect.size.height - borderLineInset);
    CGContextAddLineToPoint(context, rect.size.width - borderLineInset, rect.origin.y  + borderLineInset);
    CGContextAddLineToPoint(context, rect.origin.x + borderLineInset, rect.origin.y  + borderLineInset);
    CGContextStrokePath(context);
    
    // draw the brick marks
    if (self.fieldDimensions) {
        [self drawXAt:self.brickMark0Rect onContext:context];
        [self drawXAt:self.brickMark100Rect onContext:context];
    }
    
    CGContextRestoreGState(context);

}

-(void)drawXAt: (CGRect) rect onContext: (CGContextRef) context {
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    CGContextStrokePath(context);
    CGContextMoveToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
    CGContextStrokePath(context);
}

#pragma mark - Point/Position calculations 

-(void)calculateFieldRectangles {
    CGRect totalField = CGRectIntegral(self.bounds);
    CGFloat endzoneWidth = ceilf(self.endzonePercent * totalField.size.width);
    self.endzone0Rect = CGRectMake(0, 0, endzoneWidth, ceilf(totalField.size.height));
    self.endzone100Rect = CGRectMake(totalField.size.width-endzoneWidth, 0, endzoneWidth, ceilf(totalField.size.height));
    self.fieldRect = CGRectMake(self.endzone0Rect.size.width, 0, self.endzone100Rect.origin.x - CGRectGetMaxX(self.endzone0Rect), ceilf(totalField.size.height));
    self.totalFieldRect = totalField;
    
    // brick marks
    CGFloat centralZoneScale = self.fieldRect.size.width / self.fieldDimensions.centralZoneLength;
    CGFloat brickMarkToEndzone = floorf(self.fieldDimensions.brickMarkDistance * centralZoneScale);
    self.brickMark0Rect = CGRectMakeIntegral(CGRectGetMaxX(self.endzone0Rect) + brickMarkToEndzone - kBrickMarkRadius, CGRectGetMidY(self.fieldRect) - kBrickMarkRadius, kBrickMarkRadius * 2, kBrickMarkRadius * 2);
    self.brickMark100Rect = CGRectMakeIntegral(CGRectGetMinX(self.endzone100Rect) - brickMarkToEndzone - kBrickMarkRadius, CGRectGetMidY(self.fieldRect) - kBrickMarkRadius, kBrickMarkRadius * 2, kBrickMarkRadius * 2);
}

-(EventPosition*)calculatePosition: (CGPoint)point {
    EventPosition* position = nil;
    if (CGRectContainsPoint(self.fieldRect, point)) {
        position = [self calculatePosition:point inRect:self.fieldRect area:EventPositionAreaField];
    } else if (CGRectContainsPoint(self.endzone0Rect, point)) {
        position = [self calculatePosition:point inRect:self.endzone0Rect area:EventPositionArea0Endzone];
    } else if (CGRectContainsPoint(self.endzone100Rect, point)) {
        position = [self calculatePosition:point inRect:self.endzone100Rect area:EventPositionArea100Endzone];
    }
    return position;
}

-(EventPosition*)calculatePosition: (CGPoint)point inRect: (CGRect)rect area: (EventPositionArea)area {
    CGFloat x = (point.x - rect.origin.x) / rect.size.width;
    CGFloat y = point.y / rect.size.height;
    return [EventPosition positionInArea:area x:x y:y inverted:self.inverted];
}

-(CGPoint)calculatePoint: (EventPosition*)position {
    BOOL flipNeeded = position.inverted != self.inverted;
    EventPositionArea area = position.area;
    CGFloat positionX = position.x;
    CGFloat positionY = position.y;
    if (flipNeeded) {
        // switch endzones
        switch (position.area) {
            case EventPositionArea0Endzone :
                area = EventPositionArea100Endzone;
                break;
            case EventPositionArea100Endzone :
                area = EventPositionArea0Endzone;
                break;
            default:
                area = EventPositionAreaField;
                break;
        }
        // flip x and y
        positionX = 1 - positionX;
        positionY = 1 - positionY;
    }
    CGFloat y = roundf(positionY * self.fieldRect.size.height);
    CGPoint point = CGPointMake(0, 0);;
    if (area == EventPositionAreaField) {
        CGFloat x = roundf(CGRectGetMaxX(self.endzone0Rect) + (self.fieldRect.size.width * positionX));
        point = CGPointMake(x, y);
    } else if (area == EventPositionArea0Endzone) {
        CGFloat x = roundf(self.endzone0Rect.size.width * positionX);
        point = CGPointMake(x, y);
    } else if (area == EventPositionArea100Endzone) {
        CGFloat x = CGRectGetMaxX(self.fieldRect) + (self.endzone100Rect.size.width * positionX);
        point = CGPointMake(x, y);
    }
    return point;
}

-(void)updatePointViewLocation: (GameFieldEventPointView*)pointView toPosition: (EventPosition*)eventPosition {
    pointView.center = [self calculatePoint:eventPosition];
}

#pragma mark - Message

-(void)addMessageView {
    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 300)];
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    self.messageLabel.textColor = [UIColor whiteColor];
    self.messageLabel.hidden = YES;
    [self addSubview:self.messageLabel];
}

-(void)setMessage:(NSAttributedString *)message {
    _message = message;
    self.messageLabel.attributedText = message;
    self.messageLabel.hidden = message ? NO : YES;
    [self setNeedsLayout];
}


#pragma mark - Misc.

-(BOOL)isOurEvent:(Event*) event {
    if ([event isPull] || [event isOpponentPull] || [event isPullBegin]) {
        return [event isDefense];
    } else {
        return [event isOffense];
    }
}

-(void)setEndzone0BorderColor:(UIColor *)endzone0BorderColor {
    _endzone0BorderColor = endzone0BorderColor;
    [self.layer setNeedsDisplay];
}

-(void)setEndzone100BorderColor:(UIColor *)endzone100BorderColor {
    _endzone100BorderColor = endzone100BorderColor;
   [self.layer setNeedsDisplay];
}

@end
