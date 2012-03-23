//
//  PreferencesViewController.h
//  Ultimate
//
//  Created by Jim Geppert on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GTMOAuthAuthentication;

@interface PreferencesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView* preferencesTableView;
@property (nonatomic, strong) IBOutlet UITableView* cloudTableView;

@property (nonatomic, strong) IBOutlet UITableViewCell* playerDisplayCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* uploadCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* userCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* websiteCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* adminSiteCell;

@property (nonatomic, strong) IBOutlet UILabel* userLabel;
@property (nonatomic, strong) IBOutlet UILabel* websiteLabel;
@property (nonatomic, strong) IBOutlet UILabel* adminSiteLabel;
@property (nonatomic, strong) IBOutlet UISegmentedControl* playerDisplaySegmentedControl;
@property (nonatomic, strong) IBOutlet UIButton* syncButton;
@property (nonatomic, strong) IBOutlet UIButton* signoffButton;

-(IBAction)isDiplayingPlayerNumberChanged: (id) sender;
-(IBAction)syncButtonClicked: (id) sender;
-(IBAction)signoffButtonClicked: (id) sender;
-(void)populateViewFromModel;
-(void)goSignonView;
-(void)upload;
-(void)doUpload;
-(void)startBusyDialog;
-(void)stopBusyDialog;

@end
