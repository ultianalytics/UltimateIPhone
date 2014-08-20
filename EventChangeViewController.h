//
//  EventChangeViewController.h
//  UltimateIPhone
//
//  Created by james on 10/10/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UltimateSegmentedControl.h"
#import "UltimateViewController.h"
@class Event;

@interface EventChangeViewController : UltimateViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) Event *event;
@property (strong, nonatomic) NSString *pointDescription;
@property (strong, nonatomic) NSArray *playersInPoint;
@property (nonatomic) BOOL modalMode;
@property (strong, nonatomic) void (^completion)();

@end
