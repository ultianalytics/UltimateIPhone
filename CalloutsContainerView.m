//
//  CalloutsContainerView.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 6/23/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "CalloutsContainerView.h"
#import "CalloutView.h"

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

-(void)addCallout:(NSString *) textToDisplay anchor: (CGPoint) anchorPoint width: (CGFloat) width degrees: (int) degreesFromAnchor connectorLength: (int) length {
    [self addSubview: [[CalloutView alloc] initWithFrame: self.bounds text:textToDisplay anchor: anchorPoint width: width degrees: degreesFromAnchor connectorLength:length]];
}

-(void)addNavControllerHelpAvailableCallout {
    CalloutView *calloutView = [[CalloutView alloc] initWithFrame: self.bounds text:nil anchor: CGPointTop(self.bounds) width: 150 degrees: 180 connectorLength:80];
    UITextView *textView = [[UITextView alloc] init];
    textView.backgroundColor = [UIColor whiteColor];
    textView.font = [UIFont systemFontOfSize:22];
    textView.text = @"Tap here at any time to get help on this view.";
    calloutView.textView = textView;
    [self addSubview: calloutView];
}

@end
