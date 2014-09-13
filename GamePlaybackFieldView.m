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

#define kNormalPassAnimationDuration 2
#define kNormalBeginEventAnimationDuration .5

@interface GamePlaybackFieldView ()

@property (strong, nonatomic) NSMutableArray* currentEventViews;

@end

@implementation GamePlaybackFieldView

-(void)commonInit {
    [super commonInit];
    self.currentEventViews = [NSMutableArray array];
}

-(void)displayNewEvent: (Event*) event atRelativeSpeed: (float) relativeSpeedFactor complete: (void (^)()) completionBlock {
    GameFieldEventPointView* lastEventView = [self lastEventView];
    GameFieldEventPointView* eventView = [self createPointView];
    eventView.event = event;
    eventView.isOurEvent = [self isOurEvent:event];
    [self updatePointViewLocation:eventView toPosition:event.position];
    [self addEventPointView: eventView];
    if ([event isPositionalBegin]) {
        [self animateBeginEventAppearance:eventView atRelativeSpeed:relativeSpeedFactor lastEventView: lastEventView complete:completionBlock];
    } else {
        [self animateEventAppearance:eventView atRelativeSpeed:relativeSpeedFactor lastEventView: lastEventView complete:completionBlock];
    }
}

-(void)displayEvent: (Event*) event {
    GameFieldEventPointView* lastEventView = [self lastEventView];
    GameFieldEventPointView* eventView = [self createPointView];
    eventView.event = event;
    eventView.isOurEvent = [self isOurEvent:event];
    [self updatePointViewLocation:eventView toPosition:event.position];
    [self addEventPointView: eventView];
}

-(GameFieldEventPointView*)createPointView {
    GameFieldEventPointView* view = [[GameFieldEventPointView alloc] initWithFrame:CGRectMake(0, 0, kPointViewWidth, kPointViewWidth)];
    view.isEmphasizedEvent = YES;
    view.discDiameter = kDiscDiameter;
    view.discColor = self.discColor;
    return view;
}

-(void)addEventPointView:(GameFieldEventPointView*) eventView {
    [self addSubview:eventView];
    [self.currentEventViews addObject:eventView];
}

-(void)resetField {
    for (UIView* subView in self.subviews) {
        if ([subView isKindOfClass:[GameFieldEventPointView class]]) {
            [subView removeFromSuperview];
        }
    }
    [self.currentEventViews removeAllObjects];
}

-(void)animateBeginEventAppearance: (GameFieldEventPointView*) eventView atRelativeSpeed: (float) relativeSpeedFactor lastEventView: (GameFieldEventPointView*) lastEventView complete: (void (^)()) completionBlock {

    eventView.discHidden = NO;
    
    float normal = kNormalBeginEventAnimationDuration * 2.f;
    NSTimeInterval duration = MAX(kNormalBeginEventAnimationDuration * .1f, normal * relativeSpeedFactor);
    
    GameFieldEventPointView* lastEventViewCopy;
    if (lastEventView) {
        // create a copy of the last event and cover the original so we can fade it's changes
        lastEventViewCopy = [GameFieldEventPointView copyOf:lastEventView];
        [self addSubview:lastEventViewCopy];
        lastEventView.isEmphasizedEvent = NO;
        lastEventView.discHidden = YES;
    }
    
    eventView.alpha = 0;
    [UIView animateWithDuration:duration animations:^{
        lastEventViewCopy.alpha = 0;
        eventView.alpha = 1;
    } completion:^(BOOL finished) {
        [lastEventViewCopy removeFromSuperview];
        if (completionBlock) {
            completionBlock();
        }
    }];
}

-(void)animateEventAppearance: (GameFieldEventPointView*) eventView atRelativeSpeed: (float) relativeSpeedFactor  lastEventView: (GameFieldEventPointView*) lastEventView complete: (void (^)()) completionBlock {
    
    float normal = kNormalPassAnimationDuration * 2.f;
    NSTimeInterval duration = MAX(kNormalPassAnimationDuration * .1f, normal * relativeSpeedFactor);
    
    GameFieldEventPointView* lastEventViewCopy;
    if (lastEventView) {
        // create a copy of the last event and cover the original so we can fade it's changes
        lastEventViewCopy = [GameFieldEventPointView copyOf:lastEventView];
        [self addSubview:lastEventViewCopy];
        lastEventView.isEmphasizedEvent = NO;
        lastEventView.discHidden = YES;
    }
    
    eventView.alpha = 0;
    [UIView animateWithDuration:duration animations:^{
        lastEventViewCopy.alpha = 0;
        eventView.alpha = 1;
    } completion:^(BOOL finished) {
        [lastEventViewCopy removeFromSuperview];
        if (completionBlock) {
            completionBlock();
        }
    }];
    
}

-(GameFieldEventPointView*)lastEventView {
    return [self.currentEventViews count] > 0 ? [self.currentEventViews lastObject] : nil;
}

@end
