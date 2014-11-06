//
//  GameRecordingFieldView.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/22/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "GameRecordingFieldView.h"
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
#import "CalloutsContainerView.h"
#import "GameDiscView.h"

#define kPointViewWidth 30.0f
#define kDiscDiameter 16.0f
#define kHasDragCalloutBeenShown @"HasDragCalloutBeenShown"

#define kEndZoneCloseTolerance .05f
#define kFieldCloseTolerance .02f

@interface GameRecordingFieldView ()

@property (nonatomic, strong) GameFieldEventPointView* lastSavedEventView;
@property (nonatomic, strong) GameFieldEventPointView* previousSavedEventView;
@property (nonatomic, strong) GameFieldEventPointView* potentialEventView;

@property (nonatomic, strong) GameDiscView* movingDiscView;
@property (nonatomic, strong) UIColor* discColor;

@property (nonatomic, strong) EventPosition* potentialEventPosition;

@property (nonatomic, strong) Game* game;
@property (nonatomic) GameFieldEventPointView* movedPointView;
@property (nonatomic) CGPoint initialDragPoint;

@property (nonatomic, strong) PlayDirectionView* directionView;

@property (nonatomic, strong) UILabel* benchSideLabel;

@property (nonatomic, strong) CalloutsContainerView *calloutsViewContainer;

@end

@implementation GameRecordingFieldView
@dynamic game, potentialEventPositionPoint;

#pragma mark - Initialization

-(void)commonInit {
    [super commonInit];
    [self addTapRecognizer];
    [self addDragPressRecognizer];
    [self addBenchView];
    [self addDirectionView];
    [self addPointViews];
    [self addAnimationViews];
    
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
    view.discDiameter = kDiscDiameter;
    view.discColor = self.discColor;
    view.hidden = YES;
    __typeof(self) __weak weakSelf = self;
    view.tappedBlock = ^(CGPoint pointViewTapPoint, GameFieldEventPointView* pointView) {
        CGPoint tapPoint = [weakSelf convertPoint:pointViewTapPoint fromView:pointView];
        [weakSelf handleTap:tapPoint isOB:NO];
    };
    return view;
}

#pragma mark - Touch handling

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.initialDragPoint = [[[event allTouches] anyObject] locationInView:self];  // stow the original location
    
    [super touchesBegan:touches withEvent:event];
}

- (void)viewTapped:(UIGestureRecognizer *)gestureRecognizer {
    [self handleTap:[gestureRecognizer locationInView:self] isOB:NO];
}

- (void)viewDragged:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint pointFromOriginal = [gestureRecognizer translationInView:self];
    CGPoint dragPoint = CGPointMake(self.initialDragPoint.x + pointFromOriginal.x, self.initialDragPoint.y + pointFromOriginal.y);
    
    if (CGRectContainsPoint(self.bounds, dragPoint)) {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            self.initialDragPoint = dragPoint;
            if ([self pointView:self.lastSavedEventView contains:dragPoint]) {
                self.movedPointView = self.lastSavedEventView;
            } else if ([self pointView:self.previousSavedEventView contains:dragPoint]) {
                self.movedPointView = self.previousSavedEventView;
            }
        }
        if (self.movedPointView) {
            self.movedPointView.event.position = [self calculatePosition:dragPoint];
            self.movedPointView.center = [self calculatePoint:self.movedPointView.event.position];
        }
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (self.movedPointView) {
            [self.movedPointView setNeedsLayout];
            [self.game saveWithUpload];
            // we weren't moving an event consider a short drag a tap
        } else if ([self distanceBetweenPoint:dragPoint andPoint:self.initialDragPoint] < 20) {
            [self handleTap:dragPoint isOB:NO];
        }
        self.movedPointView = nil;
    }

}

- (void)handleTap:(CGPoint) tapPoint isOB: (BOOL) isOutOfBounds {
    EventPosition* eventPosition = [self calculatePosition:tapPoint];
    if (self.positionTappedBlock) {
        BOOL shouldDisplayPotentialEvent = self.positionTappedBlock(eventPosition, tapPoint, isOutOfBounds);
        [self updatePointViews: shouldDisplayPotentialEvent ? eventPosition : nil];
        [self animateDiscThrow];
        if (isOutOfBounds) {
            [self.lastSavedEventView flashOutOfBoundsMessage];
        }
    }
}

- (BOOL)pointView: (GameFieldEventPointView*)eventView contains: (CGPoint) dragPoint {
    return (CGRectContainsPoint(eventView.frame, dragPoint));
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

-(void)addAnimationViews {
    self.movingDiscView = [[GameDiscView alloc] initWithFrame:CGRectMake(0, 0, kDiscDiameter, kDiscDiameter)];
    self.movingDiscView.discColor = self.discColor;
    self.movingDiscView.hidden = YES;
    [self addSubview:self.movingDiscView];
}

-(void)updateForCurrentEvents {
    [self updatePointViews:nil];
    [self updateDirectionArrows];
    [self updateMessage];
    [self showAppropriateCallouts];

}

-(void)layoutPointViews {
    if (self.lastSavedEventView.visible) {
        [self updatePointViewLocation:self.lastSavedEventView toPosition:self.lastSavedEventView.event.position];
    }
    if (self.previousSavedEventView.visible) {
        [self updatePointViewLocation:self.previousSavedEventView toPosition:self.previousSavedEventView.event.position];
    }
    if (self.potentialEventView.visible) {
        [self updatePointViewLocation:self.potentialEventView toPosition:self.potentialEventPosition];
    }
}

-(void)updateMessage {
    if ([self.game isPointInProgress] || self.game.positionalBeginEvent) {
        self.message = nil;
    } else if ([self.game hasEvents]) {
        self.message = [[NSMutableAttributedString alloc] initWithString:@"Tap the field where the pull will be initiated"];
    } else {
        UIColor* opponentColor = [ColorMaster theirTeamPositionalColor];
        UIColor* ourTeamColor = [ColorMaster ourTeamPositionalColor];
        NSAttributedString* nextPart;
        NSMutableAttributedString* introMessage = [[NSMutableAttributedString alloc] initWithString:@"Ready to begin game.\n\nRemember that during the game all actions for "];
        nextPart = [[NSMutableAttributedString alloc] initWithString:@"your team" attributes:@{NSForegroundColorAttributeName : ourTeamColor}];
        [introMessage appendAttributedString:nextPart];
        nextPart = [[NSMutableAttributedString alloc] initWithString:@" will in "];
        [introMessage appendAttributedString:nextPart];
        nextPart = [[NSMutableAttributedString alloc] initWithString:@"green" attributes:@{NSForegroundColorAttributeName : ourTeamColor}];
        [introMessage appendAttributedString:nextPart];
        nextPart = [[NSMutableAttributedString alloc] initWithString:@". The "];
        [introMessage appendAttributedString:nextPart];
        nextPart = [[NSMutableAttributedString alloc] initWithString:@"opponent's" attributes:@{NSForegroundColorAttributeName : opponentColor}];
        [introMessage appendAttributedString:nextPart];
        nextPart = [[NSMutableAttributedString alloc] initWithString:@" actions will be in "];
        [introMessage appendAttributedString:nextPart];
        nextPart = [[NSMutableAttributedString alloc] initWithString:@"red" attributes:@{NSForegroundColorAttributeName : opponentColor}];
        [introMessage appendAttributedString:nextPart];
        nextPart = [[NSMutableAttributedString alloc] initWithString:@".\n\nTap the field where the pull will be initiated."];
        [introMessage appendAttributedString:nextPart];
        self.message = introMessage;
    }
}

-(void)updatePointViews: (EventPosition*)potentialEventPosition {
    Event* lastEvent = [self getLastPointEvent];
    
    // potential event
    if (potentialEventPosition) {
        self.potentialEventPosition = potentialEventPosition;
        self.potentialEventView.isOurEvent = [self isNextEventOurs];
    }
    self.potentialEventView.hidden = potentialEventPosition == nil;
    
    // last event
    if (lastEvent && lastEvent.position != nil) {
        self.lastSavedEventView.isEmphasizedEvent = !self.potentialEventView.visible;
        self.lastSavedEventView.isOurEvent = [self isOurEvent:lastEvent];
        self.lastSavedEventView.event = lastEvent;
        self.lastSavedEventView.visible = YES;
    } else {
        self.lastSavedEventView.visible = NO;
    }
    
    // previous event
    Event* previousEvent = [self getPreviousPointEvent];
    if (self.potentialEventView.hidden && previousEvent && previousEvent.position != nil) {
        self.previousSavedEventView.event = previousEvent;
        self.previousSavedEventView.isOurEvent = [self isOurEvent:previousEvent];
        self.previousSavedEventView.visible = YES;
    } else {
        self.previousSavedEventView.visible = NO;
    }
    
    [self layoutPointViews];
}

-(void)animateDiscThrow {
    Event* lastEvent = [self getLastPointEvent];
    
    // animate a disc moving from last event to potential event
    if (!self.potentialEventView.hidden && lastEvent) {
        if ([lastEvent isPositionalBegin] || [lastEvent isCatchOrOpponentCatch]) {
            self.movingDiscView.center = self.lastSavedEventView.center;
            self.movingDiscView.hidden = NO;
            self.potentialEventView.discHidden = YES;
            [UIView animateWithDuration:.5 animations:^{
                self.movingDiscView.center = self.potentialEventView.center;
            } completion:^(BOOL finished) {
                self.movingDiscView.hidden = YES;
                self.potentialEventView.discHidden = NO;
            }];
        }
    } else if (!self.lastSavedEventView.hidden && !self.previousSavedEventView.hidden) {
        Event* previousEvent = self.previousSavedEventView.event;
        if ([previousEvent isPositionalBegin] || [previousEvent isCatchOrOpponentCatch]) {
            self.movingDiscView.center = self.previousSavedEventView.center;
            self.movingDiscView.hidden = NO;
            self.lastSavedEventView.discHidden = YES;
            [UIView animateWithDuration:.5 animations:^{
                self.movingDiscView.center = self.lastSavedEventView.center;
            } completion:^(BOOL finished) {
                self.movingDiscView.hidden = YES;
                self.lastSavedEventView.discHidden = NO;
            }];
        }
    }
    
}


#pragma mark - UIView overrides

-(void)layoutSubviews {
    [super layoutSubviews];
    [self layoutDirectionViews];
    [self layoutBenchView];
    [self layoutPointViews];
}

#pragma mark - Event retrieval

-(Event*)getLastPointEvent {
    Event* pickupEvent = self.game.positionalBeginEvent;
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
    if (self.game.positionalBeginEvent) {
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

#pragma mark - Direction Arrows

-(PlayDirectionView*)createPlayDirectionView {
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([PlayDirectionView class]) owner:nil options:nil];
    return (PlayDirectionView *)nibViews[0];
}

-(void)addDirectionView {
    self.directionView = [self createPlayDirectionView];
    [self addSubview:self.directionView];
    self.directionView.hidden = YES;
}

-(void)layoutDirectionViews {
    CGFloat viewHeight = self.directionView.frameHeight;
    self.directionView.frame = CGRectMake(0, -viewHeight, self.boundsWidth, viewHeight);
}

-(void)updateDirectionArrows {
    Event* pullEvent = [self.game getInProgressPointPull];
    self.directionView.hidden = pullEvent == nil;
    if (pullEvent && pullEvent.beginPosition) {
        BOOL isNextEventOurs = [self isNextEventOurs];
        BOOL wasPullEventOurs = [pullEvent isDefense];
        
        self.directionView.isOurTeam = isNextEventOurs;
        
        BOOL wasPullPointingLeft = ![pullEvent.beginPosition isCloserToEndzoneZero];
        wasPullPointingLeft = wasPullPointingLeft ^ self.inverted ^ pullEvent.beginPosition.inverted;
        self.directionView.isPointingLeft = wasPullPointingLeft ^ isNextEventOurs ^ wasPullEventOurs;
    }
}

#pragma mark - Bench label


-(void)addBenchView {
    self.benchSideLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 15)];
    self.benchSideLabel.textColor = [UIColor whiteColor];
    self.benchSideLabel.textAlignment = NSTextAlignmentCenter;
    self.benchSideLabel.font = [UIFont systemFontOfSize:10];
    self.benchSideLabel.text = @"Bench";
    [self addSubview:self.benchSideLabel];
}

-(void)layoutBenchView {
    CGFloat viewHeight = self.inverted ? 15 : 21;
    self.benchSideLabel.frame = CGRectMake(0, self.inverted ? -viewHeight : self.boundsHeight, self.boundsWidth, viewHeight);
    self.benchSideLabel.font = [UIFont systemFontOfSize: self.inverted ? 10 : 14];
}

#pragma mark - Callouts

-(void)showAppropriateCallouts {
    if (self.lastSavedEventView && [self.lastSavedEventView.event isCatchOrOpponentCatch]) {
        [self showDragCallout];
    }
}

-(void)showDragCallout {
    if (![[NSUserDefaults standardUserDefaults] boolForKey: kHasDragCalloutBeenShown]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey: kHasDragCalloutBeenShown];
        CalloutsContainerView *calloutsView = [[CalloutsContainerView alloc] initWithFrame:self.bounds];
        
        GameFieldEventPointView* anchorView = self.lastSavedEventView;
        CGPoint anchor = [anchorView convertPoint:anchorView.boundsCenter toView:self];
        CGFloat degrees = [anchorView isBelowMidField] ? ([anchorView isRightOfMidField] ? 340 : 20) : ([anchorView isRightOfMidField] ? 200 : 160);
        [calloutsView addCallout:@"Did you know?\nYou can drag actions to adjust their position" anchor: anchor width: 180 degrees: degrees connectorLength: 60 font: [UIFont systemFontOfSize:14]];
        
        self.calloutsViewContainer = calloutsView;
        [self addSubview:self.calloutsViewContainer];
        // move the callouts off the screen and then animate their return.
        [self.calloutsViewContainer slide: YES animated: NO];
        [self.calloutsViewContainer slide: NO animated: YES];
    }
}

#pragma mark - Misc.

-(Game*)game {
    return [Game getCurrentGame];
}

-(BOOL)isNextEventOurs {
    return
    ([self.game isPointInProgress] && [self.game arePlayingOffense])||
    (![self.game isPointInProgress] && ![self.game isCurrentlyOline]);
}

-(BOOL)isPointInGoalEndzone: (CGPoint)eventPoint {
    EventPosition* position = [self calculatePosition:eventPoint];
    if ((position.area == EventPositionArea0Endzone && self.directionView.isPointingLeft) ||
        (position.area == EventPositionArea100Endzone && !self.directionView.isPointingLeft)) {
        return YES;
    }
    return NO;
}

-(BOOL)isPointVeryNearGoalLine: (CGPoint)eventPoint {
    EventPosition* position = [self calculatePosition:eventPoint];
    return [self isPositionVeryNearGoalLine:position];
}

-(BOOL)isPositionVeryNearGoalLine: (EventPosition*)position {
    if ((position.area == EventPositionArea0Endzone && position.x > (1 - kEndZoneCloseTolerance)) ||
        (position.area == EventPositionArea100Endzone && position.x < kEndZoneCloseTolerance) ||
        (position.area == EventPositionAreaField && position.x > (1 - kFieldCloseTolerance)) ||
        (position.area == EventPositionAreaField && position.x < kFieldCloseTolerance)) {
        return YES;
    }
    return NO;
}

-(CGPoint)potentialEventPositionPoint {
    return [self calculatePoint:self.potentialEventPosition];
}


@end
