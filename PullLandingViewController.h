//
//  PullLandingViewController.h
//  UltimateIPhone
//
//  Created by james on 10/22/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PullLandingViewController : UIViewController

@property (strong, nonatomic) void (^completion)(BOOL cancelled, BOOL isOutOfBounds);

@end
