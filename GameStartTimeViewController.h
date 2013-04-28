//
//  GameStartTimeViewController.h
//  UltimateIPhone
//
//  Created by james on 4/28/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameStartTimeViewController : UIViewController

@property (strong, nonatomic) NSDate* date;
@property (strong, nonatomic) void (^completion)(GameStartTimeViewController* controller);

@end
