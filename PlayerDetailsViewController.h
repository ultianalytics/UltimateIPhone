//
//  PlayerDetailsViewController.h
//  Ultimate
//
//  Created by james on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Player.h"

@interface PlayerDetailsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> 

@property (nonatomic, strong) Player* player;
@property (nonatomic, strong) IBOutlet UITextField* nickNameField;
@property (nonatomic, strong) IBOutlet UITextField* numberField;
@property (nonatomic, strong) IBOutlet UISegmentedControl* positionControl;
@property (nonatomic, strong) IBOutlet UISegmentedControl* sexControl;
@property (nonatomic, strong) IBOutlet UIButton* saveAndAddButton;
@property (nonatomic, strong) IBOutlet UIButton* deleteButton;

@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) IBOutlet UITableViewCell* nameTableCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* numberTableCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* positionTableCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* genderTableCell;

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
