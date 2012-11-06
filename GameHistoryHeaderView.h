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

-(void)setInfoForGame: (Game*)game section: (NSInteger)section;

@end
