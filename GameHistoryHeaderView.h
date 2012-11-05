//
//  GameHistoryHeaderView.h
//  UltimateIPhone
//
//  Created by james on 11/5/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Game;

@interface GameHistoryHeaderView : UIView

@property (strong, nonatomic) IBOutlet UILabel *currentPointLabel;
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *pointLabel;
@property (strong, nonatomic) IBOutlet UILabel *scoreLeadLabel;
@property (strong, nonatomic) IBOutlet UITextView *playersTextView;

-(void)setInfoForGame: (Game*)game section: (NSInteger)section;

@end
