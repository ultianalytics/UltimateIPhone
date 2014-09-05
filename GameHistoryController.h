//
//  GameHistoryController.h
//  Ultimate
//
//  Created by james on 12/26/11.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UltimateViewController.h"

@protocol GameHistoryControllerDelegate <NSObject>

- (void) eventHistoryUndoRequested;
- (void) eventHistoryUpdated;

@end

@class Game;

@interface GameHistoryController : UltimateViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) Game* game;
@property (nonatomic) BOOL isCurlAnimation;
@property (nonatomic) BOOL embeddedMode;
@property (nonatomic, weak) id<GameHistoryControllerDelegate> delegate;

-(void)refresh;
-(void)adjustInsetForTabBar;

@end
