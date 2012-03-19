//
//  GameHistoryController.h
//  Ultimate
//
//  Created by james on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "Game.h"

@interface GameHistoryController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) Game* game;
@property (nonatomic) BOOL isCurlAnimation;

@end
