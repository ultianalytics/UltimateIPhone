//
//  GameViewCalloutsView.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 6/23/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "GameViewCalloutsView.h"
#import "CalloutView.h"

@interface GameViewCalloutsView()

@end

@implementation GameViewCalloutsView

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

@end
