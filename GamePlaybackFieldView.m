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

@implementation GamePlaybackFieldView



-(void)displayNewEvent: (Event*) event complete: (void (^)()) completionBlock {
    GameFieldEventPointView* eventView = [self createPointView];
    eventView.event = event;
    eventView.isOurEvent = [self isOurEvent:event];
    [self updatePointViewLocation:eventView toPosition:event.position];
    [self addSubview:eventView];
    if (completionBlock) {
        completionBlock();
    }
}

-(GameFieldEventPointView*)createPointView {
    GameFieldEventPointView* view = [[GameFieldEventPointView alloc] initWithFrame:CGRectMake(0, 0, kPointViewWidth, kPointViewWidth)];
    view.discDiameter = kDiscDiameter;
    view.discColor = self.discColor;
    return view;
}

-(void)resetField {
    for (UIView* subView in self.subviews) {
        if ([subView isKindOfClass:[GameFieldEventPointView class]]) {
            [subView removeFromSuperview];
        }
    }
}


@end
