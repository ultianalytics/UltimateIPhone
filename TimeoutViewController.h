//
//  TimeoutViewController.h
//  UltimateIPhone
//
//  Created by james on 4/10/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UltimateViewController.h"

@class Game;

@interface TimeoutViewController : UltimateViewController

@property (nonatomic, strong) Game* game;
@property (nonatomic) BOOL modalMode;
@property (strong, nonatomic) void (^timeoutsUpdatedBlock)();

@end
