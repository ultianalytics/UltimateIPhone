//
//  FirstViewController.h
//  Ultimate
//
//  Created by james on 12/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Team;
@class UltimateSegmentedControl;

@interface TeamViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) Team* team;
@property (nonatomic, strong) IBOutlet UITableView* teamTableView;
@property (nonatomic, strong) IBOutlet UITableViewCell* nameCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* typeCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* displayCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* playersCell;
@property (nonatomic, strong) IBOutlet UITextField* teamNameField;
@property (nonatomic, strong) IBOutlet UltimateSegmentedControl* teamTypeSegmentedControl;
@property (nonatomic, strong) IBOutlet UltimateSegmentedControl* playerDisplayTypeSegmentedControl;
@property (nonatomic, strong) IBOutlet UIButton* deleteButton;
@property (nonatomic, strong) IBOutlet UIAlertView* deleteAlertView;
@property (nonatomic) BOOL shouldSkipToPlayers;

-(IBAction)teamTypeChanged: (id) sender;
-(IBAction)playerDisplayChanged: (id) sender;
-(IBAction)deleteClicked: (id) sender;
-(void)dismissKeyboard;
-(BOOL)saveChanges;
-(BOOL)verifyTeamName;
-(void)verifyAndDelete;
-(NSString*) getText: (UITextField*) textField;
-(BOOL) isDuplicateTeamName: (NSString*) newTeamName;
-(void)saveAndReturn;
-(void)populateViewFromModel;
-(void)populateModelFromView;
-(void)goToBestView;
-(void)goToPlayersView: (BOOL) animated;


@end
