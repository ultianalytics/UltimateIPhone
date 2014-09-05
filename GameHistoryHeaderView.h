//
//  GameHistoryHeaderView.h
//  UltimateIPhone
//
//  Created by james on 11/5/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Game, UPoint;

@interface GameHistoryHeaderView : UIView

-(void)setInfoForGame: (Game*)game point: (UPoint*) point withName: (NSString*) pointName isOline: (BOOL) isOline;

@end
