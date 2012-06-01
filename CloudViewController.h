//
//  CloudViewController.h
//  Ultimate
//
//  Created by Jim Geppert on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignonViewController.h"
@class GTMOAuthAuthentication;
@class TeamDownloadPickerViewController;
@class GameDownloadPickerViewController;

@interface CloudViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SignonViewControllerDelegate> {
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

@property (nonatomic, strong) IBOutlet UILabel* userLabel;
@property (nonatomic, strong) IBOutlet UILabel* websiteLabel;
@property (nonatomic, strong) IBOutlet UILabel* adminSiteLabel;
@property (nonatomic, strong) IBOutlet UIButton* uploadButton;
@property (nonatomic, strong) IBOutlet UIButton* downloadTeamButton;
@property (nonatomic, strong) IBOutlet UIButton* downloadGameButton;
@property (nonatomic, strong) IBOutlet UIButton* signoffButton;

-(IBAction)uploadButtonClicked: (id) sender;
-(IBAction)downloadTeamButtonClicked: (id) sender;
-(IBAction)downloadGameButtonClicked: (id) sender;
-(IBAction)signoffButtonClicked: (id) sender;


@end
