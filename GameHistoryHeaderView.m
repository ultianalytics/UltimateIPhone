//
//  GameHistoryHeaderView.m
//  UltimateIPhone
//
//  Created by james on 11/5/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "GameHistoryHeaderView.h"

@implementation GameHistoryHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setPointName:(NSString *)pointName {
    _pointName = pointName;
    self.currentPointLabel.hidden = YES;
    self.pointLabel.hidden = YES;
    self.pointWinnerLabel.hidden = YES;
    BOOL isCurrentPoint = [pointName isEqualToString:@"Current"];

    if (isCurrentPoint) {
        self.currentPointLabel.text =  @"Current Point" ;
        self.currentPointLabel.hidden = NO;
    } else {
        self.pointLabel.text = pointName;
        self.pointLabel.hidden = NO;
        self.pointWinnerLabel.hidden = NO;
    }
}


@end
