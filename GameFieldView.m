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
#import "OffenseEvent.h"
#import "Player.h"
#import "Game.h"
#import "UPoint.h"
#import "ColorMaster.h"

#define kPointViewWidth 30.0f

@interface GameFieldView ()

@property (nonatomic) CGRect totalFieldRect;
@property (nonatomic) CGRect fieldRect;
@property (nonatomic) CGRect endzone0Rect;
@property (nonatomic) CGRect endzone100Rect;

@property (nonatomic, strong) GameFieldEventPointView* lastSavedEventView;
@property (nonatomic, strong) GameFieldEventPointView* previousSavedEventView;
@property (nonatomic, strong) GameFieldEventPointView* potentialEventView;
@property (nonatomic, strong) EventPosition* potentialEventPosition;

@end

@implementation GameFieldView

#pragma mark - Initialization

-(void)commonInit {
    [self addTapRecognizer];
    self.fieldBorderColor = [UIColor whiteColor];  // default border color
    self.endzonePercent = .15; // default endzone percent
    self.potentialEventView = [self createPointView];
    self.potentialEventView.isEmphasizedEvent = YES;
    [self addSubview:self.potentialEventView];
    self.lastSavedEventView = [self createPointView];
    [self addSubview:self.lastSavedEventView];
    self.previousSavedEventView = [self createPointView];
    self.previousSavedEventView.isEmphasizedEvent = NO;
    [self addSubview:self.previousSavedEventView];
    [self.layer setNeedsDisplay];
}

-(void)addTapRecognizer {
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self addGestureRecognizer: tapRecognizer];
}

-(GameFieldEventPointView*)createPointView {
    GameFieldEventPointView* view = [[GameFieldEventPointView alloc] initWithFrame:CGRectMake(0, 0, kPointViewWidth, kPointViewWidth)];
    view.hidden = YES;
    __typeof(self) __weak weakSelf = self;
    view.tappedBlock = ^(CGPoint pointViewTapPoint, GameFieldEventPointView* pointView) {
        CGPoint tapPoint = [weakSelf convertPoint:pointViewTapPoint fromView:pointView];
        [weakSelf handleTap:tapPoint];
    };
    return view;
}

#pragma mark - Touch handling

- (void)viewTapped:(UIGestureRecognizer *)gestureRecognizer {
    [self handleTap:[gestureRecognizer locationInView:self]];
}

- (void)handleTap:(CGPoint) tapPoint {
    EventPosition* eventPosition = [self calculatePosition:tapPoint];
    if (self.positionTappedBlock) {
        self.positionTappedBlock(eventPosition, tapPoint);
    }
    
    [self updatePointViews:eventPosition];
}

#pragma mark - Event Point Views

-(void)updateForCurrentEvents {
    [self updatePointViews:nil];
}

-(void)updatePointViews: (EventPosition*)potentialEventPosition {
    Event* lastEvent = [self getLastPointEvent];
    
    // potential event
    if (potentialEventPosition) {
        self.potentialEventPosition = potentialEventPosition;
        [self updatePointViewLocation:self.potentialEventView toPosition:potentialEventPosition];
        self.potentialEventView.isOurEvent =  [[Game getCurrentGame] arePlayingOffense];
    }
    self.potentialEventView.hidden = potentialEventPosition == nil;
    
    // last event
    if (lastEvent && lastEvent.position != nil) {
        self.lastSavedEventView.isEmphasizedEvent = !self.potentialEventView.visible;
        self.lastSavedEventView.isOurEvent = [lastEvent isOffense];
        self.lastSavedEventView.event = lastEvent;
        [self updatePointViewLocation:self.lastSavedEventView toPosition:lastEvent.position];
        self.lastSavedEventView.visible = YES;
    } else {
        self.lastSavedEventView.visible = NO;
    }
    
    // previous event
    Event* previousEvent = [self getPreviousPointEvent];
    if (self.potentialEventView.hidden && previousEvent && previousEvent.position != nil) {
        self.previousSavedEventView.event = previousEvent;
        self.previousSavedEventView.isOurEvent = [lastEvent isOffense];
        [self updatePointViewLocation:self.previousSavedEventView toPosition:previousEvent.position];
        self.previousSavedEventView.visible = YES;
    } else {
        self.previousSavedEventView.visible = NO;
    }
    
}

-(void)updatePointViewLocation: (GameFieldEventPointView*)pointView toPosition: (EventPosition*)eventPosition {
    pointView.center = [self calculatePoint:eventPosition];
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
    
    CGContextRestoreGState(context);

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
    if (area == EventPositionAreaField) {
        CGFloat x = roundf(CGRectGetMaxX(self.endzone0Rect) + (self.fieldRect.size.width * positionX));
        return CGPointMake(x, y);
    } else if (area == EventPositionArea0Endzone) {
        CGFloat x = roundf(self.endzone0Rect.size.width * positionX);
        return CGPointMake(x, y);
    } else if (area == EventPositionArea100Endzone) {
        CGFloat x = CGRectGetMaxX(self.fieldRect) + (self.endzone100Rect.size.width * positionX);
        return CGPointMake(x, y);
    } else {
        return CGPointMake(0, 0);
    }
}

#pragma mark - Event retrieval

-(Event*)getLastPointEvent {
    Event* pickupEvent = [Game getCurrentGame].positionalPickupEvent;
    if (pickupEvent) {
        return pickupEvent;
    } else {
        return [[Game getCurrentGame] getLastEvent];
    }
}

-(Event*)getPreviousPointEvent {
    // if there is a begin event then the previous event is actually the last event
    if ([Game getCurrentGame].positionalPickupEvent) {
        return [[Game getCurrentGame] getLastEvent];
    }
    
    NSArray* lastPointEvents = [[Game getCurrentGame] getCurrentPointLastEvents:2];
    if ([lastPointEvents count] > 1) {
        return lastPointEvents[1];
    } else {
        return nil;
    }
}

-(BOOL)currentPointHasEvents {
    UPoint* currentPoint = [[Game getCurrentGame] getCurrentPoint];
    return currentPoint != nil && ![currentPoint isFinished];
}

@end
