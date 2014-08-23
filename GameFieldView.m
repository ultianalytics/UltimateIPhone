//
//  GameFieldView.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/22/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "GameFieldView.h"
#import "UIViewController+Additions.h"
#import "UIView+Convenience.h"
#import "EventPosition.h"

@interface GameFieldView ()

@property (nonatomic) CGRect totalFieldRect;
@property (nonatomic) CGRect fieldRect;
@property (nonatomic) CGRect endzone0Rect;
@property (nonatomic) CGRect endzone100Rect;

@property (nonatomic, strong) UIButton* lastSavedEventButton;
@property (nonatomic, strong) UIButton* previousSavedEventButton;

@end

@implementation GameFieldView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void)commonInit {
    self.fieldBorderColor = [UIColor whiteColor];  // default border color
    self.endzonePercent = .15; // default endzone percent
    [self.layer setNeedsDisplay];
}

#pragma mark - UIView overrides

-(void)awakeFromNib {
    [self commonInit];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self calculateFieldRectangles];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
    // draw the primary layer for the view
    [super drawLayer:layer inContext:context];
    CGFloat lineWidth = 2;
    
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, self.fieldBorderColor.CGColor);
    CGContextSetLineWidth(context, lineWidth);
    
    // draw the total field boundaries
    CGFloat borderLineInset = lineWidth - 1;  // stay inside the bounds
    CGRect rect = self.totalFieldRect;
    CGContextMoveToPoint(context, rect.origin.x + borderLineInset, rect.origin.y + borderLineInset);
    CGContextAddLineToPoint(context, rect.origin.x  + borderLineInset, rect.size.height - borderLineInset);
    CGContextAddLineToPoint(context, rect.size.width - borderLineInset, rect.size.height - borderLineInset);
    CGContextAddLineToPoint(context, rect.size.width - borderLineInset, rect.origin.y  + borderLineInset);
    CGContextAddLineToPoint(context, rect.origin.x + borderLineInset, rect.origin.y  + borderLineInset);
    CGContextStrokePath(context);
    
    // draw endzone 0 line
    CGFloat x = CGRectGetMaxX(self.endzone0Rect);
    CGContextMoveToPoint(context, x, self.endzone0Rect.origin.y);
    CGContextAddLineToPoint(context, x, CGRectGetMaxY(self.endzone0Rect));
    CGContextStrokePath(context);
    
    // draw endzone 100 line
    x = self.endzone100Rect.origin.x;
    CGContextMoveToPoint(context, x, self.endzone100Rect.origin.y);
    CGContextAddLineToPoint(context, x, CGRectGetMaxY(self.endzone100Rect));
    CGContextStrokePath(context);

}

#pragma mark - Point/Position calculations 

-(void)calculateFieldRectangles {
    CGRect totalField = CGRectIntegral(self.bounds);
    CGFloat endzoneWidth = ceilf(self.endzonePercent * totalField.size.height);
    self.endzone0Rect = CGRectMake(0, 0, endzoneWidth, ceilf(totalField.size.height));
    self.endzone100Rect = CGRectMake(totalField.size.width-endzoneWidth, 0, endzoneWidth, ceilf(totalField.size.height));
    self.fieldRect = CGRectMake(self.endzone0Rect.size.width, 0, self.endzone100Rect.origin.x - CGRectGetMaxX(self.endzone0Rect), ceilf(totalField.size.height));
    self.totalFieldRect = totalField;
}

-(EventPosition*)calculatePosition: (CGPoint)point {
    if (CGRectContainsPoint(self.fieldRect, point)) {
        return [self calculatePosition:point inRect:self.fieldRect area:EventPositionAreaField];
    } else if (CGRectContainsPoint(self.endzone0Rect, point)) {
        return [self calculatePosition:point inRect:self.endzone0Rect area:EventPositionArea0Endzone];
    } else if (CGRectContainsPoint(self.endzone100Rect, point)) {
        return [self calculatePosition:point inRect:self.endzone100Rect area:EventPositionArea100Endzone];
    } else {
        return nil;
    }
}

-(EventPosition*)calculatePosition: (CGPoint)point inRect: (CGRect)rect area: (EventPositionArea)area {
    CGFloat x = ceilf(point.x - rect.origin.x / rect.size.width);
    CGFloat y = ceilf(point.y / rect.size.height);
    return [EventPosition positionWithOrientation:self.orientation inArea:area x:x y:y];
}

-(CGPoint)calculatePoint: (EventPosition*)position {
    BOOL flipNeeded = position.orientation != self.orientation;
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
    CGFloat y = ceilf(positionY / self.fieldRect.size.height);
    if (area == EventPositionAreaField) {
        CGFloat x = ceilf(self.endzone0Rect.size.width * positionX);
        return CGPointMake(x, y);
    } else if (area == EventPositionArea0Endzone) {
        CGFloat x = self.fieldRect.origin.x + ceilf(self.fieldRect.size.width * positionX);
        return CGPointMake(x, y);
    } else if (area == EventPositionArea100Endzone) {
        CGFloat x = self.endzone100Rect.origin.x + ceilf(self.endzone100Rect.size.width * positionX);
        return CGPointMake(x, y);
    } else {
        return CGPointMake(0, 0);
    }
}

@end
