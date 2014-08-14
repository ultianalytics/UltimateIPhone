//
//  TeamViewController.h
//  Ultimate
//
//  Created by Jim Geppert on 2/25/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UltimateViewController.h"

@class Team;
@class UltimateSegmentedControl;
@class StandardButton;

@interface TeamViewController : UltimateViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {

}

@property (nonatomic, strong) Team* team;
@property (nonatomic, strong) NSArray* cells;
@property (strong, nonatomic) void (^teamChangedBlock)(Team* team);
@property (nonatomic) BOOL isModalAddMode;

@end
