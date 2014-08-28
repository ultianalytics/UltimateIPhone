//
//  PullLandPickerViewController.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 8/28/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@interface PullLandPickerViewController : UIViewController

@property (strong, nonatomic) void (^doneRequestedBlock)(Action action);

@end
