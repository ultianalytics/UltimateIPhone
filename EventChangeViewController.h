//
//  EventChangeViewController.h
//  UltimateIPhone
//
//  Created by james on 10/10/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Event;
#import "UltimateSegmentedControl.h"

@interface EventChangeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) Event *event;
@property (strong, nonatomic) NSString *pointDescription;
@property (strong, nonatomic) NSArray *playersInPoint;
@property (strong, nonatomic) void (^completion)();
@property (strong, nonatomic) IBOutlet UIButton *buttonTest;

@end
