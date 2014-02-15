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
@property (nonatomic) BOOL shouldSkipToPlayers;

@property (nonatomic, strong) IBOutlet UITableView* teamTableView;
@property (nonatomic, strong) IBOutlet UITableViewCell* nameCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* typeCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* displayCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* playersCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* leagueVineCell;
@property (nonatomic, strong) IBOutlet UITextField* teamNameField;
@property (nonatomic, strong) IBOutlet UltimateSegmentedControl* teamTypeSegmentedControl;
@property (nonatomic, strong) IBOutlet UltimateSegmentedControl* playerDisplayTypeSegmentedControl;
@property (nonatomic, strong) IBOutlet UILabel *leagueVineDescriptionLabel;
@property (nonatomic, strong) IBOutlet UIView* deleteButtonView;
@property (nonatomic, strong) IBOutlet UIView* teamCopyButtonView;
@property (nonatomic, strong) IBOutlet UIAlertView* deleteAlertView;
@property (nonatomic, strong) IBOutlet UIButton *clearCloudIdButton;
@property (strong, nonatomic) IBOutlet UIView *customFooterView;

-(IBAction)teamTypeChanged: (id) sender;
-(IBAction)playerDisplayChanged: (id) sender;
-(IBAction)deleteClicked: (id) sender;
-(IBAction)copyClicked:(id)sender;
-(IBAction)clearCloudIdClicked:(id)sender;

@end
