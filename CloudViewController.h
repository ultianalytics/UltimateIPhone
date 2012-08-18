//
//  CloudViewController.h
//  Ultimate
//
//  Created by Jim Geppert on 2/17/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewSignonController.h"
@class GTMOAuthAuthentication;
@class TeamDownloadPickerViewController;
@class GameDownloadPickerViewController;

@interface CloudViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, WebViewSignonControllerDelegate> {
    @private
    NSArray* cloudCells;
    TeamDownloadPickerViewController* teamDownloadController;
    GameDownloadPickerViewController* gameDownloadController;
    UIAlertView* busyView;
    void (^signonCompletion)();
}

@property (nonatomic, strong) IBOutlet UITableView* cloudTableView;

@property (nonatomic, strong) IBOutlet UITableViewCell* uploadCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* downloadTeamCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* downloadGameCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* userCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* websiteCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* adminSiteCell;

@property (strong, nonatomic) IBOutlet UILabel *userUnknownLabel;
@property (nonatomic, strong) IBOutlet UILabel* userLabel;
@property (nonatomic, strong) IBOutlet UILabel* websiteLabel;
@property (nonatomic, strong) IBOutlet UILabel* adminSiteLabel;
@property (nonatomic, strong) IBOutlet UIButton* uploadButton;
@property (nonatomic, strong) IBOutlet UIButton* downloadTeamButton;
@property (nonatomic, strong) IBOutlet UIButton* downloadGameButton;
@property (nonatomic, strong) IBOutlet UIButton* signoffButton;
@property (strong, nonatomic) IBOutlet UIView *scrubberView;
@property (strong, nonatomic) IBOutlet UISwitch *scrubberSwitch;

-(IBAction)uploadButtonClicked: (id) sender;
-(IBAction)downloadTeamButtonClicked: (id) sender;
-(IBAction)downloadGameButtonClicked: (id) sender;
-(IBAction)signoffButtonClicked: (id) sender;
-(IBAction)scrubSwitchChanged:(id)sender;

@end
