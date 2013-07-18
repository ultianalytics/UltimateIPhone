//
//  PullLandingViewController.h
//  UltimateIPhone
//
//  Created by james on 10/22/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UltimateViewController.h"

@interface PullLandingViewController : UltimateViewController

@property (nonatomic) double pullBeginTime;
@property (strong, nonatomic) void (^completion)(BOOL cancelled, BOOL isOutOfBounds, long hangtimeMilliseconds);

@end
