//
//  GameHistoryController.h
//  Ultimate
//
//  Created by james on 12/26/11.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Game;

@interface GameHistoryController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) Game* game;
@property (nonatomic) BOOL isCurlAnimation;

@end
