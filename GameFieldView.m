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
#import "DefenseEvent.h"
#import "Player.h"
#import "Game.h"
#import "Team.h"
#import "UPoint.h"
#import "ColorMaster.h"
#import "PlayDirectionView.h"

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
@property (nonatomic, strong) UILabel* messageLabel;

@property (nonatomic, strong) Game* game;
@property (nonatomic) BOOL eventHasBeenMoved;
@property (nonatomic) CGPoint initialDragPoint;

@property (nonatomic, strong) PlayDirectionView* ourTeamDirectionView;
@property (nonatomic, strong) PlayDirectionView* theirTeamDirectionView;

@end

@implementation GameFieldView
@dynamic game;

#pragma mark - Initialization

-(void)commonInit {
    [self addTapRecognizer];
    [self addDragPressRecognizer];
    self.endzonePercent = .15; // default endzone percent
    self.fieldBorderColor = [UIColor whiteColor];  // default border color

    [self addPointViews];
    [self addMessageView];
    [self addDirectionViews];
    
    [self.layer setNeedsDisplay];
}

-(void)addTapRecognizer {
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self addGestureRecognizer: tapRecognizer];
}

-(void)addDragPressRecognizer {
    UIPanGestureRecognizer* tapRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDragged:)];
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

- (void)viewDragged:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint dragPoint = [((UIPanGestureRecognizer*)gestureRecognizer) locationInView:self];
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.initialDragPoint = dragPoint;
        self.eventHasBeenMoved = NO;
    }
    BOOL eventWasDragged = [self handlePossibleDragOfEvent:self.lastSavedEventView atPoint:dragPoint];
    if (!eventWasDragged) {
        [self handlePossibleDragOfEvent:self.previousSavedEventView atPoint:dragPoint];
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (self.eventHasBeenMoved) {
            [self.game save];
        // we weren't moving an event consider a short drag a tap
        } else if ([self distanceBetweenPoint:dragPoint andPoint:self.initialDragPoint] < 20) {
            [self handleTap:dragPoint];
        }
    }
}

- (void)handleTap:(CGPoint) tapPoint {
    EventPosition* eventPosition = [self calculatePosition:tapPoint];
    if (self.positionTappedBlock) {
        BOOL shouldDisplayPotentialEvent = self.positionTappedBlock(eventPosition, tapPoint);
        [self updatePointViews: shouldDisplayPotentialEvent ? eventPosition : nil];
    }
}

- (BOOL)handlePossibleDragOfEvent: (GameFieldEventPointView*)eventView atPoint:  (CGPoint) dragPoint{
    if (CGRectContainsPoint(eventView.frame, dragPoint)) {
        eventView.event.position = [self calculatePosition:dragPoint];
        eventView.center = [self calculatePoint:eventView.event.position];
        self.eventHasBeenMoved = YES;
        return YES;
    }
    return NO;
}

#pragma mark - Event Point Views

-(void)addPointViews {
    self.potentialEventView = [self createPointView];
    self.potentialEventView.isEmphasizedEvent = YES;
    
    self.lastSavedEventView = [self createPointView];
    
    self.previousSavedEventView = [self createPointView];
    self.previousSavedEventView.isEmphasizedEvent = NO;
    
    [self addSubview:self.previousSavedEventView];
    [self addSubview:self.lastSavedEventView];
    [self addSubview:self.potentialEventView];
}

-(void)updateForCurrentEvents {
    [self updatePointViews:nil];
    [self updateDirectionArrows];
    self.message = [self.game isPointInProgress] || self.game.positionalPickupEvent ? nil : @"Tap the field where the pull will be initiated";
}

-(void)updatePointViews: (EventPosition*)potentialEventPosition {
    Event* lastEvent = [self getLastPointEvent];
    
    // potential event
    if (potentialEventPosition) {
        self.potentialEventPosition = potentialEventPosition;
        [self updatePointViewLocation:self.potentialEventView toPosition:potentialEventPosition];
        self.potentialEventView.isOurEvent =
            ([self.game isPointInProgress] && [self.game arePlayingOffense])||
            (![self.game isPointInProgress] && ![self.game isCurrentlyOline]);
    }
    self.potentialEventView.hidden = potentialEventPosition == nil;
    
    // last event
    if (lastEvent && lastEvent.position != nil) {
        self.lastSavedEventView.isEmphasizedEvent = !self.potentialEventView.visible;
        self.lastSavedEventView.isOurEvent = [self isOurEvent:lastEvent];
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
        self.previousSavedEventView.isOurEvent = [self isOurEvent:previousEvent];
        [self updatePointViewLocation:self.previousSavedEventView toPosition:previousEvent.position];
        self.previousSavedEventView.visible = YES;
    } else {
        self.previousSavedEventView.visible = NO;
    }
    
}

-(BOOL)isOurEvent:(Event*) event {
    if ([event isPull] || [event isOpponentPull] || [event isPullBegin]) {
        return [event isDefense];
    } else {
        return [event isOffense];
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
    if (self.message) {
        self.messageLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
    [self layoutDirectionViews];
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
    Event* pickupEvent = self.game.positionalPickupEvent;
    if (pickupEvent) {
        return pickupEvent;
    } else {
        return [self.game getInProgressPointLastEvent];
    }
}

-(Event*)getPreviousPointEvent {
    Event* lastEvent = [self.game getInProgressPointLastEvent];
    
    // if no last event then there can't be a previous
    if (!lastEvent) {
        return nil;
    }
    
    // if the game has a pickup event then the previous is actually the last event
    if (self.game.positionalPickupEvent) {
        return [self.game getInProgressPointLastEvent];
    }
    
    // if the last event is an event with a begin position then create a temporary pickup event with that position
    if (lastEvent.beginPosition) {
        Event* event;
        if ([lastEvent isPull] || [lastEvent isOpponentPull]) {
            if (lastEvent.isDefense) {
                event = [[DefenseEvent alloc] initPullBegin:lastEvent.playerOne];
            } else {
                event = [[OffenseEvent alloc] initOpponentPullBegin];
            }
        } else {
            if (lastEvent.isOffense) {
                event = [[OffenseEvent alloc] initPickupDiscWithPlayer:lastEvent.playerOne];
            } else {
                event = [[DefenseEvent alloc] initPickupDisc];
            }
        }
        event.position = lastEvent.beginPosition;
        return event;
    }
    
    // dullsville...the normal scenario
    NSArray* lastPointEvents = [self.game getInProgressPointLastEvents:2];
    if ([lastPointEvents count] > 1) {
        return lastPointEvents[1];
    } else {
        return nil;
    }
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

-(void)setMessage:(NSString *)message {
    _message = message;
    self.messageLabel.text = message;
    self.messageLabel.hidden = message ? NO : YES;
    [self setNeedsLayout];
}

#pragma mark - Direction Arrows

-(PlayDirectionView*)createPlayDirectionView {
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([PlayDirectionView class]) owner:nil options:nil];
    return (PlayDirectionView *)nibViews[0];
}

-(void)addDirectionViews {
    self.ourTeamDirectionView = [self createPlayDirectionView];
    [self addSubview:self.ourTeamDirectionView];
    self.ourTeamDirectionView.isOurTeam = YES;
    self.ourTeamDirectionView.teamName = [Team getCurrentTeam].name;
    
    self.theirTeamDirectionView = [self createPlayDirectionView];
    [self addSubview:self.theirTeamDirectionView];
    self.theirTeamDirectionView.isOurTeam = NO;
    self.theirTeamDirectionView.teamName = [Game getCurrentGame].opponentName;
}


-(void)layoutDirectionViews {
    CGFloat viewHeight = self.ourTeamDirectionView.frameHeight;
    self.ourTeamDirectionView.frame = CGRectMake(0, -viewHeight, self.boundsWidth, viewHeight);
    self.theirTeamDirectionView.frame = CGRectMake(0, self.boundsHeight, self.boundsWidth, viewHeight);
}

-(void)updateDirectionArrows {
    BOOL isOurTeamLeft = YES;  // todo...add correct logic here
    
    self.ourTeamDirectionView.isLeft = isOurTeamLeft;
    self.theirTeamDirectionView.isLeft = !isOurTeamLeft;
}

#pragma mark - Misc.

-(Game*)game {
    return [Game getCurrentGame];
}

@end
