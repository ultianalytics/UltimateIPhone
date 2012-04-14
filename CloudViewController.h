//
//  CloudViewController.h
//  Ultimate
//
//  Created by Jim Geppert on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GTMOAuthAuthentication;

@interface CloudViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView* cloudTableView;

@property (nonatomic, strong) IBOutlet UITableViewCell* uploadCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* downloadCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* userCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* websiteCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* adminSiteCell;

@property (nonatomic, strong) IBOutlet UILabel* userLabel;
@property (nonatomic, strong) IBOutlet UILabel* websiteLabel;
@property (nonatomic, strong) IBOutlet UILabel* adminSiteLabel;
@property (nonatomic, strong) IBOutlet UIButton* syncButton;
@property (nonatomic, strong) IBOutlet UIButton* downloadButton;
@property (nonatomic, strong) IBOutlet UIButton* signoffButton;

-(IBAction)syncButtonClicked: (id) sender;
-(IBAction)downloadButtonClicked: (id) sender;
-(IBAction)signoffButtonClicked: (id) sender;
-(void)populateViewFromModel;
-(void)goSignonView;
-(void)goTeamPickerView: (NSArray*) teams;
-(void)startUpload;
-(void)downloadTeam:(NSString*) cloudId;
-(void)startBusyDialog;
-(void)stopBusyDialog;
-(void)downloadTeams;
-(void)handleTeamsRetrieveCompletion: (id)response;
-(void)downloadTeam: (NSString*) cloudId;

@end
