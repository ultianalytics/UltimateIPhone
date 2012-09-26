//
//  GameDetailViewController.h
//  Ultimate
//
//  Created by Jim Geppert on 2/18/12.
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"

@interface GameDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate> {
    
    @private
    NSArray* cells;
}

@property (nonatomic, strong) Game* game;

@property (nonatomic, strong) IBOutlet UITableView* tableView;

@property (nonatomic, strong) IBOutlet UITableViewCell* opponentCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* tournamentCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* initialLineCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* gamePointsCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* windCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* statsCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* eventsCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* gameTypeCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* leaguevineGameCell;

@property (nonatomic, strong) IBOutlet UILabel* windLabel;
@property (nonatomic, strong) IBOutlet UILabel* leaguevineGameLabel;
@property (nonatomic, strong) IBOutlet UITextField* opposingTeamNameField;
@property (nonatomic, strong) IBOutlet UITextField* tournamentNameField;
@property (nonatomic, strong) IBOutlet UIButton* deleteButton;
@property (nonatomic, strong) IBOutlet UIButton* startButton;
@property (nonatomic, strong) IBOutlet UISegmentedControl* initialLine;
@property (nonatomic, strong) IBOutlet UISegmentedControl* gamePointsSegmentedControl;
@property (nonatomic, strong) IBOutlet UISegmentedControl* gameTypeSegmentedControl;

-(IBAction)opponentNameChanged: (id) sender;
-(IBAction)tournamendNameChanged: (id) sender;
-(IBAction)firstLineChanged: (id) sender; 
-(IBAction)gamePointChanged: (id) sender; 
-(NSString*)getText: (UITextField*) textField;
-(IBAction) deleteClicked: (id) sender;
-(BOOL)verifyOpponentName;
-(void)populateUIFromModel;
-(void)saveChanges;
-(void)dismissKeyboard;
-(void)upateViewTitle;
-(void)goToActionView;
-(void)addFooterButton;

@end 
