//
//  LeaguevineWaitingViewController.h
//  UltimateIPhone
//
//  Created by james on 4/5/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UltimateViewController.h"

@interface LeaguevineWaitingViewController : UltimateViewController

@property (strong, nonatomic) void (^cancelBlock)();

@end
