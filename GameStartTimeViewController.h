//
//  GameStartTimeViewController.h
//  UltimateIPhone
//
//  Created by james on 4/28/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UltimateViewController.h"

@interface GameStartTimeViewController : UltimateViewController

@property (strong, nonatomic) NSDate* date;
@property (strong, nonatomic) void (^completion)(GameStartTimeViewController* controller);

@end
