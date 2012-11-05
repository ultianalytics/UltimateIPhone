//
//  GameHistoryHeaderView.m
//  UltimateIPhone
//
//  Created by james on 11/5/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import "GameHistoryHeaderView.h"
#import "Game.h"
#import "Upoint.h"
#import "PointSummary.h"
#import "NSArray+Utilities.h"

@implementation GameHistoryHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setInfoForGame: (Game*)game section: (NSInteger)section {
    NSString* pointName = [game getPointNameAtMostRecentIndex:section];
    UPoint* point = [game getPointAtMostRecentIndex:section];
    PointSummary* summary = point.summary;
    BOOL isOline = [game isPointOline: point];
    
    self.currentPointLabel.hidden = YES;
    self.pointLabel.hidden = YES;
    self.scoreLeadLabel.hidden = YES;
    BOOL isCurrentPoint = [pointName isEqualToString:@"Current"];
    
    if (isCurrentPoint) {
        self.currentPointLabel.text =  @"Current Point" ;
        self.currentPointLabel.hidden = NO;
    } else {
        self.pointLabel.text = pointName;
        self.pointLabel.hidden = NO;
        self.scoreLeadLabel.hidden = NO;
        self.scoreLeadLabel.text = summary.score.ours > summary.score.theirs ? @"(Us)" : summary.score.ours < summary.score.theirs ? @"(Them)" : @"";
    }
    
    if ([point.line  count] > 0) {
        NSString* playersList = [[point.line valueForKeyPath: @"name"]componentsJoinedByString: @", "];
        self.playersTextView.text = [NSString stringWithFormat:@"%@: %@", isOline ? @"O-line" : @"D-line", playersList];
    }

}

@end
