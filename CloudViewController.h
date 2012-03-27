//
//  CloudViewController.h
//  Ultimate
//
//  Created by Jim Geppert on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GTMOAuthAuthentication;

@interface CloudViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView* twitterTableView;
@property (nonatomic, strong) IBOutlet UITableView* cloudTableView;

@property (nonatomic, strong) IBOutlet UITableViewCell* tweetEveryEventCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* tweetButtonCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* uploadCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* userCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* websiteCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* adminSiteCell;

@property (nonatomic, strong) IBOutlet UILabel* userLabel;
@property (nonatomic, strong) IBOutlet UILabel* websiteLabel;
@property (nonatomic, strong) IBOutlet UILabel* adminSiteLabel;
@property (nonatomic, strong) IBOutlet UIButton* syncButton;
@property (nonatomic, strong) IBOutlet UIButton* signoffButton;
@property (nonatomic, strong) IBOutlet UISwitch* tweetEveryEventSwitch;

-(IBAction)isTweetingEveryEventChanged: (id) sender;
-(IBAction)tweetButtonClicked: (id) sender;
-(IBAction)syncButtonClicked: (id) sender;
-(IBAction)signoffButtonClicked: (id) sender;
-(void)populateViewFromModel;
-(void)goSignonView;
-(void)upload;
-(void)doUpload;
-(void)startBusyDialog;
-(void)stopBusyDialog;

@end
