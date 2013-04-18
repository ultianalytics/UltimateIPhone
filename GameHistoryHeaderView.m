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
#import "PlayerSubstitution.h"
#import "NSArray+Utilities.h"
#import "Player.h"

@interface GameHistoryHeaderView()

@property (strong, nonatomic) IBOutlet UILabel *pointLabel;
@property (strong, nonatomic) IBOutlet UILabel *playersLabel;

@end

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
    
    BOOL isCurrentPoint = [pointName isEqualToString:@"Current"];
    
    if (isCurrentPoint) {
        self.pointLabel.text =  @"Current Point" ;
        self.pointLabel.font = [UIFont boldSystemFontOfSize:14];
    } else {
        self.pointLabel.text = [NSString stringWithFormat: @"%@ %@", pointName, summary.score.ours > summary.score.theirs ? @"(us)" : summary.score.ours < summary.score.theirs ? @"(them)" : @""];
    }
    
    if ([point.line count] > 0) {
        if ([game isTimeBasedEnd] && [point isPeriodEnd] && [[point events] count] == 1) {
            self.playersLabel.text = @"";
        } else {
            self.playersLabel.text = [NSString stringWithFormat:@"%@: %@", isOline ? @"O-line" : @"D-line", [self playersText: point]];
        }
    }

}

-(NSString*)playersText: (UPoint*)point {
    NSMutableSet* allPlayerNames = [NSMutableSet setWithArray:[point.line valueForKeyPath: @"name"]];
    for (PlayerSubstitution* substitution in point.substitutions) {
        [allPlayerNames addObject:substitution.fromPlayer.name];
        [allPlayerNames addObject:substitution.toPlayer.name];
    }
    for (PlayerSubstitution* substitution in point.substitutions) {
        if ([allPlayerNames containsObject:substitution.fromPlayer.name]) {
            [allPlayerNames removeObject:substitution.fromPlayer.name];
            [allPlayerNames addObject: [NSString stringWithFormat:@"%@ (partial)", substitution.fromPlayer.name]];
        }
        if ([allPlayerNames containsObject:substitution.toPlayer.name]) {
            [allPlayerNames removeObject:substitution.toPlayer.name];
            [allPlayerNames addObject: [NSString stringWithFormat:@"%@ (partial)", substitution.toPlayer.name]];
        }
    }
    return [[allPlayerNames allObjects] componentsJoinedByString: @", "];
}

@end
