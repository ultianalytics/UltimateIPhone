//
//  GamePlaybackFieldView.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 9/12/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "GamePlaybackFieldView.h"
#import "GameFieldEventPointView.h"
#import "Event.h"
#import "GameDiscView.h"
#import "GamePlaybackTracerView.h"

#define kNormalPassAnimationDuration 1
#define kNormalWrapUpAnimationDuration .5

@interface GamePlaybackFieldView ()

@property (strong, nonatomic) NSMutableArray* currentEventViews;
@property (nonatomic, strong) GameDiscView* movingDiscView;

@end

@implementation GamePlaybackFieldView


#pragma mark - Initializing

-(void)commonInit {
    [super commonInit];
    self.currentEventViews = [NSMutableArray array];
    [self addMovingDiscView];
}

-(void)addMovingDiscView {
    self.movingDiscView = [[GameDiscView alloc] initWithFrame:CGRectMake(0, 0, kDiscDiameter, kDiscDiameter)];
    self.movingDiscView.discColor = self.discColor;
    self.movingDiscView.hidden = YES;
    [self addSubview:self.movingDiscView];
}

#pragma mark - Displaying events

-(void)displayNewEvent: (Event*) event atRelativeSpeed: (float) relativeSpeedFactor complete: (void (^)()) completionBlock {
    GameFieldEventPointView* lastEventView = [self lastEventView];
    GameFieldEventPointView* eventView = [self createPointView];
    eventView.event = event;
    eventView.isOurEvent = [self isOurEvent:event];
    [self updatePointViewLocation:eventView toPosition:event.position];
    [self addEventPointView: eventView];
    [self animateEventAppearance:eventView atRelativeSpeed:relativeSpeedFactor lastEventView: lastEventView complete:completionBlock];
}


-(void)displayEvent: (Event*) event {
    GameFieldEventPointView* lastEventView = [self lastEventView];
    if (lastEventView) {
        lastEventView.discHidden = YES;
        lastEventView.isEmphasizedEvent = NO;
    }
    GameFieldEventPointView* eventView = [self createPointView];
    eventView.event = event;
    eventView.isOurEvent = [self isOurEvent:event];
    [self updatePointViewLocation:eventView toPosition:event.position];
    [self addEventPointView: eventView];
    if (lastEventView && ![event isPositionalBegin]) {
        [self addTracerArrowFrom:lastEventView to:eventView];
    }
}

-(GameFieldEventPointView*)createPointView {
    GameFieldEventPointView* view = [[GameFieldEventPointView alloc] initWithFrame:CGRectMake(0, 0, kPointViewWidth, kPointViewWidth)];
    view.isEmphasizedEvent = YES;
    view.discDiameter = kDiscDiameter;
    view.discColor = self.discColor;
    return view;
}

-(void)resetField {
    for (UIView* subView in self.subviews) {
        if ([subView isKindOfClass:[GameFieldEventPointView class]] || [subView isKindOfClass:[GamePlaybackTracerView class]]) {
            [subView removeFromSuperview];
        }
    }
    [self.currentEventViews removeAllObjects];
}

-(void)animateEventAppearance: (GameFieldEventPointView*) eventView atRelativeSpeed: (float) relativeSpeedFactor  lastEventView: (GameFieldEventPointView*) lastEventView complete: (void (^)()) completionBlock {
    
    GamePlaybackTracerView* tracerView;
    GameFieldEventPointView* lastEventViewCopy;
    
    if (lastEventView) {
        // add a tracer view (if not a pull or pickup)
        if (![eventView.event isPositionalBegin]) {
            tracerView = [self addTracerArrowFrom:lastEventView to:eventView];
            if (!self.tracerArrowsHidden) {
                tracerView.alpha = 0;
                tracerView.hidden = NO;
            }
        }
        
        // create a copy of the last event and cover the original so we can fade it's changes
        lastEventViewCopy = [GameFieldEventPointView copyOf:lastEventView];
        [self addSubview:lastEventViewCopy];
        
        // adjust the last event
        lastEventView.isEmphasizedEvent = NO;
        lastEventView.discHidden = YES;
        
        // setup for moving disc view
        eventView.discHidden = YES;
        self.movingDiscView.center = lastEventView.center;
        [self bringSubviewToFront:self.movingDiscView];
        self.movingDiscView.hidden = NO;
        
    }
    
    // animate the moving of the frisbee from passer to receiver, the appearance of the new event and disappearance of the old event
    eventView.alpha = 0;
    [UIView animateWithDuration:[self scaleDuration:kNormalPassAnimationDuration usingFactor:relativeSpeedFactor] animations:^{
        if (lastEventView) {
            self.movingDiscView.center = eventView.center;
            lastEventViewCopy.alpha = 0;
        }
        eventView.alpha = 1;
    } completion:^(BOOL finished) {
        // cleanup
        [lastEventViewCopy removeFromSuperview];
        self.movingDiscView.hidden = YES;
        eventView.discHidden = NO;
        
        if (lastEventView && !self.tracerArrowsHidden) {
            
            // animate showing the arrow (if we are displaying them)
            [UIView animateWithDuration:[self scaleDuration:kNormalWrapUpAnimationDuration usingFactor:relativeSpeedFactor] animations:^{
                tracerView.alpha = 1;
            } completion:^(BOOL finished) {
                [self safelyPeformCompletion:completionBlock];
            }];
            
        } else {
            [self safelyPeformCompletion:completionBlock];
        }
    }];
    
}

-(GamePlaybackTracerView*)addTracerArrowFrom: (GameFieldEventPointView*) fromView to: (GameFieldEventPointView*) toView {
    GamePlaybackTracerView* tracerView = nil;
    if (fromView && toView) {
        tracerView = [[GamePlaybackTracerView alloc] initWithFrame:self.bounds];
        tracerView.sourcePoint = fromView.center;
        tracerView.destinationPoint = toView.center;
        tracerView.isOurEvent = toView.isOurEvent;
        tracerView.hidden = self.tracerArrowsHidden;
        [self addSubview:tracerView];
        [self sendSubviewToBack:tracerView];
    }
    return tracerView;
}

#pragma mark - Misc

-(GameFieldEventPointView*)lastEventView {
    return [self.currentEventViews count] > 0 ? [self.currentEventViews lastObject] : nil;
}

-(void)setTracerArrowsHidden:(BOOL)tracerArrowsHidden {
    _tracerArrowsHidden = tracerArrowsHidden;
    for (UIView* subView in self.subviews) {
        if ([subView isKindOfClass:[GamePlaybackTracerView class]]) {
            ((GamePlaybackTracerView*)subView).hidden = tracerArrowsHidden;
        }
    }
}

-(void)addEventPointView:(GameFieldEventPointView*) eventView {
    [self addSubview:eventView];
    [self.currentEventViews addObject:eventView];
}
     
-(void)safelyPeformCompletion: (void (^)()) completionBlock {
    if (completionBlock) {
        completionBlock();
    }
}

-(NSTimeInterval)scaleDuration: (float)standardDuration usingFactor: (float)relativeSpeedFactor {
    float normal = standardDuration * 2.f;
    NSTimeInterval duration = MAX(standardDuration * .1f, normal * relativeSpeedFactor);
    return duration;
}

@end
