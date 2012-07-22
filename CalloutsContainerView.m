//
//  CalloutsContainerView.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 6/23/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "CalloutsContainerView.h"
#import "CalloutView.h"

@interface CalloutsContainerView()

@end

@implementation CalloutsContainerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
        [self addGestureRecognizer:recognizer];
    }
    return self;
}

-(void)tapped {
    [self removeFromSuperview];
}

-(CalloutView*)addCallout:(NSString *) textToDisplay anchor: (CGPoint) anchorPoint width: (CGFloat) width degrees: (int) degreesFromAnchor connectorLength: (int) length font: (UIFont *) font {
    CalloutView *callout = [[CalloutView alloc] initWithFrame: self.bounds text:textToDisplay anchor: anchorPoint width: width degrees: degreesFromAnchor connectorLength:length];
    if (font) {
        callout.fontOverride = font;
    }
    [self addSubview: callout];
    return callout;
}

-(CalloutView*)addCallout:(NSString *) textToDisplay anchor: (CGPoint) anchorPoint width: (CGFloat) width degrees: (int) degreesFromAnchor connectorLength: (int) length {
    return [self addCallout:textToDisplay anchor:anchorPoint width:width degrees:degreesFromAnchor connectorLength:length font:nil];
}

-(CalloutView*)addNavControllerHelpAvailableCallout {
    CalloutView *calloutView = [[CalloutView alloc] initWithFrame: self.bounds text:@"Tap here at any time to get help on this view." anchor: CGPointTop(self.bounds) width: 150 degrees: 180 connectorLength:80];
    calloutView.fontOverride = [UIFont systemFontOfSize:22];
    [self addSubview: calloutView];
    return calloutView;
}

-(void)slide: (BOOL) slideOut animated: (BOOL) animated {
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass: [CalloutView class]]) {
            [((CalloutView *)subView) slide:slideOut animated: YES];
        }
    }
}


@end
