//
//  GameDetailViewController.h
//  Ultimate
//
//  Created by Jim Geppert on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"

@interface GameDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) Game* game;

@property (nonatomic, strong) IBOutlet UITableView* tableView;

@property (nonatomic, strong) IBOutlet UITableViewCell* startTimeCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* scoreCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* opponentCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* tournamentCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* initialLineCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* gamePointsCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* windCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* statsCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* eventsCell;

@property (nonatomic, strong) IBOutlet UILabel* startTimeLabel;
@property (nonatomic, strong) IBOutlet UILabel* scoreLabel;
@property (nonatomic, strong) IBOutlet UILabel* windLabel;
@property (nonatomic, strong) IBOutlet UITextField* opposingTeamNameField;
@property (nonatomic, strong) IBOutlet UITextField* tournamentNameField;
@property (nonatomic, strong) IBOutlet UIButton* makeCurrentButton;
@property (nonatomic, strong) IBOutlet UIButton* deleteButton;
@property (nonatomic, strong) IBOutlet UIButton* startButton;
@property (nonatomic, strong) IBOutlet UISegmentedControl* initialLine;
@property (nonatomic, strong) IBOutlet UISegmentedControl* gamePointsSegmentedControl;

-(IBAction)opponentNameChanged: (id) sender;
-(IBAction)tournamendNameChanged: (id) sender;
-(IBAction)firstLineChanged: (id) sender; 
-(IBAction)gamePointChanged: (id) sender; 
-(NSString*)getText: (UITextField*) textField;
-(IBAction) makeCurrentClicked: (id) sender;
-(IBAction) deleteClicked: (id) sender;
-(BOOL)verifyOpponentName;
-(void)populateUIFromModel;
-(void)saveChanges;

@end 
