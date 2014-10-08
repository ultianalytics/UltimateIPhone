//
//  CloudViewController.h
//  Ultimate
//
//  Created by Jim Geppert on 2/17/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UltimateViewController.h"
@class GTMOAuthAuthentication;
@class TeamDownloadPickerViewController;
@class GameDownloadPickerViewController;

@interface CloudViewController : UltimateViewController <UITableViewDelegate, UITableViewDataSource> {
    @private
    NSArray* cloudCells;
    TeamDownloadPickerViewController* teamDownloadController;
    GameDownloadPickerViewController* gameDownloadController;
    void (^signonCompletion)();
}

@property (nonatomic, strong) IBOutlet UITableView* cloudTableView;
@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (nonatomic, strong) IBOutlet UITableViewCell* userCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* autoUploadCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* websiteCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* adminSiteCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* privacyPolicyCell;

@property (strong, nonatomic) IBOutlet UILabel *userUnknownLabel;
@property (nonatomic, strong) IBOutlet UILabel* userLabel;
@property (nonatomic, strong) IBOutlet UILabel* websiteLabel;
@property (nonatomic, strong) IBOutlet UILabel* adminSiteLabel;
@property (nonatomic, strong) IBOutlet UIButton* uploadButton;
@property (nonatomic, strong) IBOutlet UIButton* downloadTeamButton;
@property (nonatomic, strong) IBOutlet UIButton* downloadGameButton;
@property (nonatomic, strong) IBOutlet UIButton* signoffButton;
@property (nonatomic, strong) IBOutlet UISegmentedControl* autoUploadSegmentedControl;
@property (strong, nonatomic) IBOutlet UIView *scrubberView;
@property (strong, nonatomic) IBOutlet UISwitch *scrubberSwitch;

@property (strong, nonatomic) IBOutlet UIView *busyView;
@property (strong, nonatomic) IBOutlet UIView *busyDisplay;

-(IBAction)uploadButtonClicked: (id) sender;
-(IBAction)downloadTeamButtonClicked: (id) sender;
-(IBAction)downloadGameButtonClicked: (id) sender;
-(IBAction)signoffButtonClicked: (id) sender;
-(IBAction)scrubSwitchChanged:(id)sender;

@end
