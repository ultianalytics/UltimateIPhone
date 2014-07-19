//
//  PlayerDetailsViewController.h
//  Ultimate
//
//  Created by james on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UltimateViewController.h"

@class Player;
@class UltimateSegmentedControl;

@interface PlayerDetailsViewController : UltimateViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    NSArray* cells;
}

@property (nonatomic, strong) Player* player;
@property (nonatomic, strong) IBOutlet UITextField* nickNameField;
@property (nonatomic, strong) IBOutlet UITextField* numberField;
@property (nonatomic, strong) IBOutlet UltimateSegmentedControl* positionControl;
@property (nonatomic, strong) IBOutlet UltimateSegmentedControl* sexControl;
@property (nonatomic, strong) IBOutlet UltimateSegmentedControl* statusControl;

@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (nonatomic, strong) IBOutlet UIButton* saveAndAddButton;
@property (nonatomic, strong) IBOutlet UIButton* deleteButton;

@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) IBOutlet UITableViewCell* nameTableCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* numberTableCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* positionTableCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* genderTableCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* absentTableCell;

-(IBAction)addAnotherClicked: (id) sender;
-(IBAction)deleteClicked: (id) sender;
-(void)okClicked;
-(void)cancelClicked;
-(void)returnToTeamView;
-(void)populateViewFromModel;
-(void)populateModelFromView;
-(void)addPlayer;
-(void)updatePlayer;
-(void)deletePlayer;
-(NSString*) getNickNameViewText;
-(NSString*) getNumberViewText;
-(BOOL)verifyPlayer;
-(BOOL)isDuplicatePlayerName: (NSString*) newPlayerName;
-(BOOL)isDuplicatePlayerNumber: (NSString*) newPlayerNumber;

@end
