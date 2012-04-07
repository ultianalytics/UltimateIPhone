//
//  TeamDownloadPickerViewController.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 4/7/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Team;

@interface TeamDownloadPickerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray* teams;
@property (nonatomic, strong) Team* selectedTeam;
@property (nonatomic, strong) IBOutlet UITableView* teamsTableView;

@end
